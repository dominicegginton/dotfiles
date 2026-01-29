use libadwaita as adw;

use adw::gio::Settings;
use adw::gtk::{Application, Box, Orientation};
use adw::prelude::*;
use adw::ApplicationWindow;
use gtk4_layer_shell::{Edge, Layer, LayerShell};

const APP_ID: &str = "dev.dominicegginton.Shell";

fn main() {
    let _ = Settings::new("org.gnome.desktop.interface");
    let application = Application::builder().application_id(APP_ID).build();

    application.connect_startup(|_| {
        adw::init().unwrap();
    });

    application.connect_activate(|app| {
        let content = Box::new(Orientation::Vertical, 0);

        let window = ApplicationWindow::builder()
            .application(app)
            .content(&content)
            .build();
        window.init_layer_shell();
        window.set_layer(Layer::Overlay);
        window.auto_exclusive_zone_enable();
        window.set_size_request(0, 50);

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
