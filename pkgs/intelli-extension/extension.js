function getSettings(schema) {
  const Gio = imports.gi.Gio;
  return new Gio.Settings({ schema_id: schema });
}
import GObject from "gi://GObject";
import St from "gi://St";
import Clutter from "gi://Clutter";
import Gio from "gi://Gio";
import Meta from "gi://Meta";
import Shell from "gi://Shell";
import GLib from "gi://GLib";

import {
  Extension,
  gettext as _,
} from "resource:///org/gnome/shell/extensions/extension.js";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import * as PopupMenu from "resource:///org/gnome/shell/ui/popupMenu.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

const IntelliIndicator = GObject.registerClass(
  class IntelliIndicator extends PanelMenu.Button {
    _init() {
      super._init(0.0, _("Intelli"));

      this._buildMenu();
    }

    _buildMenu() {
      let item = new PopupMenu.PopupBaseMenuItem({
        activate: false,
        reactive: true,
        can_focus: true,
      });

      let layout = new St.BoxLayout({
        vertical: true,
        style_class: "intelli-layout",
        x_expand: true,
        y_expand: true,
      });

      this._entry = new St.Entry({
        hint_text: _("Type here..."),
        can_focus: true,
        x_expand: true,
        style_class: "intelli-entry",
      });

      this._entry.clutter_text.connect("activate", () => {
        log(`Intelli Extension: ${this._entry.get_text()}`);
        this.menu.close();
      });

      layout.add_child(this._entry);

      item.add_child(layout);
      this.menu.addMenuItem(item);

      this.menu.connect("opened", () => {
        this._entry.grab_key_focus();
      });
    }

    toggle() {
      if (this.menu.isOpen) {
        this.menu.close();
      } else {
        // Open without standard panel animation
        this.menu.open(false);

        const [x, y] = global.get_pointer();
        const menuActor = this.menu.actor;

        GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
          if (menuActor) {
            menuActor.set_position(x, y);
          }
          return GLib.SOURCE_REMOVE;
        });
      }
    }
  },
);

export default class IntelliExtension extends Extension {
  enable() {
    this._settings = getSettings("org.gnome.shell.extensions.intelli");
    this._indicator = new IntelliIndicator();

    Main.panel.addToStatusArea(this.uuid, this._indicator);

    this._bindKeyboardShortcuts();
  }

  disable() {
    this._unbindKeyboardShortcuts();
    if (this._indicator) {
      this._indicator.destroy();
      this._indicator = null;
    }
    this._settings = null;
  }

  _bindKeyboardShortcuts() {
    const ModeType = Object.prototype.hasOwnProperty.call(Shell, "ActionMode")
      ? Shell.ActionMode
      : Shell.KeyBindingMode;

    Main.wm.addKeybinding(
      "shortcut-intelli",
      this._settings,
      Meta.KeyBindingFlags.NONE,
      ModeType.ALL,
      () => {
        this._indicator.toggle();
      },
    );
  }

  _unbindKeyboardShortcuts() {
    Main.wm.removeKeybinding("shortcut-intelli");
  }
}
