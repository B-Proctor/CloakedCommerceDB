const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // Set your MySQL root password here if any
    database: 'cloakedcommerce'
});

db.connect((err) => {
    if (err) {
        console.error('Database connection error:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

module.exports = db;
