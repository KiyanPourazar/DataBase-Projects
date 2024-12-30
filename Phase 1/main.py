import psycopg2

conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="mypass",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

try:
    # Inserting sample data into People table
    insert_people_query = """
    INSERT INTO People (PersonID, FirstName, LastName, NationalID, DateOfBirth, PhoneNumber, Address, Email)
    VALUES
    (1, 'Ali', 'Ahmadi', '1234567890', '1980-01-01', '09123456789', 'Tehran, Iran', 'ali.ahmadi@example.com'),
    (2, 'Sara', 'Karimi', '9876543210', '1990-05-15', '09345678901', 'Isfahan, Iran', 'sara.karimi@example.com');
    """
    
    # Inserting sample data into Employees table
    insert_employees_query = """
    INSERT INTO Employees (EmployeeID, PersonID, Position)
    VALUES
    (1, 1, 'Manager');
    """
    
    # Inserting sample data into Customers table
    insert_customers_query = """
    INSERT INTO Customers (CustomerID, PersonID, CustomerType)
    VALUES
    (1, 2, 'Individual');
    """
    
    # Inserting sample data into Accounts table
    insert_accounts_query = """
    INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, Status, OpenDate, CloseDate)
    VALUES
    (1, 1, 'Savings', 10000.00, 'Active', '2023-01-01', NULL);
    """
    
    # Inserting sample data into Transactions table
    insert_transactions_query = """
    INSERT INTO Transactions (TransactionID, FromAccountID, ToAccountID, Amount, TransactionDate)
    VALUES
    (1, 1, NULL, 500.00, '2023-01-15');
    """
    
    # Inserting sample data into Loans table
    insert_loans_query = """
    INSERT INTO Loans (LoanID, CustomerID, LoanType, LoanAmount, InterestRate, StartDate, EndDate)
    VALUES
    (1, 1, 'Home Loan', 500000.00, 3.5, '2023-02-01', '2033-02-01');
    """
    
    # Inserting sample data into Installments table
    insert_installments_query = """
    INSERT INTO Installments (InstallmentID, LoanID, DueDate, AmountDue, AmountPaid, PaymentDate)
    VALUES
    (1, 1, '2023-03-01', 5000.00, 5000.00, '2023-03-01');
    """
    
    # Execute all insert statements
    cur.execute(insert_people_query)
    cur.execute(insert_employees_query)
    cur.execute(insert_customers_query)
    cur.execute(insert_accounts_query)
    cur.execute(insert_transactions_query)
    cur.execute(insert_loans_query)
    cur.execute(insert_installments_query)
    
    # Commit the changes
    conn.commit()
    print("Data inserted successfully!")

    # Example queries to check data
    cur.execute("SELECT * FROM People;")
    people_records = cur.fetchall()
    print("People Table:")
    for record in people_records:
        print(record)

    cur.execute("SELECT * FROM Accounts;")
    accounts_records = cur.fetchall()
    print("Accounts Table:")
    for record in accounts_records:
        print(record)

except Exception as e:
    conn.rollback()
    print("Error:", e)

finally:
    cur.close()
    conn.close()
