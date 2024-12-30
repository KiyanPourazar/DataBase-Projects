CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone_number VARCHAR(11),
    credit VARCHAR(20) DEFAULT '0',
    date_of_birth DATE
);