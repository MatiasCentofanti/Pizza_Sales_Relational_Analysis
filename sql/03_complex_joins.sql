-- ==============================================================
-- Consultas avanzadas para la toma de decisiones.
-- ==============================================================

-- ==============================================================
-- SECCIÓN 1: KPIs GLOBALES (Indicadores Clave de Desempeño)
-- ==============================================================

-- 1.1. Resumen Ejecutivo
-- Muestra Ingresos Totales, Ordenes Totales, Pizzas Vendidas y Ticket Promedio
SELECT 
    FORMAT(SUM(od.quantity * p.price), 'C', 'en-US') AS Ingresos_Totales,
    COUNT(DISTINCT o.order_id) AS Total_Ordenes,
    SUM(od.quantity) AS Total_Pizzas_Vendidas,
    FORMAT(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id), 'C', 'en-US') AS Ticket_Promedio
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN orders o ON od.order_id = o.order_id;


-- ==============================================================
-- SECCIÓN 2: ANÁLISIS DE PRODUCTO Y MENÚ
-- ==============================================================

-- 2.1. Las 5 Pizzas Más Vendidas (Revenue Generators)
SELECT TOP 5
    pt.name AS Nombre_Pizza,
    pt.category AS Categoria,
    SUM(od.quantity) AS Cantidad_Vendida,
    FORMAT(SUM(od.quantity * p.price), 'C', 'en-US') AS Ingresos_Generados
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, pt.category
ORDER BY SUM(od.quantity * p.price) DESC;

-- 2.2. Las 5 Pizzas MENOS Vendidas (Candidatas a eliminar del menú)
SELECT TOP 5
    pt.name AS Nombre_Pizza,
    pt.category,
    SUM(od.quantity) AS Cantidad_Vendida,
    FORMAT(SUM(od.quantity * p.price), 'C', 'en-US') AS Ingresos_Generados
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, pt.category
ORDER BY Cantidad_Vendida ASC;

-- 2.3. Preferencia de Tamaño por Categoría (¿La gente pide Veggie grande o chica?)
SELECT 
    pt.category,
    p.size,
    COUNT(od.order_details_id) AS Cantidad_Pedidos,
    FORMAT(COUNT(od.order_details_id) * 100.0 / SUM(COUNT(od.order_details_id)) OVER(PARTITION BY pt.category), 'N2') + '%' AS Mix_Por_Categoria
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, p.size
ORDER BY pt.category, p.size;


-- ==============================================================
-- SECCIÓN 3: ANÁLISIS TEMPORAL (Tendencias)
-- ==============================================================

-- 3.1. Días más ocupados de la semana
-- Útil para planificar turnos de empleados
SELECT 
    DATENAME(WEEKDAY, o.date) AS Dia_Semana,
    COUNT(DISTINCT o.order_id) AS Total_Ordenes,
    SUM(od.quantity) AS Pizzas_Preparadas
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATENAME(WEEKDAY, o.date), DATEPART(WEEKDAY, o.date)
ORDER BY Total_Ordenes DESC; -- Ordenado por volumen

-- 3.2. Hora Pico (Busy Hours) - Detallado
SELECT 
    DATEPART(HOUR, o.time) AS Hora_Del_Dia,
    COUNT(DISTINCT o.order_id) AS Total_Ordenes,
    SUM(od.quantity) AS Total_Pizzas
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATEPART(HOUR, o.time)
ORDER BY Total_Ordenes DESC;


-- ==============================================================
-- SECCIÓN 4: ADVANCED ANALYTICS (Window Functions & CTEs)
-- ==============================================================

-- 4.1. Ingresos Acumulados por Día (Running Total)
-- Muestra cómo crece el dinero día a día. Demuestra uso de CTE y Window Functions.
WITH VentasDiarias AS (
    SELECT 
        o.date,
        SUM(od.quantity * p.price) AS Ingreso_Diario
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.date
)
SELECT 
    date,
    FORMAT(Ingreso_Diario, 'C', 'en-US') as Venta_Dia,
    FORMAT(SUM(Ingreso_Diario) OVER (ORDER BY date), 'C', 'en-US') AS Venta_Acumulada
FROM VentasDiarias
ORDER BY date;

-- 4.2. Ranking de Pizzas dentro de cada Categoría
-- ¿Cuál es la #1 de Pollo? ¿Cuál es la #1 Vegetariana?
SELECT 
    Categoria,
    Nombre_Pizza,
    Ingresos,
    Ranking_Categoria
FROM (
    SELECT 
        pt.category AS Categoria,
        pt.name AS Nombre_Pizza,
        SUM(od.quantity * p.price) AS Ingresos,
        -- RANK() crea un ranking reiniciando el conteo para cada categoría
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS Ranking_Categoria
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS RankingTable
WHERE Ranking_Categoria <= 3 -- Mostrar solo el Top 3 de cada categoría
ORDER BY Categoria, Ranking_Categoria;
