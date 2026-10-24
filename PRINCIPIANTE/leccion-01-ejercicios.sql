/* Lección 1: SELECT y FROM
   Escribe tu consulta debajo de cada enunciado. Base: PracticaSQL */

USE PracticaSQL;
GO

-- Parte A: tablas pequeñas

-- 1. Muestra todas las columnas y todas las filas de la tabla departamentos.


-- 2. Muestra solo las columnas nombre y cargo de todos los empleados.


-- 3. Muestra nombre y salario de los empleados, con la columna salario renombrada como sueldo_mensual.


-- 4. Muestra la lista de áreas de la tabla empleados, sin que se repita ninguna.


-- Parte B: tablas grandes (cuidado con SELECT * sin TOP)

-- 5. Muestra las primeras 10 filas de la tabla ventas.


-- 6. Muestra solo id_venta, fecha y cantidad de las primeras 20 ventas.


-- 7. ¿Qué canales de venta existen? Muestra cada canal una sola vez.


-- 8. ¿Qué categorías de productos existen? Muestra cada categoría una sola vez.


-- 9. ¿Qué tipos de infracción hay en la tabla comparendos? Cada tipo una sola vez.


-- 10. De la tabla municipios, muestra municipio y poblacion de las primeras 15 filas,
--     con poblacion renombrada como habitantes.


-- Pregunta de reflexión (respóndela en un comentario):
-- ¿Por qué no conviene ejecutar SELECT * FROM ventas sin TOP en una tabla de millones de filas?
