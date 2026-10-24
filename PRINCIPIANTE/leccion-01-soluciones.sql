/* Lección 1: soluciones. Mira esto solo después de intentarlo. */

USE PracticaSQL;
GO

-- 1
SELECT * FROM departamentos;

-- 2
SELECT nombre, cargo FROM empleados;

-- 3
SELECT nombre, salario AS sueldo_mensual FROM empleados;

-- 4
SELECT DISTINCT area FROM empleados;

-- 5
SELECT TOP 10 * FROM ventas;

-- 6
SELECT TOP 20 id_venta, fecha, cantidad FROM ventas;

-- 7
SELECT DISTINCT canal FROM ventas;

-- 8
SELECT DISTINCT categoria FROM productos;

-- 9
SELECT DISTINCT tipo_infraccion FROM comparendos;

-- 10
SELECT TOP 15 municipio, poblacion AS habitantes FROM municipios;

-- Reflexión: trae millones de filas que no necesitas; tarda, consume memoria y red,
-- y puede bloquear el cliente. Con TOP y solo las columnas necesarias exploras rápido.
