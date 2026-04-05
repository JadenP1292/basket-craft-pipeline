-- Basket Craft Sample Data
-- Simulates 6 months of e-commerce orders for dashboard testing

USE basket_craft;

-- Insert Categories (Product lines for a craft/home goods store)
INSERT INTO categories (category_name, description) VALUES
('Woven Baskets', 'Handwoven baskets for storage and decoration'),
('Storage Solutions', 'Organizational bins, boxes, and containers'),
('Home Decor', 'Decorative items for home styling'),
('Kitchen & Dining', 'Handcrafted kitchen accessories and serveware'),
('Garden & Outdoor', 'Planters, outdoor storage, and garden accessories'),
('Gift Sets', 'Curated gift collections and bundles');

-- Insert Products
INSERT INTO products (product_name, category_id, unit_price, cost_price) VALUES
-- Woven Baskets (category_id = 1)
('Large Seagrass Storage Basket', 1, 45.99, 18.00),
('Medium Wicker Laundry Hamper', 1, 65.00, 25.00),
('Small Rattan Decorative Basket', 1, 28.50, 11.00),
('Bamboo Bread Basket', 1, 22.00, 8.50),
('Cotton Rope Basket Set (3pc)', 1, 55.00, 22.00),

-- Storage Solutions (category_id = 2)
('Fabric Storage Cube - Gray', 2, 18.99, 7.50),
('Wooden Crate Organizer', 2, 34.00, 13.00),
('Woven Shelf Basket', 2, 24.50, 9.50),
('Closet Storage Box Set', 2, 42.00, 16.00),
('Under-bed Storage Container', 2, 38.00, 15.00),

-- Home Decor (category_id = 3)
('Macrame Wall Hanging - Large', 3, 78.00, 30.00),
('Ceramic Vase Collection', 3, 52.00, 20.00),
('Woven Table Runner', 3, 35.00, 14.00),
('Decorative Throw Pillow Set', 3, 48.00, 18.00),
('Natural Wood Frame - 8x10', 3, 29.00, 11.00),

-- Kitchen & Dining (category_id = 4)
('Bamboo Serving Tray', 4, 32.00, 12.00),
('Woven Placemats (Set of 4)', 4, 28.00, 10.00),
('Wooden Utensil Holder', 4, 24.00, 9.00),
('Natural Fiber Coasters (6pc)', 4, 18.00, 7.00),
('Handwoven Fruit Bowl', 4, 42.00, 16.00),

-- Garden & Outdoor (category_id = 5)
('Woven Plant Basket - Large', 5, 36.00, 14.00),
('Seagrass Planter Set', 5, 58.00, 23.00),
('Outdoor Storage Basket', 5, 48.00, 19.00),
('Garden Tool Caddy', 5, 32.00, 12.00),
('Hanging Planter Basket', 5, 26.00, 10.00),

-- Gift Sets (category_id = 6)
('Home Starter Gift Box', 6, 89.00, 35.00),
('Kitchen Essentials Bundle', 6, 75.00, 30.00),
('Spa & Relaxation Set', 6, 62.00, 24.00),
('New Home Gift Basket', 6, 110.00, 42.00),
('Hostess Gift Collection', 6, 55.00, 22.00);

