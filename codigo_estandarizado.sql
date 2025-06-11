/*Estandarización de la columna de fecha a formato universal YYYY-MM-DD para poder filtrar correctamente los datos*/
ALTER TABLE table_netflix_titles 
ALTER COLUMN date_added TYPE DATE 
USING TO_DATE(date_added, 'Month DD, YYYY');


/*Creo dos columnas nuevas para poder desagregar la colmna 'duration' puesto que la misma tiene resultados
con valores en unidades de tiempo y en unidad de cantidad de temporadas*/

ALTER TABLE table_netflix_titles ADD COLUMN duration_int INT;
ALTER TABLE table_netflix_titles ADD COLUMN duration_type TEXT;

UPDATE table_netflix_titles 
SET duration_int = regexp_replace(duration, '[^0-9]', '', 'g')::INT,
    duration_type = regexp_replace(duration, '[0-9]', '', 'g');


/*Genero una tabla de directores, dado que hay determinados show_id que tienen mas de un director,
de esta manera tenemos el desgloce correcto de directores por pelicula*/

CREATE TABLE directores (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    director TEXT,
    CONSTRAINT unique_director_per_show UNIQUE (show_id, director));

INSERT INTO directores (show_id, director)
SELECT show_id, UNNEST(string_to_array(director, ', '))
FROM table_netflix_titles
WHERE director IS NOT NULL;

ALTER TABLE table_netflix_titles RENAME COLUMN "cast" TO actores_1;


/*Creo tabla relacional de actores de manera de poder desagregar el listado del elenco que figura en la coumna cast, 
de esta manera podriamos contabilizar los actores que tuvo cada pelicula*/

CREATE TABLE actores (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    actor TEXT,
    CONSTRAINT unique_actor_per_show UNIQUE (show_id, actor));

INSERT INTO actores (show_id, actor)
SELECT show_id, UNNEST(string_to_array(actores_1, ', '))
FROM table_netflix_titles
WHERE actores_1 IS NOT NULL;

/*Procedo a eliminar valores duplicados dentro de una misma fila para la columna referida a actores*/

UPDATE table_netflix_titles
SET actores_1 = array_to_string(
    ARRAY(SELECT DISTINCT UNNEST(string_to_array(actores_1, ', '))), ', ');


/*Actualizo el valor de la columna duration, dado que hay 3 resultados 
que tienen el valor de duration en la columna de rating*/ 

UPDATE table_netflix_titles
SET duration = rating, rating = NULL
WHERE duration IS NULL AND rating ~ '^[0-9]';


/*Dado que luego identifique el error de la columna rating que poseia valores de la columna duration, 
procedo a actualizar 'duration_int' y 'duration_type' para que impacten los resultados de cantidad 
y unidad de medida correctamente*/

UPDATE table_netflix_titles 
SET duration_int = NULLIF(regexp_replace(duration, '[^0-9]', '', 'g'), '')::INT,
    duration_type = regexp_replace(duration, '[0-9]', '', 'g');


/*Creo una tabla llamada categorias con el fin de poder deglozar corectamente las 
categorias a las que aplica cada pelicula,
dado que pueden pertenecer a mas de un genero o tipo de pelicula*/

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    categoria TEXT,
    CONSTRAINT unique_categoria_per_show UNIQUE (show_id, categoria));

INSERT INTO categorias (show_id, categoria)
SELECT show_id, UNNEST(string_to_array(listed_in, ', '))
FROM table_netflix_titles
WHERE listed_in IS NOT NULL;


/*Creo otra tabla relacional para la columna country, dado que hay varios resultados posibles por pelicula*/

CREATE TABLE paises (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    pais TEXT,
    CONSTRAINT unique_pais_per_show UNIQUE (show_id, pais));

INSERT INTO paises (show_id, pais)
SELECT show_id, UNNEST(string_to_array(country, ', '))
FROM table_netflix_titles
WHERE country IS NOT NULL;
