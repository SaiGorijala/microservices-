-- Migration: Create tables
-- Run this against your PostgreSQL instance

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  description TEXT DEFAULT '',
  stock INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);
