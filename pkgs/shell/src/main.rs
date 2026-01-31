use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{
    Application, Box, Button, CssProvider, Label, Orientation,
    STYLE_PROVIDER_PRIORITY_APPLICATION,
};
use adw::prelude::*;
use adw::ApplicationWindow;
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use libadwaita::glib;
use std::ops::ControlFlow;
use std::thread;

use niri_ipc::{socket::Socket, Event, Request, Response};

const APP_ID: &str = "dev.dominicegginton.Shell";

const STYLE: &str = "
    .rounded-corners {
        border-radius: 15px;

        background-color: rgba(30, 30, 30, 0.8);
        backdrop-filter: blur(80px);

        color: white;
    }
";

fn set_background(image_path: &str) {
    // Get the currently running process of swaybg
    let swaybg_processes = std::process::Command::new("pgrep").arg("swaybg").output();

    // Start a new swaybg process with the specified image
    let _ = std::process::Command::new("swaybg")
        .args(&["-i", image_path, "-m", "fill"])
        .spawn();

    // Wait for 100 milliseconds to ensure swaybg starts before killing previous instances
    std::thread::sleep(std::time::Duration::from_millis(1000));

    // Kill previous swaybg processes
    // TODO: Fix this - dont kill process - migrate from swaybg to setting background via wlroots protocol
    if let Ok(output) = swaybg_processes {
        // Parse the output to get PIDs
        let pids = String::from_utf8_lossy(&output.stdout);

        println!("Killing swaybg PIDs: {}", pids);
        // Kill each PID
        for pid in pids.lines() {
            println!("Killing swaybg PID: {}", pid);
            let status = std::process::Command::new("kill")
                .args(&["-9", "-P", pid])
                .status();
            if let Ok(s) = status {
                println!("Killed swaybg PID: {} with status: {}", pid, s);
            } else {
                eprintln!("Failed to kill swaybg PID: {}", pid);
            }
        }
    }
}

fn get_time() -> String {
    // Get the current local time
    let now = chrono::Local::now();

    // Get user preferences for time format
    let settings = Settings::new("org.gnome.desktop.interface");
    let show_date = settings.get::<bool>("clock-show-date");
    let show_weekday = settings.get::<bool>("clock-show-weekday");
    let use_24_hour = settings.get::<String>("clock-format") == "24h";
    let show_seconds = settings.get::<bool>("clock-show-seconds");

    // Format the time based on user preferences
    let mut format = String::new();
    if show_weekday {
        format.push_str("%a ");
    }
    if show_date {
        format.push_str("%Y-%m-%d ");
    }
    if use_24_hour {
        format.push_str("%H:%M");
    } else {
        format.push_str("%I:%M %p");
    }
    if show_seconds {
        format.push_str(":%S");
    }

    // Return the formatted time string
    now.format(&format).to_string()
}

fn get_battery_percentage() -> String {
    // Use upower to get battery information
    let output = std::process::Command::new("upower")
        .args(&["-i", "/org/freedesktop/UPower/devices/battery_BAT0"])
        .output()
        .expect("Failed to execute upower command");

    // Parse the output to find the percentage line
    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if line.trim_start().starts_with("percentage:") {
            // Extract and return the percentage value
            return line
                .trim_start()
                .split_whitespace()
                .nth(1)
                .unwrap_or("N/A")
                .to_string();
        }
    }

    // If percentage not found, return N/A
    "N/A".to_string()
}

fn get_power_state() -> String {
    // Use upower to get battery information
    let output = std::process::Command::new("upower")
        .args(&["-i", "/org/freedesktop/UPower/devices/battery_BAT0"])
        .output()
        .expect("Failed to execute upower command");

    // Parse the output to find the state line
    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if line.trim_start().starts_with("state:") {
            // Extract and return the state value
            return line
                .trim_start()
                .split_whitespace()
                .nth(1)
                .unwrap_or("N/A")
                .to_string();
        }
    }

    // If state not found, return N/A
    "N/A".to_string()
}

fn get_network_status() -> String {
    // Use nmcli to get network status
    let output = std::process::Command::new("nmcli")
        .args(&["-t", "-f", "ACTIVE,SSID", "dev", "wifi"])
        .output()
        .expect("Failed to execute nmcli command");

    // Parse the output to find the active connection
    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        let parts: Vec<&str> = line.split(':').collect();
        if parts.len() == 2 && parts[0] == "yes" {
            // Return the SSID of the active connection
            return parts[1].to_string();
        }
    }

    // If no active connection found, return Disconnected
    "Disconnected".to_string()
}

