-- Create and select database
DROP DATABASE IF EXISTS cloakedcommerce;
CREATE DATABASE cloakedcommerce;
USE cloakedcommerce;

-- Users Table
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','trader') DEFAULT 'trader',
    hash_key VARCHAR(16)
);

-- Products Table
CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    cost_c_prime DECIMAL(10, 2),
    cost_c_double_prime DECIMAL(10, 2)
);

-- Equivalence Table
CREATE TABLE IF NOT EXISTS Equivalence (
    equivalence_id INT AUTO_INCREMENT PRIMARY KEY,
    product1 INT,
    product2 INT,
    percentage DECIMAL(10, 2),
    FOREIGN KEY (product1) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product2) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Posts Table
CREATE TABLE IF NOT EXISTS Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    partner_id INT,
    product_offered INT,
    product_requested INT,
    amount_offered DECIMAL(10,2),
    amount_requested DECIMAL(10,2),
    is_fulfilled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (partner_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_offered) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_requested) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Transactions Table
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

INSERT INTO Products (product_name, description, cost_c_prime, cost_c_double_prime) VALUES
('Copper Ore', 'Raw copper ore for smelting.', 8.00, 2.00),
('Timber', 'Freshly cut timber logs.', 10.00, 3.00),
('Leather', 'Tanned leather for crafting.', 15.00, 5.00),
('Wheat', 'Harvested wheat grain.', 5.00, 1.50),
('Spices', 'Rare spices used in trade.', 20.00, 7.00),
('Cloth', 'Simple woven cloth.', 12.00, 4.00),
('Stone Blocks', 'Used for construction.', 6.00, 2.50),
('Wool', 'Sheep wool for textile production.', 7.00, 3.00);