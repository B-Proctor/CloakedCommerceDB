const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();

app.use(express.json());
app.use(cors());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'cloakedcommerce'
});

db.connect(err => {
    if (err) throw err;
    console.log('Connected to MySQL');
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
