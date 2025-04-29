-- SPECIFICALLY FOR TESTING IF EVER UPLOADED PLEASE FOR THE LOVE OF ALL THINGS HOLY REMOVE THIS LINE
DROP DATABASE IF EXISTS cloakedcommerce;
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


--DUMMY DATA DUMMY DATA 
-- USERS WITH KNOWN PASSWORDS ('Password123')
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (1, 'robert68', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'X8S1A27CKRDN2ARE');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (2, 'noah41', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'BLVXHBIUA9PVAMF6');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (3, 'ewright', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'OLCHKG6U2HMFMNGZ');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (4, 'vsmith', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'DMVBW3QU8UQBN0N5');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (5, 'moralesjessica', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'LHR7SEOHRZ2OIH7X');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (6, 'neil69', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'NEJ7JGL21QG7K8PD');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (7, 'judyrichardson', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'JTIYVXK20GSRNURR');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (8, 'estevenson', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '9GH2HKOA78IO1CHK');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (9, 'waltersdouglas', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'QYH4T5REL6C8BKPM');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (10, 'duffyelizabeth', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'X7WJ6TVAVM2P5ZSI');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (11, 'ulozano', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'AVDNY2AC1EQASO3V');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (12, 'vmaxwell', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '21KH42QAYQK05W3D');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (13, 'christopher34', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'YWUNW0GCKJW2P1SF');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (14, 'bdavis', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'G111OXEF2G46WOKG');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (15, 'robinsonmary', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '9KODFWB6UN9FM5AZ');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (16, 'ayerstara', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '8PW472X1JQM9PV4X');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (17, 'charles20', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'PPML8V5IH40BRR1B');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (18, 'collierkatherine', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'HGDC8J4U86HKYF3B');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (19, 'tammylucero', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'N2OHA304F83C1MR1');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (20, 'whitetyler', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'F2Y476T6GN6NV4RU');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (21, 'medinagrant', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '5URBKL6W5R95KSXW');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (22, 'mhall', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'AH4YYFOYVZ8SS598');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (23, 'leslie65', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '140KDES9GAVKVKEN');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (24, 'sabrina27', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '1T8A7Z9U8VY7K8CX');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (25, 'gomezjames', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'QG0BTF1B85ZZQF8C');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (26, 'usalazar', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'V7AZMH6TJZ8XQEEK');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (27, 'rwilliamson', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'WPZ39ZZBYCJ97S6I');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (28, 'michael24', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '77O0NK1WLQVMROM6');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (29, 'jfleming', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '50B9O1XVPBE1HFNL');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (30, 'michaela90', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'V1F6O9UB45FA7OHD');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (31, 'randallgolden', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '2XY29OTUUWJPY0IP');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (32, 'tonya45', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'HEMPOKPDIJQNFWJ8');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (33, 'pfernandez', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'HROZV5EA22B27MFN');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (34, 'ahunt', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'WT0VEP3YTOGBTBLT');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (35, 'cynthiamay', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'HOZ2VCN3LC86PWQA');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (36, 'matthewpatterson', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'W2VFAL7LJGQH65VE');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (37, 'stacy91', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'A1GZDSI9IKOIYJWL');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (38, 'wilkinsmark', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '7HAZHKVNKD0SUBVQ');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (39, 'summer53', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'HXHW9RHUAGOI1MQU');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (40, 'bryan81', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '2G38MTZEXRODR4LK');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (41, 'vegamary', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', '0L134YKXXPNLAMBL');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (42, 'martinemily', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'C6GNP82XB9I0MUXG');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (43, 'lisahernandez', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'MBWD6CVUX53J3GHF');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (44, 'ashleystephenson', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'DXL6CHYQMWEEADGA');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (45, 'samantha75', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'AJBXC6LHCZXJLSL0');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (46, 'cameron21', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'admin', 'MFOQP0J1FNNUHCAT');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (47, 'moralesryan', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'QOZNJO7IJOFXU7KW');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (48, 'gutierrezbrian', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'Q272L7V1WGEYZ6U0');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (49, 'michael22', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', 'STYYGWTW26MQUK5F');
INSERT INTO Users (user_id, username, password_hash, role, hash_key) VALUES (50, 'byrdjennifer', '008c70392e3abfbd0fa47bbc2ed96aa99bd49e159727fcba0f2e6abeb3a9d601', 'trader', '8IEUJ4KOTQA54MZE');

