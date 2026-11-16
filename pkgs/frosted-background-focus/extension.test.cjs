const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const vm = require("node:vm");
const { test } = require("node:test");

const source = readFileSync(join(__dirname, "extension.js"), "utf8")
  .replace(/^import .*;\n/gm, "")
  .replace("export default class", "class")
  .concat("\nglobalThis.ExtensionUnderTest = FrostedBackgroundFocus;");

class Signals {
  constructor() {
    this.handlers = new Map();
    this.nextId = 1;
  }
  connect(name, callback) {
    const id = this.nextId++;
    this.handlers.set(id, { name, callback });
    return id;
  }
  disconnect(id) {
    assert.ok(this.handlers.delete(id));
  }
  emit(name, ...args) {
    for (const handler of this.handlers.values()) {
      if (handler.name === name)
        handler.callback(this, ...args);
    }
  }
}

function actor(type) {
  const window = { get_window_type: () => type };
  const effects = new Map();
  let opacity = 255;
  return {
    window,
    effects,
    get_opacity: () => opacity,
    set_opacity: value => { opacity = value; },
    ease: ({ opacity: value }) => { opacity = value; },
    get_meta_window: () => window,
    get_effect: name => effects.get(name),
    add_effect_with_name: (name, effect) => effects.set(name, effect),
    remove_effect: effect => {
      for (const [name, current] of effects) {
        if (current === effect)
          effects.delete(name);
      }
    },
  };
}

class ActorGroup extends Signals {
  constructor(children = []) {
    super();
    this.children = children;
    this.effects = new Map();
  }
  get_children() { return this.children; }
  get_effect(name) { return this.effects.get(name); }
  add_effect_with_name(name, effect) { this.effects.set(name, effect); }
  remove_effect(effect) {
    for (const [name, current] of this.effects) {
      if (current === effect)
        this.effects.delete(name);
    }
  }
  add(child) {
    this.children.push(child);
    this.emit("child-added", child);
  }
  remove(child) {
    this.children = this.children.filter(current => current !== child);
    this.emit("child-removed", child);
  }
}

for (const legacy of [false, true]) {
  test(`focus, window mapping, and cleanup with ${legacy ? "sigma" : "radius"} API`, () => {
    class BlurEffect {
      constructor(options) {
        this.options = options;
      }
    }
    BlurEffect.prototype[legacy ? "set_sigma" : "set_radius"] = function (value) {
      this.amount = value;
    };

    class QuickToggle extends Signals {
      constructor(options) {
        super();
        Object.assign(this, options);
        this._checked = options.checked;
      }
      get checked() { return this._checked; }
      set checked(value) {
        if (this._checked === value)
          return;
        this._checked = value;
        this.emit("notify::checked");
      }
      destroy() { this.destroyed = true; }
    }
    class SystemIndicator {
      constructor() {
        this.quickSettingsItems = [];
      }
      _addIndicator() {
        this.indicator = { icon_name: null, visible: false };
        return this.indicator;
      }
      destroy() { this.destroyed = true; }
    }
    const display = new Signals();
    const manager = new Signals();
    const first = actor("normal");
    const second = actor("normal");
    const dialog = actor("dialog");
    const actors = [first, second, dialog];
    const windowGroup = new ActorGroup();
    const topWindowGroup = new ActorGroup();
    const shellChrome = new ActorGroup();
    const uiGroup = new ActorGroup([windowGroup, topWindowGroup, shellChrome]);
    const backgroundGroup = new ActorGroup();
    let focused = first.window;
    display.get_focus_window = () => focused;
    let indicator;
    let quickToggle;
    let systemIndicator;
    const context = {
      Shell: { BlurEffect, BlurMode: { ACTOR: "actor" } },
      QuickSettings: { QuickToggle, SystemIndicator },
      Extension: class {
        constructor() {
          this.uuid = "focus-test";
          this.metadata = { name: "Focus", uuid: this.uuid };
        }
      },
      Clutter: { AnimationMode: { EASE_OUT_QUAD: "ease-out-quad" } },
      global: {
        display,
        window_manager: manager,
        window_group: windowGroup,
        top_window_group: topWindowGroup,
        get_window_actors: () => actors,
      },
      Main: {
        panel: {
          statusArea: {
            quickSettings: {
              addExternalIndicator: value => {
                systemIndicator = value;
                quickToggle = value.quickSettingsItems[0];
                indicator = value.indicator;
              },
            },
          },
        },
        layoutManager: { uiGroup, _backgroundGroup: backgroundGroup },
      },
      console,
    };
    vm.runInNewContext(source, context);
    const extension = new context.ExtensionUnderTest();
    extension.enable();

    assert.equal(first.effects.size, 0);
    assert.equal(dialog.effects.size, 1);
    assert.equal(second.effects.size, 1);
    assert.equal([...second.effects.values()][0].amount, 12);
    assert.equal([...second.effects.values()][0].options.mode, "actor");
    assert.equal([...second.effects.values()][0].options.brightness, 0.9);
    assert.equal(second.get_opacity(), 240);
    assert.equal(shellChrome.effects.size, 1);
    assert.equal(backgroundGroup.effects.size, 1);
    assert.equal(windowGroup.effects.size, 0);
    assert.equal(topWindowGroup.effects.size, 0);
    assert.equal(quickToggle.checked, true);
    assert.equal(indicator.visible, true);

    quickToggle.checked = false;
    assert.equal(first.effects.size, 0);
    assert.equal(second.effects.size, 0);
    assert.equal(dialog.effects.size, 0);
    assert.equal(first.get_opacity(), 255);
    assert.equal(shellChrome.effects.size, 0);
    assert.equal(backgroundGroup.effects.size, 0);
    assert.equal(indicator.visible, false);
    assert.equal(indicator.icon_name, "view-reveal-symbolic");

    focused = second.window;
    display.emit("notify::focus-window");
    assert.equal(first.effects.size, 0);
    assert.equal(second.effects.size, 0);
    assert.equal(first.get_opacity(), 255);
    assert.equal(second.get_opacity(), 255);

    const added = actor("normal");
    actors.push(added);
    manager.emit("map", added);
    assert.equal(added.effects.size, 0);
    assert.equal(added.get_opacity(), 255);

    const newShellActor = new ActorGroup();
    uiGroup.add(newShellActor);
    assert.equal(newShellActor.effects.size, 0);

    quickToggle.checked = true;
    assert.equal(first.effects.size, 1);
    assert.equal(second.effects.size, 0);
    assert.equal(dialog.effects.size, 1);
    assert.equal(added.effects.size, 1);
    assert.equal(added.get_opacity(), 240);
    assert.equal(shellChrome.effects.size, 1);
    assert.equal(backgroundGroup.effects.size, 1);
    assert.equal(newShellActor.effects.size, 1);
    assert.equal(indicator.visible, true);
    assert.equal(indicator.icon_name, "view-conceal-symbolic");

    uiGroup.remove(newShellActor);
    assert.equal(newShellActor.effects.size, 0);

    extension.disable();
    assert.equal(first.effects.size, 0);
    assert.equal(added.effects.size, 0);
    assert.equal(first.get_opacity(), 255);
    assert.equal(added.get_opacity(), 255);
    assert.equal(shellChrome.effects.size, 0);
    assert.equal(backgroundGroup.effects.size, 0);
    assert.equal(display.handlers.size, 0);
    assert.equal(manager.handlers.size, 0);
    assert.equal(uiGroup.handlers.size, 0);
    assert.equal(quickToggle.destroyed, true);
    assert.equal(systemIndicator.destroyed, true);
  });
}
