-- ============================================
-- Sample Data for Retail Medallion Database
-- ============================================

USE [RetailMedallion];
GO

-- =============================================
-- Sample Suppliers
-- =============================================
INSERT INTO Bronze.RawSuppliers (SourceSupplierID, SupplierName, ContactName, Email, Phone, Address, City, State, Country, PaymentTerms, SourceSystem)
VALUES
('SUP001', 'Global Electronics Inc', 'John Smith', 'john@globalelec.com', '555-0101', '123 Tech Blvd', 'San Jose', 'CA', 'USA', 'Net 30', 'ERP'),
('SUP002', 'Fashion Forward Ltd', 'Sarah Johnson', 'sarah@fashionfwd.com', '555-0102', '456 Style Ave', 'New York', 'NY', 'USA', 'Net 45', 'ERP'),
('SUP003', 'Home Essentials Co', 'Mike Wilson', 'mike@homeess.com', '555-0103', '789 Home St', 'Chicago', 'IL', 'USA', 'Net 30', 'ERP'),
('SUP004', 'Sports Unlimited', 'Lisa Brown', 'lisa@sportsunl.com', '555-0104', '321 Athletic Way', 'Denver', 'CO', 'USA', 'Net 60', 'ERP'),
('SUP005', 'Food & Beverage Direct', 'Tom Davis', 'tom@fbdirect.com', '555-0105', '654 Taste Rd', 'Atlanta', 'GA', 'USA', 'Net 15', 'ERP');

-- =============================================
-- Sample Stores
-- =============================================
INSERT INTO Bronze.RawStores (SourceStoreID, StoreName, StoreType, Address, City, State, ZipCode, Country, Phone, ManagerName, OpenDate, SquareFootage, SourceSystem)
VALUES
('STR001', 'Downtown Flagship', 'Flagship', '100 Main Street', 'New York', 'NY', '10001', 'USA', '212-555-0001', 'Robert Chen', '2015-03-15', '45000', 'POS'),
('STR002', 'Mall of America', 'Mall', '200 Mall Road', 'Bloomington', 'MN', '55425', 'USA', '952-555-0002', 'Jennifer Lee', '2016-08-20', '25000', 'POS'),
('STR003', 'Westfield Shopping Center', 'Mall', '300 West Ave', 'Los Angeles', 'CA', '90001', 'USA', '310-555-0003', 'Marcus Thompson', '2017-01-10', '30000', 'POS'),
('STR004', 'Suburban Express', 'Express', '400 Suburb Lane', 'Dallas', 'TX', '75001', 'USA', '214-555-0004', 'Amanda Garcia', '2018-05-25', '12000', 'POS'),
('STR005', 'Chicago Loop Store', 'Standard', '500 Michigan Ave', 'Chicago', 'IL', '60601', 'USA', '312-555-0005', 'David Kim', '2019-09-01', '20000', 'POS'),
('STR006', 'Seattle Pike Place', 'Boutique', '600 Pike St', 'Seattle', 'WA', '98101', 'USA', '206-555-0006', 'Emily Watson', '2020-02-14', '8000', 'POS'),
('STR007', 'Miami Beach Outlet', 'Outlet', '700 Ocean Drive', 'Miami', 'FL', '33139', 'USA', '305-555-0007', 'Carlos Rodriguez', '2020-11-20', '35000', 'POS'),
('STR008', 'Boston Harbor', 'Standard', '800 Harbor Way', 'Boston', 'MA', '02101', 'USA', '617-555-0008', 'Patricia Murphy', '2021-04-15', '18000', 'POS');