fn main() {
    // Create GTK application
    let application = Application::builder().application_id(APP_ID).build();

    // On startup
    application.connect_startup(|_| {
        // Initialize libadwaita
        adw::init().unwrap();

        // Get the current theme
        let settings = Settings::new("org.gnome.desktop.interface");
        let current_theme = settings.get::<String>("color-scheme");

        // Get the background settings
        let desktop_background = Settings::new("org.gnome.desktop.background");
        let light_background_image_uri: String = desktop_background
            .get::<String>("picture-uri")
            .replace("file://", "");
        let dark_background_image_uri: String = desktop_background
            .get::<String>("picture-uri-dark")
            .replace("file://", "");

        // Set the initial background based on the current theme
        if current_theme == "prefer-dark" {
            set_background(&dark_background_image_uri);
        } else {
            set_background(&light_background_image_uri);
        }
    });

    // Set up the application when activated
    application.connect_activate(|app| {
        // Margin used for content
        let margin = 20;

        // Apply CSS styling once for the display
        let provider = CssProvider::new();
        let _ = provider.load_from_data(STYLE);
        let display_for_style = adw::gtk::gdk::Display::default().expect("Could not connect to a display.");
        adw::gtk::style_context_add_provider_for_display(
            &display_for_style,
            &provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION,
        );

        // Helper to build a single window with its own content and timeouts
        let make_window = |app: &Application| {
            // Main content box
            let content = Box::new(Orientation::Horizontal, margin);

            // Set content margins
            content.set_margin_top(margin / 2);
            content.set_margin_bottom(margin / 2);
            content.set_margin_start(margin);
            content.set_margin_end(margin);

            // Network button
            let network_button = Button::with_label(&format!("Network: {}", get_network_status()));
            content.append(&network_button);
            let nb_for_click = network_button.clone();
            network_button.connect_clicked(move |btn| {
                let on = std::process::Command::new("nmcli")
                    .args(&["radio", "wifi"])
                    .output();
                if let Ok(output) = on {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    if stdout.contains("enabled") {
                        let _ = std::process::Command::new("nmcli")
                            .args(&["radio", "wifi", "off"])
                            .status();
                        btn.remove_css_class("suggested-action");
                    } else {
                        let _ = std::process::Command::new("nmcli")
                            .args(&["radio", "wifi", "on"])
                            .status();
                        btn.add_css_class("suggested-action");
                    }
                }
            });

            // Update network status every 1 seconds
            let nb_for_timeout = nb_for_click.clone();
            glib::timeout_add_seconds_local(1, move || {
                let on = std::process::Command::new("nmcli")
                    .args(&["radio", "wifi"])
                    .output();
                if let Ok(output) = on {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    if stdout.contains("enabled") {
                        nb_for_timeout.add_css_class("suggested-action");
                    } else {
                        nb_for_timeout.remove_css_class("suggested-action");
                    }
                }
                nb_for_timeout.set_label(&format!("Network: {}", get_network_status()));
                ControlFlow::Continue(()).into()
            });

            // Power state label
            let power_state = Label::new(Some("Power: N/A"));
            power_state.set_text(&format!("Power: {}", get_power_state()));
            content.append(&power_state);

            // Update power state every 1 second
            let ps = power_state.clone();
            glib::timeout_add_seconds_local(1, move || {
                ps.set_text(&format!("Power: {}", get_power_state()));
                ControlFlow::Continue(()).into()
            });

            // Battery label
            let battery = Label::new(Some("Battery: 100%"));
            battery.set_text(&format!("Battery: {}", get_battery_percentage()));
            content.append(&battery);

            // Update battery every 1 second
            let batt = battery.clone();
            glib::timeout_add_seconds_local(1, move || {
                batt.set_text(&format!("Battery: {}", get_battery_percentage()));
                ControlFlow::Continue(()).into()
            });

            // Theme toggle button
            let theme_button = Button::with_label("Toggle Light/Dark Theme");
            theme_button.add_css_class("suggested-action");

            // Connect button click to toggle theme
            content.append(&theme_button);
            theme_button.connect_clicked(move |_| {
                // Get current theme settings
                let settings = Settings::new("org.gnome.desktop.interface");
                let current_theme = settings.get::<String>("color-scheme");

                // Get the background settings
                let desktop_background = Settings::new("org.gnome.desktop.background");
                let light_background_image_uri: String = desktop_background
                    .get::<String>("picture-uri")
                    .replace("file://", "");
                let dark_background_image_uri: String = desktop_background
                    .get::<String>("picture-uri-dark")
                    .replace("file://", "");

                // Toggle the theme and update background
                if current_theme == "prefer-dark" {
                    settings.set("color-scheme", &"prefer-light").unwrap();
                    set_background(&light_background_image_uri);
                } else {
                    settings.set("color-scheme", &"prefer-dark").unwrap();
                    set_background(&dark_background_image_uri);
                }
            });

            // Clock label
            let clock = Label::new(None);
            clock.set_text(&get_time());
            content.append(&clock);

            // Update clock every second
            let clk = clock.clone();
            glib::timeout_add_seconds_local(1, move || {
                clk.set_text(&get_time());
                ControlFlow::Continue(()).into()
            });

            // Create the application window
            let window = ApplicationWindow::builder()
                .application(app)
                .content(&content)
                .build();

            // Layer shell setup
            window.init_layer_shell();

            // Apply the rounded corners CSS class to the window
            window.add_css_class("rounded-corners");

            // Set the layer to overlay so it appears above other windows
            window.set_layer(Layer::Overlay);

            // Anchor the window to the edges of the screen
            window.set_anchor(Edge::Left, false);
            window.set_anchor(Edge::Right, true);
            window.set_anchor(Edge::Top, true);
            window.set_anchor(Edge::Bottom, false);

            // Set the size and margins of the window
            window.set_size_request(0, 0);
            window.set_margin(Edge::Left, margin);
            window.set_margin(Edge::Right, margin);
            window.set_margin(Edge::Top, margin);
            window.set_margin(Edge::Bottom, margin);

            // Start hidden; only show when overlay is open
            window.hide();

            window
        };

        // Channel to receive overview open/close events from the background thread
        let (tx, rx) = std::sync::mpsc::channel::<bool>();

        // Spawn a thread to connect to niri's IPC socket and read events
        thread::spawn(move || {
            // Connect to the niri IPC socket
            let mut socket = match Socket::connect() {
                Ok(s) => s,
                Err(e) => {
                    eprintln!("Failed to connect to niri socket: {}", e);
                    return;
                }
            };

            // Request the EventStream
            match socket.send(Request::EventStream) {
                Ok(Ok(response)) => match response {
                    Response::Handled => {
                        // Start reading events
                        let mut read_event = socket.read_events();
                        loop {
                            match read_event() {
                                Ok(event) => {
                                    // Check for OverviewOpenedOrClosed events
                                    if let Event::OverviewOpenedOrClosed { is_open } = event {
                                        let _ = tx.send(is_open);
                                    }
                                }
                                Err(e) => {
                                    eprintln!("Error reading niri event: {:?}", e);
                                    break;
                                }
                            }
                        }
                    }
                    other => {
                        eprintln!("Unexpected response to EventStream request: {:?}", other);
                    }
                },
                Ok(Err(msg)) => eprintln!("niri rejected EventStream request: {}", msg),
                Err(e) => eprintln!("Failed to request EventStream: {}", e),
            }
        });

        // Build one window per monitor so the overlay appears on all screens
        let display = adw::gtk::gdk::Display::default().expect("Could not connect to a display.");
        let monitors = display.monitors();
        let n_monitors = monitors.n_items();
        let mut windows: Vec<ApplicationWindow> = Vec::new();
        for i in 0..n_monitors {
            if let Some(obj) = monitors.item(i) {
                if let Ok(monitor) = obj.downcast::<adw::gtk::gdk::Monitor>() {
                    let window = make_window(app);
                    #[allow(unused_must_use)]
                    {
                        let _ = window.set_monitor(Some(&monitor));
                    }
                    // Use the existing margin/anchor rules from `make_window`.
                    // Keep size request flexible so margins and content determine sizing.
                    window.set_size_request(0, 0);
                    windows.push(window);
                }
            }
        }
        // Poll the receiver in the main loop and show/hide all windows accordingly.
        let windows_for_ipc = windows.iter().map(|w| w.clone()).collect::<Vec<_>>();
        glib::idle_add_local(move || {
            while let Ok(is_open) = rx.try_recv() {
                for w in &windows_for_ipc {
                    if is_open {
                        w.show();
                    } else {
                        w.hide();
                    }
                }
            }
            ControlFlow::Continue(()).into()
        });
    });

    application.run();
}
