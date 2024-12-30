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
