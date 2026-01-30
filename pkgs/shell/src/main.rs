use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{Application, Box, Button, Label, Orientation};
use adw::prelude::*;
use adw::ApplicationWindow;
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use libadwaita::glib;
use std::ops::ControlFlow;

const APP_ID: &str = "dev.dominicegginton.Shell";

fn get_time() -> String {
    let now = chrono::Local::now();
    now.format("%H:%M:%S").to_string()
}

fn get_battery_percentage() -> String {
    let output = std::process::Command::new("upower")
        .args(&["-i", "/org/freedesktop/UPower/devices/battery_BAT0"])
        .output()
        .expect("Failed to execute upower command");

    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if line.trim_start().starts_with("percentage:") {
            return line
                .trim_start()
                .split_whitespace()
                .nth(1)
                .unwrap_or("N/A")
                .to_string();
        }
    }
    "N/A".to_string()
}

fn main() {
    let application = Application::builder().application_id(APP_ID).build();

    application.connect_startup(|_| {
        adw::init().unwrap();
    });

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

        // GSettings for changing GTK theme
        let settings = Settings::new("org.gnome.desktop.interface");

        // Clock label
        let clock = Label::new(None);
        clock.set_text(&get_time());
        content.append(&clock);

        // Update clock every second
        glib::timeout_add_seconds_local(1, move || {
            clock.set_text(&get_time());
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

        // Style the button
        theme_button.add_css_class("suggested-action");

        // Connect button click to toggle theme
        content.append(&theme_button);
        theme_button.connect_clicked(move |_| {
            if settings.get::<String>("color-scheme") == "prefer-dark" {
                let _ = settings.set_string("color-scheme", "default");
            } else {
                let _ = settings.set_string("color-scheme", "prefer-dark");
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
