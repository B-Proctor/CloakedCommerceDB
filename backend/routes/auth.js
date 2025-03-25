const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

// Generate 16-character hash key
function generateHashKey() {
    return crypto.randomBytes(8).toString('hex'); // 16 hex characters
}

// REGISTER
router.post('/register', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).send('Missing fields');
    }

    const hashKey = generateHashKey();
    const password_hash = await bcrypt.hash(password, 10);

    const query = 'INSERT INTO Users (username, password_hash, role, hash_key) VALUES (?, ?, ?, ?)';
    const values = [username, password_hash, 'trader', hashKey];

    db.query(query, values, (err, result) => {
        if (err) {
            console.error("Register error:", err);
            return res.status(500).send('Registration failed. Username may already exist.');
        }
        res.redirect('/login.html');
    });
});

// LOGIN
router.post('/login', (req, res) => {
    const { username, password } = req.body;

    db.query('SELECT * FROM Users WHERE username = ?', [username], async (err, results) => {
        if (err) {
            console.error("Login DB error:", err);
            return res.status(500).send('Server error.');
        }

        if (results.length === 0) {
            return res.status(401).send('Invalid credentials.');
        }

        const user = results[0];
        const match = await bcrypt.compare(password, user.password_hash);

        if (match) {
            req.session.user = {
                id: user.user_id,
                username: user.username,
                role: user.role,
                hash_key: user.hash_key
            };
            res.send(`<h3>Welcome, ${user.username}!</h3><p>Your hash_key is: ${user.hash_key}</p>`);
        } else {
            res.status(401).send('Invalid credentials.');
        }
    });
});

module.exports = router;
