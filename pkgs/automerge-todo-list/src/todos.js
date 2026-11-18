const htmlEntities = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;",
};

const escapeHtml = (value) =>
  String(value).replace(/[&<>"']/g, (character) => htmlEntities[character]);

export const createTodo = ({ id, text, createdAt }) => ({
  id,
  text: text.trim(),
  createdAt,
  done: false,
});

export const reduceTodos = (todos, action) => {
  switch (action.type) {
    case "add":
      return Object.hasOwn(todos, action.todo.id)
        ? todos
        : { ...todos, [action.todo.id]: action.todo };
    case "toggle":
      return Object.hasOwn(todos, action.id)
        ? { ...todos, [action.id]: { ...todos[action.id], done: action.done } }
        : todos;
    case "delete":
      return Object.hasOwn(todos, action.id)
        ? Object.fromEntries(Object.entries(todos).filter(([id]) => id !== action.id))
        : todos;
    default:
      throw new Error(`Unknown to-do action: ${action.type}`);
  }
};

const renderTodo = ({ id, text, done }) => {
  const safeId = escapeHtml(id);
  const safeText = escapeHtml(text);
  const completionLabel = done ? "Mark incomplete" : "Mark complete";
  const checkbox = [
    `<input type="checkbox" data-action="toggle" data-id="${safeId}"`,
    `aria-label="${completionLabel}: ${safeText}"${done ? " checked" : ""}>`,
  ].join(" ");
  const deleteButton = [
    `<button type="button" data-action="delete" data-id="${safeId}"`,
    `aria-label="Delete: ${safeText}">Delete</button>`,
  ].join(" ");

  return `<li><label>${checkbox} ${safeText}</label> ${deleteButton}</li>`;
};

const compareTodos = (left, right) =>
  left.createdAt - right.createdAt || left.id.localeCompare(right.id);

export const renderTodos = (todos) =>
  Object.values(todos).toSorted(compareTodos).map(renderTodo).join("");
