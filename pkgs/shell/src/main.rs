use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{Application, Box, Button, Label, Orientation};
use adw::prelude::*;
use adw::ApplicationWindow;
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use libadwaita::glib;
use std::ops::ControlFlow;

const APP_ID: &str = "dev.dominicegginton.Shell";

fn set_background(image_path: &str) {
    // Get the currently running process of swaybg
    let swaybg_processes = std::process::Command::new("pgrep")
        .arg("swaybg")
        .output();

    // Start a new swaybg process with the specified image
    let _ = std::process::Command::new("swaybg")
        .args(&["-i", image_path, "-m", "fill"])
        .spawn();

    // Wait for 100 milliseconds to ensure swaybg starts before killing previous instances
    std::thread::sleep(std::time::Duration::from_millis(1000));

    // Kill previous swaybg processes
    if let Ok(output) = swaybg_processes {
        // Parse the output to get PIDs
        let pids = String::from_utf8_lossy(&output.stdout);

        // Kill each PID
        for pid in pids.lines() {
            let _ = std::process::Command::new("kill")
                .arg(pid)
                .status();
        }
    }
}

fn get_time() -> String {
    // Get the current local time
    let now = chrono::Local::now();

    // Format the time as HH:MM:SS
    now.format("%H:%M:%S").to_string()
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
        // Margin
        let margin = 10;

        // Main content box
        let content = Box::new(Orientation::Horizontal, margin);

        // Set content margins
        content.set_margin_top(margin / 2);
        content.set_margin_bottom(margin / 2);
        content.set_margin_start(margin);
        content.set_margin_end(margin);

        // Clock label
        let clock = Label::new(None);
        clock.set_text(&get_time());
        content.append(&clock);

        // Update clock every second
        glib::timeout_add_seconds_local(1, move || {
            clock.set_text(&get_time());
            ControlFlow::Continue(()).into()
        });

        // Network button
        let network_button = Button::with_label(&format!("Network: {}", get_network_status()));
        content.append(&network_button);
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
        glib::timeout_add_seconds_local(1, move || {
            let on = std::process::Command::new("nmcli")
                .args(&["radio", "wifi"])
                .output();
            if let Ok(output) = on {
                let stdout = String::from_utf8_lossy(&output.stdout);
                if stdout.contains("enabled") {
                    network_button.add_css_class("suggested-action");
                } else {
                    network_button.remove_css_class("suggested-action");
                }
            }
            network_button.set_label(&format!("Network: {}", get_network_status()));
            ControlFlow::Continue(()).into()
        });

        // Power state label
        let power_state = Label::new(Some("Power: N/A"));
        power_state.set_text(&format!("Power: {}", get_power_state()));
        content.append(&power_state);

        // Update power state every 30 seconds
        glib::timeout_add_seconds_local(30, move || {
            power_state.set_text(&format!("Power: {}", get_power_state()));
            ControlFlow::Continue(()).into()
        });

        // Battery label
        let battery = Label::new(Some("Battery: 100%"));
        battery.set_text(&format!("Battery: {}", get_battery_percentage()));
        content.append(&battery);

        // Update battery every 10 seconds
        glib::timeout_add_seconds_local(10, move || {
            battery.set_text(&format!("Battery: {}", get_battery_percentage()));
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

        // Create the application window
        let window = ApplicationWindow::builder()
            .application(app)
            .content(&content)
            .build();

        // Layer shell setup
        window.init_layer_shell();

        // Set the layer to overlay so it appears above other windows
        window.set_layer(Layer::Overlay);

        // Push other windows out of the way
        window.auto_exclusive_zone_enable();

        // Anchor the window to the edges of the screen
        window.set_anchor(Edge::Left, true);
        window.set_anchor(Edge::Right, true);
        window.set_anchor(Edge::Top, true);
        window.set_anchor(Edge::Bottom, false);

        // Set the size and margins of the window
        let margin = 0;
        window.set_size_request(0, 0);
        window.set_margin(Edge::Left, margin);
        window.set_margin(Edge::Right, margin);
        window.set_margin(Edge::Top, margin);
        window.set_margin(Edge::Bottom, margin);

        // Show the window
        window.show();
    });

    application.run();
}
