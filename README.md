# Proyecto de Importación y Visualización

Este proyecto permite importar y visualizar datos utilizando **SQL Server** y **Power BI**. Contiene scripts de SQL Server organizados según el orden de ejecución, además de un archivo `.pbix` generado en modo de importación, que se conecta únicamente a las vistas generadas en el script `04`.

Una vez ejecutados todos los scripts, Power BI puede conectarse directamente a las vistas de la base de datos.

---

## Tecnologías Utilizadas

- SQL Server Express  
- Power BI  
- Python  

---

## Pasos Recomendados

### 1. Corrección de archivos de origen
Antes de realizar la importación de datos, se recomienda ejecutar el script de Python para corregir el archivo `a2_anon`. El archivo generado será el que se utilice en la importación.

> **Nota:** Si el script no funciona, instalar las librerías necesarias con (desde la raiz del proyecto):
>
> ```bash
> pip install -r requerimientos.txt
> ```

### 2. Ejecución de scripts SQL
Los scripts están numerados según el orden de ejecución. Se recomienda seguir este orden para asegurar que todas las vistas y tablas se generen correctamente.

### 3. Configuración de rutas
SQL Server no acepta rutas relativas en T-SQL. Todas las rutas deben actualizarse para asegurar el correcto funcionamiento de las importaciones.  
En el script de Python también es necesario ajustar las rutas de los archivos de datos.

### 4. Conexión con Power BI
Una vez ejecutados los scripts, el archivo `.pbix` puede conectarse directamente a las vistas de la base de datos.

---

## Mejoras Sugeridas

- Implementar **índices no cluster** en las vistas para optimizar las consultas.  
- Configurar **logins y usuarios** para limitar el acceso directo de Power BI a la base de datos.  

---

## Notas

- Los datos son **ficticios**, generados exclusivamente con fines académicos y de desarrollo del proyecto.  
- Es importante revisar y ajustar las rutas y permisos antes de ejecutar las importaciones.
