# Curso de SQL para análisis de datos

Repositorio de estudio de Diego ([@DiegoDVU](https://github.com/DiegoDVU)). Aquí guardo lo que voy aprendiendo de SQL, organizado por niveles, con apuntes, ejercicios y las consultas que resuelvo. El objetivo es dominar SQL aplicado al análisis de datos y dejar un portafolio de consultas sobre volúmenes grandes de datos.

- **Motor de referencia:** SQL Server (T-SQL), consultado con DBeaver.
- **Datos:** ficticios, generados por script, con millones de filas para practicar como en un entorno de Big Data.
- **Metodología:** cada lección tiene apuntes (qué es, para qué sirve, dónde se usa), ejercicios prácticos y un reto al final de cada nivel.

## Estructura

```
curso-sql-analisis-datos/
├── README.md                  <- este archivo: índice y progreso
├── datos/                     <- scripts para crear la base y llenarla de datos
│   ├── README.md
│   ├── 01_crear_base_y_tablas.sql
│   ├── 02_poblar_datos_masivos.sql
│   └── generar_datos.py       <- alternativa en Python (CSV o SQLite)
├── 01-principiante/           <- leer y filtrar datos
├── 02-basico/                 <- resumir y combinar tablas
└── 03-avanzado/               <- análisis profundo y buenas prácticas
```

## Cómo empezar

1. Instala SQL Server (la edición Developer o Express sirve) y DBeaver.
2. Sigue las instrucciones de [`datos/README.md`](datos/README.md) para crear la base `PracticaSQL` y llenarla de datos.
3. Abre la lección que corresponda, lee los apuntes y resuelve los ejercicios antes de mirar las soluciones.

## Modelo de datos (resumen)

| Tabla | Qué contiene | Filas por defecto |
|---|---|---|
| `departamentos` | Departamentos de Colombia y su región | 33 |
| `municipios` | Ciudades principales y municipios ficticios | ~850 |
| `clientes` | Clientes ficticios por municipio y segmento | 200.000 |
| `productos` | Catálogo con precio, costo y stock | 5.000 |
| `empleados` | Empleados por área y cargo | 2.000 |
| `nomina` | Nómina mensual simplificada por empleado | 72.000 |
| `ventas` | Ventas 2021-2025 | 5.000.000 |
| `comparendos` | Comparendos de tránsito 2021-2025 | 2.000.000 |

Todos los datos son ficticios y no representan cifras reales.

## Temario y progreso

### Nivel 1: principiante
- [ ] 01. `SELECT`, `FROM`, alias y `DISTINCT`
- [ ] 02. `WHERE` y operadores de comparación
- [ ] 03. `ORDER BY` y `TOP`
- [ ] 04. `IN`, `BETWEEN`, `LIKE` e `IS NULL`
- [ ] 05. Tipos de datos, `CREATE TABLE` e `INSERT`
- [ ] 06. `UPDATE` y `DELETE`
- [ ] Reto del nivel 1

### Nivel 2: básico
- [ ] 07. Agregaciones: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- [ ] 08. `GROUP BY` y `HAVING`
- [ ] 09. `INNER JOIN`
- [ ] 10. `LEFT`, `RIGHT` y `FULL JOIN`
- [ ] 11. Funciones de texto y fechas
- [ ] 12. `CASE WHEN` y manejo de nulos
- [ ] 13. `UNION` y `UNION ALL`
- [ ] Reto del nivel 2

### Nivel 3: avanzado
- [ ] 14. Subconsultas
- [ ] 15. CTEs (`WITH`)
- [ ] 16. Window functions
- [ ] 17. Claves, normalización y modelo estrella
- [ ] 18. Vistas y procedimientos almacenados
- [ ] 19. Índices y planes de ejecución
- [ ] 20. Consultas para dashboards en Power BI
- [ ] Proyecto final
