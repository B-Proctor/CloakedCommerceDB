const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /dashboard – return user's barters + transactions + hash key
router.get('/', (req, res) => {
    if (!req.session.user) return res.status(403).send("Not logged in");

    const userId = req.session.user.id;

    // Get this user's barter posts
    db.query('SELECT * FROM Posts WHERE user_id = ?', [userId], (err, posts) => {
        if (err) {
            console.error("Error getting posts:", err);
            return res.status(500).send("Failed to load posts");
        }

        // Get this user's transactions (as A or X)
        db.query(
            'SELECT * FROM Transactions WHERE a_id = ? OR x_id = ?',
            [userId, userId],
            (err2, trades) => {
                if (err2) {
                    console.error("Error getting trades:", err2);
                    return res.status(500).send("Failed to load transactions");
                }

                // Return everything needed for the profile view
                res.json({
                    user: req.session.user,
                    posts,
                    trades
                });
            }
        );
    });
});

module.exports = router;
