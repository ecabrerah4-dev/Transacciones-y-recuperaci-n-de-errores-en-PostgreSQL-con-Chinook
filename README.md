# Práctica de Transacciones y Control Concurrente en PostgreSQL (Chinook)

Evaluación centrada en el control transaccional, atomicidad, manejo de errores, puntos de salvado (`SAVEPOINT`), aislamiento y visibilidad entre sesiones concurrentes utilizando una copia local de la base de datos **Chinook**.

---

## 🛠️ 1. Entorno y Prerrequisitos
* **Motor de Base de Datos:** PostgreSQL 18
* **Cliente SQL:** DataGrip / psql
* **Base de Datos:** Variante oficial de Chinook https://github.com/lerocha/chinook-database (`Chinook_PostgreSql_SerialPKs.sql`)

---

## 🚀 2. Orden de Ejecución de las Pruebas

Ejecuta los scripts en el siguiente orden lógico:

1. **`01_venta_exitosa.sql` (Sesión A):** Crea una venta con sus detalles y calcula el total. Se pausará antes de confirmar.
   * *Verificación:* Corre `04_validaciones.sql` en la **Sesión B** para comprobar que aún no es visible. Vuelve a la Sesión A para confirmar (`COMMIT`) y repite la validación en B para ver los datos confirmados.

2. **`02_rollback_total.sql` (Sesión A):** Simula un error de llave foránea al insertar un código inexistente, demostrando la reversión total (`ROLLBACK`) sin dejar registros incompletos.

3. **`03_savepoint.sql` (Sesión A):** Demuestra el uso de puntos de salvado (`SAVEPOINT`) para anular una operación de riesgo individual sin perder los detalles válidos que ya se habían preparado.

4. **`04_validaciones.sql`:** Script global para comprobar la integridad referencial y la ausencia de registros huérfanos.

---

##  3. Manejo de Errores

Si tu consola se detiene de inmediato ante un error, ejecuta manualmente el comando de recuperación correspondiente antes de continuar:
* **Para el Escenario 2:** `ROLLBACK;`
* **Para el Escenario 3:** `ROLLBACK TO SAVEPOINT antes_riesgo;`

Manejo de Errores
Si tu consola se detiene de inmediato ante un error, ejecuta manualmente el comando de recuperación correspondiente antes de continuar:

Para el Escenario 2: ROLLBACK;
Para el Escenario 3: ROLLBACK TO SAVEPOINT antes_riesgo;

