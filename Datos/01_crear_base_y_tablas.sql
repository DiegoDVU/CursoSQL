/* ============================================================================
   Curso SQL para análisis de datos
   Paso 1 de 2: crear la base PracticaSQL y sus tablas (SQL Server / T-SQL)

   - Todos los datos del curso son FICTICIOS y sirven solo para practicar.
   - Este script BORRA y vuelve a crear la base PracticaSQL si ya existe.
   - Las tablas no tienen índices adicionales a propósito: en el nivel avanzado
     los crearás para medir cuánto mejora el rendimiento con millones de filas.
   ============================================================================ */

USE master;
GO

IF DB_ID('PracticaSQL') IS NOT NULL
BEGIN
    ALTER DATABASE PracticaSQL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PracticaSQL;
END
GO

CREATE DATABASE PracticaSQL;
GO

-- Modo simple: el log de transacciones no crece sin control al cargar millones de filas
ALTER DATABASE PracticaSQL SET RECOVERY SIMPLE;
GO

USE PracticaSQL;
GO

/* ---------- Geografía ---------- */
CREATE TABLE dbo.departamentos (
    cod_depto     TINYINT       NOT NULL PRIMARY KEY,
    departamento  NVARCHAR(60)  NOT NULL,
    region        NVARCHAR(20)  NOT NULL
);

CREATE TABLE dbo.municipios (
    cod_muni   INT           NOT NULL PRIMARY KEY,
    municipio  NVARCHAR(80)  NOT NULL,
    cod_depto  TINYINT       NOT NULL REFERENCES dbo.departamentos(cod_depto),
    poblacion  INT           NOT NULL
);

/* ---------- Ventas e inventario ---------- */
CREATE TABLE dbo.clientes (
    id_cliente      INT           NOT NULL PRIMARY KEY,
    nombre          NVARCHAR(80)  NOT NULL,
    cod_muni        INT           NOT NULL REFERENCES dbo.municipios(cod_muni),
    segmento        NVARCHAR(15)  NOT NULL,
    fecha_registro  DATE          NOT NULL,
    activo          BIT           NOT NULL
);

CREATE TABLE dbo.productos (
    id_producto      INT            NOT NULL PRIMARY KEY,
    producto         NVARCHAR(80)   NOT NULL,
    categoria        NVARCHAR(30)   NOT NULL,
    precio_unitario  DECIMAL(12,2)  NOT NULL,
    costo_unitario   DECIMAL(12,2)  NOT NULL,
    stock            INT            NOT NULL
);

/* ---------- Recursos humanos ---------- */
CREATE TABLE dbo.empleados (
    id_empleado    INT            NOT NULL PRIMARY KEY,
    nombre         NVARCHAR(80)   NOT NULL,
    cargo          NVARCHAR(30)   NOT NULL,
    area           NVARCHAR(30)   NOT NULL,
    salario        DECIMAL(12,2)  NOT NULL,
    cod_muni       INT            NOT NULL REFERENCES dbo.municipios(cod_muni),
    fecha_ingreso  DATE           NOT NULL
);

/* ---------- Tablas de hechos (las grandes) ---------- */
CREATE TABLE dbo.ventas (
    id_venta     BIGINT         NOT NULL PRIMARY KEY,
    fecha        DATE           NOT NULL,
    id_cliente   INT            NOT NULL REFERENCES dbo.clientes(id_cliente),
    id_producto  INT            NOT NULL REFERENCES dbo.productos(id_producto),
    id_empleado  INT            NOT NULL REFERENCES dbo.empleados(id_empleado),
    cantidad     TINYINT        NOT NULL,
    descuento    DECIMAL(4,2)   NOT NULL,
    canal        NVARCHAR(15)   NOT NULL
);

CREATE TABLE dbo.nomina (
    id_nomina     INT            NOT NULL PRIMARY KEY,
    id_empleado   INT            NOT NULL REFERENCES dbo.empleados(id_empleado),
    periodo       DATE           NOT NULL,   -- primer día de cada mes
    salario_base  DECIMAL(12,2)  NOT NULL,
    horas_extra   DECIMAL(6,2)   NOT NULL,
    deducciones   DECIMAL(12,2)  NOT NULL
);

CREATE TABLE dbo.comparendos (
    id_comparendo    BIGINT         NOT NULL PRIMARY KEY,
    fecha            DATE           NOT NULL,
    cod_muni         INT            NOT NULL REFERENCES dbo.municipios(cod_muni),
    tipo_infraccion  NVARCHAR(40)   NOT NULL,
    valor            DECIMAL(12,2)  NOT NULL,
    pagado           BIT            NOT NULL
);
GO
