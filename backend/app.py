# backend/app.py
import os
import psycopg2
from flask import Flask, request, jsonify

app = Flask(__name__)

# Database config from environment variables (with Docker-friendly defaults)
DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("DB_NAME", "taskdb")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASS = os.environ.get("DB_PASS", "postgres")

def get_db_connection():
    """Open a new database connection."""
    return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS)

@app.route('/tasks', methods=['GET'])
def get_tasks():
    """Retrieve all tasks."""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, description FROM tasks;')
    rows = cur.fetchall()
    tasks = [{"id": r[0], "description": r[1]} for r in rows]  # format as list of dicts
    cur.close()
    conn.close()
    return jsonify(tasks)

@app.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Retrieve a single task by ID."""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, description FROM tasks WHERE id = %s;', (task_id,))
    task = cur.fetchone()
    cur.close()
    conn.close()
    if task:
        return jsonify({"id": task[0], "description": task[1]})
    else:
        return jsonify({"error": "Task not found"}), 404

@app.route('/tasks', methods=['POST'])
def create_task():
    """Create a new task."""
    data = request.get_json()
    description = data.get('description', '')
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('INSERT INTO tasks (description) VALUES (%s) RETURNING id;', (description,))
    new_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Task created", "id": new_id}), 201

@app.route('/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update an existing task by ID."""
    data = request.get_json()
    description = data.get('description', '')
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('UPDATE tasks SET description = %s WHERE id = %s;', (description, task_id))
    if cur.rowcount == 0:
        # Task ID not found
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": "Task not found"}), 404
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Task updated"})

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task by ID."""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM tasks WHERE id = %s;', (task_id,))
    if cur.rowcount == 0:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({"error": "Task not found"}), 404
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Task deleted"})

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

