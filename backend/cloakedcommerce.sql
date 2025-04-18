-- Reset database
DROP DATABASE IF EXISTS cloakedcommerce; --SPECIFICALLY FOR TESTING IF EVER UPLOADED PLEASE FOR THE LOVE OF ALL THIGNS HOLY RMEOVE THIS LINE
CREATE DATABASE cloakedcommerce;
USE cloakedcommerce;

-- USERS TABLE
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'trader') DEFAULT 'trader',
    hash_key VARCHAR(16) UNIQUE
);

-- PRODUCTS TABLE (with base_value instead of equivalence table)
CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    cost_c_prime DECIMAL(10, 2),        -- cost of sending product P
    cost_c_double_prime DECIMAL(10, 2), -- cost of sending product E
    base_value DECIMAL(10, 2) NOT NULL DEFAULT 1.00
);

-- POSTS TABLE
CREATE TABLE IF NOT EXISTS Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                -- Poster (A or X)
    partner_id INT NOT NULL,             -- Anonymous partner (B or Y)
    product_offered INT NOT NULL,
    product_requested INT NOT NULL,
    amount_offered DECIMAL(10,2),
    amount_requested DECIMAL(10,2),
    willing_to_split BOOLEAN DEFAULT FALSE,
    is_fulfilled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (partner_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_offered) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_requested) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TRANSACTIONS TABLE (Four-Party Barter Logic)
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    
    a_id INT, b_id INT,
    x_id INT, y_id INT,

    post_a_id INT,
    post_x_id INT,

    p_product_id INT,
    e_product_id INT,

    amount_p DECIMAL(10, 2),
    amount_e DECIMAL(10, 2),

    cost_c_prime DECIMAL(10, 2),        -- loss when A receives P
    cost_c_double_prime DECIMAL(10, 2), -- loss when Y receives E

    hash_code VARCHAR(16) NOT NULL,
    a_half_sent BOOLEAN DEFAULT FALSE,
    y_half_sent BOOLEAN DEFAULT FALSE,
    transaction_status ENUM('pending', 'validated', 'complete', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (a_id) REFERENCES Users(user_id),
    FOREIGN KEY (b_id) REFERENCES Users(user_id),
    FOREIGN KEY (x_id) REFERENCES Users(user_id),
    FOREIGN KEY (y_id) REFERENCES Users(user_id),
    FOREIGN KEY (p_product_id) REFERENCES Products(product_id),
    FOREIGN KEY (e_product_id) REFERENCES Products(product_id),
    FOREIGN KEY (post_a_id) REFERENCES Posts(post_id),
    FOREIGN KEY (post_x_id) REFERENCES Posts(post_id)
);

CREATE TABLE IF NOT EXISTS Product_Submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    suggested_value DECIMAL(10,2) NOT NULL,
    reason TEXT,
    reviewed BOOLEAN DEFAULT FALSE,
    approved BOOLEAN DEFAULT FALSE,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE IF NOT EXISTS Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


-- PRODUCTS SEED DATA (with base_value added)
INSERT INTO Products (product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES
('Copper Ore', 'Raw copper ore for smelting.', 8.00, 2.00, 1.00),
('Timber', 'Freshly cut timber logs.', 10.00, 3.00, 2.00),
('Leather', 'Tanned leather for crafting.', 15.00, 5.00, 3.00),
('Wheat', 'Harvested wheat grain.', 5.00, 1.50, 0.50),
('Spices', 'Rare spices used in trade.', 20.00, 7.00, 4.00),
('Cloth', 'Simple woven cloth.', 12.00, 4.00, 2.50),
('Stone Blocks', 'Used for construction.', 6.00, 2.50, 1.25),
('Wool', 'Sheep wool for textile production.', 7.00, 3.00, 1.75);
