document.addEventListener('DOMContentLoaded', function() {
    const todoTable = document.querySelector('#todos tbody');
    const todoTextArea = document.querySelector('#new-todo');
    const todoSubmit = document.querySelector('#new-todo-submit');
    const todoCancel = document.querySelector('#new-todo-cancel');
    window.todoTable = todoTable;
    const loadTodos = function() {
        fetch('/api/todos')
            .then(response => response.json())
            .then(data => {
                todoTable.innerHTML = "";
                for (const k in data) {
                    const rowData = `<td><input type='checkbox'></td><td>${data[k].text}</td>`;
                    const row = document.createElement('tr');
                    row.innerHTML = rowData;
                    row.dataset.tid = k;
                    const cbox = row.querySelector('input');
                    if (data[k].state == 'DONE') {
                        cbox.checked = true;
                        cbox.disabled = true;
                    } else {
                        cbox.addEventListener('click', function(evt) {
                            console.log('TODO ' + k + ' checked.');
                            cbox.disabled = true;
                            const formData = new FormData();
                            formData.append('status', 'DONE');
                            const url = `/api/todos/${k}`;
                            fetch(url, {
                                method: 'POST',
                                body: formData,
                            }).catch((err) => {
                                console.error('Error in click: ', error);
                            });
                        });
                    }
                    todoTable.appendChild(row);
                }
            })
            .catch((error) => {
                console.error('Error in loadTodos: ', error);
                // TODO: display something to user
            });
    };
    if (!!todoTable) {
        loadTodos();
    }
    if (!!todoSubmit) {
        todoSubmit.addEventListener('click', function(evt) {
            evt.preventDefault();
            const formData = new FormData();
            formData.append('todo', todoTextArea.value);
            fetch('/api/todos', {
                method: 'POST',
                body: formData,
            }).then(() => {
              loadTodos();
              todoTextArea.value = "";
            }).catch((error) => {
                console.error('ERROR posting: ', error);
            });
        });
    }
    if (!!todoCancel) {
        todoCancel.addEventListener('click', function(evt) {
            evt.preventDefault();
            todoTextArea.value = "";
        });
    }
});
