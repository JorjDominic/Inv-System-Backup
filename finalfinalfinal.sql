-- ========== ROLES ==========
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Roles (RoleName) VALUES
('Owner'), ('Developer'), ('Cashier'), ('Staff'),('Customer');

-- ========== USERS ==========
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(250) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    RoleID INT NOT NULL DEFAULT 5, -- Changed from DEFAULT 1 to DEFAULT 5
    ResetCode VARCHAR(10) DEFAULT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- ========== CUSTOMERS ==========
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Address TEXT,
    City VARCHAR(50),
    ZipCode VARCHAR(20),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE SET NULL
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
    ImageURL VARCHAR(255) DEFAULT NULL,
    CategoryID INT,
    PurchasePrice DECIMAL(10,2),
    SellingPrice DECIMAL(10,2),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
SELECT * FROM transactions ;
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

-- ========== PAYMENT METHODS ==========
CREATE TABLE PaymentMethods (
    PaymentMethodID INT PRIMARY KEY AUTO_INCREMENT,
    MethodName VARCHAR(50) UNIQUE NOT NULL,
    Description TEXT,
    IsActive BOOLEAN DEFAULT TRUE,
    RequiresVerification BOOLEAN DEFAULT FALSE,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO PaymentMethods (MethodName, Description, RequiresVerification) VALUES 
('Cash', 'Cash payment for walk-in transactions', FALSE),
('Credit', 'Credit purchase for regular customers', FALSE),
('GCash', 'GCash e-wallet via PayMongo', TRUE),
('Card', 'Credit/Debit card payment via PayMongo', TRUE),
('Maya', 'Maya (PayMaya) e-wallet via PayMongo', TRUE),
('GrabPay', 'GrabPay e-wallet via PayMongo', TRUE),
('Other', 'Other payment methods', FALSE);

-- ========== ORDERS ==========
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CustomerID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    OrderStatus ENUM('pending', 'paid', 'preparing', 'ready_for_pickup', 'completed', 'cancelled', 'refunded') NOT NULL DEFAULT 'pending',
    ShippingAddress TEXT,
    ShippingCity VARCHAR(50),
    ShippingZipCode VARCHAR(20),
    ContactNumber VARCHAR(20),
    TotalAmount DECIMAL(10,2),
    Notes TEXT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PickupDate DATE NULL,
    PickupTime TIME NULL,
    PickupCode VARCHAR(10) NULL,
    PickupNotes TEXT NULL,
    ReferenceNumber VARCHAR(255) NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE SET NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL
);

-- ========== ORDER DETAILS ==========
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2),
    Subtotal DECIMAL(10,2) GENERATED ALWAYS AS (Quantity * Price) STORED,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- ========== TRANSACTIONS ==========
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionType ENUM('online', 'walk_in') NOT NULL,
    PaymentMethodID INT NOT NULL,
    Status ENUM('pending', 'completed', 'failed', 'refunded', 'voided', 'paid') NOT NULL DEFAULT 'pending',
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE RESTRICT,
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID) ON DELETE RESTRICT
);
ALTER TABLE Transactions 
MODIFY COLUMN Status ENUM(
    'pending', 
    'completed', 
    'failed', 
    'refunded', 
    'voided', 
    'paid', 
    'cancelled'
) NOT NULL DEFAULT 'pending';
-- ========== PAYMONGO TRANSACTIONS ==========
CREATE TABLE PaymongoTransactions (
    PaymongoID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT NOT NULL UNIQUE,
    PaymentIntentID VARCHAR(100),
    PaymentSourceID VARCHAR(100),
    PaymentID VARCHAR(100),
    ClientKey VARCHAR(100),
    PaymentMethod VARCHAR(50),
    AuthorizedOnly BOOLEAN DEFAULT FALSE,
    AuthorizedAt DATETIME,
    CapturedAt DATETIME,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerEmail VARCHAR(100),
    CustomerPhone VARCHAR(20),
    BillingAddress TEXT,
    BillingCity VARCHAR(50),
    BillingZipCode VARCHAR(20),
    BillingCountry VARCHAR(50) DEFAULT 'Philippines',
    Description TEXT,
    StatementDescriptor VARCHAR(50),
    ErrorMessage TEXT,
    WebhookData JSON,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID) ON DELETE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL
);

