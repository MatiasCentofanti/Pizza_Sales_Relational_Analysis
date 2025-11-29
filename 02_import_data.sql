-- ==============================================================
-- CARGA DE DATOS (ETL)
-- ==============================================================

-- A. Cargar ORDERS
-- Filtramos nulos en la PK para evitar errores
INSERT INTO orders (order_id, date, time)
SELECT 
    order_id, 
    TRY_CAST(date AS DATE), 
    TRY_CAST(time AS TIME)
FROM [dbo].[orders.csv];

-- B. Cargar PIZZA_TYPES
INSERT INTO pizza_types (pizza_type_id, name, category, ingredients)
SELECT 
    pizza_type_id, 
    name, 
    category, 
    ingredients
FROM [dbo].[pizza_types.csv];

-- C. Cargar PIZZAS (Con corrección de precio)
INSERT INTO pizzas (pizza_id, pizza_type_id, size, price)
SELECT 
    pizza_id, 
    pizza_type_id, 
    size, 
    -- LÓGICA DE CORRECCIÓN DE PRECIOS:
    CASE 
        -- Caso 1: Precio "1275" -> 12.75 (Mayor a 1000, le faltan dos decimales)
        WHEN TRY_CAST(price AS FLOAT) > 1000 THEN TRY_CAST(price AS FLOAT) / 100.0
        
        -- Caso 2: Precio "205" -> 20.50 (Entre 200 y 1000, probablemente le falta un decimal)
        -- Ajustamos el rango según tus datos. Las pizzas suelen costar entre $10 y $30.
        WHEN TRY_CAST(price AS FLOAT) > 25 AND TRY_CAST(price AS FLOAT) <= 1000 THEN TRY_CAST(price AS FLOAT) / 10.0
        
        -- Caso 3: Precio "12" -> 12.00 (Ya es correcto)
        ELSE TRY_CAST(price AS DECIMAL(5,2))
    END
FROM [dbo].[pizzas.csv]

-- D. Cargar ORDER_DETAILS
INSERT INTO order_details (order_details_id, order_id, pizza_id, quantity)
SELECT 
    order_details_id, 
    order_id, 
    pizza_id, 
    quantity
FROM [dbo].[order_details.csv];