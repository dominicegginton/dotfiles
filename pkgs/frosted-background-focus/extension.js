import Clutter from "gi://Clutter";
import Shell from "gi://Shell";
import St from "gi://St";
import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";

const EFFECT_NAME = "frosted-background-focus-blur";
const BLUR_RADIUS = 12;
const BLUR_BRIGHTNESS = 0.9;
const UNFOCUSED_OPACITY = 0.94;
const TRANSITION_DURATION = 240;

export default class FrostedBackgroundFocus extends Extension {
  enable() {
    this._originalOpacities = new Map();
    this._shellActors = new Set();
    this._uiGroup = Main.layoutManager.uiGroup;
    this._uiGroupAddedSignal = this._uiGroup.connect("actor-added", (_group, actor) => {
      this._addShellBlur(actor);
    });
    this._uiGroupRemovedSignal = this._uiGroup.connect("actor-removed", (_group, actor) => {
      this._removeShellBlur(actor);
    });
    this._addShellBlur(Main.layoutManager._backgroundGroup);
    for (const actor of this._uiGroup.get_children())
      this._addShellBlur(actor);

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
    this._uiGroup.disconnect(this._uiGroupAddedSignal);
    this._uiGroup.disconnect(this._uiGroupRemovedSignal);
    for (const actor of this._shellActors)
      this._removeShellBlur(actor);
    this._shellActors.clear();
    this._uiGroup = null;

    for (const actor of global.get_window_actors()) {
      const effect = actor.get_effect(EFFECT_NAME);
      if (effect)
        actor.remove_effect(effect);
      const state = this._originalOpacities.get(actor);
      if (state)
        actor.set_opacity(state.opacity);
    }
    this._originalOpacities.clear();
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
    if (!window || window === focusedWindow) {
      if (effect)
        actor.remove_effect(effect);
      this._easeOpacity(actor, false);
      return;
    }

    if (!effect)
      this._addBlur(actor);

    this._easeOpacity(actor, true);
  }

  _easeOpacity(actor, unfocused) {
    let state = this._originalOpacities.get(actor);
    if (!state) {
      if (!unfocused)
        return;
      state = { opacity: actor.get_opacity(), target: null };
      this._originalOpacities.set(actor, state);
    }

    const target = unfocused
      ? Math.round(state.opacity * UNFOCUSED_OPACITY)
      : state.opacity;
    if (state.target === target)
      return;

    state.target = target;
    actor.ease({
      opacity: target,
      duration: TRANSITION_DURATION,
      mode: Clutter.AnimationMode.EASE_OUT_QUAD,
    });
  }

  _addShellBlur(actor) {
    if (actor === global.window_group || actor === global.top_window_group)
      return;

    if (!actor.get_effect(EFFECT_NAME))
      this._addBlur(actor);

    this._shellActors.add(actor);
  }

  _addBlur(actor) {
    const blur = new Shell.BlurEffect({
      mode: Shell.BlurMode.ACTOR,
      brightness: BLUR_BRIGHTNESS,
    });
    // GNOME 45 exposes sigma; newer Shell versions expose radius.
    if (typeof blur.set_radius === "function")
      blur.set_radius(BLUR_RADIUS);
    else
      blur.set_sigma(BLUR_RADIUS);
    actor.add_effect_with_name(EFFECT_NAME, blur);
  }

  _removeShellBlur(actor) {
    const effect = actor.get_effect(EFFECT_NAME);
    if (effect)
      actor.remove_effect(effect);
    this._shellActors.delete(actor);
  }
}
