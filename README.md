# CloakedCommerceDB

CloakedCommerceDB is an anonymous barter platform that allows users to securely exchange goods without revealing personal identities. 
Built with Node.js, MySQL, and plain frontend technologies, it supports anonymous transactions via unique hash keys and enforces access control through user roles.

---

## Features

- Secure user registration and login with hashed passwords
- Automatic generation of anonymous hash keys for all users
- Anonymous barter listings using partner hash keys
- Session-based access control and authentication
- Admin dashboard with role-based access
- Navbar updates based on user login and role
- Interface to create and view active barter posts

---

## Setup Instructions

### Prerequisites

- Node.js
- XAMPP (for Apache, MySQL, and phpMyAdmin)

---

### 1. Clone the Repository

```bash
git clone https://github.com/B-Proctor/CloakedCommerceDB
cd cloakedcommerce
```

---

### 2. Install Backend Dependencies

```bash
cd backend
npm install
```

---

### 3. Set Up the Database

1. Open XAMPP and start Apache and MySQL.
2. Go to http://localhost/phpmyadmin in your browser.
3. Import the file `cloakedcommerce.sql`.
4. Ensure the database `cloakedcommerce` and all its tables are created.

---

### 4. Start the Backend Server

```bash
npm start
```

This runs the server at:  
http://localhost:3000

---

### 5. Access the Application

Open your browser and go to:  
http://localhost:3000
(IF THIS CAUSES ERRORS THIS PORT MAY NOT BE OPEN AND NEEDS TO BE UPDATED IN SEVER.JS)
---

## Folder Structure

```
CloakedCommerceDB/
├── backend/
│   ├── routes/
│   │   ├── auth.js
│   │   ├── barter.js
│   │   ├── admin.js
│   │   └── dashboard.js
│   ├── server.js
│   └── db.js
├── frontend/
│   ├── index.html
│   ├── listings.html
│   ├── login.html
│   ├── register.html
│   ├── admin.html
│   ├── home.html
│   ├── style.css
│   └── navbar.js
├── cloakedcommerce.sql
└── README.md
```

---

## User Roles

- trader: Can post listings and view available matches.
- admin: Has access to admin-only functions and management dashboard.

---

## Contact

For questions or feedback, contact:  
Braydyn Proctor  or Owen McDaniel