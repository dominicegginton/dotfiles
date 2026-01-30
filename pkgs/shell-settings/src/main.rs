use libadwaita as adw;

use adw::gtk::{Application, Box, HeaderBar, Label, Orientation};
use adw::prelude::{ApplicationExt, ApplicationExtManual, BoxExt, WidgetExt};
use adw::ApplicationWindow;

const APP_ID: &str = "dev.dominicegginton.ShellSettings";
const APP_NAME: &str = "Shell Settings";

fn main() {
    let application = Application::builder().application_id(APP_ID).build();

    application.connect_startup(|_| {
        adw::init().unwrap();
    });

    application.connect_activate(|app| {
        let content = Box::new(Orientation::Vertical, 0);

        let header_bar = HeaderBar::new();
        let title_label = Label::new(Some(APP_NAME));
        header_bar.set_title_widget(Some(&title_label));
        header_bar.set_show_title_buttons(true);

        content.append(&header_bar);

        let window = ApplicationWindow::builder()
            .application(app)
            .content(&content)
            .build();

        window.show();
    });

    application.run();
}
