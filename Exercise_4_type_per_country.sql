SELECT
p.pais, 
n.type, 
COUNT(*) AS cantidad_titulos
FROM table_netflix_titles n
JOIN paises p 
ON n.show_id = p.show_id
WHERE p.pais IS NOT NULL
GROUP BY p.pais, n.type
ORDER BY cantidad_titulos DESC;
