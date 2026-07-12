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

const APP_ID: &str = "dev.dominicegginton.Shell";

const STYLE: &str = "
    .rounded-corners {
        border-radius: 30px;
    }
";

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
        let _current_theme = settings.get::<String>("color-scheme");

        // Set the initial background based on the current theme
        // (Initial set is now handled by the sway-wallpaper systemd service)
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

        // Helper to build a single window with its own content and timeouts.
        // Accept an optional monitor so quick-menu windows can be placed on the same screen.
        let make_window = |app: &Application,
                           monitor: Option<adw::gtk::gdk::Monitor>|
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

            // Time label
            let time_label = Label::new(Some(&get_time()));
            content.append(&time_label);

            // Update time every 1 second
            let tl = time_label.clone();
            glib::timeout_add_seconds_local(1, move || {
                tl.set_label(&get_time());
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

                // Settings button: opens the `shell-settings` app
                let settings_btn = Button::with_label("⚙");
                settings_btn.add_css_class("flat");
                first_row.append(&settings_btn);
                settings_btn.connect_clicked(move |_| {
                    let _ = std::process::Command::new("shell-settings").spawn();
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

                    // Toggle the theme and update background
                    if current_theme == "prefer-dark" {
                        settings.set("color-scheme", &"prefer-light").unwrap();
                    } else {
                        settings.set("color-scheme", &"prefer-dark").unwrap();
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

            // Always show the shell bar
            right_window.show();

            (right_window, quick_win_cell)
        };

        // Build one window per monitor so the overlay appears on all screens
        let display = adw::gtk::gdk::Display::default().expect("Could not connect to a display.");
        let monitors = display.monitors();
        let n_monitors = monitors.n_items();
        let mut windows: Vec<(
            ApplicationWindow,
            std::rc::Rc<std::cell::RefCell<Option<ApplicationWindow>>>,
        )> = Vec::new();
        for i in 0..n_monitors {
            if let Some(obj) = monitors.item(i) {
                if let Ok(monitor) = obj.downcast::<adw::gtk::gdk::Monitor>() {
                    let (window, quick_cell) = make_window(app, Some(monitor.clone()));
                    #[allow(unused_must_use)]
                    {
                        let _ = window.set_monitor(Some(&monitor));
                    }
                    // Use the existing margin/anchor rules from `make_window`.
                    // Keep size request flexible so margins and content determine sizing.
                    window.set_size_request(0, 0);
                    windows.push((window, quick_cell));
                }
            }
        }

    });

    application.run();
}
