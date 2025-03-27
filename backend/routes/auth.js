const express = require('express');
const bcrypt = require('bcrypt');
const db = require('../db');

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
    const { username, password } = req.body;
    const hash = await bcrypt.hash(password, 10);

    const hash_key = require('crypto').randomBytes(8).toString('hex'); //  Generate 16-char anonymous hash

    const sql = `
        INSERT INTO Users (username, password_hash, hash_key)
        VALUES (?, ?, ?)
    `;

    db.query(sql, [username, hash, hash_key], (err) => {
        if (err) {
            console.error('Register error:', err);
            return res.status(500).send('Registration failed.');
        }
        res.redirect("/login.html")
    });
});

// Login
router.post('/login', (req, res) => {
    const { username, password } = req.body;

    db.query('SELECT * FROM Users WHERE username = ?', [username], async (err, results) => {
        if (err || results.length === 0) {
            alert('Login failed. Check your credentials.');
        }

        const user = results[0];
        const valid = await bcrypt.compare(password, user.password_hash);

        if (valid) {
            req.session.user = {
                user_id: user.user_id,
                username: user.username,
                role: user.role,
                hash_key: user.hash_key
            };
            res.redirect("/index.html")
        } else {
            res.status(401).send('Invalid username or password.');
        }
    });
});

// Session check
router.get('/session', (req, res) => {
    if (req.session.user) {
        res.json(req.session.user);
    } else {
        res.status(401).json({ error: 'Not logged in' });
    }
});

// Logout
router.get('/logout', (req, res) => {
    req.session.destroy(() => {
        res.redirect('/');
    });
});

module.exports = router;
