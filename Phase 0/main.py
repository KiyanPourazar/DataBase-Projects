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
    insert_query = """
    INSERT INTO users (username, email, phone_number, credit, date_of_birth)
    VALUES (%s, %s, %s, %s, %s)
    """
    data_to_insert = [
        ('user01', 'user01@example.com','09121231233','2500.02$','1992-12-23'),
        ('user02', 'user02@example.com','09123456787','12000.23$','1962-11-03')
    ]
    cur.executemany(insert_query, data_to_insert)

    conn.commit()
    print("Data inserted successfully!")

except Exception as e:
    conn.rollback()
    print("Error:", e)

finally:
    cur.close()
    conn.close()
