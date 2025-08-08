import { App, Gdk, Gtk } from "astal/gtk3";
import { GLib } from "astal";
import TopBar from "./widgets/TopBar";
import Volume from "./widgets/Volume";
import Notification from "./widgets/Notification";

const E = GLib.getenv;
const path = `${E("XDG_DATA_HOME")}/icons/hicolor/32x32/apps`;
App.add_icons(path);
App.start({
  instanceName: "residence" + Math.random().toString(36).substring(2, 15),
  requestHandler: (_, res) => res("ok"),
  main() {
    const topbars = new Map<Gdk.Monitor, Gtk.Widget>();
    const notifications = new Map<Gdk.Monitor, Gtk.Widget>();
    const volumes = new Map<Gdk.Monitor, Gtk.Widget>();
    for (const gdkmonitor of App.get_monitors()) {
      topbars.set(gdkmonitor, TopBar(gdkmonitor));
      notifications.set(gdkmonitor, Notification(gdkmonitor));
      volumes.set(gdkmonitor, Volume(gdkmonitor));
    }
    App.connect("monitor-added", (_, gdkmonitor) => {
      if (gdkmonitor.model) {
        topbars.set(gdkmonitor, TopBar(gdkmonitor));
        notifications.set(gdkmonitor, Notification(gdkmonitor));
        volumes.set(gdkmonitor, Volume(gdkmonitor));
      }
    });
    App.connect("monitor-removed", (_, gdkmonitor) => {
      if (gdkmonitor.model) {
        topbars.get(gdkmonitor)?.destroy();
        notifications.get(gdkmonitor)?.destroy();
        volumes.get(gdkmonitor)?.destroy();
        topbars.delete(gdkmonitor);
        notifications.delete(gdkmonitor);
        volumes.delete(gdkmonitor);
      }
    });
  },
});
