class TodoList {
  constructor() {
    this._todos = [];
    this._nextId = 1;
  }

  addTodo(title) {
    if (!title || !title.trim()) {
      throw new Error('Title is required');
    }
    const id = this._nextId++;
    this._todos.push({ id, title: title.trim(), completed: false });
    return id;
  }

  getTodos() {
    return [...this._todos];
  }

  completeTodo(id) {
    const todo = this._todos.find(t => t.id === id);
    if (!todo) {
      throw new Error('Todo not found');
    }
    todo.completed = true;
  }

  deleteTodo(id) {
    const index = this._todos.findIndex(t => t.id === id);
    if (index === -1) {
      throw new Error('Todo not found');
    }
    this._todos.splice(index, 1);
  }
}

module.exports = { TodoList };
