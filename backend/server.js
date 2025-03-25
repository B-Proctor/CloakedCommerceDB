const express = require('express');
const session = require('express-session');
const path = require('path');
const authRoutes = require('./routes/auth');

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use(session({
    secret: 'supersecret',
    resave: false,
    saveUninitialized: true
}));

app.use(express.static(path.join(__dirname, '..', 'frontend')));
app.use('/auth', authRoutes);

app.listen(3000, () => {
    console.log('Server running at http://localhost:3000');
});
