import { IndexedDBStorageAdapter, Repo, WebSocketClientAdapter } from "@automerge/vanillajs";
import { createTodo, reduceTodos, renderTodos } from "./todos.js";

const form = document.querySelector("#todo-form");
const input = document.querySelector("#todo-input");
const submitButton = form.querySelector('button[type="submit"]');
const list = document.querySelector("#todo-list");
const emptyState = document.querySelector("#empty-state");
const status = document.querySelector("#sync-status");
const copyButton = document.querySelector("#copy-link");
const shareLink = document.querySelector("#share-link");
const currentUrl = new URL(location.href);
const syncUrl =
  currentUrl.searchParams.get("sync") ??
  `${location.protocol === "https:" ? "wss:" : "ws:"}//${location.hostname}:3030`;

const render = (handle) => {
  const todos = handle.doc().todos;
  list.innerHTML = renderTodos(todos);
  emptyState.hidden = Object.keys(todos).length > 0;
};

const dispatch = (handle, action) =>
  handle.change((doc) => {
    const previous = Object.fromEntries(Object.entries(doc.todos));
    const next = reduceTodos(previous, action);

    if (next === previous) return;

    switch (action.type) {
      case "add":
        doc.todos[action.todo.id] = next[action.todo.id];
        break;
      case "toggle":
        doc.todos[action.id].done = next[action.id].done;
        break;
      case "delete":
        delete doc.todos[action.id];
        break;
    }
  });

const mountList = (handle) => {
  handle.on("change", () => render(handle));
  render(handle);
  input.disabled = false;
  submitButton.disabled = false;

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const text = input.value.trim();
    if (!text) {
      input.setCustomValidity("Enter a task.");
      input.reportValidity();
      input.setCustomValidity("");
      return;
    }

    dispatch(handle, {
      type: "add",
      todo: createTodo({
        id: crypto.randomUUID(),
        text,
        createdAt: Date.now(),
      }),
    });
    form.reset();
    input.focus();
  });

  list.addEventListener("change", (event) => {
    const checkbox = event.target.closest('input[data-action="toggle"]');
    if (!checkbox) return;

    dispatch(handle, {
      type: "toggle",
      id: checkbox.dataset.id,
      done: checkbox.checked,
    });
  });

  list.addEventListener("click", (event) => {
    const button = event.target.closest('button[data-action="delete"]');
    if (!button) return;

    dispatch(handle, { type: "delete", id: button.dataset.id });
  });
};

const openList = async () => {
  status.textContent = `Connecting to ${syncUrl}…`;
  const network = new WebSocketClientAdapter(syncUrl);
  const connectionTimeout = window.setTimeout(() => {
    status.textContent = `Could not connect to ${syncUrl}; retrying.`;
  }, 3000);

  network.on("peer-candidate", () => {
    window.clearTimeout(connectionTimeout);
    status.textContent = `Syncing with ${syncUrl}.`;
  });
  network.on("peer-disconnected", () => {
    status.textContent = `Disconnected from ${syncUrl}; reconnecting…`;
  });

  const repo = new Repo({
    network: [network],
    storage: new IndexedDBStorageAdapter(),
  });
  const documentId = currentUrl.searchParams.get("doc");
  const handle = documentId ? await repo.find(documentId) : repo.create({ todos: {} });

  currentUrl.searchParams.set("doc", handle.documentId);
  history.replaceState(null, "", `${currentUrl.pathname}${currentUrl.search}${currentUrl.hash}`);

  shareLink.href = currentUrl.href;
  shareLink.textContent = currentUrl.href;
  copyButton.disabled = false;
  mountList(handle);
};

copyButton.addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(shareLink.href);
    status.textContent = "Share link copied.";
  } catch (error) {
    console.error("Could not copy the share link.", error);
    status.textContent = "Could not copy the link. Copy the URL shown below.";
  }
});

openList().catch((error) => {
  console.error("Could not open the to-do list.", error);
  status.textContent = `Could not open the list: ${error.message}`;
});