-- ========== WALK-IN TRANSACTIONS ==========
CREATE TABLE WalkinTransactions (
    WalkinID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT NOT NULL UNIQUE,
    ProcessedBy INT NOT NULL,
    CashReceived DECIMAL(10,2),
    ChangeAmount DECIMAL(10,2),
    ReceiptNumber VARCHAR(50),
    RegisterID INT,
    Notes TEXT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID) ON DELETE CASCADE,
    FOREIGN KEY (ProcessedBy) REFERENCES Users(UserID) ON DELETE RESTRICT
);

-- ========== PAYMENT LINKS ==========
CREATE TABLE IF NOT EXISTS PaymentLinks (
    PaymentLinkID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    LinkID VARCHAR(100) NOT NULL,
    ReferenceNumber VARCHAR(50) NOT NULL,
    CheckoutURL VARCHAR(255) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- ========== RECEIPTS ==========
CREATE TABLE Receipts (
    ReceiptID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT,
    OrderID INT,
    CustomerID INT,
    UserID INT,
    TotalAmount DECIMAL(10,2),
    Discount DECIMAL(10,2) DEFAULT 0.00,
    TaxAmount DECIMAL(10,2) DEFAULT 0.00,
    FinalAmount DECIMAL(10,2) GENERATED ALWAYS AS (TotalAmount - Discount + TaxAmount) STORED,
    PaymentMethodID INT,
    ReceiptNumber VARCHAR(50) UNIQUE,
    DateIssued DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID) ON DELETE SET NULL,
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

-- ========== REFUNDS ==========
CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Reason TEXT,
    ProcessedBy INT,
    RefundDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    RefundReference VARCHAR(100),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID) ON DELETE RESTRICT,
    FOREIGN KEY (ProcessedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);

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

-- ========== EXPENSES ==========
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY AUTO_INCREMENT,
    Description VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL,
    UserID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ========== EXPIRED ITEMS ==========
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

-- ========== NOTIFICATIONS ==========
CREATE TABLE Notifications (
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

-- ========== PAYMENT WEBHOOKS ==========
CREATE TABLE PaymentWebhooks (
    WebhookID INT AUTO_INCREMENT PRIMARY KEY,
    EventType VARCHAR(100) NOT NULL,
    PayloadData JSON NOT NULL,
    Signature VARCHAR(255),
    ProcessedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('received', 'processed', 'failed') DEFAULT 'received',
    ErrorMessage TEXT,
    INDEX (EventType),
    INDEX (Status)
);

-- ========== INDEXES FOR PERFORMANCE ==========
CREATE INDEX idx_transactions_order ON Transactions(OrderID);
CREATE INDEX idx_transactions_status ON Transactions(Status);
CREATE INDEX idx_paymongo_payment_intent ON PaymongoTransactions(PaymentIntentID);
CREATE INDEX idx_paymongo_payment_source ON PaymongoTransactions(PaymentSourceID);
CREATE INDEX idx_orders_status ON Orders(OrderStatus);
CREATE INDEX idx_orders_date ON Orders(OrderDate);
CREATE INDEX idx_inventory_expiry ON Inventory(ExpiryDate);
CREATE INDEX idx_product_category ON Product(CategoryID);

-- ========== SET DEFAULT ROLE FOR ADMIN ==========
DELIMITER //

CREATE TRIGGER set_first_user_as_owner
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
    -- Check if this is the first user being inserted into the table
    DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count FROM Users;
    
    -- If no users exist yet, set this one as Owner (RoleID = 1)
    IF user_count = 0 THEN
        SET NEW.RoleID = 1;
    -- Otherwise set to Customer role (5)
    ELSE
        SET NEW.RoleID = 5;
    END IF;
END//

DELIMITER ;