-- =============================================
-- Sample Products
-- =============================================
INSERT INTO Bronze.RawProducts (SourceProductID, ProductName, ProductDescription, Category, SubCategory, Brand, SKU, UPC, UnitPrice, CostPrice, Weight, SourceSystem)
VALUES
-- Electronics
('PRD001', 'Smart TV 55 inch 4K', '55 inch 4K Ultra HD Smart LED TV', 'Electronics', 'TVs', 'TechVision', 'TV-55-4K-001', '123456789001', '699.99', '450.00', '35.5', 'ERP'),
('PRD002', 'Wireless Bluetooth Headphones', 'Premium noise-canceling headphones', 'Electronics', 'Audio', 'SoundMax', 'HP-BT-NC-002', '123456789002', '249.99', '125.00', '0.5', 'ERP'),
('PRD003', 'Laptop Pro 15', '15 inch laptop with i7 processor', 'Electronics', 'Computers', 'TechPro', 'LP-15-I7-003', '123456789003', '1299.99', '850.00', '4.5', 'ERP'),
('PRD004', 'Smartphone X12', 'Latest smartphone with 5G', 'Electronics', 'Phones', 'MobileMax', 'SP-X12-5G-004', '123456789004', '999.99', '650.00', '0.4', 'ERP'),
('PRD005', 'Wireless Earbuds', 'True wireless earbuds with charging case', 'Electronics', 'Audio', 'SoundMax', 'EB-TW-005', '123456789005', '149.99', '60.00', '0.1', 'ERP'),
-- Fashion
('PRD006', 'Men Classic Polo Shirt', 'Cotton polo shirt - multiple colors', 'Fashion', 'Men Clothing', 'StyleCraft', 'MS-POLO-006', '123456789006', '49.99', '18.00', '0.3', 'ERP'),
('PRD007', 'Women Casual Dress', 'Summer casual dress', 'Fashion', 'Women Clothing', 'Elegance', 'WD-CAS-007', '123456789007', '79.99', '28.00', '0.4', 'ERP'),
('PRD008', 'Leather Wallet', 'Genuine leather bifold wallet', 'Fashion', 'Accessories', 'LeatherLux', 'AC-WAL-008', '123456789008', '59.99', '22.00', '0.2', 'ERP'),
('PRD009', 'Running Shoes Pro', 'Professional running shoes', 'Fashion', 'Footwear', 'SportStep', 'SH-RUN-009', '123456789009', '129.99', '55.00', '0.8', 'ERP'),
('PRD010', 'Designer Sunglasses', 'UV protection designer sunglasses', 'Fashion', 'Accessories', 'VisionStyle', 'AC-SUN-010', '123456789010', '189.99', '65.00', '0.1', 'ERP'),
-- Home
('PRD011', 'Coffee Maker Deluxe', '12-cup programmable coffee maker', 'Home', 'Kitchen', 'BrewMaster', 'KT-COF-011', '123456789011', '89.99', '42.00', '5.0', 'ERP'),
('PRD012', 'Air Purifier', 'HEPA air purifier for large rooms', 'Home', 'Appliances', 'CleanAir', 'AP-HEP-012', '123456789012', '199.99', '95.00', '12.0', 'ERP'),
('PRD013', 'Luxury Bedding Set', 'Queen size 1000 thread count sheets', 'Home', 'Bedding', 'DreamSleep', 'BD-QN-013', '123456789013', '149.99', '55.00', '3.0', 'ERP'),
('PRD014', 'Smart Thermostat', 'WiFi enabled smart thermostat', 'Home', 'Smart Home', 'HomeConnect', 'SH-THR-014', '123456789014', '179.99', '85.00', '0.8', 'ERP'),
('PRD015', 'Robot Vacuum', 'Smart robot vacuum with mapping', 'Home', 'Appliances', 'CleanBot', 'AP-RBV-015', '123456789015', '349.99', '180.00', '7.5', 'ERP'),
-- Sports
('PRD016', 'Yoga Mat Premium', 'Non-slip premium yoga mat', 'Sports', 'Fitness', 'FitLife', 'FT-YGM-016', '123456789016', '39.99', '12.00', '2.0', 'ERP'),
('PRD017', 'Dumbbell Set 50lb', 'Adjustable dumbbell set', 'Sports', 'Weights', 'IronStrong', 'WT-DBS-017', '123456789017', '299.99', '150.00', '50.0', 'ERP'),
('PRD018', 'Tennis Racket Pro', 'Professional tennis racket', 'Sports', 'Tennis', 'AceServe', 'TN-RKT-018', '123456789018', '179.99', '75.00', '0.7', 'ERP'),
('PRD019', 'Basketball Official', 'Official size basketball', 'Sports', 'Basketball', 'HoopStar', 'BB-OFF-019', '123456789019', '34.99', '14.00', '1.4', 'ERP'),
('PRD020', 'Fitness Tracker Watch', 'Advanced fitness tracker with GPS', 'Sports', 'Wearables', 'FitTrack', 'FT-GPS-020', '123456789020', '199.99', '85.00', '0.1', 'ERP'),
-- Food & Beverage
('PRD021', 'Organic Coffee Beans 2lb', 'Premium organic coffee beans', 'Food', 'Coffee', 'BeanBrew', 'CF-ORG-021', '123456789021', '24.99', '10.00', '2.0', 'ERP'),
('PRD022', 'Gourmet Chocolate Box', 'Assorted gourmet chocolates', 'Food', 'Confectionery', 'ChocoLux', 'CN-CHC-022', '123456789022', '34.99', '15.00', '1.0', 'ERP'),
('PRD023', 'Protein Powder 5lb', 'Whey protein powder', 'Food', 'Supplements', 'FitFuel', 'SP-PRO-023', '123456789023', '54.99', '25.00', '5.0', 'ERP'),
('PRD024', 'Green Tea Collection', 'Premium green tea variety pack', 'Food', 'Tea', 'TeaZen', 'TE-GRN-024', '123456789024', '19.99', '7.00', '0.5', 'ERP'),
('PRD025', 'Sparkling Water 24pk', 'Natural sparkling water', 'Food', 'Beverages', 'PureSpring', 'BV-SPK-025', '123456789025', '14.99', '6.00', '20.0', 'ERP');

