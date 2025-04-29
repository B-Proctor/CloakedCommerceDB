const express = require('express');
const router = express.Router();
const db = require('../db');
const crypto = require('crypto');


// Helper function to insert a notification
 function notifyUser(userId, message) {
     db.query('INSERT INTO Notifications (user_id, message, is_read, created_at) VALUES (?, ?, 0, NOW())', [userId, message]);
}

// Middleware: Require login
function requireLogin(req, res, next) {
    if (!req.session.user) return res.status(401).json({ error: 'Unauthorized' });
    next();
}

// Get all products
router.get('/products', (req, res) => {
    db.query('SELECT * FROM Products', (err, results) => {
        if (err) return res.status(500).send('Error fetching products');
        res.json(results);
    });
});

// Get all active barter posts
router.get('/posts', (req, res) => {
    db.query('SELECT * FROM Posts WHERE is_fulfilled = 0', (err, results) => {
        if (err) return res.status(500).send('Error fetching posts');
        res.json(results);
    });
});

// Get a specific post
router.get('/posts/:id', (req, res) => {
    const id = req.params.id;
    db.query('SELECT * FROM Posts WHERE post_id = ?', [id], (err, results) => {
        if (err || results.length === 0) return res.status(404).send("Post not found");
        res.json(results[0]);
    });
});

router.post('/posts', requireLogin, async (req, res) => {
    const user_id = req.session.user.user_id;
    const {
        partner_hash_key,
        product_offered,
        product_requested,
        amount_offered,
        amount_requested
    } = req.body;

    console.log("New post received");
    console.log("User:", user_id);
    console.log("Partner hash:", partner_hash_key);
    console.log("Offering product:", product_offered, " x", amount_offered);
    console.log("Requesting product:", product_requested, " x", amount_requested);

    if (!partner_hash_key || !product_offered || !product_requested) {
        console.warn("Missing required fields");
        return res.status(400).send('Missing required fields.');
    }

    db.query('SELECT user_id FROM Users WHERE hash_key = ?', [partner_hash_key], (err, partnerResults) => {
        if (err || partnerResults.length === 0) {
            console.warn("Invalid partner hash key");
            return res.status(400).send('Invalid partner hash key.');
        }

        const partner_id = partnerResults[0].user_id;
        console.log("Partner found:", partner_id);

        const sql = `
            INSERT INTO Posts (user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested)
            VALUES (?, ?, ?, ?, ?, ?)
        `;

        db.query(sql, [user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested], (err2, result) => {
            if (err2) {
                console.error("Failed to insert post:", err2);
                return res.status(500).send('Failed to post barter.');
            }

            const newPostId = result.insertId;
            console.log("New post ID:", newPostId);

            const matchSql = `
                SELECT * FROM Posts
                WHERE product_offered = ? AND product_requested = ? AND is_fulfilled = 0 AND user_id != ?
                LIMIT 1
            `;

            db.query(matchSql, [product_requested, product_offered, user_id], (err3, matches) => {
                if (err3) {
                    console.error("Error finding match:", err3);
                    return res.status(500).send("Error matching posts.");
                }

                if (matches.length === 0) {
                    console.log("No matching post found.");
                    return res.status(200).send('Barter post submitted. No match yet.');
                }

                const match = matches[0];
                console.log("Match found. Match Post ID:", match.post_id);

                db.query(`SELECT * FROM Products WHERE product_id IN (?, ?)`, [product_requested, product_offered], (err5, products) => {
                    if (err5 || products.length < 2) {
                        console.warn("Product data incomplete.");
                        return res.status(200).send('Posted. Cost data incomplete.');
                    }

                    const pProd = products.find(p => p.product_id == product_requested);
                    const eProd = products.find(p => p.product_id == product_offered);

                    const cost_c_prime = parseFloat(pProd.cost_c_prime || 0);
                    const cost_c_double_prime = parseFloat(eProd.cost_c_double_prime || 0);
                    const value_p = parseFloat(pProd.base_value || 1);
                    const value_e = parseFloat(eProd.base_value || 1);

                    const adjustedP = amount_requested * value_p * (1 - cost_c_prime / 100);
                    const adjustedE = match.amount_offered * value_e * (1 - cost_c_double_prime / 100);

                    console.log("Value Debug:");
                    console.log("Base value P:", value_p);
                    console.log("Base value E:", value_e);
                    console.log("Cost c':", cost_c_prime);
                    console.log("Cost c'':", cost_c_double_prime);
                    console.log("Adjusted P value:", adjustedP);
                    console.log("Adjusted E value:", adjustedE);

                    if (Math.abs(adjustedP - adjustedE) > 0.01) {
                        console.warn("<!> Trade mismatch! Proceeding anyway — user will get poor value.");
                    }

                    const hash = (crypto.randomBytes(8).toString('hex')).toUpperCase();
                    console.log("Generated transaction hash:", hash);

                    db.query(`
                        INSERT INTO Transactions (
                            a_id, b_id, x_id, y_id,
                            post_a_id, post_x_id,
                            p_product_id, e_product_id,
                            amount_p, amount_e,
                            cost_c_prime, cost_c_double_prime,
                            hash_code, transaction_status
                        )
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
                    `, [
                        user_id, partner_id,
                        match.user_id, match.partner_id,
                        newPostId, match.post_id,
                        product_requested, product_offered,
                        amount_requested, match.amount_offered,
                        cost_c_prime, cost_c_double_prime,
                        hash
                    ], (err6) => {
                        if (err6) {
                            console.error("Failed to insert transaction:", err6);
                            return res.status(500).send('Transaction failed.');
                        }

                        console.log("Transaction created successfully.");
                         notifyUser(user_id, `Your verification code (first half): ${hash.slice(0, 8)}`);
                         notifyUser(match.partner_id, `Your verification code (second half): ${hash.slice(8)}`);
                        db.query(`UPDATE Posts SET is_fulfilled = 1 WHERE post_id IN (?, ?)`, [newPostId, match.post_id]);
                        return res.status(200).send('Barter matched and transaction created.');
                        // Notify A and Y with their verification code halves



                    });
                });
            });
        });
    });
});

