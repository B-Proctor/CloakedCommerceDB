CREATE DATABASE IF NOT EXISTS cloakedcommerce;

USE cloakedcommerce;

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    cost_c_prime DECIMAL(10, 2),
    cost_c_double_prime DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    a_id INT,
    b_id INT,
    x_id INT,
    y_id INT,
    p_product_id INT,
    e_product_id INT,
    hash_code VARCHAR(16),
    amount_p DECIMAL(10, 2),
    amount_e DECIMAL(10, 2),
    cost_c_prime DECIMAL(10, 2),
    cost_c_double_prime DECIMAL(10, 2),
    equivalence_id INT,
    FOREIGN KEY (a_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (b_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (x_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (y_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (p_product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (e_product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    partner_id INT,
    product_offered INT,
    product_requested INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (partner_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_offered) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_requested) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Equivalence (
    equivalence_id INT AUTO_INCREMENT PRIMARY KEY,
    product1 INT,
    product2 INT,
    percentage DECIMAL(10, 2),
    FOREIGN KEY (product1) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product2) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
