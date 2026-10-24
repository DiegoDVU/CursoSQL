#!/usr/bin/env python3
"""
Generador de datos ficticios para el curso de SQL (alternativa en Python).

Crea los mismos 8 tablas del modelo PracticaSQL en archivos CSV y, si lo pides,
tambien una base SQLite lista para consultar. Solo usa la libreria estandar.

Ejemplos:
    python generar_datos.py                                  # CSV con volumenes por defecto
    python generar_datos.py --ventas 5000000                 # mas filas
    python generar_datos.py --sqlite practica.db             # ademas crea una base SQLite
    python generar_datos.py --clientes 1000 --ventas 5000 --comparendos 2000   # prueba rapida

Los datos son ficticios. Con la misma --semilla siempre se obtienen los mismos datos.
"""
import argparse
import csv
import os
import random
import sqlite3
from datetime import date, timedelta

INICIO = date(2021, 1, 1)
DIAS = 1826  # 2021-01-01 hasta 2025-12-31

# (cod_depto, departamento, region, ciudad principal)
DEPARTAMENTOS = [
    (5, "Antioquia", "Andina", "Medellín"), (8, "Atlántico", "Caribe", "Barranquilla"),
    (11, "Bogotá D.C.", "Andina", "Bogotá"), (13, "Bolívar", "Caribe", "Cartagena"),
    (15, "Boyacá", "Andina", "Tunja"), (17, "Caldas", "Andina", "Manizales"),
    (18, "Caquetá", "Amazonía", "Florencia"), (19, "Cauca", "Pacífica", "Popayán"),
    (20, "Cesar", "Caribe", "Valledupar"), (23, "Córdoba", "Caribe", "Montería"),
    (25, "Cundinamarca", "Andina", "Soacha"), (27, "Chocó", "Pacífica", "Quibdó"),
    (41, "Huila", "Andina", "Neiva"), (44, "La Guajira", "Caribe", "Riohacha"),
    (47, "Magdalena", "Caribe", "Santa Marta"), (50, "Meta", "Orinoquía", "Villavicencio"),
    (52, "Nariño", "Pacífica", "Pasto"), (54, "Norte de Santander", "Andina", "Cúcuta"),
    (63, "Quindío", "Andina", "Armenia"), (66, "Risaralda", "Andina", "Pereira"),
    (68, "Santander", "Andina", "Bucaramanga"), (70, "Sucre", "Caribe", "Sincelejo"),
    (73, "Tolima", "Andina", "Ibagué"), (76, "Valle del Cauca", "Pacífica", "Cali"),
    (81, "Arauca", "Orinoquía", "Arauca"), (85, "Casanare", "Orinoquía", "Yopal"),
    (86, "Putumayo", "Amazonía", "Mocoa"), (88, "San Andrés y Providencia", "Insular", "San Andrés"),
    (91, "Amazonas", "Amazonía", "Leticia"), (94, "Guainía", "Amazonía", "Inírida"),
    (95, "Guaviare", "Amazonía", "San José del Guaviare"), (97, "Vaupés", "Amazonía", "Mitú"),
    (99, "Vichada", "Orinoquía", "Puerto Carreño"),
]

NOMBRES = ["Laura", "Carlos", "Marta", "Andrés", "Sofía", "Jorge", "Paula", "Iván", "Camila", "Felipe",
           "Valentina", "Santiago", "Daniela", "Mateo", "Natalia", "Sebastián", "Juliana", "Esteban",
           "Carolina", "Alejandro"]
APELLIDOS = ["Gómez", "Ruiz", "Peña", "Silva", "Torres", "Mora", "Díaz", "Castro", "Rojas", "Vargas",
             "Herrera", "Ortiz", "Ramírez", "Moreno", "Jiménez", "Cárdenas", "Pardo", "Suárez",
             "Mendoza", "León"]
CATEGORIAS = ["Hogar", "Tecnología", "Ropa", "Deportes", "Juguetes", "Alimentos", "Belleza",
              "Ferretería", "Automotriz"]