// Dashboard API
router.get('/dashboard', requireLogin, (req, res) => {
    const userId = req.session.user.user_id;

    // Fetch user's posts
    db.query('SELECT * FROM Posts WHERE user_id = ?', [userId], (err, posts) => {
        if (err) {
            console.error('Error fetching posts:', err);
            return res.status(500).send('Error fetching posts');
        }

        // Fetch user's transactions
        db.query(`
            SELECT * FROM Transactions
            WHERE a_id = ? OR b_id = ? OR x_id = ? OR y_id = ?
        `, [userId, userId, userId, userId], (err2, trades) => {
            if (err2) {
                console.error('Error fetching transactions:', err2);
                return res.status(500).send('Error fetching transactions');
            }

            // Now send both
            res.json({
                user: req.session.user,
                posts: posts,
                trades: trades.map(trade => ({
                    ...trade,
                    completed: trade.transaction_status === 'complete'
                }))
            });
        });
    });
});


// Fetch code notifications for a user
router.get('/notifications', requireLogin, (req, res) => {
    const user_id = req.session.user.user_id;

    const sql = `
        SELECT transaction_id, hash_code, a_id, y_id 
        FROM Transactions 
        WHERE transaction_status = 'pending' 
        AND (a_id = ? OR y_id = ?)
    `;

    db.query(sql, [user_id, user_id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Failed to fetch notifications." });
        }

        const messages = results.map(tx => {
            if (tx.a_id === user_id) {
                return `Hey! Your verification code is ${tx.hash_code.slice(0, 8)}. Send this to your partner B.`;
            } else if (tx.y_id === user_id) {
                return `Hey! Your verification code is ${tx.hash_code.slice(8)}. Keep this safe and submit it when ready.`;
            } else {
                return null;
            }
        }).filter(Boolean);

        res.json(messages);
    });
});
router.post('/notifications/mark-read', requireLogin, (req, res) => {
    const { notification_id } = req.body;
    const user_id = req.session.user.user_id;

    if (!notification_id) {
        return res.status(400).send('Missing notification ID.');
    }

    db.query(
        'UPDATE Notifications SET is_read = TRUE WHERE notification_id = ? AND user_id = ?',
        [notification_id, user_id],
        (err) => {
            if (err) {
                console.error('Error marking notification as read:', err);
                return res.status(500).send('Failed to mark as read.');
            }
            res.send('Notification marked as read.');
        }
    );
});

