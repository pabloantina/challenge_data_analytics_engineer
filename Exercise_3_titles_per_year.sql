SELECT release_year, 
COUNT(*) AS cantidad_titulos
FROM table_netflix_titles
WHERE release_year IS NOT NULL
GROUP BY release_year
ORDER BY release_year;