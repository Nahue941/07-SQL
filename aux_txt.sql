CREATE TABLE movies (
    id          INTEGER     PRIMARY KEY,
    name        TEXT        DEFAULT NULL,
    year        INTEGER     DEFAULT NULL,
    rank        REAL        DEFAULT NULL
);

CREATE TABLE actors(
    id          INTEGER     PRIMARY KEY,
    first_name  TEXT        DEFAULT NULL,
    last_name   TEXT        DEFAULT NULL,
    gender      TEXT        DEFAULT NULL
);

CREATE TABLE roles(
    actor_id    INTEGER,
    movie_id    INTEGER,
    role_name   TEXT        DEFAULT NULL
);

/*////////////////////////////QUERIES//////////////////////////////*/

/*/////////////////       movies from 1994      /////////////////*/
--Encontrá todas las películas hechas en el año en que naciste.

SELECT name, year, rank FROM movies WHERE year = 1994;


/*/////////////////       k movies from 1982      /////////////////*/
--¿Cuantás películas tiene nuestra base de datos para el año 1982?

SELECT COUNT(*) FROM movies WHERE year = 1982;


/*/////////////////       Actor with `satck` in last_name      /////////////////*/
--Encontrá los actores que tienen "stack" en su apellido.

SELECT id, first_name, last_name, gender FROM actors WHERE last_name LIKE '%stack%';


/*/////////////////       10 Most popular first_name      /////////////////*/
--¿Cúales son los 10 nombres más populares? ¿Cúales son los 10 apellidos más populares? ¿Cuales son los full_names más populares?

SELECT first_name, COUNT(*) 
    FROM actors 
    GROUP BY first_name
    ORDER BY COUNT(*) DESC
    LIMIT 10;

    /*/////////////////       10 Most popular last_name      /////////////////*/
SELECT last_name, COUNT(*) 
    FROM actors 
    GROUP BY last_name
    ORDER BY COUNT(*) DESC
    LIMIT 10;

    /*/////////////////       10 Most popular full_name      /////////////////*/
SELECT first_name, last_name, COUNT(*) 
    FROM actors 
    GROUP BY first_name, last_name
    ORDER BY COUNT(*) DESC
    LIMIT 10;


/*////////////////       100 more active actors      /////////////////*/
--Listá el top 100 de actores más activos y el número de roles en los que participó.

SELECT first_name, last_name, COUNT(*) role_count
    FROM actors
    INNER JOIN roles ON id = actor_id
    GROUP BY actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 100;


/*////////////////       top popular movies genre      /////////////////*/
--¿Cuántas películas tiene IMBD de cada género ordenado por el más popular?

SELECT genre, COUNT(*) num_movies_by_genres
    FROM movies_genres
    INNER JOIN movies ON movie_id = id
    GROUP BY genre
    ORDER BY COUNT(*) ASC;


/*////////////////       bravehearth      /////////////////*/
--Lista el nombre y apellido de todos los actores que actuaron en la película 'Braveheart' de 1995, ordenados alfabéticamente por sus apellidos.

SELECT a.first_name, a.last_name
    FROM movies         AS m
    INNER JOIN roles            ON m.id = movie_id
    INNER JOIN actors   AS a    ON actor_id = a.id
    WHERE m.name = 'Braveheart'
        AND m.year = 1995
    ORDER BY a.last_name ASC;


/*////////////////       Noir Bisiesto      /////////////////*/
--Listá todos los directores que dirigieron una película de género 'Film-Noir' en un año bisiesto (hagamos de cuenta que todos los años divisibles por 4 son años bisiestos, aunque no sea verdad en la vida real).
--Tu query deberá retornar el nombre del director, el nombre de la película y el año, ordenado por el nombre de la película.

-- SELECT d.first_name, d.last_name, m.name, m.year
--     FROM directors                  d
--     INNER JOIN movies_directors     md      ON md.director_id = d.id
--     INNER JOIN movies               m       ON md.movie_id = m.id
--     INNER JOIN movies_genres     AS mg      ON m.id = mg.movie_id
--         WHERE m.year % 4 = 0
--             AND mg.genre = 'Film-Noir'
--         ORDER BY m.name ASC;