SEGMENTOS = ["Minorista"] * 6 + ["Corporativo"] * 3 + ["Mayorista"]
CARGOS = ["Auxiliar"] * 7 + ["Analista"] * 5 + ["Asesor"] * 4 + ["Técnico"] * 2 + ["Coordinador", "Director"]
AREAS = ["Ventas", "Contabilidad", "Recursos Humanos", "Control Interno", "Sistemas", "Logística"]
CANALES = ["Tienda", "Web", "Teléfono", "Marketplace"]
DESCUENTOS = [0.00, 0.00, 0.05, 0.10, 0.15]
INFRACCIONES = ["Exceso de velocidad", "Estacionamiento indebido", "No portar SOAT", "Semáforo en rojo",
                "Sin revisión técnico-mecánica", "Uso de celular", "Conducir en estado de embriaguez",
                "Sin cinturón de seguridad"]

ESQUEMA_SQLITE = {
    "departamentos": "cod_depto INTEGER PRIMARY KEY, departamento TEXT, region TEXT",
    "municipios": "cod_muni INTEGER PRIMARY KEY, municipio TEXT, cod_depto INTEGER, poblacion INTEGER",
    "clientes": "id_cliente INTEGER PRIMARY KEY, nombre TEXT, cod_muni INTEGER, segmento TEXT, "
                "fecha_registro TEXT, activo INTEGER",
    "productos": "id_producto INTEGER PRIMARY KEY, producto TEXT, categoria TEXT, "
                 "precio_unitario REAL, costo_unitario REAL, stock INTEGER",
    "empleados": "id_empleado INTEGER PRIMARY KEY, nombre TEXT, cargo TEXT, area TEXT, salario REAL, "
                 "cod_muni INTEGER, fecha_ingreso TEXT",
    "nomina": "id_nomina INTEGER PRIMARY KEY, id_empleado INTEGER, periodo TEXT, salario_base REAL, "
              "horas_extra REAL, deducciones REAL",
    "ventas": "id_venta INTEGER PRIMARY KEY, fecha TEXT, id_cliente INTEGER, id_producto INTEGER, "
              "id_empleado INTEGER, cantidad INTEGER, descuento REAL, canal TEXT",
    "comparendos": "id_comparendo INTEGER PRIMARY KEY, fecha TEXT, cod_muni INTEGER, "
                   "tipo_infraccion TEXT, valor REAL, pagado INTEGER",
}


def fecha_al_azar(rng, inicio=INICIO, dias=DIAS):
    return (inicio + timedelta(days=rng.randrange(dias))).isoformat()


def nombre_al_azar(rng):
    return f"{rng.choice(NOMBRES)} {rng.choice(APELLIDOS)}"


