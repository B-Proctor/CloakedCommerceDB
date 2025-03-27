const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/users', (req, res) => {
    db.query('SELECT user_id, username, role FROM Users', (err, results) => {
        if (err) return res.status(500).send('Failed to retrieve users');
        res.json(results);
    });
});

router.delete('/users/:id', (req, res) => {
    const id = req.params.id;
    db.query('DELETE FROM Users WHERE user_id = ?', [id], (err) => {
        if (err) return res.status(500).send('Failed to delete user');
        res.sendStatus(204);
    });
});

module.exports = router;
