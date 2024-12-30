--created by Kiyan Pourazar
-- Creating the People table
CREATE TABLE People (
    PersonID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    NationalID VARCHAR(20) UNIQUE,
    DateOfBirth DATE,
    PhoneNumber VARCHAR(15),
    Address VARCHAR(255),
    Email VARCHAR(100)
);

-- Creating the Employees table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    PersonID INT UNIQUE,
    Position VARCHAR(50),
    FOREIGN KEY (PersonID) REFERENCES People(PersonID)
);

-- Creating the Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    PersonID INT UNIQUE,
    CustomerType VARCHAR(10) CHECK (CustomerType IN ('Individual', 'Corporate')),
    FOREIGN KEY (PersonID) REFERENCES People(PersonID)
);

-- Creating the Accounts table
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(10) CHECK (AccountType IN ('Savings', 'Current')),
    Balance DECIMAL(15, 2),
    Status VARCHAR(10) CHECK (Status IN ('Active', 'Suspended', 'Closed')),
    OpenDate DATE,
    CloseDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Creating the Transactions table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    FromAccountID INT,
    ToAccountID INT,
    Amount DECIMAL(15, 2),
    TransactionDate DATE,
    FOREIGN KEY (FromAccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ToAccountID) REFERENCES Accounts(AccountID)
);

-- Creating the Loans table
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    LoanType VARCHAR(50),
    LoanAmount DECIMAL(15, 2),
    InterestRate DECIMAL(5, 2),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Creating the Installments table
CREATE TABLE Installments (
    InstallmentID INT PRIMARY KEY,
    LoanID INT,
    DueDate DATE,
    AmountDue DECIMAL(15, 2),
    AmountPaid DECIMAL(15, 2),
    PaymentDate DATE,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- Inserting sample data
INSERT INTO People (PersonID, FirstName, LastName, NationalID, DateOfBirth, PhoneNumber, Address, Email) VALUES
(1, 'Ali', 'Ahmadi', '1234567890', '1980-01-01', '09123456789', 'Tehran, Iran', 'ali.ahmadi@example.com'),
(2, 'Sara', 'Karimi', '9876543210', '1990-05-15', '09345678901', 'Isfahan, Iran', 'sara.karimi@example.com'),
(3, 'David', 'Mills', '1921072918', '1985-11-02', '214555123', 'Elm St 456', 'davidmillss8@gmail.com');

INSERT INTO Employees (EmployeeID, PersonID, Position) VALUES
(1, 1, 'Manager');

INSERT INTO Customers (CustomerID, PersonID, CustomerType) VALUES
(1, 2, 'Individual'),
(2, 3, 'Individual');

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, Status, OpenDate, CloseDate) VALUES
(1, 1, 'Savings', 10000.00, 'Active', '2023-01-01', NULL),
(2, 2, 'Current', 5000.00, 'Active', '2023-01-15', NULL);

INSERT INTO Transactions (TransactionID, FromAccountID, ToAccountID, Amount, TransactionDate) VALUES
(1, 1, 2, 500.00, '2023-01-20');

INSERT INTO Loans (LoanID, CustomerID, LoanType, LoanAmount, InterestRate, StartDate, EndDate) VALUES
(1, 1, 'Home Loan', 500000.00, 3.5, '2023-02-01', '2033-02-01');

INSERT INTO Installments (InstallmentID, LoanID, DueDate, AmountDue, AmountPaid, PaymentDate) VALUES
(1, 1, '2023-03-01', 5000.00, 5000.00, '2023-03-01');

-- Creating the Views
CREATE VIEW customer_accounts AS
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.AccountID,
    a.AccountType,
    a.Balance
FROM Customers c
JOIN People p ON c.PersonID = p.PersonID
JOIN Accounts a ON c.CustomerID = a.CustomerID;

CREATE VIEW bank_transactions AS
SELECT 
    t.TransactionID,
    t.FromAccountID,
    t.ToAccountID,
    t.Amount,
    t.TransactionDate
FROM Transactions t;

CREATE VIEW bank_member AS
SELECT 
    p.FirstName,
    p.LastName,
    p.NationalID,
    e.Position
