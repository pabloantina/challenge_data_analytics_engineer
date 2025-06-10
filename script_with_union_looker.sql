
WITH union_data AS (
/*Realizo un JOIN previo en cada una de las dos tablas relacionales con la tabla principal destinada al catalogo.
Luego realizo un UNION entre ambas tablas completadas para obtener el desgloce de paises y categorias con columnas adicionales de interes*/

/*Coloco varios TRIMs dado que al haber descargado previamente la data y utilizarla en Looker Studio, encontre que no matcheaban los valores texto con las condiciones que colocaba,
al revisar la fuente descargada note que las columnas tenian posterior a su texto espacios vacios que "rompian" mis condiciones*/

SELECT
TRIM(n.show_id) AS show_id,
TRIM(type) AS type, 
TRIM(title) AS title,
NULL AS categoria,
TRIM(p.pais) AS pais,
TRIM(country) AS country,
date_added, 
release_year, 
TRIM(rating) AS rating, 
TRIM(duration) AS duration, 
TRIM(listed_in) AS listed_in, 
TRIM(description) AS description,
duration_int,
TRIM(duration_type) AS duration_type
FROM table_netflix_titles n

JOIN paises p 
ON TRIM(n.show_id) = TRIM(p.show_id)

UNION ALL

SELECT
TRIM(n.show_id) AS show_id,
TRIM(type) AS type, 
TRIM(title) AS title,
TRIM(c.categoria) AS categoria,
NULL AS pais,
TRIM(country) AS country,
date_added, 
release_year, 
TRIM(rating) AS rating, 
TRIM(duration) AS duration, 
TRIM(listed_in) AS listed_in, 
TRIM(description) AS description,
duration_int,
TRIM(duration_type) AS duration_type
FROM table_netflix_titles n

JOIN categorias c 
ON TRIM(n.show_id) = TRIM(c.show_id)
)

/*Una vez unidas ambas tablas, procedo a colocar un row_number 
que me facilitara el posterior filtrado para contabilizar show_id unicos entre otras variables*/

SELECT *,
ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY pais NULLS LAST, categoria NULLS LAST) AS row_number
FROM union_data;