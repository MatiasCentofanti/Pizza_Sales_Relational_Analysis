-- 1. Tabla: ORDENES (Padre)
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

-- 2. Tabla: TIPOS DE PIZZA (Catálogo)
CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients VARCHAR(MAX)
);

-- 3. Tabla: PIZZAS (Precios y Tamaños)
-- Esta depende de pizza_types
CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50),
    size VARCHAR(5),
    price DECIMAL(5, 2), -- Usamos DECIMAL para dinero
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

-- 4. Tabla: DETALLE DE ORDENES (La tabla que une todo)
-- Esta depende de 'orders' y 'pizzas'
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id)
);
