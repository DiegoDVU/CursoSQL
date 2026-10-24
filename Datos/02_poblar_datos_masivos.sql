/* ============================================================================
   Curso SQL para análisis de datos
   Paso 2 de 2: generar datos masivos ficticios (SQL Server / T-SQL)

   IMPORTANTE: ejecuta este script COMPLETO como un solo lote.
     - SSMS / Azure Data Studio: selecciona todo y ejecuta (F5 / Ctrl+Shift+E).
     - DBeaver: selecciona todo el texto (Ctrl+A) y usa Ctrl+Enter, que envía
       la selección como un único lote. Si usas "Ejecutar script" (Alt+X),
       DBeaver parte el texto en sentencias y las variables @ se pierden.

   Volúmenes por defecto (cámbialos aquí abajo si tu equipo es más modesto):
     ventas 5.000.000 | comparendos 2.000.000 | clientes 200.000
     nomina 72.000 (2.000 empleados x 36 meses) | productos 5.000

   Los datos son pseudoaleatorios pero DETERMINISTAS: si no cambias los
   volúmenes, todos obtienen exactamente las mismas filas y los mismos
   resultados. La distribución es aproximada, no estadísticamente perfecta.
   ============================================================================ */

USE PracticaSQL;
SET NOCOUNT ON;

/* ---------- Parámetros de volumen ---------- */
DECLARE @N_CLIENTES     INT = 200000;
DECLARE @N_PRODUCTOS    INT = 5000;
DECLARE @N_EMPLEADOS    INT = 2000;
DECLARE @N_VENTAS       INT = 5000000;
DECLARE @N_COMPARENDOS  INT = 2000000;
DECLARE @MESES_NOMINA   INT = 36;
-- Límite técnico: el mayor de los volúmenes no puede superar 10.000.000
DECLARE @MAXN INT = (SELECT MAX(v) FROM (VALUES (@N_CLIENTES),(@N_PRODUCTOS),(@N_EMPLEADOS),(@N_VENTAS),(@N_COMPARENDOS)) AS t(v));

/* ---------- Tabla auxiliar de números: 1, 2, 3, ... @MAXN ---------- */
;WITH d AS (SELECT x FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS t(x))
SELECT TOP (@MAXN) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS INT) AS n
INTO #n
FROM d d1 CROSS JOIN d d2 CROSS JOIN d d3 CROSS JOIN d d4
     CROSS JOIN d d5 CROSS JOIN d d6 CROSS JOIN d d7;

CREATE UNIQUE CLUSTERED INDEX ix_n ON #n(n);

/* ---------- Departamentos (reales, con clasificación regional simplificada) ---------- */
SELECT cod_depto, departamento, region, ciudad
INTO #dep
FROM (VALUES
    (5,  N'Antioquia',                 N'Andina',    N'Medellín'),
    (8,  N'Atlántico',                 N'Caribe',    N'Barranquilla'),
    (11, N'Bogotá D.C.',               N'Andina',    N'Bogotá'),
    (13, N'Bolívar',                   N'Caribe',    N'Cartagena'),
    (15, N'Boyacá',                    N'Andina',    N'Tunja'),
    (17, N'Caldas',                    N'Andina',    N'Manizales'),
    (18, N'Caquetá',                   N'Amazonía',  N'Florencia'),
    (19, N'Cauca',                     N'Pacífica',  N'Popayán'),
    (20, N'Cesar',                     N'Caribe',    N'Valledupar'),
    (23, N'Córdoba',                   N'Caribe',    N'Montería'),
    (25, N'Cundinamarca',              N'Andina',    N'Soacha'),
    (27, N'Chocó',                     N'Pacífica',  N'Quibdó'),
    (41, N'Huila',                     N'Andina',    N'Neiva'),
    (44, N'La Guajira',                N'Caribe',    N'Riohacha'),
    (47, N'Magdalena',                 N'Caribe',    N'Santa Marta'),
    (50, N'Meta',                      N'Orinoquía', N'Villavicencio'),
    (52, N'Nariño',                    N'Pacífica',  N'Pasto'),
    (54, N'Norte de Santander',        N'Andina',    N'Cúcuta'),
    (63, N'Quindío',                   N'Andina',    N'Armenia'),
    (66, N'Risaralda',                 N'Andina',    N'Pereira'),
    (68, N'Santander',                 N'Andina',    N'Bucaramanga'),
    (70, N'Sucre',                     N'Caribe',    N'Sincelejo'),
    (73, N'Tolima',                    N'Andina',    N'Ibagué'),
    (76, N'Valle del Cauca',           N'Pacífica',  N'Cali'),
    (81, N'Arauca',                    N'Orinoquía', N'Arauca'),
    (85, N'Casanare',                  N'Orinoquía', N'Yopal'),
    (86, N'Putumayo',                  N'Amazonía',  N'Mocoa'),
    (88, N'San Andrés y Providencia',  N'Insular',   N'San Andrés'),
    (91, N'Amazonas',                  N'Amazonía',  N'Leticia'),
    (94, N'Guainía',                   N'Amazonía',  N'Inírida'),
    (95, N'Guaviare',                  N'Amazonía',  N'San José del Guaviare'),
    (97, N'Vaupés',                    N'Amazonía',  N'Mitú'),
    (99, N'Vichada',                   N'Orinoquía', N'Puerto Carreño')
) AS v(cod_depto, departamento, region, ciudad);

