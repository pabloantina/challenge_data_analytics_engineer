SELECT 
pais,
count(pais) AS quantity_paises
FROM paises
GROUP BY pais
ORDER BY quantity_paises DESC
LIMIT 10