-- Insert Customers (100 sample customers)
INSERT INTO customers (first_name, last_name, email, city, state) VALUES
('Emma', 'Johnson', 'emma.j@email.com', 'Austin', 'TX'),
('Liam', 'Williams', 'liam.w@email.com', 'Portland', 'OR'),
('Olivia', 'Brown', 'olivia.b@email.com', 'Denver', 'CO'),
('Noah', 'Jones', 'noah.j@email.com', 'Seattle', 'WA'),
('Ava', 'Garcia', 'ava.g@email.com', 'Phoenix', 'AZ'),
('Ethan', 'Miller', 'ethan.m@email.com', 'San Diego', 'CA'),
('Sophia', 'Davis', 'sophia.d@email.com', 'Nashville', 'TN'),
('Mason', 'Rodriguez', 'mason.r@email.com', 'Chicago', 'IL'),
('Isabella', 'Martinez', 'isabella.m@email.com', 'Miami', 'FL'),
('William', 'Hernandez', 'william.h@email.com', 'Atlanta', 'GA'),
('Mia', 'Lopez', 'mia.l@email.com', 'Boston', 'MA'),
('James', 'Gonzalez', 'james.g@email.com', 'Dallas', 'TX'),
('Charlotte', 'Wilson', 'charlotte.w@email.com', 'Minneapolis', 'MN'),
('Benjamin', 'Anderson', 'benjamin.a@email.com', 'San Francisco', 'CA'),
('Amelia', 'Thomas', 'amelia.t@email.com', 'Philadelphia', 'PA'),
('Lucas', 'Taylor', 'lucas.t@email.com', 'Charlotte', 'NC'),
('Harper', 'Moore', 'harper.m@email.com', 'Detroit', 'MI'),
('Henry', 'Jackson', 'henry.j@email.com', 'Columbus', 'OH'),
('Evelyn', 'Martin', 'evelyn.m@email.com', 'Indianapolis', 'IN'),
('Alexander', 'Lee', 'alexander.l@email.com', 'San Jose', 'CA'),
('Abigail', 'Perez', 'abigail.p@email.com', 'Jacksonville', 'FL'),
('Daniel', 'Thompson', 'daniel.t@email.com', 'Fort Worth', 'TX'),
('Emily', 'White', 'emily.w@email.com', 'Oklahoma City', 'OK'),
('Michael', 'Harris', 'michael.h@email.com', 'Las Vegas', 'NV'),
('Elizabeth', 'Sanchez', 'elizabeth.s@email.com', 'Louisville', 'KY'),
('Sebastian', 'Clark', 'sebastian.c@email.com', 'Milwaukee', 'WI'),
('Avery', 'Ramirez', 'avery.r@email.com', 'Albuquerque', 'NM'),
('Matthew', 'Lewis', 'matthew.l@email.com', 'Tucson', 'AZ'),
('Sofia', 'Robinson', 'sofia.r@email.com', 'Fresno', 'CA'),
('Joseph', 'Walker', 'joseph.w@email.com', 'Sacramento', 'CA'),
('Ella', 'Young', 'ella.y@email.com', 'Kansas City', 'MO'),
('David', 'Allen', 'david.a@email.com', 'Mesa', 'AZ'),
('Scarlett', 'King', 'scarlett.k@email.com', 'Omaha', 'NE'),
('Jackson', 'Wright', 'jackson.w@email.com', 'Colorado Springs', 'CO'),
('Victoria', 'Scott', 'victoria.s@email.com', 'Raleigh', 'NC'),
('Samuel', 'Torres', 'samuel.t@email.com', 'Long Beach', 'CA'),
('Madison', 'Nguyen', 'madison.n@email.com', 'Virginia Beach', 'VA'),
('Owen', 'Hill', 'owen.h@email.com', 'Oakland', 'CA'),
('Luna', 'Flores', 'luna.f@email.com', 'Tulsa', 'OK'),
('Jack', 'Green', 'jack.g@email.com', 'Arlington', 'TX'),
('Chloe', 'Adams', 'chloe.a@email.com', 'Tampa', 'FL'),
('Aiden', 'Nelson', 'aiden.n@email.com', 'New Orleans', 'LA'),
('Penelope', 'Baker', 'penelope.b@email.com', 'Honolulu', 'HI'),
('Luke', 'Hall', 'luke.h@email.com', 'Wichita', 'KS'),
('Layla', 'Rivera', 'layla.r@email.com', 'Aurora', 'CO'),
('John', 'Campbell', 'john.c@email.com', 'Cleveland', 'OH'),
('Riley', 'Mitchell', 'riley.m@email.com', 'Anaheim', 'CA'),
('Gabriel', 'Carter', 'gabriel.c@email.com', 'Lexington', 'KY'),
('Zoey', 'Roberts', 'zoey.r@email.com', 'Stockton', 'CA'),
('Julian', 'Gomez', 'julian.g@email.com', 'Pittsburgh', 'PA');