-- =============================================
-- Sample Customers
-- =============================================
INSERT INTO Bronze.RawCustomers (SourceCustomerID, FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country, DateOfBirth, Gender, SourceSystem)
VALUES
('CUS001', 'James', 'Anderson', 'james.anderson@email.com', '555-1001', '123 Oak Street', 'New York', 'NY', '10001', 'USA', '1985-03-15', 'Male', 'CRM'),
('CUS002', 'Sarah', 'Williams', 'sarah.w@email.com', '555-1002', '456 Maple Ave', 'Los Angeles', 'CA', '90001', 'USA', '1990-07-22', 'Female', 'CRM'),
('CUS003', 'Michael', 'Brown', 'mbrown@email.com', '555-1003', '789 Pine Road', 'Chicago', 'IL', '60601', 'USA', '1978-11-08', 'Male', 'CRM'),
('CUS004', 'Emily', 'Davis', 'emily.davis@email.com', '555-1004', '321 Cedar Lane', 'Houston', 'TX', '77001', 'USA', '1992-05-30', 'Female', 'CRM'),
('CUS005', 'David', 'Miller', 'dmiller@email.com', '555-1005', '654 Birch Blvd', 'Phoenix', 'AZ', '85001', 'USA', '1988-09-12', 'Male', 'CRM'),
('CUS006', 'Jessica', 'Wilson', 'jwilson@email.com', '555-1006', '987 Elm Court', 'Philadelphia', 'PA', '19101', 'USA', '1995-01-25', 'Female', 'CRM'),
('CUS007', 'Christopher', 'Taylor', 'ctaylor@email.com', '555-1007', '147 Willow Way', 'San Antonio', 'TX', '78201', 'USA', '1982-06-18', 'Male', 'CRM'),
('CUS008', 'Amanda', 'Martinez', 'amartinez@email.com', '555-1008', '258 Ash Drive', 'San Diego', 'CA', '92101', 'USA', '1991-12-03', 'Female', 'CRM'),
('CUS009', 'Daniel', 'Garcia', 'dgarcia@email.com', '555-1009', '369 Spruce St', 'Dallas', 'TX', '75201', 'USA', '1987-04-28', 'Male', 'CRM'),
('CUS010', 'Michelle', 'Rodriguez', 'mrodriguez@email.com', '555-1010', '741 Redwood Pl', 'San Jose', 'CA', '95101', 'USA', '1993-08-14', 'Female', 'CRM'),
('CUS011', 'Matthew', 'Lee', 'mlee@email.com', '555-1011', '852 Sequoia Ave', 'Austin', 'TX', '78701', 'USA', '1980-02-09', 'Male', 'CRM'),
('CUS012', 'Ashley', 'Thompson', 'athompson@email.com', '555-1012', '963 Magnolia Rd', 'Jacksonville', 'FL', '32201', 'USA', '1994-10-21', 'Female', 'CRM'),
('CUS013', 'Joshua', 'White', 'jwhite@email.com', '555-1013', '159 Cypress Ln', 'Fort Worth', 'TX', '76101', 'USA', '1986-07-07', 'Male', 'CRM'),
('CUS014', 'Stephanie', 'Harris', 'sharris@email.com', '555-1014', '357 Palm Blvd', 'Columbus', 'OH', '43201', 'USA', '1989-03-19', 'Female', 'CRM'),
('CUS015', 'Andrew', 'Clark', 'aclark@email.com', '555-1015', '486 Hickory Dr', 'Charlotte', 'NC', '28201', 'USA', '1983-11-30', 'Male', 'CRM'),
('CUS016', 'Nicole', 'Lewis', 'nlewis@email.com', '555-1016', '624 Walnut St', 'Seattle', 'WA', '98101', 'USA', '1996-06-05', 'Female', 'CRM'),
('CUS017', 'Ryan', 'Robinson', 'rrobinson@email.com', '555-1017', '753 Chestnut Ave', 'Denver', 'CO', '80201', 'USA', '1984-09-26', 'Male', 'CRM'),
('CUS018', 'Lauren', 'Walker', 'lwalker@email.com', '555-1018', '891 Poplar Rd', 'Boston', 'MA', '02101', 'USA', '1997-01-12', 'Female', 'CRM'),
('CUS019', 'Kevin', 'Hall', 'khall@email.com', '555-1019', '234 Sycamore Ln', 'Nashville', 'TN', '37201', 'USA', '1981-05-08', 'Male', 'CRM'),
('CUS020', 'Rachel', 'Allen', 'rallen@email.com', '555-1020', '567 Beech Ct', 'Miami', 'FL', '33101', 'USA', '1992-12-17', 'Female', 'CRM');

PRINT 'Sample data inserted successfully';
PRINT 'Run ETL.uspRunFullPipeline to transform data to Silver and Gold layers';
