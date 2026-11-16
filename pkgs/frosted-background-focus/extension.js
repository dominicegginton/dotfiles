import Meta from "gi://Meta";
import Shell from "gi://Shell";
import St from "gi://St";
import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";

const EFFECT_NAME = "frosted-background-focus-blur";
const BLUR_RADIUS = 12;

export default class FrostedBackgroundFocus extends Extension {
  enable() {
    this._indicator = new PanelMenu.Button(0.0, this.metadata.name, false);
    this._indicator.add_child(new St.Icon({
      icon_name: "face-laugh-symbolic",
      style_class: "system-status-icon",
    }));
    this._indicator.connect("button-press-event", () => {
      console.log(`${this.metadata.uuid}: Panel button clicked!`);
    });
    Main.panel.addToStatusArea(this.uuid, this._indicator);

    this._focusSignal = global.display.connect("notify::focus-window", () => {
      this._updateWindowEffects();
    });
    this._mapSignal = global.window_manager.connect("map", (_manager, actor) => {
      this._updateActor(actor, global.display.get_focus_window());
    });
    this._updateWindowEffects();
  }

  disable() {
    global.display.disconnect(this._focusSignal);
    global.window_manager.disconnect(this._mapSignal);
    for (const actor of global.get_window_actors()) {
      const effect = actor.get_effect(EFFECT_NAME);
      if (effect)
        actor.remove_effect(effect);
    }
    this._indicator.destroy();
    this._indicator = null;
  }

  _updateWindowEffects() {
    const focusedWindow = global.display.get_focus_window();
    for (const actor of global.get_window_actors())
      this._updateActor(actor, focusedWindow);
  }

  _updateActor(actor, focusedWindow) {
    const window = actor.get_meta_window();
    const effect = actor.get_effect(EFFECT_NAME);
    if (!window || window.get_window_type() !== Meta.WindowType.NORMAL || window === focusedWindow) {
      if (effect)
        actor.remove_effect(effect);
      return;
    }

    if (!effect) {
      const blur = new Shell.BlurEffect({ mode: Shell.BlurMode.ACTOR });
      // GNOME 45 exposes sigma; newer Shell versions expose radius.
      if (typeof blur.set_radius === "function")
        blur.set_radius(BLUR_RADIUS);
      else
        blur.set_sigma(BLUR_RADIUS);
      actor.add_effect_with_name(EFFECT_NAME, blur);
    }
  }
}