INSERT INTO dbo.departamentos (cod_depto, departamento, region)
SELECT cod_depto, departamento, region FROM #dep;

/* ---------- Municipios: la ciudad principal + municipios ficticios por departamento ---------- */
INSERT INTO dbo.municipios (cod_muni, municipio, cod_depto, poblacion)
SELECT d.cod_depto * 1000 + 1,
       d.ciudad,
       d.cod_depto,
       150000 + (CHECKSUM(d.cod_depto, 11) & 2147483647) % 2000000
FROM #dep d
UNION ALL
SELECT d.cod_depto * 1000 + s.n,
       N'Municipio ' + RIGHT('00'  + CAST(d.cod_depto AS VARCHAR(3)), 2) + N'-'
                     + RIGHT('000' + CAST(s.n AS VARCHAR(3)), 3),
       d.cod_depto,
       2000 + (CHECKSUM(d.cod_depto * 1000 + s.n, 12) & 2147483647) % 80000
FROM #dep d
JOIN #n s ON s.n BETWEEN 2 AND 8 + (d.cod_depto * 7) % 40
         AND d.cod_depto NOT IN (11, 88);

-- Lista numerada de municipios para poder asignarlos "al azar" a otras tablas
SELECT CAST(ROW_NUMBER() OVER (ORDER BY cod_muni) AS INT) AS idx, cod_muni
INTO #muni
FROM dbo.municipios;