-- PRODUCTS
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (1, 'Single Widget', 'Specific writer foreign national draw run kind before return people woman foreign.', 14.89, 14.02, 96.62);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (2, 'Production Thing', 'Become threat country edge sure direction glass word one hour find.', 2.69, 6.36, 44.19);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (3, 'Project Item', 'Left decade your foot dinner raise young detail.', 16.88, 16.13, 77.23);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (4, 'Keep Widget', 'Manager some test laugh worry people guy see.', 18.4, 8.55, 92.15);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (5, 'Thing Widget', 'Military prepare meet our really one surface cell parent important meet.', 3.09, 18.57, 63.6);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (6, 'Resource Thing', 'North wish may realize person majority ahead.', 4.66, 3.34, 96.01);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (7, 'Able Thing', 'Itself also probably pressure project amount focus food become.', 7.6, 12.01, 55.83);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (8, 'News Widget', 'Look among sister surface third once whom second whose common.', 5.2, 12.33, 94.64);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (9, 'Major Item', 'Instead court small recently if well ability public ten.', 8.47, 14.35, 19.07);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (10, 'Specific Item', 'Hard industry society admit color mean senior Mrs wrong there walk reach.', 2.86, 15.69, 20.32);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (11, 'Attention Widget', 'Story mission lead join one anyone school performance likely.', 1.74, 2.63, 36.13);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (12, 'Beyond Widget', 'Wind stay get law reveal number happen win someone cut office they evening.', 14.6, 11.93, 51.74);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (13, 'Skill Widget', 'Trouble perhaps possible dark charge eat meet real state.', 14.07, 4.8, 27.52);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (14, 'All Thing', 'Cell employee recent set too well benefit group.', 10.03, 6.71, 13.23);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (15, 'My Thing', 'Upon for defense fight there subject against or recently media.', 11.14, 16.3, 57.17);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (16, 'Stay Gadget', 'Perhaps health series vote hour lot box Congress.', 4.54, 5.83, 35.22);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (17, 'Decade Gadget', 'Class everyone religious inside significant perform.', 5.4, 17.04, 23.14);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (18, 'Throw Thing', 'Huge into nothing figure agree keep mouth movement community thought for early.', 3.59, 3.46, 34.06);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (19, 'Actually Thing', 'Employee worry movie outside book mean never national summer television.', 12.34, 8.81, 15.66);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (20, 'Citizen Gadget', 'Must smile meeting last probably late police course data idea.', 18.3, 18.7, 33.64);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (21, 'Sport Thing', 'Page just agree why laugh close most under not poor.', 8.13, 11.56, 56.29);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (22, 'Save Thing', 'Especially benefit high themselves economy build apply add station nice staff exist pay learn.', 6.45, 8.59, 69.28);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (23, 'Least Thing', 'Scene table picture surface nature but adult surface wish any save compare.', 2.46, 13.45, 93.75);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (24, 'Mention Item', 'Simply glass including defense seek worker produce.', 5.42, 18.54, 40.47);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (25, 'Figure Thing', 'Campaign ask cause sing girl front recent art certainly floor establish consider.', 14.73, 16.6, 90.44);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (26, 'Win Thing', 'Head do dream above prove test often.', 3.56, 16.37, 56.79);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (27, 'Want Widget', 'Environment usually reveal view set back his.', 3.84, 1.18, 60.93);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (28, 'Individual Item', 'Line worker wife project skill adult institution enter skin early outside.', 9.57, 1.5, 18.32);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (29, 'Part Thing', 'South result management director factor subject.', 9.08, 5.77, 13.25);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (30, 'Walk Item', 'Consider foot show expert media population all site above player material ago.', 10.6, 4.69, 76.92);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (31, 'Fact Item', 'Never follow management as total simply fine.', 14.13, 8.96, 23.02);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (32, 'Then Item', 'Hear mention consider six single knowledge foot water plan customer five push although.', 13.97, 8.55, 49.63);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (33, 'Better Widget', 'Interview born evening parent issue word understand race away popular body they grow.', 7.18, 12.49, 23.75);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (34, 'Artist Thing', 'Various fact explain investment pass a yourself control.', 15.88, 13.17, 13.38);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (35, 'Environmental Thing', 'Check benefit enter how wrong focus audience.', 18.14, 6.06, 97.15);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (36, 'Game Gadget', 'Agent career will full edge my.', 16.59, 5.11, 12.89);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (37, 'Executive Widget', 'Detail leader event image eight technology.', 13.19, 18.23, 14.51);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (38, 'Parent Thing', 'Question shoulder gas suddenly rise skin at dinner at why various protect.', 16.68, 15.35, 86.15);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (39, 'Student Thing', 'Yourself to under able environment include leg role experience also worry those fund.', 12.62, 19.45, 62.83);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (40, 'Say Item', 'Garden resource cup protect once forward them research.', 1.19, 2.56, 28.47);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (41, 'Vote Thing', 'Institution country live spring knowledge to next store any activity.', 19.84, 1.41, 99.62);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (42, 'Only Widget', 'Guy paper whole might analysis exactly standard coach card guy score there tough.', 16.83, 6.3, 15.08);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (43, 'Scene Thing', 'How follow change place usually adult fact.', 7.93, 19.77, 37.2);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (44, 'Commercial Item', 'Spend method general but but another benefit.', 14.0, 13.45, 67.17);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (45, 'Land Item', 'Actually field general beat go trade increase mission not maybe forget.', 6.45, 15.78, 12.97);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (46, 'Wrong Widget', 'Walk other rock attorney order glass method class race.', 16.86, 9.34, 38.73);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (47, 'Your Gadget', 'Must represent record themselves environment drive charge work benefit simple market.', 14.46, 7.08, 98.97);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (48, 'Remain Thing', 'Rock trouble lead seem also get note poor already current.', 14.51, 4.26, 61.34);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (49, 'Big Widget', 'Culture reason manager authority often whatever team there form throw across raise.', 6.39, 12.46, 21.55);
INSERT INTO Products (product_id, product_name, description, cost_c_prime, cost_c_double_prime, base_value) VALUES (50, 'Market Widget', 'Return car us sister rock during school walk back research space score.', 10.49, 9.57, 72.29);

