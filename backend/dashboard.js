const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
    if (!req.session || !req.session.user) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    const user_id = req.session.user.user_id;

    db.query('SELECT * FROM Posts WHERE user_id = ?', [user_id], (err, posts) => {
        if (err) return res.status(500).send("Error fetching posts");

        db.query('SELECT * FROM Transactions WHERE a_id = ? OR b_id = ? OR x_id = ? OR y_id = ?',
            [user_id, user_id, user_id, user_id], (err2, trades) => {
                if (err2) return res.status(500).send("Error fetching transactions");

                res.json({
                    user: req.session.user,
                    posts: posts,
                    trades: trades
                });
            });
    });
});

module.exports = router;
