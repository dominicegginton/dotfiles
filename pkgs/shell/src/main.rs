use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{Application, Box, Button, Label, Orientation};
use adw::prelude::*;
use adw::ApplicationWindow;
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use libadwaita::glib;
use std::ops::ControlFlow;

const APP_ID: &str = "dev.dominicegginton.Shell";

fn render_clock(label: &Label) {
    let now = chrono::Local::now();
    label.set_text(&now.format("%H:%M:%S").to_string());
}

fn render_battery(label: &Label) {
    let output = std::process::Command::new("upower")
        .args(&["-i", "/org/freedesktop/UPower/devices/battery_BAT0"])
        .output()
        .expect("Failed to execute upower command");

    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if line.trim_start().starts_with("percentage:") {
            let percentage = line.trim_start().split_whitespace().nth(1).unwrap_or("N/A");
            label.set_text(&format!("Battery: {}", percentage));
            return;
        }
    }
    label.set_text("Battery: N/A");
}

fn main() {
    let application = Application::builder().application_id(APP_ID).build();

    application.connect_startup(|_| {
        adw::init().unwrap();
    });

    application.connect_activate(|app| {
        let content = Box::new(Orientation::Vertical, 0);

        // GSettings for changing GTK theme (created here to avoid moving into the
        // `connect_activate` closure's environment which must be 'static)
        let settings = Settings::new("org.gnome.desktop.interface");

        let clock = Label::new(None);
        content.append(&clock);
        render_clock(&clock);
        glib::timeout_add_seconds_local(1, move || {
            render_clock(&clock);
            ControlFlow::Continue(()).into()
        });

        let battery = Label::new(Some("Battery: 100%"));
        content.append(&battery);
        render_battery(&battery);
        glib::timeout_add_seconds_local(10, move || {
            render_battery(&battery);
            ControlFlow::Continue(()).into()
        });

        let theme_button = Button::with_label("Toggle Light/Dark Theme");
        theme_button.set_margin_top(10);
        theme_button.set_margin_bottom(10);
        theme_button.add_css_class("suggested-action");
        content.append(&theme_button);
        theme_button.connect_clicked(move |_| {
            if settings.get::<String>("color-scheme") == "prefer-dark" {
                let _ = settings.set_string("color-scheme", "default");
            } else {
                let _ = settings.set_string("color-scheme", "prefer-dark");
            }
        });

        let window = ApplicationWindow::builder()
            .application(app)
            .content(&content)
            .build();
        window.init_layer_shell();
        window.set_layer(Layer::Overlay);
        window.auto_exclusive_zone_enable();
        window.set_size_request(0, 10);

        let anchors = [
            (Edge::Left, true),
            (Edge::Right, true),
            (Edge::Top, false),
            (Edge::Bottom, true),
        ];
        for (anchor, state) in anchors {
            window.set_anchor(anchor, state);
        }

        window.show();
    });

    application.run();
}
