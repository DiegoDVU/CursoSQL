# Lección 1: `SELECT` y `FROM`

## Qué es
Una base de datos es un conjunto de tablas. Cada tabla se parece a una hoja de Excel: las **columnas** son los campos (nombre, salario, área) y cada **fila** es un registro. SQL es el lenguaje con el que le pedimos datos a esas tablas.

## Estructura básica

```sql
SELECT columna1, columna2
FROM nombre_de_la_tabla;
```

- `SELECT` dice **qué columnas** quieres ver.
- `FROM` dice **de qué tabla** las tomas.
- `SELECT *` trae todas las columnas.

## Alias con `AS`
Cambia el nombre de una columna solo en el resultado, sin tocar la tabla.

```sql
SELECT nombre, salario AS sueldo_mensual
FROM empleados;
```

## `DISTINCT`: quitar repetidos
Devuelve cada valor una sola vez. Sirve para saber qué categorías existen en una columna.

```sql
SELECT DISTINCT area
FROM empleados;
```

## `TOP`: limitar filas (T-SQL)
En SQL Server se escribe `TOP n` justo después de `SELECT`. En PostgreSQL y SQLite se usa `LIMIT n` al final.

```sql
SELECT TOP 10 *
FROM ventas;
```

## Para qué sirve y dónde se usa
Es el punto de partida de cualquier análisis:
- Explorar una tabla desconocida antes de construir un reporte.
- Quedarte solo con las columnas que necesitas.
- Conocer los valores posibles de una columna (canales de venta, áreas, tipos de infracción).
- Revisar rápido qué datos llegaron a un Data Lake o a un modelo de Power BI.

## Buena práctica con tablas grandes
`ventas` tiene millones de filas. Un `SELECT *` sin `TOP` intenta traerlas todas: tarda, consume memoria y puede bloquear tu cliente. Al explorar una tabla grande:
1. Usa `TOP` para mirar una muestra.
2. Pide solo las columnas que necesitas.
3. Usa `DISTINCT` en columnas de pocas categorías, no en columnas casi únicas.

## Resumen
| Quiero... | Escribo... |
|---|---|
| Ver todo | `SELECT * FROM tabla` |
| Ver algunas columnas | `SELECT col1, col2 FROM tabla` |
| Renombrar una columna | `SELECT col AS nuevo_nombre FROM tabla` |
| Quitar repetidos | `SELECT DISTINCT col FROM tabla` |
| Ver solo una muestra | `SELECT TOP 10 * FROM tabla` |

Los ejercicios están en [`leccion-01-ejercicios.sql`](leccion-01-ejercicios.sql). Intenta resolverlos antes de abrir [las soluciones](leccion-01-soluciones.sql).