-- Generate Orders for October 2024 - March 2025 (6 months of data)
-- This creates realistic order patterns with seasonal variation

-- October 2024 Orders (Fall season - moderate sales)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(1, '2024-10-02', 'completed'), (5, '2024-10-03', 'completed'), (12, '2024-10-05', 'completed'),
(8, '2024-10-07', 'completed'), (15, '2024-10-08', 'completed'), (3, '2024-10-10', 'completed'),
(22, '2024-10-11', 'completed'), (17, '2024-10-12', 'completed'), (30, '2024-10-14', 'completed'),
(9, '2024-10-15', 'completed'), (25, '2024-10-16', 'completed'), (41, '2024-10-18', 'completed'),
(6, '2024-10-19', 'completed'), (33, '2024-10-21', 'completed'), (19, '2024-10-22', 'completed'),
(45, '2024-10-24', 'completed'), (11, '2024-10-25', 'completed'), (28, '2024-10-26', 'completed'),
(37, '2024-10-28', 'completed'), (4, '2024-10-29', 'completed'), (48, '2024-10-30', 'completed'),
(14, '2024-10-31', 'completed');

-- November 2024 Orders (Holiday prep - increased sales)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(2, '2024-11-01', 'completed'), (16, '2024-11-02', 'completed'), (29, '2024-11-03', 'completed'),
(7, '2024-11-04', 'completed'), (35, '2024-11-05', 'completed'), (21, '2024-11-06', 'completed'),
(43, '2024-11-07', 'completed'), (10, '2024-11-08', 'completed'), (26, '2024-11-09', 'completed'),
(38, '2024-11-10', 'completed'), (1, '2024-11-11', 'completed'), (18, '2024-11-12', 'completed'),
(32, '2024-11-13', 'completed'), (46, '2024-11-14', 'completed'), (13, '2024-11-15', 'completed'),
(27, '2024-11-16', 'completed'), (40, '2024-11-17', 'completed'), (5, '2024-11-18', 'completed'),
(23, '2024-11-19', 'completed'), (36, '2024-11-20', 'completed'), (49, '2024-11-21', 'completed'),
(8, '2024-11-22', 'completed'), (31, '2024-11-23', 'completed'), (44, '2024-11-24', 'completed'),
(15, '2024-11-25', 'completed'), (24, '2024-11-26', 'completed'), (39, '2024-11-27', 'completed'),
(3, '2024-11-28', 'completed'), (20, '2024-11-29', 'completed'), (47, '2024-11-30', 'completed');

-- December 2024 Orders (Peak holiday season - highest sales)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(6, '2024-12-01', 'completed'), (19, '2024-12-01', 'completed'), (34, '2024-12-02', 'completed'),
(42, '2024-12-02', 'completed'), (11, '2024-12-03', 'completed'), (25, '2024-12-03', 'completed'),
(50, '2024-12-04', 'completed'), (2, '2024-12-04', 'completed'), (17, '2024-12-05', 'completed'),
(28, '2024-12-05', 'completed'), (37, '2024-12-06', 'completed'), (9, '2024-12-06', 'completed'),
(22, '2024-12-07', 'completed'), (45, '2024-12-07', 'completed'), (4, '2024-12-08', 'completed'),
(14, '2024-12-08', 'completed'), (33, '2024-12-09', 'completed'), (48, '2024-12-09', 'completed'),
(7, '2024-12-10', 'completed'), (21, '2024-12-10', 'completed'), (38, '2024-12-11', 'completed'),
(1, '2024-12-11', 'completed'), (16, '2024-12-12', 'completed'), (30, '2024-12-12', 'completed'),
(43, '2024-12-13', 'completed'), (10, '2024-12-13', 'completed'), (26, '2024-12-14', 'completed'),
(35, '2024-12-14', 'completed'), (5, '2024-12-15', 'completed'), (18, '2024-12-15', 'completed'),
(41, '2024-12-16', 'completed'), (12, '2024-12-16', 'completed'), (29, '2024-12-17', 'completed'),
(46, '2024-12-17', 'completed'), (3, '2024-12-18', 'completed'), (23, '2024-12-18', 'completed'),
(36, '2024-12-19', 'completed'), (49, '2024-12-19', 'completed'), (8, '2024-12-20', 'completed'),
(27, '2024-12-20', 'completed'), (40, '2024-12-21', 'completed'), (13, '2024-12-21', 'completed'),
(31, '2024-12-22', 'completed'), (44, '2024-12-22', 'completed'), (15, '2024-12-23', 'completed');

