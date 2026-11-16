import Clutter from "gi://Clutter";
import Shell from "gi://Shell";
import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";
import * as QuickSettings from "resource:///org/gnome/shell/ui/quickSettings.js";

const EFFECT_NAME = "frosted-background-focus-blur";
const BLUR_RADIUS = 12;
const BLUR_BRIGHTNESS = 0.9;
const UNFOCUSED_OPACITY = 0.94;
const TRANSITION_DURATION = 240;

export default class FrostedBackgroundFocus extends Extension {
  enable() {
    this._focusModeEnabled = true;
    this._originalOpacities = new Map();
    this._shellActors = new Set();
    this._uiGroup = Main.layoutManager.uiGroup;
    this._uiGroupAddedSignal = this._uiGroup.connect("child-added", (_group, actor) => {
      this._addShellBlur(actor);
    });
    this._uiGroupRemovedSignal = this._uiGroup.connect("child-removed", (_group, actor) => {
      this._removeShellBlur(actor);
    });
    this._addShellBlur(Main.layoutManager._backgroundGroup);
    for (const actor of this._uiGroup.get_children())
      this._addShellBlur(actor);

    this._systemIndicator = new QuickSettings.SystemIndicator();
    this._indicator = this._systemIndicator._addIndicator();
    this._indicator.icon_name = "view-conceal-symbolic";
    this._indicator.visible = this._focusModeEnabled;
    this._toggle = new QuickSettings.QuickToggle({
      title: "Focus mode",
      iconName: "view-conceal-symbolic",
      toggleMode: true,
      checked: this._focusModeEnabled,
    });
    this._toggle.connect("notify::checked", () => {
      this._setFocusModeEnabled(this._toggle.checked);
    });
    this._systemIndicator.quickSettingsItems.push(this._toggle);
    Main.panel.statusArea.quickSettings.addExternalIndicator(this._systemIndicator);

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
    this._clearFocusEffects();
    this._uiGroup = null;
    this._toggle.destroy();
    this._systemIndicator.destroy();
    this._toggle = null;
    this._systemIndicator = null;
    this._indicator = null;
  }

  _setFocusModeEnabled(enabled) {
    if (enabled === this._focusModeEnabled)
      return;

    this._focusModeEnabled = enabled;
    this._indicator.visible = enabled;
    this._indicator.icon_name = enabled ? "view-conceal-symbolic" : "view-reveal-symbolic";

    if (!enabled) {
      this._clearFocusEffects();
      return;
    }

    this._addShellBlur(Main.layoutManager._backgroundGroup);
    for (const actor of this._uiGroup.get_children())
      this._addShellBlur(actor);
    this._updateWindowEffects();
  }

  _clearFocusEffects() {
    for (const actor of this._shellActors)
      this._removeShellBlur(actor);
    this._shellActors.clear();

    for (const actor of global.get_window_actors()) {
      const effect = actor.get_effect(EFFECT_NAME);
      if (effect)
        actor.remove_effect(effect);
      const state = this._originalOpacities.get(actor);
      if (state)
        actor.set_opacity(state.opacity);
    }
    this._originalOpacities.clear();
  }

  _updateWindowEffects() {
    if (!this._focusModeEnabled)
      return;

    const focusedWindow = global.display.get_focus_window();
    for (const actor of global.get_window_actors())
      this._updateActor(actor, focusedWindow);
  }

  _updateActor(actor, focusedWindow) {
    if (!this._focusModeEnabled)
      return;

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
    if (!this._focusModeEnabled)
      return;

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