DECLARE @N_MUNI INT = (SELECT COUNT(*) FROM #muni);

/* ---------- Clientes ---------- */
INSERT INTO dbo.clientes (id_cliente, nombre, cod_muni, segmento, fecha_registro, activo)
SELECT s.n,
       CHOOSE(1 + r.h1 % 20, N'Laura', N'Carlos', N'Marta', N'Andrés', N'Sofía', N'Jorge', N'Paula', N'Iván',
                             N'Camila', N'Felipe', N'Valentina', N'Santiago', N'Daniela', N'Mateo', N'Natalia',
                             N'Sebastián', N'Juliana', N'Esteban', N'Carolina', N'Alejandro')
         + N' ' +
       CHOOSE(1 + r.h2 % 20, N'Gómez', N'Ruiz', N'Peña', N'Silva', N'Torres', N'Mora', N'Díaz', N'Castro',
                             N'Rojas', N'Vargas', N'Herrera', N'Ortiz', N'Ramírez', N'Moreno', N'Jiménez',
                             N'Cárdenas', N'Pardo', N'Suárez', N'Mendoza', N'León'),
       m.cod_muni,
       CHOOSE(1 + r.h3 % 10, N'Minorista', N'Minorista', N'Minorista', N'Minorista', N'Minorista', N'Minorista',
                             N'Corporativo', N'Corporativo', N'Corporativo', N'Mayorista'),
       DATEADD(DAY, r.h5 % 1826, CAST('2021-01-01' AS DATE)),
       CASE WHEN r.h6 % 10 < 8 THEN 1 ELSE 0 END
FROM #n s
CROSS APPLY (SELECT CHECKSUM(s.n, 51) & 2147483647 AS h1, CHECKSUM(s.n, 52) & 2147483647 AS h2,
                    CHECKSUM(s.n, 53) & 2147483647 AS h3, CHECKSUM(s.n, 54) & 2147483647 AS h4,
                    CHECKSUM(s.n, 55) & 2147483647 AS h5, CHECKSUM(s.n, 56) & 2147483647 AS h6) r
JOIN #muni m ON m.idx = 1 + r.h4 % @N_MUNI
WHERE s.n <= @N_CLIENTES;

/* ---------- Productos ---------- */
INSERT INTO dbo.productos (id_producto, producto, categoria, precio_unitario, costo_unitario, stock)
SELECT s.n,
       r.cat + N' - Producto ' + RIGHT('0000' + CAST(s.n AS VARCHAR(10)), 4),
       r.cat,
       r.precio,
       CAST(r.precio * (0.55 + (r.h3 % 30) / 100.0) AS DECIMAL(12,2)),
       r.h4 % 500
FROM #n s
CROSS APPLY (SELECT CHOOSE(1 + (CHECKSUM(s.n, 21) & 2147483647) % 9,
                           N'Hogar', N'Tecnología', N'Ropa', N'Deportes', N'Juguetes',
                           N'Alimentos', N'Belleza', N'Ferretería', N'Automotriz') AS cat,
                    CAST(5000 + (CHECKSUM(s.n, 22) & 2147483647) % 495000 AS DECIMAL(12,2)) AS precio,
                    CHECKSUM(s.n, 23) & 2147483647 AS h3,
                    CHECKSUM(s.n, 24) & 2147483647 AS h4) r
WHERE s.n <= @N_PRODUCTOS;

/* ---------- Empleados ---------- */
INSERT INTO dbo.empleados (id_empleado, nombre, cargo, area, salario, cod_muni, fecha_ingreso)
SELECT s.n,
       CHOOSE(1 + r.h1 % 20, N'Laura', N'Carlos', N'Marta', N'Andrés', N'Sofía', N'Jorge', N'Paula', N'Iván',
                             N'Camila', N'Felipe', N'Valentina', N'Santiago', N'Daniela', N'Mateo', N'Natalia',
                             N'Sebastián', N'Juliana', N'Esteban', N'Carolina', N'Alejandro')
         + N' ' +
       CHOOSE(1 + r.h2 % 20, N'Gómez', N'Ruiz', N'Peña', N'Silva', N'Torres', N'Mora', N'Díaz', N'Castro',
                             N'Rojas', N'Vargas', N'Herrera', N'Ortiz', N'Ramírez', N'Moreno', N'Jiménez',
                             N'Cárdenas', N'Pardo', N'Suárez', N'Mendoza', N'León'),
       CHOOSE(1 + r.h3 % 20, N'Auxiliar', N'Auxiliar', N'Auxiliar', N'Auxiliar', N'Auxiliar', N'Auxiliar', N'Auxiliar',
                             N'Analista', N'Analista', N'Analista', N'Analista', N'Analista',
                             N'Asesor', N'Asesor', N'Asesor', N'Asesor',
                             N'Técnico', N'Técnico', N'Coordinador', N'Director'),
       CHOOSE(1 + r.h4 % 6, N'Ventas', N'Contabilidad', N'Recursos Humanos', N'Control Interno', N'Sistemas', N'Logística'),
       CAST(1800000 + (r.h5 % 5201) * 1000 AS DECIMAL(12,2)),
       m.cod_muni,
       DATEADD(DAY, r.h7 % 3650, CAST('2016-01-01' AS DATE))
FROM #n s
CROSS APPLY (SELECT CHECKSUM(s.n, 61) & 2147483647 AS h1, CHECKSUM(s.n, 62) & 2147483647 AS h2,
                    CHECKSUM(s.n, 63) & 2147483647 AS h3, CHECKSUM(s.n, 64) & 2147483647 AS h4,
                    CHECKSUM(s.n, 65) & 2147483647 AS h5, CHECKSUM(s.n, 66) & 2147483647 AS h6,
                    CHECKSUM(s.n, 67) & 2147483647 AS h7) r
JOIN #muni m ON m.idx = 1 + r.h6 % @N_MUNI
WHERE s.n <= @N_EMPLEADOS;

/* ---------- Nómina: cada empleado x cada mes (simplificada: salario fijo) ---------- */
INSERT INTO dbo.nomina (id_nomina, id_empleado, periodo, salario_base, horas_extra, deducciones)
SELECT CAST(ROW_NUMBER() OVER (ORDER BY e.id_empleado, s.n) AS INT),
       e.id_empleado,
       DATEADD(MONTH, s.n - 1, CAST('2023-01-01' AS DATE)),
       e.salario,
       CAST((CHECKSUM(e.id_empleado * 100 + s.n, 41) & 2147483647) % 400 / 10.0 AS DECIMAL(6,2)),
       CAST(e.salario * 0.08 AS DECIMAL(12,2))
FROM dbo.empleados e
JOIN #n s ON s.n <= @MESES_NOMINA;

/* ---------- Ventas (tabla grande) ---------- */
INSERT INTO dbo.ventas (id_venta, fecha, id_cliente, id_producto, id_empleado, cantidad, descuento, canal)
SELECT s.n,
       DATEADD(DAY, r.h1 % 1826, CAST('2021-01-01' AS DATE)),
       1 + r.h2 % @N_CLIENTES,
       1 + r.h3 % @N_PRODUCTOS,
       1 + r.h4 % @N_EMPLEADOS,
       1 + r.h5 % 10,
       CHOOSE(1 + r.h6 % 5, 0.00, 0.00, 0.05, 0.10, 0.15),
       CHOOSE(1 + r.h7 % 4, N'Tienda', N'Web', N'Teléfono', N'Marketplace')
FROM #n s
CROSS APPLY (SELECT CHECKSUM(s.n, 31) & 2147483647 AS h1, CHECKSUM(s.n, 32) & 2147483647 AS h2,
                    CHECKSUM(s.n, 33) & 2147483647 AS h3, CHECKSUM(s.n, 34) & 2147483647 AS h4,
                    CHECKSUM(s.n, 35) & 2147483647 AS h5, CHECKSUM(s.n, 36) & 2147483647 AS h6,
                    CHECKSUM(s.n, 37) & 2147483647 AS h7) r
WHERE s.n <= @N_VENTAS;

/* ---------- Comparendos (tabla grande) ---------- */
INSERT INTO dbo.comparendos (id_comparendo, fecha, cod_muni, tipo_infraccion, valor, pagado)
SELECT s.n,
       DATEADD(DAY, r.h1 % 1826, CAST('2021-01-01' AS DATE)),
       m.cod_muni,
       CHOOSE(1 + r.h3 % 8, N'Exceso de velocidad', N'Estacionamiento indebido', N'No portar SOAT',
                            N'Semáforo en rojo', N'Sin revisión técnico-mecánica', N'Uso de celular',
                            N'Conducir en estado de embriaguez', N'Sin cinturón de seguridad'),
       CAST(200000 + (r.h4 % 20) * 50000 AS DECIMAL(12,2)),
       CASE WHEN r.h5 % 100 < 62 THEN 1 ELSE 0 END
FROM #n s
CROSS APPLY (SELECT CHECKSUM(s.n, 71) & 2147483647 AS h1, CHECKSUM(s.n, 72) & 2147483647 AS h2,
                    CHECKSUM(s.n, 73) & 2147483647 AS h3, CHECKSUM(s.n, 74) & 2147483647 AS h4,
                    CHECKSUM(s.n, 75) & 2147483647 AS h5) r
JOIN #muni m ON m.idx = 1 + r.h2 % @N_MUNI
WHERE s.n <= @N_COMPARENDOS;

/* ---------- Limpieza y verificación ---------- */
DROP TABLE #n;
DROP TABLE #dep;
DROP TABLE #muni;

-- COUNT(*) lo estudiaremos en la lección 7; aquí solo sirve para verificar la carga
SELECT 'departamentos' AS tabla, COUNT(*) AS filas FROM dbo.departamentos UNION ALL
SELECT 'municipios',    COUNT(*) FROM dbo.municipios    UNION ALL
SELECT 'clientes',      COUNT(*) FROM dbo.clientes      UNION ALL
SELECT 'productos',     COUNT(*) FROM dbo.productos     UNION ALL
SELECT 'empleados',     COUNT(*) FROM dbo.empleados     UNION ALL
SELECT 'nomina',        COUNT(*) FROM dbo.nomina        UNION ALL
SELECT 'ventas',        COUNT(*) FROM dbo.ventas        UNION ALL
SELECT 'comparendos',   COUNT(*) FROM dbo.comparendos;
