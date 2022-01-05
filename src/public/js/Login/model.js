export default class Model {
    constructor() {
        this.view = null;
        this.todos = JSON.parse(localStorage.getItem('todos'));
        if (!this.todos || this.todos.length < 1) {
            this.todos = [
                {
                    id: 0,
                    title: 'Learn JS',
                    description: 'Watch JS Tutorials',
                    completed: false
                }
            ]
            this.currentId = 1;
        } else {
            this.currentId = this.todos[this.todos.length - 1].id + 1;
        }

    }

    setView(view) {
        this.view = view;
    }

    getTodos() {
        // Clonar array para devolver una una copia de la misma.
        return this.todos.map((todo) => ({ ...todo }));
    }

    save() {
        localStorage.setItem('todos', JSON.stringify(this.todos));
    }


    fidnTodo(id) {
        return this.todos.findIndex((todo) => todo.id === id);
    }

    toggleCompleted(id) {
        const index = this.fidnTodo(id);
        const todo = this.todos[index];
        todo.completed = !todo.completed;

        this.save();
    }

    editTodo(id, values) {
        // console.log(id, values);
        const index = this.fidnTodo(id);
        Object.assign(this.todos[index], values);
        this.save();
    }

    addTodo(title, description) {
        const todo = {
            id: this.currentId++,
            title: title,
            description: description,
            completed: false,
        }

        this.todos.push(todo);
        console.log(this.todos)
        this.save();

        // return Object.assign({}, todo);
        return { ...todo }; //Express sintaxs
    }

    removeTodo(id) {
        const index = this.fidnTodo(id);
        this.todos.splice(index, 1);
        this.save();
    }
}