-- January 2025 Orders (Post-holiday - lower sales)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(20, '2025-01-02', 'completed'), (39, '2025-01-04', 'completed'), (6, '2025-01-06', 'completed'),
(24, '2025-01-08', 'completed'), (47, '2025-01-10', 'completed'), (11, '2025-01-12', 'completed'),
(32, '2025-01-14', 'completed'), (2, '2025-01-16', 'completed'), (19, '2025-01-18', 'completed'),
(42, '2025-01-20', 'completed'), (9, '2025-01-22', 'completed'), (28, '2025-01-24', 'completed'),
(50, '2025-01-26', 'completed'), (14, '2025-01-28', 'completed'), (37, '2025-01-30', 'completed');

-- February 2025 Orders (Valentine's boost)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(4, '2025-02-01', 'completed'), (17, '2025-02-03', 'completed'), (33, '2025-02-05', 'completed'),
(48, '2025-02-07', 'completed'), (7, '2025-02-09', 'completed'), (22, '2025-02-10', 'completed'),
(38, '2025-02-11', 'completed'), (1, '2025-02-12', 'completed'), (16, '2025-02-13', 'completed'),
(30, '2025-02-14', 'completed'), (43, '2025-02-14', 'completed'), (10, '2025-02-15', 'completed'),
(26, '2025-02-17', 'completed'), (35, '2025-02-19', 'completed'), (5, '2025-02-21', 'completed'),
(21, '2025-02-23', 'completed'), (41, '2025-02-25', 'completed'), (12, '2025-02-27', 'completed');

-- March 2025 Orders (Spring refresh)
INSERT INTO orders (customer_id, order_date, order_status) VALUES
(29, '2025-03-01', 'completed'), (46, '2025-03-03', 'completed'), (3, '2025-03-05', 'completed'),
(18, '2025-03-07', 'completed'), (36, '2025-03-09', 'completed'), (49, '2025-03-11', 'completed'),
(8, '2025-03-13', 'completed'), (23, '2025-03-15', 'completed'), (40, '2025-03-17', 'completed'),
(13, '2025-03-19', 'completed'), (31, '2025-03-21', 'completed'), (44, '2025-03-23', 'completed'),
(15, '2025-03-25', 'completed'), (27, '2025-03-27', 'completed'), (6, '2025-03-29', 'completed'),
(34, '2025-03-30', 'completed'), (45, '2025-03-31', 'completed');

-- Generate Order Items (multiple items per order, variety of products)
-- October 2024 items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 2, 45.99, 91.98), (1, 13, 1, 35.00, 35.00),
(2, 6, 3, 18.99, 56.97), (2, 19, 1, 18.00, 18.00),
(3, 11, 1, 78.00, 78.00), (3, 14, 2, 48.00, 96.00),
(4, 26, 1, 89.00, 89.00),
(5, 2, 1, 65.00, 65.00), (5, 8, 2, 24.50, 49.00),
(6, 16, 1, 32.00, 32.00), (6, 17, 2, 28.00, 56.00),
(7, 21, 2, 36.00, 72.00), (7, 25, 1, 26.00, 26.00),
(8, 5, 1, 55.00, 55.00), (8, 12, 1, 52.00, 52.00),
(9, 27, 1, 75.00, 75.00),
(10, 3, 3, 28.50, 85.50), (10, 7, 1, 34.00, 34.00),
(11, 18, 2, 24.00, 48.00), (11, 20, 1, 42.00, 42.00),
(12, 29, 1, 110.00, 110.00),
(13, 4, 2, 22.00, 44.00), (13, 15, 1, 29.00, 29.00),
(14, 9, 1, 42.00, 42.00), (14, 22, 1, 58.00, 58.00),
(15, 28, 1, 62.00, 62.00),
(16, 10, 2, 38.00, 76.00), (16, 23, 1, 48.00, 48.00),
(17, 1, 1, 45.99, 45.99), (17, 24, 1, 32.00, 32.00),
(18, 30, 1, 55.00, 55.00),
(19, 6, 4, 18.99, 75.96), (19, 11, 1, 78.00, 78.00),
(20, 2, 1, 65.00, 65.00), (20, 16, 1, 32.00, 32.00),
(21, 26, 1, 89.00, 89.00), (21, 17, 1, 28.00, 28.00),
(22, 5, 1, 55.00, 55.00), (22, 21, 2, 36.00, 72.00);

