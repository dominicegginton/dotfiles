use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{
    Align, Application, Box, Button, CssProvider, Label, Orientation,
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
        border-radius: 30px;
    }
    .transparent-background {
        background-color: rgba(0, 0, 0, 0);
        color: white;
        transition: background-color 200ms ease;
    }
    .transparent-background:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }
    .transparent-background:active {
        background-color: rgba(255, 255, 255, 0.2);
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
        let display_for_style =
            adw::gtk::gdk::Display::default().expect("Could not connect to a display.");
        adw::gtk::style_context_add_provider_for_display(
            &display_for_style,
            &provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION,
        );

        // Channel to receive overview open/close events from the background thread
        let (tx, rx) = std::sync::mpsc::channel::<bool>();

        // Helper to build a single window with its own content and timeouts.
        // Accept an optional monitor so quick-menu windows can be placed on the same screen.
        let make_window = |app: &Application,
                           monitor: Option<adw::gtk::gdk::Monitor>,
                           tx: std::sync::mpsc::Sender<bool>|
         -> (
            ApplicationWindow,
            std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>>,
        ) {
            // Main content box
            let content = Box::new(Orientation::Horizontal, margin);

            // Set content margins
            content.set_margin_top(margin / 2);
            content.set_margin_bottom(margin / 2);
            content.set_margin_start(margin);
            content.set_margin_end(margin);

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

            // Create the application window
            let right_window = ApplicationWindow::builder()
                .application(app)
                .content(&content)
                .build();

            // Quick-menu holder (lazy-created)
            let quick_win_cell: std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>> =
                std::rc::Rc::new(std::cell::RefCell::new(None));
            let quick_win_for_click = quick_win_cell.clone();
            let app_for_quick = app.clone();
            // If we have a monitor, clone it for placement
            let monitor_for_quick = monitor.clone();

            // Attach a click gesture to the bar content so clicking the right window
            // toggles the quick-settings menu.
            let gesture = adw::gtk::GestureClick::new();
            let q_for_click = quick_win_for_click.clone();
            let app_for_quick = app_for_quick.clone();
            let monitor_for_quick = monitor_for_quick.clone();
            let tx_for_outer = tx.clone();
            gesture.connect_pressed(move |_, _, _, _| {
                let mut q = q_for_click.borrow_mut();
                if let Some(existing) = q.as_ref() {
                    existing.hide();
                    *q = None;
                    return;
                }

                // Build quick menu content
                let margin = 20;
                let quick_content = Box::new(Orientation::Vertical, margin);
                quick_content.set_margin_top(margin);
                quick_content.set_margin_bottom(margin);
                quick_content.set_margin_start(margin);
                quick_content.set_margin_end(margin);

                // First row
                let first_row = Box::new(Orientation::Horizontal, margin);
                quick_content.append(&first_row);

                // Second row could hold more quick settings in future
                let second_row = Box::new(Orientation::Horizontal, margin);
                quick_content.append(&second_row);

                // Settings button: opens the `shell-settings` app (show first)
                let settings_btn = Button::with_label("⚙");
                settings_btn.add_css_class("flat");
                first_row.append(&settings_btn);
                let tx_for_settings = tx_for_outer.clone();
                settings_btn.connect_clicked(move |_| {
                    let _ = std::process::Command::new("shell-settings").spawn();
                    let _ = tx_for_settings.send(false);

                    // Also request niri to close the overview via IPC.
                    if let Ok(mut s) = Socket::connect() {
                        let _ = s.send(Request::Action(niri_ipc::Action::CloseOverview {}));
                    }
                });

                let quick_theme = Button::with_label("Toggle Light/Dark Theme");
                quick_theme.add_css_class("suggested-action");
                // Make second-row buttons expand to full width
                quick_theme.set_hexpand(true);
                quick_theme.set_halign(Align::Fill);
                second_row.append(&quick_theme);
                quick_theme.connect_clicked(move |_| {
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

                // Create the quick menu window
                let quick = ApplicationWindow::builder()
                    .application(&app_for_quick)
                    .content(&quick_content)
                    .build();

                // Layer shell setup for quick menu
                quick.init_layer_shell();
                quick.add_css_class("rounded-corners");
                quick.set_layer(Layer::Overlay);

                // Position the quick menu under the right window
                quick.set_anchor(Edge::Left, false);
                quick.set_anchor(Edge::Right, true);
                quick.set_anchor(Edge::Top, true);
                quick.set_anchor(Edge::Bottom, false);
                quick.set_size_request(300, 0);
                quick.set_margin(Edge::Right, margin);
                quick.set_margin(Edge::Top, margin * 4);

                // If we have a monitor, set it for the quick menu
                if let Some(ref mon) = monitor_for_quick {
                    #[allow(unused_must_use)]
                    {
                        let _ = quick.set_monitor(Some(mon));
                    }
                }

                quick.show();
                *q = Some(quick);
            });

            content.add_controller(gesture);

            // Layer shell setup
            right_window.init_layer_shell();

            // Apply the rounded corners CSS class to the window
            right_window.add_css_class("rounded-corners");
            right_window.add_css_class("transparent-background");

            // Set the layer to overlay so it appears above other windows
            right_window.set_layer(Layer::Overlay);

            // Anchor the window to the edges of the screen
            right_window.set_anchor(Edge::Left, false);
            right_window.set_anchor(Edge::Right, true);
            right_window.set_anchor(Edge::Top, true);
            right_window.set_anchor(Edge::Bottom, false);

            // Set the size and margins of the window
            right_window.set_size_request(0, 0);
            right_window.set_margin(Edge::Left, margin);
            right_window.set_margin(Edge::Right, margin);
            right_window.set_margin(Edge::Top, margin);
            right_window.set_margin(Edge::Bottom, margin);

            // Start hidden; only show when overlay is open
            right_window.hide();

            (right_window, quick_win_cell)
        };

        // Spawn a thread to connect to niri's IPC socket and read events
        let tx_thread = tx.clone();
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
                                        let _ = tx_thread.send(is_open);
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
        let mut windows: Vec<(
            ApplicationWindow,
            std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>>,
        )> = Vec::new();
        // Build one window per monitor so the overlay appears on all screens
        // Also create a centered time window per monitor which toggles a notification window on click.
        let mut center_windows: Vec<(
            ApplicationWindow,
            std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>>,
        )> = Vec::new();
        for i in 0..n_monitors {
            if let Some(obj) = monitors.item(i) {
                if let Ok(monitor) = obj.downcast::<adw::gtk::gdk::Monitor>() {
                    let (window, quick_cell) = make_window(app, Some(monitor.clone()), tx.clone());
                    #[allow(unused_must_use)]
                    {
                        let _ = window.set_monitor(Some(&monitor));
                    }
                    // Use the existing margin/anchor rules from `make_window`.
                    // Keep size request flexible so margins and content determine sizing.
                    window.set_size_request(0, 0);
                    windows.push((window, quick_cell));

                    // --- Center time window (per-monitor) ---
                    let center_content = Box::new(Orientation::Vertical, margin);
                    // Match the right window content padding: top/bottom half, start/end full
                    center_content.set_margin_top(margin / 2);
                    center_content.set_margin_bottom(margin / 2);
                    center_content.set_margin_start(margin);
                    center_content.set_margin_end(margin);

                    let time_label = Label::new(Some(get_time().as_str()));
                    center_content.append(&time_label);

                    // Update center time every second
                    let time_label_clone = time_label.clone();
                    glib::timeout_add_seconds_local(1, move || {
                        time_label_clone.set_label(&get_time());
                        ControlFlow::Continue(()).into()
                    });

                    let center_win = ApplicationWindow::builder()
                        .application(app)
                        .content(&center_content)
                        .build();

                    // Notification window holder (lazy)
                    let notif_cell: std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>> =
                        std::rc::Rc::new(std::cell::RefCell::new(None));
                    let notif_cell_for_click = notif_cell.clone();
                    let app_for_notif = app.clone();
                    let monitor_for_center = monitor.clone();

                    center_win.add_controller({
                        let notif_cell_for_click = notif_cell_for_click.clone();
                        let app_for_notif = app_for_notif.clone();
                        let monitor_for_center = monitor_for_center.clone();
                        let gesture = adw::gtk::GestureClick::new();
                        gesture.connect_pressed(move |_, _, _, _| {
                            let mut ncell = notif_cell_for_click.borrow_mut();
                            if let Some(existing) = ncell.as_ref() {
                                existing.hide();
                                *ncell = None;
                                return;
                            }

                            // Build notification content
                            let notif_content = Box::new(Orientation::Vertical, margin);
                            notif_content.set_margin_top(margin);
                            notif_content.set_margin_bottom(margin);
                            notif_content.set_margin_start(margin);
                            notif_content.set_margin_end(margin);

                            // Create the notification window
                            let notif_win = ApplicationWindow::builder()
                                .application(&app_for_notif)
                                .content(&notif_content)
                                .build();

                            // Layer shell setup for notification
                            notif_win.init_layer_shell();
                            notif_win.add_css_class("rounded-corners");
                            notif_win.add_css_class("dark-background");
                            notif_win.set_layer(Layer::Overlay);
                            notif_win.set_size_request(300, 100);
                            // Anchor the notification near the top-center
                            notif_win.set_anchor(Edge::Left, false);
                            notif_win.set_anchor(Edge::Right, false);
                            notif_win.set_anchor(Edge::Top, true);
                            notif_win.set_anchor(Edge::Bottom, false);
                            // Offset from the top
                            notif_win.set_margin(Edge::Top, margin * 4);
                            #[allow(unused_must_use)]
                            {
                                let _ = notif_win.set_monitor(Some(&monitor_for_center));
                            }
                            notif_win.show();
                            *ncell = Some(notif_win);
                        });
                        gesture
                    });

                    center_win.init_layer_shell();
                    center_win.add_css_class("rounded-corners");
                    center_win.add_css_class("transparent-background");
                    center_win.set_layer(Layer::Overlay);
                    center_win.set_size_request(0, 0);
                    // Anchor to the top and keep centered horizontally
                    center_win.set_anchor(Edge::Left, false);
                    center_win.set_anchor(Edge::Right, false);
                    center_win.set_anchor(Edge::Top, true);
                    center_win.set_anchor(Edge::Bottom, false);
                    // Window margins — match the right window so padding is consistent
                    center_win.set_margin(Edge::Left, margin);
                    center_win.set_margin(Edge::Right, margin);
                    center_win.set_margin(Edge::Top, margin);
                    center_win.set_margin(Edge::Bottom, margin);
                    #[allow(unused_must_use)]
                    {
                        let _ = center_win.set_monitor(Some(&monitor));
                    }
                    // Start hidden; only show when overlay is open
                    center_win.hide();

                    center_windows.push((center_win, notif_cell));
                }
            }
        }
        // Poll the receiver in the main loop and show/hide all windows accordingly.
        let windows_for_ipc = windows
            .iter()
            .chain(center_windows.iter())
            .map(|(w, q)| (w.clone(), q.clone()))
            .collect::<Vec<_>>();
        glib::idle_add_local(move || {
            while let Ok(is_open) = rx.try_recv() {
                for (w, qcell) in &windows_for_ipc {
                    if is_open {
                        w.show();
                    } else {
                        // Hide main window
                        w.hide();
                        // Close quick-menu if open
                        let mut maybe_q = qcell.borrow_mut();
                        if let Some(qwin) = maybe_q.as_ref() {
                            qwin.hide();
                        }
                        *maybe_q = None;
                    }
                }
            }
            ControlFlow::Continue(()).into()
        });
    });

    application.run();
}
