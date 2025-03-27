const express = require('express');
const router = express.Router();
const db = require('../db');
const crypto = require('crypto');

// Middleware: Require login
function requireLogin(req, res, next) {
    if (!req.session.user) return res.status(401).json({ error: 'Unauthorized' });
    next();
}

// Get products
router.get('/products', (req, res) => {
    db.query('SELECT * FROM Products', (err, results) => {
        if (err) return res.status(500).send('Error fetching products');
        res.json(results);
    });
});

// Get active barter posts
router.get('/posts', (req, res) => {
    db.query('SELECT * FROM Posts WHERE is_fulfilled = 0', (err, results) => {
        if (err) return res.status(500).send('Error fetching posts');
        res.json(results);
    });
});

// Get specific post
router.get('/posts/:id', (req, res) => {
    const id = req.params.id;
    db.query('SELECT * FROM Posts WHERE post_id = ?', [id], (err, results) => {
        if (err || results.length === 0) return res.status(404).send("Post not found");
        res.json(results[0]);
    });
});

// Submit new post (must be logged in)
router.post('/posts', requireLogin, (req, res) => {
    const user_id = req.session.user.user_id;
    const {
        partner_hash_key,
        product_offered,
        product_requested,
        amount_offered = 1,
        amount_requested = 1
    } = req.body;

    db.query('SELECT user_id FROM Users WHERE hash_key = ?', [partner_hash_key], (err, results) => {
        if (err || results.length === 0) {
            return res.status(400).send('Invalid partner hash key.');
        }

        const partner_id = results[0].user_id;

        const sql = `
            INSERT INTO Posts (user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested)
            VALUES (?, ?, ?, ?, ?, ?)
        `;

        db.query(sql, [user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested], (err2) => {
            if (err2) {
                console.error('Error posting barter:', err2);
                return res.status(500).send('Failed to post barter.');
            }
            res.status(200).send('Barter post submitted.');
        });
    });
});

// Match posts logic (for future use)
router.post('/match', (req, res) => {
    const sql = `
        SELECT A.*, X.*
        FROM Posts A
        JOIN Posts X
        ON A.product_offered = X.product_requested
        AND A.product_requested = X.product_offered
        AND A.is_fulfilled = 0 AND X.is_fulfilled = 0
        LIMIT 1
    `;

    db.query(sql, (err, results) => {
        if (err || results.length === 0) {
            return res.status(404).send("No match found.");
        }

        const match = results[0];
        const fullHash = crypto.randomBytes(8).toString('hex') + crypto.randomBytes(8).toString('hex');
        const codeA = fullHash.slice(0, 8);
        const codeY = fullHash.slice(8);

        res.json({
            message: "Match found!",
            A_code: codeA,
            Y_code: codeY,
            exchange_key: fullHash
        });
    });
});

module.exports = router;