-- November 2024 items (more gift sets for holidays)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(23, 26, 2, 89.00, 178.00), (23, 30, 1, 55.00, 55.00),
(24, 11, 1, 78.00, 78.00), (24, 14, 1, 48.00, 48.00),
(25, 27, 1, 75.00, 75.00), (25, 28, 1, 62.00, 62.00),
(26, 1, 2, 45.99, 91.98), (26, 3, 2, 28.50, 57.00),
(27, 29, 1, 110.00, 110.00), (27, 12, 1, 52.00, 52.00),
(28, 16, 2, 32.00, 64.00), (28, 17, 2, 28.00, 56.00),
(29, 26, 1, 89.00, 89.00),
(30, 5, 1, 55.00, 55.00), (30, 8, 2, 24.50, 49.00),
(31, 30, 2, 55.00, 110.00),
(32, 2, 1, 65.00, 65.00), (32, 21, 1, 36.00, 36.00),
(33, 27, 1, 75.00, 75.00), (33, 19, 2, 18.00, 36.00),
(34, 29, 1, 110.00, 110.00),
(35, 11, 1, 78.00, 78.00), (35, 13, 2, 35.00, 70.00),
(36, 26, 1, 89.00, 89.00), (36, 28, 1, 62.00, 62.00),
(37, 6, 5, 18.99, 94.95),
(38, 1, 1, 45.99, 45.99), (38, 4, 2, 22.00, 44.00),
(39, 30, 1, 55.00, 55.00), (39, 15, 2, 29.00, 58.00),
(40, 27, 2, 75.00, 150.00),
(41, 29, 1, 110.00, 110.00), (41, 20, 1, 42.00, 42.00),
(42, 26, 1, 89.00, 89.00),
(43, 2, 1, 65.00, 65.00), (43, 12, 1, 52.00, 52.00),
(44, 11, 1, 78.00, 78.00), (44, 22, 1, 58.00, 58.00),
(45, 28, 2, 62.00, 124.00),
(46, 5, 2, 55.00, 110.00), (46, 16, 1, 32.00, 32.00),
(47, 27, 1, 75.00, 75.00), (47, 30, 1, 55.00, 55.00),
(48, 29, 1, 110.00, 110.00), (48, 21, 2, 36.00, 72.00),
(49, 26, 2, 89.00, 178.00),
(50, 1, 1, 45.99, 45.99), (50, 3, 1, 28.50, 28.50),
(51, 11, 2, 78.00, 156.00), (51, 14, 1, 48.00, 48.00),
(52, 30, 1, 55.00, 55.00), (52, 28, 1, 62.00, 62.00);