-- POSTS
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (1, 31, 45, 30, 30, 1.67, 4.8, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (2, 7, 24, 26, 19, 2.57, 1.44, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (3, 46, 7, 2, 14, 3.06, 1.52, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (4, 13, 1, 48, 27, 3.81, 4.25, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (5, 11, 20, 18, 21, 2.27, 1.45, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (6, 41, 23, 42, 20, 1.27, 1.99, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (7, 34, 7, 24, 43, 2.13, 2.69, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (8, 18, 38, 38, 20, 3.36, 4.77, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (9, 43, 13, 24, 8, 2.01, 1.36, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (10, 50, 12, 49, 13, 3.45, 1.56, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (11, 42, 13, 23, 19, 4.39, 2.68, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (12, 27, 38, 41, 37, 4.53, 2.62, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (13, 25, 10, 33, 40, 4.57, 1.74, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (14, 31, 35, 15, 25, 4.6, 3.3, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (15, 43, 46, 13, 25, 2.15, 2.74, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (16, 18, 2, 22, 37, 4.42, 1.14, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (17, 7, 39, 26, 21, 1.67, 3.72, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (18, 17, 42, 23, 17, 3.86, 3.13, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (19, 41, 15, 12, 28, 3.77, 3.84, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (20, 23, 10, 36, 28, 3.04, 4.16, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (21, 16, 35, 10, 41, 3.37, 2.98, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (22, 1, 50, 1, 13, 3.9, 3.96, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (23, 32, 38, 20, 17, 4.46, 4.65, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (24, 29, 43, 36, 19, 2.87, 2.22, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (25, 41, 34, 25, 42, 4.17, 2.57, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (26, 30, 3, 21, 28, 1.06, 3.02, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (27, 27, 42, 50, 39, 4.43, 2.65, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (28, 12, 28, 4, 16, 1.4, 4.77, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (29, 38, 46, 46, 50, 2.02, 1.22, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (30, 1, 14, 1, 33, 3.43, 1.79, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (31, 16, 46, 14, 7, 2.74, 1.87, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (32, 13, 15, 38, 34, 2.88, 3.9, 1, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (33, 17, 15, 9, 38, 4.36, 4.28, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (34, 22, 6, 8, 35, 2.51, 4.59, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (35, 30, 41, 3, 38, 1.73, 3.48, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (36, 18, 6, 31, 19, 2.93, 2.64, 0, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (37, 13, 49, 40, 5, 4.84, 1.23, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (38, 7, 26, 13, 3, 3.46, 3.51, 0, 0);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (39, 11, 12, 50, 44, 1.34, 1.15, 1, 1);
INSERT INTO Posts (post_id, user_id, partner_id, product_offered, product_requested, amount_offered, amount_requested, willing_to_split, is_fulfilled) VALUES (40, 19, 44, 26, 7, 4.29, 4.95, 1, 0);

-- TRANSACTIONS
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (1, 47, 8, 21, 39, 34, 38, 33, 31, 4.37, 3.02, 6.69, 1.38, 'MNO4OT4LIU4XU9CJ', 1, 1, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (2, 2, 18, 29, 11, 29, 12, 47, 42, 1.94, 1.68, 4.75, 5.59, 'I8QNME34NUCVEZGK', 0, 0, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (3, 9, 24, 6, 14, 2, 4, 4, 28, 4.93, 3.31, 2.53, 9.25, 'OVHGIWV6QMCBM7YC', 1, 0, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (4, 22, 18, 45, 1, 1, 2, 18, 14, 2.92, 1.64, 5.19, 1.27, 'Z52Z7MK3TTY4SX6M', 1, 0, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (5, 8, 16, 17, 4, 26, 7, 38, 48, 1.39, 3.46, 8.82, 1.57, 'B77RCNDFCA7X4NZ1', 1, 1, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (6, 34, 8, 48, 12, 6, 26, 13, 5, 2.84, 3.49, 4.98, 2.85, 'PJW3ZU49VITBIWWQ', 0, 0, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (7, 45, 43, 16, 10, 32, 25, 44, 22, 4.37, 1.76, 3.78, 3.74, '7T9EUILEZEGXUFTW', 0, 0, 'cancelled');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (8, 46, 19, 7, 5, 31, 7, 26, 12, 3.32, 2.81, 9.65, 1.26, '5VDROC0SSQLV8TXA', 1, 0, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (9, 37, 1, 45, 40, 31, 33, 41, 29, 3.23, 4.33, 2.98, 5.18, 'OLS57RI6FFXA5AI2', 1, 1, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (10, 1, 5, 7, 46, 22, 40, 18, 9, 2.5, 1.66, 5.4, 4.65, '1U5T35EKJS0VERU3', 0, 0, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (11, 48, 5, 12, 6, 18, 19, 12, 7, 2.49, 3.08, 4.85, 9.06, 'SIQVZ9LEO4NSI1PY', 0, 1, 'complete');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (12, 1, 2, 29, 31, 22, 8, 36, 28, 2.17, 1.8, 8.97, 7.63, '29BKNVUGPKCEKNEN', 0, 1, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (13, 12, 47, 33, 12, 18, 7, 32, 32, 1.44, 2.98, 2.95, 5.9, 'JDUAB6MUR4AL483O', 0, 0, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (14, 31, 50, 19, 44, 26, 40, 30, 8, 2.11, 2.47, 2.88, 4.07, 'CGE5J3LG7SYSWULA', 1, 1, 'pending');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (15, 13, 2, 27, 14, 5, 35, 30, 45, 4.08, 2.81, 6.31, 1.26, 'HS2C60ORZ58A7NZV', 1, 0, 'cancelled');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (16, 50, 7, 23, 39, 32, 18, 4, 22, 3.24, 4.05, 7.12, 1.73, '4JX7URB8SARQZR07', 0, 0, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (17, 40, 40, 18, 20, 4, 26, 45, 7, 2.92, 2.44, 8.23, 6.62, '1MBPTBSQFA7SQSLV', 0, 1, 'validated');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (18, 1, 21, 24, 24, 40, 30, 44, 24, 2.97, 1.35, 8.13, 4.84, 'VGQTTO91HN71J47B', 1, 1, 'complete');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (19, 27, 19, 33, 11, 22, 35, 35, 49, 5.0, 2.82, 5.68, 6.63, 'BMLNVPC3WWWI9FBG', 0, 1, 'cancelled');
INSERT INTO Transactions (transaction_id, a_id, b_id, x_id, y_id, post_a_id, post_x_id, p_product_id, e_product_id, amount_p, amount_e, cost_c_prime, cost_c_double_prime, hash_code, a_half_sent, y_half_sent, transaction_status) VALUES (20, 2, 2, 32, 19, 10, 27, 1, 44, 3.85, 2.08, 3.77, 5.08, 'JSETSR58Q8HMB3B9', 1, 1, 'complete');

-- PRODUCT SUBMISSIONS
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (1, 11, 'Technology Thingamajig', 'Performance despite watch family no yeah rise east window data management consider.', 15.1, 'Charge player physical we center floor amount join successful its four least scientist choose performance.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (2, 29, 'Per Tool', 'Sort else specific community leg enough mind enter.', 48.07, 'How poor camera travel age writer lay plant day direction section kid nature experience mother generation.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (3, 7, 'Quickly Thingamajig', 'Suggest suffer pick nation appear off action there.', 70.3, 'A between far finish write gun specific instead school per society middle seven everybody success Mr.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (4, 30, 'Big Thingamajig', 'Drug wonder opportunity line knowledge hair guess I beat ball air.', 47.34, 'There say open leg painting condition important individual middle ten woman.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (5, 36, 'Figure Thingamajig', 'Popular institution dream like collection factor threat feeling meeting everybody gun main tend.', 51.34, 'Such state research account war pressure become.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (6, 13, 'Glass Device', 'Rate television material travel product drive opportunity machine decision energy direction loss.', 58.56, 'Receive position make parent within stage remain country book coach hard boy economic cost.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (7, 12, 'Cause Thingamajig', 'Of apply window project all mention add view leave old particular dark.', 24.14, 'Piece like study like wrong for identify.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (8, 33, 'Can Tool', 'Garden green long room rich stay trouble part ability choice wonder.', 73.06, 'Apply perhaps see national sort dream security table.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (9, 1, 'Article Tool', 'Administration wrong certain late everything after room.', 90.02, 'Foot study all career staff religious including with make.');
INSERT INTO Product_Submissions (submission_id, user_id, product_name, description, suggested_value, reason) VALUES (10, 6, 'Small Device', 'Dream read she ball wait then owner its now box.', 99.01, 'Various former outside after stuff new accept almost rule mention suggest during modern water.');
