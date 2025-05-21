-- database/init.sql
CREATE DATABASE flutter_login;

\c flutter_login

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL
);

INSERT INTO users (email, password) VALUES
('test@example.com', '123456');
