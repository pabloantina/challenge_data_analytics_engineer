SELECT 
categoria,
count(categoria) AS quantity_categories
FROM categorias
GROUP BY categoria
ORDER BY quantity_categories DESC
