const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/tasks - List all tasks
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, title, description, completed, created_at, updated_at FROM tasks ORDER BY created_at DESC'
    );
    res.json({ success: true, tasks: result.rows });
  } catch (err) {
    console.error('Error fetching tasks:', err);
    res.status(500).json({ success: false, error: 'Failed to fetch tasks' });
  }
});

// POST /api/tasks - Create a new task
router.post('/', async (req, res) => {
  try {
    const { title, description } = req.body;

    if (!title) {
      return res.status(400).json({ success: false, error: 'Title is required' });
    }

    const result = await db.query(
      'INSERT INTO tasks (title, description) VALUES ($1, $2) RETURNING id, title, description, completed, created_at, updated_at',
      [title, description || null]
    );

    res.status(201).json({ success: true, task: result.rows[0] });
  } catch (err) {
    console.error('Error creating task:', err);
    res.status(500).json({ success: false, error: 'Failed to create task' });
  }
});

// PUT /api/tasks/:id - Update a task
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, completed } = req.body;

    const result = await db.query(
      'UPDATE tasks SET title = COALESCE($1, title), description = COALESCE($2, description), completed = COALESCE($3, completed), updated_at = NOW() WHERE id = $4 RETURNING id, title, description, completed, created_at, updated_at',
      [title, description, completed, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Task not found' });
    }

    res.json({ success: true, task: result.rows[0] });
  } catch (err) {
    console.error('Error updating task:', err);
    res.status(500).json({ success: false, error: 'Failed to update task' });
  }
});

// DELETE /api/tasks/:id - Delete a task
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('DELETE FROM tasks WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Task not found' });
    }

    res.json({ success: true, message: 'Task deleted' });
  } catch (err) {
    console.error('Error deleting task:', err);
    res.status(500).json({ success: false, error: 'Failed to delete task' });
  }
});

module.exports = router;
