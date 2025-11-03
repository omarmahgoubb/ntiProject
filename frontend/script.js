// frontend/script.js
document.addEventListener("DOMContentLoaded", () => {
  const taskListEl = document.getElementById("taskList");
  const newTaskInput = document.getElementById("newTaskDesc");
  const addTaskBtn = document.getElementById("addTaskBtn");

  // Load all tasks from the API
  function loadTasks() {
    fetch("/api/tasks")
      .then(response => response.json())
      .then(tasks => {
        taskListEl.innerHTML = "";
        tasks.forEach(task => {
          const li = document.createElement("li");
          li.textContent = `${task.description} (ID: ${task.id})`;
          taskListEl.appendChild(li);
        });
      })
      .catch(err => console.error("Failed to load tasks:", err));
  }

  // Add a new task via the API
  addTaskBtn.addEventListener("click", () => {
    const description = newTaskInput.value;
    if (!description) return;
    fetch("/api/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ description: description })
    })
    .then(response => {
      if (response.ok) {
        newTaskInput.value = "";
        loadTasks();  // Refresh list after adding
      } else {
        console.error("Failed to add task");
      }
    })
    .catch(err => console.error("Error adding task:", err));
  });

  // Initial load of tasks
  loadTasks();
});

