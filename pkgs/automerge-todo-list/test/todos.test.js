import assert from "node:assert/strict";
import test from "node:test";
import { createTodo, reduceTodos, renderTodos } from "../src/todos.js";

test("todo actions return new state without changing the prior state", () => {
  const initial = {};
  const todo = createTodo({ id: "one", text: "  Buy milk  ", createdAt: 1 });
  const added = reduceTodos(initial, { type: "add", todo });
  const completed = reduceTodos(added, {
    type: "toggle",
    id: "one",
    done: true,
  });
  const deleted = reduceTodos(completed, { type: "delete", id: "one" });

  assert.deepEqual(initial, {});
  assert.equal(todo.text, "Buy milk");
  assert.equal(added.one.done, false);
  assert.equal(completed.one.done, true);
  assert.deepEqual(deleted, {});
});

test("rendering escapes todo content before inserting HTML", () => {
  const markup = renderTodos({
    one: {
      id: "one",
      text: "<img src=x onerror=alert(1)>",
      createdAt: 1,
      done: false,
    },
  });

  assert.match(markup, /&lt;img src=x onerror=alert\(1\)&gt;/);
  assert.doesNotMatch(markup, /<img/);
});
