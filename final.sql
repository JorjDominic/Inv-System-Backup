-- ========== ROLES ==========
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Roles (RoleName) VALUES
('Owner'), ('Developer'), ('Cashier'), ('Staff');

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

-- ========== AUDIT TRAIL ==========
CREATE TABLE audit_trail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    affected_username VARCHAR(100) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    action TEXT NOT NULL,
    timestamp DATETIME NOT NULL
);

-- ========== CATEGORY ==========
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);

INSERT INTO Category (CategoryName) VALUES 
('Animal Feeds'), ('Animal Care'), ('Seeds'), ('Fertilizers'),
('Insecticide'), ('Molluscide'), ('Herbicide'), ('Miscellaneous');

-- ========== PRODUCT ==========
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT,
    PurchasePrice DECIMAL(10,2),
    SellingPrice DECIMAL(10,2),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

-- ========== INVENTORY ==========
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    DateReceived DATE,
    ExpiryDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

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
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
SELECT * FROM DELETEDitems;
-- ========== PAYMENT METHODS ==========
CREATE TABLE PaymentMethods (
    PaymentMethodID INT PRIMARY KEY AUTO_INCREMENT,
    MethodName VARCHAR(50) UNIQUE
);

INSERT INTO PaymentMethods (MethodName)
VALUES ('Cash'), ('Credit'), ('GCash'), ('Card'), ('Other');

-- ========== ORDERS ==========
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    OrderDate DATE,
    PaymentMethodID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID)
);

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

-- ========== RECEIPTS ==========
CREATE TABLE Receipts (
    ReceiptID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    CustomerID INT,
    UserID INT,
    TotalAmount DECIMAL(10,2),
    Discount DECIMAL(10,2),
    PaymentMethodID INT,
    DateIssued DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

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

-- ========== INVENTORY LOGS ==========
CREATE TABLE InventoryLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    UsernameSnapshot VARCHAR(100),
    ProductNameSnapshot VARCHAR(200),
    InventoryID INT,
    Action VARCHAR(50) NOT NULL,
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

-- ========== REFUNDED ITEMS ==========
CREATE TABLE RefundedItems (
    RefundID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    QuantityRefunded INT NOT NULL,
    ItemCondition ENUM('PRISTINE', 'DAMAGED') NOT NULL,
    RefundedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    ProcessedBy INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (ProcessedBy) REFERENCES Users(UserID)
);
SELECT * FROM RefundedItems;

-- ========== DAMAGED ITEMS ==========
CREATE TABLE DamagedItems (
    DamageID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Reason TEXT,
    ReportedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    ReportedBy INT,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (ReportedBy) REFERENCES Users(UserID)
);

SELECT * FROM DamagedItems;
-- ========== SET DEFAULT ROLE FOR ADMIN ==========
UPDATE Users SET RoleID = 1 WHERE UserID = 1;

CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY AUTO_INCREMENT,
    Description VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL,
    UserID INT NOT NULL,  -- Foreign key referencing Users table
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE Expenses ADD CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE ExpiredItems (
    ExpiredID INT AUTO_INCREMENT PRIMARY KEY,
    InventoryID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    ExpiryDate DATE NOT NULL,
    ReportedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateExpired DATETIME DEFAULT CURRENT_TIMESTAMP,
    ReportedBy INT NOT NULL,
    PurchasePrice DECIMAL(10,2) NOT NULL,
    LossValue DECIMAL(10,2) GENERATED ALWAYS AS (Quantity * PurchasePrice) STORED,
    Remarks TEXT NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (ReportedBy) REFERENCES Users(UserID)
);
DESCRIBE Product;
SELECT * FROM inventorylogs;
SELECT * FROM expireditems;
SELECT * FROM expenses;
DROP TABLE notifications;
SELECT * FROM notifications; 

SELECT * FROM Inventory 
WHERE ExpiryDate < CURRENT_DATE 
AND Quantity >1;

CREATE TABLE  Notifications (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    NotificationType VARCHAR(50) NOT NULL,
    Message TEXT NOT NULL,
    IsRead TINYINT(1) DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (UserID),
    INDEX (NotificationType),
    INDEX (IsRead)
);