-- December 2024 items (peak holiday - heavy on gift sets)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(53, 29, 2, 110.00, 220.00), (53, 26, 1, 89.00, 89.00),
(54, 27, 1, 75.00, 75.00), (54, 30, 2, 55.00, 110.00),
(55, 11, 1, 78.00, 78.00), (55, 12, 1, 52.00, 52.00),
(56, 28, 2, 62.00, 124.00),
(57, 26, 1, 89.00, 89.00), (57, 1, 2, 45.99, 91.98),
(58, 29, 1, 110.00, 110.00), (58, 5, 1, 55.00, 55.00),
(59, 27, 2, 75.00, 150.00), (59, 14, 1, 48.00, 48.00),
(60, 30, 1, 55.00, 55.00), (60, 28, 1, 62.00, 62.00),
(61, 2, 2, 65.00, 130.00), (61, 21, 1, 36.00, 36.00),
(62, 29, 1, 110.00, 110.00),
(63, 26, 2, 89.00, 178.00), (63, 11, 1, 78.00, 78.00),
(64, 27, 1, 75.00, 75.00), (64, 16, 2, 32.00, 64.00),
(65, 30, 2, 55.00, 110.00), (65, 3, 2, 28.50, 57.00),
(66, 28, 1, 62.00, 62.00), (66, 15, 1, 29.00, 29.00),
(67, 29, 1, 110.00, 110.00), (67, 12, 1, 52.00, 52.00),
(68, 26, 1, 89.00, 89.00), (68, 5, 1, 55.00, 55.00),
(69, 1, 3, 45.99, 137.97), (69, 4, 2, 22.00, 44.00),
(70, 27, 1, 75.00, 75.00), (70, 30, 1, 55.00, 55.00),
(71, 11, 2, 78.00, 156.00), (71, 14, 2, 48.00, 96.00),
(72, 29, 1, 110.00, 110.00),
(73, 28, 2, 62.00, 124.00), (73, 22, 1, 58.00, 58.00),
(74, 26, 1, 89.00, 89.00), (74, 2, 1, 65.00, 65.00),
(75, 27, 2, 75.00, 150.00),
(76, 30, 1, 55.00, 55.00), (76, 6, 3, 18.99, 56.97),
(77, 29, 2, 110.00, 220.00), (77, 11, 1, 78.00, 78.00),
(78, 26, 1, 89.00, 89.00), (78, 28, 1, 62.00, 62.00),
(79, 1, 2, 45.99, 91.98), (79, 8, 2, 24.50, 49.00),
(80, 27, 1, 75.00, 75.00), (80, 30, 1, 55.00, 55.00),
(81, 5, 2, 55.00, 110.00), (81, 21, 2, 36.00, 72.00),
(82, 29, 1, 110.00, 110.00), (82, 12, 1, 52.00, 52.00),
(83, 26, 2, 89.00, 178.00), (83, 14, 1, 48.00, 48.00),
(84, 28, 1, 62.00, 62.00), (84, 16, 2, 32.00, 64.00),
(85, 27, 1, 75.00, 75.00), (85, 3, 3, 28.50, 85.50),
(86, 11, 1, 78.00, 78.00), (86, 30, 2, 55.00, 110.00),
(87, 29, 1, 110.00, 110.00), (87, 26, 1, 89.00, 89.00),
(88, 2, 1, 65.00, 65.00), (88, 22, 1, 58.00, 58.00),
(89, 27, 2, 75.00, 150.00), (89, 28, 1, 62.00, 62.00),
(90, 30, 1, 55.00, 55.00), (90, 5, 1, 55.00, 55.00),
(91, 1, 2, 45.99, 91.98), (91, 6, 4, 18.99, 75.96),
(92, 29, 1, 110.00, 110.00),
(93, 26, 1, 89.00, 89.00), (93, 11, 1, 78.00, 78.00),
(94, 28, 2, 62.00, 124.00), (94, 12, 1, 52.00, 52.00),
(95, 27, 1, 75.00, 75.00), (95, 30, 1, 55.00, 55.00),
(96, 14, 2, 48.00, 96.00), (96, 21, 1, 36.00, 36.00),
(97, 29, 2, 110.00, 220.00);