FROM Employees e
JOIN People p ON e.PersonID = p.PersonID
UNION ALL
SELECT 
    p.FirstName,
    p.LastName,
    p.NationalID,
    'Customer' AS Position
FROM Customers c
JOIN People p ON c.PersonID = p.PersonID;

-- Adding Triggers
-- Trigger to set OpenDate automatically when an account is created
CREATE OR REPLACE FUNCTION set_open_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.OpenDate := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_open_date
BEFORE INSERT ON Accounts
FOR EACH ROW
EXECUTE FUNCTION set_open_date();

-- Trigger to prevent deleting a customer with active loans
CREATE OR REPLACE FUNCTION prevent_customer_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Loans WHERE CustomerID = OLD.CustomerID AND EndDate > CURRENT_DATE) THEN
        RAISE EXCEPTION 'Cannot delete a customer with active loans';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_customer_deletion
BEFORE DELETE ON Customers
FOR EACH ROW
EXECUTE FUNCTION prevent_customer_deletion();

-- Trigger to update account balances after a transaction
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.FromAccountID IS NOT NULL THEN
        UPDATE Accounts SET Balance = Balance - NEW.Amount WHERE AccountID = NEW.FromAccountID;
    END IF;
    IF NEW.ToAccountID IS NOT NULL THEN
        UPDATE Accounts SET Balance = Balance + NEW.Amount WHERE AccountID = NEW.ToAccountID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_account_balance
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();

-- Trigger to check sufficient balance before transaction
CREATE OR REPLACE FUNCTION check_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.FromAccountID IS NOT NULL THEN
        IF (SELECT Balance FROM Accounts WHERE AccountID = NEW.FromAccountID) < NEW.Amount THEN
            RAISE EXCEPTION 'Insufficient balance for transaction';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_balance
BEFORE INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION check_balance();

-- Adding Functions
-- Function to calculate total balance for a customer
CREATE OR REPLACE FUNCTION calculate_total_balance(customer_id INT)
RETURNS DECIMAL AS $$
DECLARE
    total_balance DECIMAL := 0;
BEGIN
    SELECT SUM(Balance) INTO total_balance
    FROM Accounts
    WHERE CustomerID = customer_id;
    RETURN total_balance;
END;
$$ LANGUAGE plpgsql;

-- Function to check loan status
CREATE OR REPLACE FUNCTION get_loan_status(loan_id INT)
RETURNS VARCHAR AS $$
DECLARE
    status VARCHAR;
BEGIN
    SELECT CASE
        WHEN EndDate > CURRENT_DATE THEN 'Active'
        ELSE 'Closed'
    END INTO status
    FROM Loans
    WHERE LoanID = loan_id;
    RETURN status;
END;
$$ LANGUAGE plpgsql;

-- Function to count active loans for a customer
CREATE OR REPLACE FUNCTION count_active_loans(customer_id INT)
RETURNS INT AS $$
DECLARE
    active_loans INT := 0;
BEGIN
    SELECT COUNT(*) INTO active_loans
    FROM Loans
    WHERE CustomerID = customer_id AND EndDate > CURRENT_DATE;
    RETURN active_loans;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate total payments for a loan
CREATE OR REPLACE FUNCTION calculate_total_payments(loan_id INT)
RETURNS DECIMAL AS $$
DECLARE
    total_payments DECIMAL := 0;
BEGIN
    SELECT SUM(AmountPaid) INTO total_payments
    FROM Installments
    WHERE LoanID = loan_id;
    RETURN total_payments;
END;
$$ LANGUAGE plpgsql;

-- Function to get customer name by ID
CREATE OR REPLACE FUNCTION get_customer_name(customer_id INT)
RETURNS VARCHAR AS $$
DECLARE
    customer_name VARCHAR;
BEGIN
    SELECT CONCAT(FirstName, ' ', LastName) INTO customer_name
    FROM People
    WHERE PersonID = (SELECT PersonID FROM Customers WHERE CustomerID = customer_id);
    RETURN customer_name;
END;
$$ LANGUAGE plpgsql;