// Submit a code from A or Y
router.post('/submit-code', (req, res) => {
    const { code } = req.body;

    if (!code || code.length !== 8) {
        return res.status(400).send("Invalid code format.");
    }

    const sql = `SELECT * FROM Transactions WHERE hash_code LIKE ? OR hash_code LIKE ?`;
    const frontMatch = code + '%';
    const backMatch = '%' + code;

    db.query(sql, [frontMatch, backMatch], (err, results) => {
        if (err) return res.status(500).send("Error verifying code.");
        if (results.length === 0) return res.status(404).send("No matching transaction found.");

        const tx = results[0];
        const isFront = tx.hash_code.startsWith(code);
        const isBack = tx.hash_code.endsWith(code);

        if ((isFront && tx.a_half_sent) || (isBack && tx.y_half_sent)) {
            return res.status(409).send("Code already submitted.");
        }

        const updateFields = [];
        if (isFront) updateFields.push("a_half_sent = 1");
        if (isBack) updateFields.push("y_half_sent = 1");

        const updateQuery = `UPDATE Transactions SET ${updateFields.join(', ')} WHERE transaction_id = ?`;

        db.query(updateQuery, [tx.transaction_id], (err2) => {
            if (err2) return res.status(500).send("Failed to update transaction.");

            db.query(`SELECT a_half_sent, y_half_sent FROM Transactions WHERE transaction_id = ?`, [tx.transaction_id], (err3, finalCheck) => {
                if (err3 || finalCheck.length === 0) {
                    return res.status(500).send("Error checking completion.");
                }

                const complete = finalCheck[0].a_half_sent && finalCheck[0].y_half_sent;
                if (complete) {
                    db.query(`UPDATE Transactions SET transaction_status = 'complete' WHERE transaction_id = ?`, [tx.transaction_id], (err4) => {
                        if (err4) {
                            console.error('Failed to update transaction status to complete:', err4);
                        } else {
                            notifyUser(tx.a_id, 'Trade completed successfully! Thank you for using CloakedCommerceDB.');
                            notifyUser(tx.y_id, 'Trade completed successfully! Thank you for using CloakedCommerceDB.');
                        }
                    });
                    return res.status(200).send("Code accepted. Trade completed.");
                }


                return res.status(200).send("Code accepted. Waiting for the other party.");
            });
        });
    });
});




// Submit a product suggestion request
router.post('/submitrequest', requireLogin, (req, res) => {
    const user_id = req.session.user.user_id;
    const { product_name, description, suggested_value, reason } = req.body;

    if (!product_name || !suggested_value || !reason) {
        return res.status(400).send("Missing fields.");
    }

    const sql = `
        INSERT INTO Product_Submissions (user_id, product_name, description, suggested_value, reason)
        VALUES (?, ?, ?, ?, ?)
    `;

    db.query(sql, [user_id, product_name, description, suggested_value, reason], (err) => {
        if (err) {
            console.error("Failed to insert product request:", err);
            return res.status(500).send("Failed to submit product.");
        }
        res.send("Product request submitted!");
    });
});

router.get('/notifications/all', requireLogin, (req, res) => {
    const user_id = req.session.user.user_id;

    db.query(
        'SELECT * FROM Notifications WHERE user_id = ? ORDER BY created_at DESC',
        [user_id],
        (err, results) => {
            if (err) {
                console.error("Error fetching notifications:", err);
                return res.status(500).json({ error: "Failed to fetch notifications." });
            }
            res.json(results);
        }
    );
});


router.post('/notifications/delete', requireLogin, (req, res) => {
    const { notification_id } = req.body;

    db.query(
        'DELETE FROM Notifications WHERE notification_id = ? AND user_id = ?',
        [notification_id, req.session.user.user_id],
        (err) => {
            if (err) {
                return res.status(500).send("Failed to delete notification.");
            }
            res.send("Notification deleted.");
        }
    );
});
router.get('/notifications/unread-count', requireLogin, (req, res) => {
    const user_id = req.session.user.user_id;
    db.query(
        'SELECT COUNT(*) AS unread FROM Notifications WHERE user_id = ? AND is_read = FALSE',
        [user_id],
        (err, results) => {
            if (err) return res.status(500).json({ error: 'Failed to fetch count.' });
            res.json({ unread: results[0].unread });
        }
    );
});

router.get('/recent-trades', (req, res) => {
    db.query(
        `SELECT
          t.amount_p,
          t.amount_e,
          p1.product_name AS p_product_name,
          p2.product_name AS e_product_name,
          p1.base_value AS p_base_value,
          p2.base_value AS e_base_value
        FROM Transactions t
        JOIN Products p1 ON t.p_product_id = p1.product_id
        JOIN Products p2 ON t.e_product_id = p2.product_id
        WHERE t.transaction_status = 'complete'
        ORDER BY t.transaction_id DESC
        LIMIT 5`,
        (err, results) => {
            if (err) {
                console.error('Error fetching recent trades:', err);
                return res.status(500).json({ error: 'Failed to fetch recent trades.' });
            }
            res.json(results);
        }
    );
});



module.exports = router;