-- January 2025 items (post-holiday - storage/organization focus)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(98, 6, 4, 18.99, 75.96), (98, 9, 2, 42.00, 84.00),
(99, 7, 2, 34.00, 68.00), (99, 10, 1, 38.00, 38.00),
(100, 2, 1, 65.00, 65.00), (100, 8, 3, 24.50, 73.50),
(101, 5, 2, 55.00, 110.00),
(102, 1, 1, 45.99, 45.99), (102, 6, 2, 18.99, 37.98),
(103, 9, 1, 42.00, 42.00), (103, 10, 2, 38.00, 76.00),
(104, 7, 1, 34.00, 34.00), (104, 3, 2, 28.50, 57.00),
(105, 8, 2, 24.50, 49.00), (105, 6, 3, 18.99, 56.97),
(106, 2, 1, 65.00, 65.00), (106, 5, 1, 55.00, 55.00),
(107, 10, 2, 38.00, 76.00),
(108, 1, 2, 45.99, 91.98), (108, 7, 1, 34.00, 34.00),
(109, 9, 1, 42.00, 42.00), (109, 8, 2, 24.50, 49.00),
(110, 6, 5, 18.99, 94.95),
(111, 3, 3, 28.50, 85.50), (111, 10, 1, 38.00, 38.00),
(112, 5, 1, 55.00, 55.00), (112, 2, 1, 65.00, 65.00);

-- February 2025 items (Valentine's - home decor & gift sets)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(113, 28, 2, 62.00, 124.00), (113, 14, 1, 48.00, 48.00),
(114, 11, 1, 78.00, 78.00), (114, 13, 2, 35.00, 70.00),
(115, 30, 2, 55.00, 110.00),
(116, 12, 1, 52.00, 52.00), (116, 15, 2, 29.00, 58.00),
(117, 26, 1, 89.00, 89.00), (117, 28, 1, 62.00, 62.00),
(118, 11, 2, 78.00, 156.00),
(119, 14, 2, 48.00, 96.00), (119, 30, 1, 55.00, 55.00),
(120, 27, 1, 75.00, 75.00), (120, 29, 1, 110.00, 110.00),
(121, 28, 1, 62.00, 62.00), (121, 12, 1, 52.00, 52.00),
(122, 26, 2, 89.00, 178.00),
(123, 30, 2, 55.00, 110.00), (123, 11, 1, 78.00, 78.00),
(124, 13, 3, 35.00, 105.00), (124, 14, 1, 48.00, 48.00),
(125, 28, 1, 62.00, 62.00), (125, 27, 1, 75.00, 75.00),
(126, 15, 2, 29.00, 58.00), (126, 12, 1, 52.00, 52.00),
(127, 11, 1, 78.00, 78.00), (127, 30, 1, 55.00, 55.00),
(128, 29, 1, 110.00, 110.00),
(129, 26, 1, 89.00, 89.00), (129, 14, 2, 48.00, 96.00),
(130, 1, 2, 45.99, 91.98), (130, 5, 1, 55.00, 55.00);

-- March 2025 items (Spring - garden & home refresh)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(131, 21, 3, 36.00, 108.00), (131, 22, 1, 58.00, 58.00),
(132, 25, 2, 26.00, 52.00), (132, 23, 1, 48.00, 48.00),
(133, 1, 2, 45.99, 91.98), (133, 21, 2, 36.00, 72.00),
(134, 24, 1, 32.00, 32.00), (134, 22, 1, 58.00, 58.00),
(135, 11, 1, 78.00, 78.00), (135, 25, 3, 26.00, 78.00),
(136, 21, 2, 36.00, 72.00), (136, 3, 2, 28.50, 57.00),
(137, 23, 1, 48.00, 48.00), (137, 13, 1, 35.00, 35.00),
(138, 22, 2, 58.00, 116.00),
(139, 25, 2, 26.00, 52.00), (139, 24, 2, 32.00, 64.00),
(140, 21, 1, 36.00, 36.00), (140, 14, 1, 48.00, 48.00),
(141, 1, 1, 45.99, 45.99), (141, 5, 1, 55.00, 55.00),
(142, 22, 1, 58.00, 58.00), (142, 23, 1, 48.00, 48.00),
(143, 25, 4, 26.00, 104.00),
(144, 21, 2, 36.00, 72.00), (144, 11, 1, 78.00, 78.00),
(145, 24, 1, 32.00, 32.00), (145, 3, 3, 28.50, 85.50),
(146, 22, 1, 58.00, 58.00), (146, 13, 2, 35.00, 70.00),
(147, 21, 3, 36.00, 108.00), (147, 25, 2, 26.00, 52.00);
