const express = require('express');
const session = require('express-session');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
const barterRoutes = require('./routes/barter');
const adminRoutes = require('./routes/admin');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: false
}));

app.use('/auth', authRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/barter', barterRoutes);
app.use('/admin', adminRoutes);

app.use(express.static(path.join(__dirname, '../frontend')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