def escribir_csv(carpeta, tabla, filas):
    """Escribe una tabla en CSV (la primera linea son los nombres de columna)."""
    columnas = [c.split()[0] for c in ESQUEMA_SQLITE[tabla].split(", ")]
    ruta = os.path.join(carpeta, f"{tabla}.csv")
    total = 0
    with open(ruta, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(columnas)
        for fila in filas:
            w.writerow(fila)
            total += 1
    print(f"  {tabla}.csv: {total:,} filas")


def main():
    p = argparse.ArgumentParser(description="Genera datos ficticios para el curso de SQL")
    p.add_argument("--salida", default="salida", help="carpeta donde se escriben los CSV")
    p.add_argument("--clientes", type=int, default=200_000)
    p.add_argument("--productos", type=int, default=5_000)
    p.add_argument("--empleados", type=int, default=2_000)
    p.add_argument("--ventas", type=int, default=1_000_000)
    p.add_argument("--comparendos", type=int, default=500_000)
    p.add_argument("--meses-nomina", type=int, default=36)
    p.add_argument("--semilla", type=int, default=42)
    p.add_argument("--sqlite", help="si se indica, crea tambien esta base SQLite con los datos")
    a = p.parse_args()

    rng = random.Random(a.semilla)
    os.makedirs(a.salida, exist_ok=True)
    print(f"Generando datos en '{a.salida}'...")

    # Geografia
    escribir_csv(a.salida, "departamentos", ((c, d, r) for c, d, r, _ in DEPARTAMENTOS))
    municipios = []
    for cod, _, _, ciudad in DEPARTAMENTOS:
        municipios.append((cod * 1000 + 1, ciudad, cod, rng.randrange(150_000, 2_150_000)))
        if cod in (11, 88):
            continue
        for k in range(2, 8 + (cod * 7) % 40 + 1):
            municipios.append((cod * 1000 + k, f"Municipio {cod:02d}-{k:03d}", cod, rng.randrange(2_000, 82_000)))
    escribir_csv(a.salida, "municipios", municipios)
    cods_muni = [m[0] for m in municipios]

    # Clientes y productos
    escribir_csv(a.salida, "clientes", (
        (i, nombre_al_azar(rng), rng.choice(cods_muni), rng.choice(SEGMENTOS), fecha_al_azar(rng),
         1 if rng.random() < 0.8 else 0)
        for i in range(1, a.clientes + 1)))

    def productos():
        for i in range(1, a.productos + 1):
            cat = rng.choice(CATEGORIAS)
            precio = rng.randrange(5_000, 500_000)
            costo = round(precio * rng.uniform(0.55, 0.84), 2)
            yield (i, f"{cat} - Producto {i:04d}", cat, precio, costo, rng.randrange(500))
    escribir_csv(a.salida, "productos", productos())

    # Empleados y nomina
    empleados = [(i, nombre_al_azar(rng), rng.choice(CARGOS), rng.choice(AREAS),
                  1_800_000 + rng.randrange(5201) * 1000, rng.choice(cods_muni),
                  fecha_al_azar(rng, date(2016, 1, 1), 3650))
                 for i in range(1, a.empleados + 1)]
    escribir_csv(a.salida, "empleados", empleados)

    def nomina():
        n = 0
        for e in empleados:
            for m in range(a.meses_nomina):
                n += 1
                anio, mes = divmod(2023 * 12 + m, 12)
                yield (n, e[0], date(anio, mes + 1, 1).isoformat(), e[4],
                       round(rng.randrange(400) / 10, 1), round(e[4] * 0.08, 2))
    escribir_csv(a.salida, "nomina", nomina())

    # Tablas de hechos
    escribir_csv(a.salida, "ventas", (
        (i, fecha_al_azar(rng), rng.randint(1, a.clientes), rng.randint(1, a.productos),
         rng.randint(1, a.empleados), rng.randint(1, 10), rng.choice(DESCUENTOS), rng.choice(CANALES))
        for i in range(1, a.ventas + 1)))
    escribir_csv(a.salida, "comparendos", (
        (i, fecha_al_azar(rng), rng.choice(cods_muni), rng.choice(INFRACCIONES),
         200_000 + rng.randrange(20) * 50_000, 1 if rng.random() < 0.62 else 0)
        for i in range(1, a.comparendos + 1)))

    # SQLite opcional
    if a.sqlite:
        if os.path.exists(a.sqlite):
            os.remove(a.sqlite)
        con = sqlite3.connect(a.sqlite)
        for tabla, columnas in ESQUEMA_SQLITE.items():
            con.execute(f"CREATE TABLE {tabla} ({columnas})")
            with open(os.path.join(a.salida, f"{tabla}.csv"), encoding="utf-8") as f:
                lector = csv.reader(f)
                next(lector)
                marcas = ",".join("?" * len(columnas.split(", ")))
                con.executemany(f"INSERT INTO {tabla} VALUES ({marcas})", lector)
        con.commit()
        con.close()
        print(f"Base SQLite creada: {a.sqlite}")
    print("Listo.")


if __name__ == "__main__":
    main()
