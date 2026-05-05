-- Seed data

INSERT INTO users (name, email) VALUES
  ('Alice Johnson', 'alice@example.com'),
  ('Bob Smith', 'bob@example.com'),
  ('Carol White', 'carol@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, price, description, stock) VALUES
  ('Laptop Pro', 1299.99, 'High-performance laptop', 50),
  ('Wireless Mouse', 29.99, 'Ergonomic wireless mouse', 200),
  ('USB-C Hub', 49.99, '7-in-1 USB-C hub', 150)
ON CONFLICT DO NOTHING;
