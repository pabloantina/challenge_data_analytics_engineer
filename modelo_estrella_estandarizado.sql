/* 
Modelo Estrella para análisis de contenido de Netflix.
Este modelo está compuesto por:
 - Tabla de hechos: main_table
 - Dimensiones: fecha, tipo (serie - pelicula), duración, país, actor, categoría.
 - Este modelo esta basado en la estandarización previa dado que algunas tablas ya habian sido creadas
 con motivo de poder desagregar la información de los datos crudos de 'table_netflix_titles'*/


/* Tabla principal, referida a los hechos. */
CREATE TABLE main_table (
    id SERIAL PRIMARY KEY,
    show_id TEXT UNIQUE REFERENCES table_netflix_titles(show_id),
    id_fecha DATE,
    id_tipo TEXT,
    id_duracion_tipo TEXT,
    duracion_int INT
);

INSERT INTO main_table (show_id, id_fecha, id_tipo, id_duracion_tipo, duracion_int)
SELECT 
    show_id,
    date_added,
    type,
    duration_type,
    duration_int
FROM table_netflix_titles;

/* Tabla destinada a la dimension de tiempo - espacio. */
CREATE TABLE dimension_date (
    id_fecha DATE PRIMARY KEY,
    year INT,
    mes INT,
    dia INT);

INSERT INTO dimension_date (id_fecha, year, mes, dia)
SELECT DISTINCT
    date_added,
    EXTRACT(YEAR FROM date_added)::INT,
    EXTRACT(MONTH FROM date_added)::INT,
    EXTRACT(DAY FROM date_added)::INT
FROM table_netflix_titles
WHERE date_added IS NOT NULL


/* Tabla destinada a la dimensión de tipo de contenido serie - pelicula. */
CREATE TABLE dimension_type (
    id_tipo TEXT PRIMARY KEY
);

INSERT INTO dimension_type
SELECT DISTINCT type FROM table_netflix_titles;

/* Las siguientes tres tablas categorias, actores y paises fueron creadas previamente en la estandarización de datos,
a partir de tablas relacionales, de manera tal de poder desglozar las cadenas de texto por cada show_id y poder
realizar una correcta contabilziación para cada una de estas dimensiones */

/*Tabla de categorias*/
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    categoria TEXT,
    CONSTRAINT unique_categoria_per_show UNIQUE (show_id, categoria));

INSERT INTO categorias (show_id, categoria)
SELECT show_id, UNNEST(string_to_array(listed_in, ', '))
FROM table_netflix_titles
WHERE listed_in IS NOT NULL;

/*Tabla de actores*/
CREATE TABLE actores (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    actor TEXT,
    CONSTRAINT unique_actor_per_show UNIQUE (show_id, actor));

INSERT INTO actores (show_id, actor)
SELECT show_id, UNNEST(string_to_array(actores_1, ', '))
FROM table_netflix_titles
WHERE actores_1 IS NOT NULL;

/*Tabla de paises*/
CREATE TABLE paises (
    id SERIAL PRIMARY KEY,
    show_id TEXT REFERENCES table_netflix_titles(show_id),
    pais TEXT,
    CONSTRAINT unique_pais_per_show UNIQUE (show_id, pais));

INSERT INTO paises (show_id, pais)
SELECT show_id, UNNEST(string_to_array(country, ', '))
FROM table_netflix_titles
WHERE country IS NOT NULL;
