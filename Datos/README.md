# Datos de práctica

Base de datos ficticia `PracticaSQL` con tres áreas (geografía, ventas e inventario, recursos humanos) y dos tablas grandes: `ventas` y `comparendos`.

## Opción A: SQL Server (recomendada)

Genera los datos directamente en tu servidor, sin archivos pesados.

1. Ejecuta `01_crear_base_y_tablas.sql`. Crea la base `PracticaSQL` (si ya existe, la borra) y las 8 tablas.
2. Ejecuta `02_poblar_datos_masivos.sql` **completo, como un solo lote**:
   - SSMS o Azure Data Studio: selecciona todo y ejecuta.
   - DBeaver: `Ctrl+A` y luego `Ctrl+Enter`, que envía la selección como un único lote. Con `Alt+X` (ejecutar script) DBeaver parte el texto en sentencias y se pierden las variables `@`.
3. Al final verás una tabla con el número de filas de cada tabla.

Si tu equipo es modesto, baja `@N_VENTAS` y `@N_COMPARENDOS` al inicio del script 02.

Los datos son pseudoaleatorios pero deterministas: con los volúmenes por defecto, todas las personas obtienen los mismos datos y los mismos resultados.

## Opción B: Python (CSV o SQLite)

```bash
python generar_datos.py                      # CSV en la carpeta salida/
python generar_datos.py --sqlite practica.db # además crea una base SQLite
python generar_datos.py --ventas 5000000     # más filas
```

Solo necesita Python 3, sin instalar librerías. Los CSV se pueden importar a SQL Server con el asistente de importación de DBeaver o con `BULK INSERT`. La opción SQLite sirve para practicar sin instalar SQL Server, pero algunas funciones cambian respecto a T-SQL.

## Aviso

Esta carpeta es material de práctica: no contiene datos reales de personas, empresas ni hechos.
