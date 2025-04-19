-- ========== ROLES ==========
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Roles (RoleName) VALUES
('Owner'), ('Developer'), ('Cashier'), ('Staff');

SELECT * FROM Roles;

-- ========== USERS ==========
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(250) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    RoleID INT NOT NULL DEFAULT 4,
    ResetCode VARCHAR(10) DEFAULT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

SELECT * FROM Users;

-- ========== CUSTOMERS ==========
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    RegisteredAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

SELECT * FROM Customers;

-- ========== AUDIT TRAIL ==========
CREATE TABLE audit_trail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    affected_username VARCHAR(100) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    action TEXT NOT NULL,
    timestamp DATETIME NOT NULL
);

SELECT * FROM audit_trail;

-- ========== CATEGORY ==========
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);

INSERT INTO Category (CategoryName) VALUES 
('Animal Feeds'), ('Animal Care'), ('Seeds'), ('Fertilizers'),
('Insecticide'), ('Molluscide'), ('Herbicide'), ('Miscellaneous');

SELECT * FROM Category;

-- ========== PRODUCT ==========
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT,
    PurchasePrice DECIMAL(10,2),
    SellingPrice DECIMAL(10,2),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

SELECT * FROM Product;

-- ========== INVENTORY ==========
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    DateReceived DATE,
    ExpiryDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

SELECT * FROM Inventory;

-- ========== DELETED ITEMS ==========
CREATE TABLE DeletedItems (
    DeletedID INT AUTO_INCREMENT PRIMARY KEY,
    InventoryID INT,
    ProductName VARCHAR(200),
    Quantity INT,
    PurchasePrice DECIMAL(10,2),
    SellingPrice DECIMAL(10,2),
    DateReceived DATE,
    ExpiryDate DATE,
    CategoryID INT
);

SELECT * FROM DeletedItems;

-- ========== PAYMENT METHODS ==========
CREATE TABLE PaymentMethods (
    PaymentMethodID INT PRIMARY KEY AUTO_INCREMENT,
    MethodName VARCHAR(50) UNIQUE
);

INSERT INTO PaymentMethods (MethodName)
VALUES ('Cash'), ('Credit'), ('GCash'), ('Card'), ('Other');

SELECT * FROM PaymentMethods;

-- ========== ORDERS ==========
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    OrderDate DATE,
    PaymentMethodID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID)
);

SELECT * FROM Orders;

-- ========== ORDER DETAILS ==========
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

SELECT * FROM OrderDetails;

-- ========== RECEIPTS ==========
CREATE TABLE Receipts (
    ReceiptID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    CustomerID INT,
    UserID INT, -- 👈 Added this line
    TotalAmount DECIMAL(10,2),
    Discount DECIMAL(10,2),
    PaymentMethodID INT,
    DateIssued DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) -- 👈 New FK to Users table
);
SELECT * FROM Receipts;

-- ========== DELETED USERS ==========
CREATE TABLE DeletedUsers (
    DeletedID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Username VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    RoleID INT NOT NULL,
    DeletedBy VARCHAR(100) NOT NULL,
    DeletedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

SELECT * FROM DeletedUsers;

CREATE TABLE InventoryLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    UsernameSnapshot VARCHAR(100), -- Stores the name of the user at the time of logging
    InventoryID INT,
    Action VARCHAR(50) NOT NULL,  -- Examples: 'add', 'restock', 'deduct', 'manual_adjustment'
    QuantityChanged INT NOT NULL,
    Remarks TEXT,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

SELECT * FROM InventoryLogs;


-- ========== ROLE UPDATE SAMPLE ==========
UPDATE Users
SET RoleID = 1
WHERE UserID = 1;
