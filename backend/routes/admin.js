const express = require('express');
const router = express.Router();
const db = require('../db');



function requireAdmin(req, res, next) {
    if (!req.session.user || req.session.user.role !== 'admin') {
        return res.status(403).send('Access denied.');
    }
    next();
}

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

// Get all pending product submissions
router.get('/submissions', (req, res) => {
    if (!req.session.user || req.session.user.role !== 'admin') return res.status(403).send("Forbidden");

    db.query(`SELECT * FROM Product_Submissions WHERE reviewed = FALSE`, (err, results) => {
        if (err) return res.status(500).send("Failed to fetch submissions.");
        res.json(results);
    });
});

// Approve a product submission
router.post('/approve-product', (req, res) => {
    if (!req.session.user || req.session.user.role !== 'admin') return res.status(403).send("Forbidden");

    const { id } = req.body;
    const selectSql = `SELECT * FROM Product_Submissions WHERE submission_id = ?`;

    db.query(selectSql, [id], (err, result) => {
        if (err || result.length === 0) return res.status(400).send("Invalid submission.");
        const submission = result[0];

        const insertProductSql = `
            INSERT INTO Products (product_name, description, cost_c_prime, cost_c_double_prime, base_value)
            VALUES (?, ?, 0.00, 0.00, ?)
        `;

        db.query(insertProductSql, [submission.product_name, submission.description, submission.suggested_value], (err2) => {
            if (err2) return res.status(500).send("Failed to add product.");

            db.query(`UPDATE Product_Submissions SET reviewed = TRUE, approved = TRUE WHERE submission_id = ?`, [id]);
            res.send("Product approved and added.");
        });
    });
});

// Deny a product submission
router.post('/deny-product', (req, res) => {
    if (!req.session.user || req.session.user.role !== 'admin') return res.status(403).send("Forbidden");

    const { id } = req.body;
    db.query(`UPDATE Product_Submissions SET reviewed = TRUE, approved = FALSE WHERE submission_id = ?`, [id], (err) => {
        if (err) return res.status(500).send("Failed to deny submission.");
        res.send("Product submission denied.");
    });
});

// View all products
router.get('/products', requireAdmin, (req, res) => {
    db.query('SELECT * FROM Products', (err, results) => {
        if (err) return res.status(500).send('Error fetching products');
        res.json(results);
    });
});
// Delete product
router.post('/delete-product', requireAdmin, (req, res) => {
    const { id } = req.body;
    if (!id) return res.status(400).send("Missing product ID");

    db.query('DELETE FROM Products WHERE product_id = ?', [id], (err) => {
        if (err) return res.status(500).send("Failed to delete product");
        res.send("Product deleted successfully.");
    });
});

// Get all transactions
router.get('/transactions', requireAdmin, (req, res) => {
    db.query(`
        SELECT transaction_id, a_id, b_id, x_id, y_id, 
               p_product_id, e_product_id, 
               transaction_status, hash_code
        FROM Transactions
        ORDER BY created_at DESC
    `, (err, results) => {
        if (err) return res.status(500).send("Failed to fetch transactions");
        res.json(results);
    });
});

router.post('/send-notification', (req, res) => {
    const { user_id, message } = req.body;

    if (!user_id || !message) {
        return res.status(400).send("Missing user_id or message.");
    }

    const sql = `
        INSERT INTO Notifications (user_id, message)
        VALUES (?, ?)
    `;
    db.query(sql, [user_id, message], (err) => {
        if (err) {
            console.error("Notification insert failed:", err);
            return res.status(500).send("Failed to send notification.");
        }
        res.send("Notification sent.");
    });
});


module.exports = router;
