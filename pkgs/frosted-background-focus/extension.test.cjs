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
  return {
    window,
    effects,
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

    class Button extends Signals {
      add_child(child) { this.child = child; }
      destroy() { this.destroyed = true; }
    }
    const display = new Signals();
    const manager = new Signals();
    const first = actor("normal");
    const second = actor("normal");
    const dialog = actor("dialog");
    const actors = [first, second, dialog];
    let focused = first.window;
    display.get_focus_window = () => focused;
    let indicator;
    const context = {
      Meta: { WindowType: { NORMAL: "normal" } },
      Shell: { BlurEffect, BlurMode: { ACTOR: "actor" } },
      St: { Icon: class { constructor(options) { this.options = options; } } },
      PanelMenu: { Button },
      Main: { panel: { addToStatusArea: (_uuid, button) => { indicator = button; } } },
      Extension: class {
        constructor() {
          this.uuid = "focus-test";
          this.metadata = { name: "Focus", uuid: this.uuid };
        }
      },
      global: { display, window_manager: manager, get_window_actors: () => actors },
      console,
    };
    vm.runInNewContext(source, context);
    const extension = new context.ExtensionUnderTest();
    extension.enable();

    assert.equal(first.effects.size, 0);
    assert.equal(dialog.effects.size, 0);
    assert.equal(second.effects.size, 1);
    assert.equal([...second.effects.values()][0].amount, 12);
    assert.equal([...second.effects.values()][0].options.mode, "actor");

    focused = second.window;
    display.emit("notify::focus-window");
    assert.equal(first.effects.size, 1);
    assert.equal(second.effects.size, 0);

    const added = actor("normal");
    actors.push(added);
    manager.emit("map", added);
    assert.equal(added.effects.size, 1);

    extension.disable();
    assert.equal(first.effects.size, 0);
    assert.equal(added.effects.size, 0);
    assert.equal(display.handlers.size, 0);
    assert.equal(manager.handlers.size, 0);
    assert.equal(indicator.destroyed, true);
  });
}