SELECT d.first_name, d.last_name, m.name, m.year
    FROM directors d, movies m, movies_genres mg, movies_directors md
    WHERE md.director_id = d.id 
        AND md.movie_id = m.id
        AND m.id = mg.movie_id
        AND m.year % 4 = 0
        AND mg.genre = 'Film-Noir'
        ORDER BY m.name;


/*////////////////       Bacon      /////////////////*/
--Listá todos los actores que hayann trabajado con Kevin Bacon en una película de Drama (incluí el nombre de la película) y excluí al Sr. Bacon de los resultados.

SELECT  mo.name, ac.first_name, ac.last_name
FROM actors ac, roles ro, movies mo,
(
    SELECT mg.movie_id
    FROM roles r, movies m, actors a, movies_genres mg,
    (
        SELECT id 
        FROM actors 
        WHERE first_name || ' ' || last_name = 'Kevin Bacon') kevin

    WHERE m.id = r.movie_id
        AND r.actor_id = kevin.id
        AND a.id = r.actor_id
        AND mg.movie_id = m.id
        AND mg.genre = 'Drama')movieID

WHERE ro.movie_id = movieID.movie_id
    AND ac.id = ro.actor_id
    AND mo.id = movieID.movie_id
    AND ac.first_name || ' ' || ac.last_name <> 'Kevin Bacon';


/*////////////////       Actores Inmortales      /////////////////*/
--¿Cúales son los actores que actuaron en un film antes de 1900 y también en un film después del 2000?

SELECT DISTINCT a.first_name, a.last_name, ac1.actor_id as id
FROM actors a,
(
    SELECT r1.actor_id
    FROM roles r1, movies m1
    WHERE r1.movie_id = m1.id
    AND m1.year >2000) ac1,
(
    SELECT r2.actor_id
    FROM roles r2, movies m2
    WHERE r2.movie_id = m2.id
    AND m2.year < 1900) ac2
WHERE ac1.actor_id = ac2.actor_id
    AND ac1.actor_id = a.id;


/*////////////////       Ocupados en Filmacion      /////////////////*/
--Buscá actores que hayan tenido cinco, o más, roles distintos en la misma película luego del año 1990.

SELECT a.first_name, a.last_name, m.name, m.year, rol.roles_cant
FROM
(
    SELECT r.movie_id, r.actor_id, count(*) roles_cant
    FROM 
    (
        SELECT DISTINCT actor_id, movie_id, role 
        FROM roles)r
    GROUP BY r.movie_id, r.actor_id
    HAVING count(*) > 4) rol,

movies m,
actors a
WHERE rol.movie_id = m.id
AND rol.actor_id = a.id
AND m.year > 1990;


/*////////////////       Girl Power     /////////////////*/
--Contá los números de películas que tuvieron sólo actrices. Dividilas por año.
--Empezá por incluir películas sin reparto pero, luego, estrechá tu búsqueda a películas que tuvieron reparto.

SELECT m.year, COUNT(*) femaleOnly
FROM movies m,
(
    SELECT r1.movie_id
    FROM roles r1,
    (
        SELECT wo.id
        FROM actors wo
        WHERE wo.gender = 'F'
        GROUP BY wo.id) wom

    WHERE r1.actor_id = wom.id

    EXCEPT -- El except excluye los resultados que se encuentran en la Squery de la derecha. Mismo campo comparador en ambas queries

    SELECT r2.movie_id
    FROM roles r2,
    (
        SELECT ma.id
        FROM actors ma
        WHERE ma.gender = 'M'
        GROUP BY ma.id)man

    WHERE r2.actor_id = man.id
    GROUP BY r2.movie_id)mov

WHERE mov.movie_id = m.id
GROUP BY m.year
ORDER BY m.year;


--#END