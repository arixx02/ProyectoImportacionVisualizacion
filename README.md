# Proyecto de importación y visualizacion
<p>
  El proyecto contiene una solucion de SQL Server con los scripts enumerados segun orden de ejecución, el pbix que esta adjunto fue generado con import mode y solo hace uso de las vistas generadas en el script 04, despues de ejecutar todos los archivos se puede conectar Power BI a las vistas directamente conectandolo a la BD
</p>
## Cosas a mejorar
<ul>
  <li>Hacer uso de indices no cluster para optimizar las consultas en las vistas</li>
  <li>Hacer uso de login y usuarios para minimizar el ingreso de Power BI a la BD</li>
</ul>
## Tecnologias
<ul>
<li>SQL Server Express</li>
<li>Power BI</li> 
<li>Python</li> 
</ul>
<p>Antes de realizar las importaciones recomiendo ejecutar el script de python para corregir el archvivo a2_anon y usar el generado en la importación, si no funciona el script hay que instalar las librerias mediante pip install</p>
## Configuracion de rutas
Sql Server no acepta rtas relativas en T - SQL asi que en todas las importaciones hay ue actualizar las rutas para el correcto funcionamiento, en el .py de igual manera hay que configurar eso.
<footer>Los datos son ficticios, generados plenamente para el desarrollo academico del proyecto</footer>
