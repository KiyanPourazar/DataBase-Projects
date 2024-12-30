#Created by Kiyan Pourazar

import psycopg2

def execute_query(query, params=None):
    try:
        conn = psycopg2.connect(
            dbname="postgres",
            user="postgres",
            password="mypass",
            host="localhost",
            port="5432"
        )
        cur = conn.cursor()
        cur.execute(query, params)
        if query.strip().upper().startswith("SELECT"):
            result = cur.fetchall()
            cur.close()
            conn.close()
            return result
        conn.commit()
        cur.close()
        conn.close()
        return "Query executed successfully"
    except Exception as e:
        return f"Error: {e}"

def create_person(person_id, first_name, last_name, national_id, date_of_birth, phone, address, email):
    query = """
    INSERT INTO People (PersonID, FirstName, LastName, NationalID, DateOfBirth, PhoneNumber, Address, Email)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """
    params = (person_id, first_name, last_name, national_id, date_of_birth, phone, address, email)
    return execute_query(query, params)

def update_person_address(person_id, new_address):
    query = """
    UPDATE People
    SET Address = %s
    WHERE PersonID = %s
    """
    params = (new_address, person_id)
    return execute_query(query, params)

def delete_person(person_id):
    query = """
    DELETE FROM People
    WHERE PersonID = %s
    """
    params = (person_id,)
    return execute_query(query, params)

def select_all_people():
    query = """
    SELECT * FROM People
    """
    return execute_query(query)

# Example usage
print(create_person(4, 'David', 'Mills', '1931072918', '1985-11-02', '214555123', 'Main St 12', 'davidmillss8@gmail.com'))
print(update_person_address(4, 'Elm St 456'))
print(delete_person(4))
print(select_all_people())
