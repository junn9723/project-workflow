// @spec: specs/001-todo-module.md
const { TodoList } = require('../../src/todo');

describe('TodoList', () => {
  let todoList;

  beforeEach(() => {
    todoList = new TodoList();
  });

  // AC-1: addTodo("タイトル") で新しいTodoが追加され、IDが返される
  describe('AC-1: addTodo', () => {
    test('タイトルを指定してTodoを追加するとIDが返される', () => {
      const id = todoList.addTodo('買い物に行く');
      expect(id).toBeDefined();
      expect(typeof id).toBe('number');
    });

    test('追加されたTodoは未完了の状態', () => {
      const id = todoList.addTodo('買い物に行く');
      const todos = todoList.getTodos();
      const todo = todos.find(t => t.id === id);
      expect(todo.title).toBe('買い物に行く');
      expect(todo.completed).toBe(false);
    });

    test('複数追加すると異なるIDが割り当てられる', () => {
      const id1 = todoList.addTodo('タスク1');
      const id2 = todoList.addTodo('タスク2');
      expect(id1).not.toBe(id2);
    });
  });

  // AC-2: getTodos() で全Todoの配列が返される
  describe('AC-2: getTodos', () => {
    test('空の場合は空配列が返される', () => {
      expect(todoList.getTodos()).toEqual([]);
    });

    test('追加した全Todoが返される', () => {
      todoList.addTodo('タスク1');
      todoList.addTodo('タスク2');
      const todos = todoList.getTodos();
      expect(todos).toHaveLength(2);
      expect(todos[0].title).toBe('タスク1');
      expect(todos[1].title).toBe('タスク2');
    });
  });

  // AC-3: completeTodo(id) で該当Todoのcompletedがtrueになる
  describe('AC-3: completeTodo', () => {
    test('指定IDのTodoが完了になる', () => {
      const id = todoList.addTodo('完了するタスク');
      todoList.completeTodo(id);
      const todos = todoList.getTodos();
      expect(todos.find(t => t.id === id).completed).toBe(true);
    });
  });

  // AC-4: deleteTodo(id) で該当Todoが削除される
  describe('AC-4: deleteTodo', () => {
    test('指定IDのTodoが削除される', () => {
      const id = todoList.addTodo('削除するタスク');
      todoList.deleteTodo(id);
      expect(todoList.getTodos()).toHaveLength(0);
    });

    test('他のTodoは影響を受けない', () => {
      const id1 = todoList.addTodo('残るタスク');
      const id2 = todoList.addTodo('削除するタスク');
      todoList.deleteTodo(id2);
      const todos = todoList.getTodos();
      expect(todos).toHaveLength(1);
      expect(todos[0].id).toBe(id1);
    });
  });

  // AC-5: 存在しないIDに対する操作でエラーが投げられる
  describe('AC-5: 存在しないID', () => {
    test('completeTodo: 存在しないIDでエラー', () => {
      expect(() => todoList.completeTodo(999)).toThrow('Todo not found');
    });

    test('deleteTodo: 存在しないIDでエラー', () => {
      expect(() => todoList.deleteTodo(999)).toThrow('Todo not found');
    });
  });

  // AC-6: タイトルが空文字の場合エラーが投げられる
  describe('AC-6: バリデーション', () => {
    test('空文字でエラー', () => {
      expect(() => todoList.addTodo('')).toThrow('Title is required');
    });

    test('空白のみでエラー', () => {
      expect(() => todoList.addTodo('   ')).toThrow('Title is required');
    });
  });
});
