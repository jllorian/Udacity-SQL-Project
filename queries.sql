/* Author: José María Llorián Álvarez */

/* Date: 2021-09-11 */

/* Introduction:
This project analyzes the DVD Rental Database. */

/* ----------------------------------------------------------------------------------------------------------------------- */

/* Documentation:
a.- This queries have been written by using Visual Studio Code. Extensions used:
    Name: change-case
        ID: wmaurer.change-case
        Description: Quickly change the case (camelCase, CONSTANT_CASE, snake_case, etc) of the current selection or current word
        Version: 1.0.0
        Editor: wmaurer
        VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=wmaurer.change-case
    Name: Excel Viewer
        ID: grapecity.gc-excelviewer
        Description: View Excel spreadsheets and CSV files within Visual Studio Code workspaces.
        Version: 3.0.44
        Editor: GrapeCity
        VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=GrapeCity.gc-excelviewer
    Name: SQLTools
        ID: mtxr.sqltools
        Description: Database management done right. Connection explorer, query runner, intellisense, bookmarks, query history. Feel like a database hero!
        Version: 0.23.0
        Editor: Matheus Teixeira
        VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools
    Name: SQLTools PostgreSQL/Redshift Driver
        ID: mtxr.sqltools-driver-pg
        Description: SQLTools PostgreSQL/Redshift Driver
        Version: 0.2.0
        Editor: Matheus Teixeira
        VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools-driver-pg
    Name: Tabnine - Code Faster with the All-Language AI Assistant for Code Completion, autocomplete JavaScript, Python, TypeScript, PHP, Go, Java, node.js, Ruby, C/C++, HTML/CSS, C#, Rust, SQL, Bash, Kotlin, R
        ID: tabnine.tabnine-vscode
        Description 👩‍💻🤖 JavaScript, Python, Java, Typescript & all other languages - AI Code completion plugin. Tabnine makes developers more productive by auto-completing their code.
        Version: 3.4.26
        Editor: TabNine
        VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=TabNine.tabnine-vscode
b.- Maximum characters per line are 125.
c.- Each query's columns, but the first one, are preceded by a comma (,) in order to avoid errors when executing the query (
    as I tend to put a comma in the last column prior the FROM clause). I.e.:

        SELECT  column_1 AS 1
                ,column_2 AS 2
        FROM Table_1
        ;

d.- The first column after the SELECT statement is followed by a tab, the columns are appilated in separate lines. I find
    this more appealing and easier to read.
e.- All queries are ended by a semicolon (;) in a separe line.
f.- Clauses are written in CAPITAL letters.
g.- Each query will be numerated using the following format:

        #.-

h.- Every query will be preceeded by a short introduction.
i.- Some queries will be followed by a Note explaining why I have done the query that way. */

/* Thank you for reviewing this project. */

/* ---------------------------------------------------------------------------------------------------------------------- */

/* 1.- Create a query that lists each movie, the film category it is classified in, and the number of times it has been
    rented out. Objective: understand more about the movies that families are watching. The following categories are
    considered family movies: Animation, Children, Classics, Comedy, Family, and Music. */

WITH t1 AS (SELECT  f.title AS "title"
                    ,f.film_id AS "id"
                    ,COUNT(r.*) AS "rental_count"
            FROM rental r
            JOIN inventory i
                ON i.inventory_id = r.inventory_id
            RIGHT JOIN film f
                ON f.film_id = i.film_id
            GROUP BY 1, 2
            ORDER BY 2 ASC)

SELECT  t1.title AS "Title"
        ,c.name AS "Category"
        ,t1.rental_count AS "Times Rented"
FROM t1
JOIN film_category fc
    ON fc.film_id = t1.id
JOIN category c
    ON c.category_id = fc.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 2,1 ASC
;

/* Note about query 1.-: I have opted for dividing the query in two parts. The former part (subquery) pulls the rental count
    while the latter wraps the answer to the question. As we are only interested in family-friendly categories I have
    used those categories as a filter. */

/* 2.- Provide a table with the movie titles and divide them into 4 levels based on the quartiles of the rental duration for
    movies across all categories. Indicate the catefory taht these family-friendly movies fall into. In the first query
    (1.-) we pulled the categories considered family-friendly. */

WITH t2 AS (SELECT  f.film_id AS "id"
                    ,fc.category_id AS "c_id"
                    ,name AS "c_name"
            FROM film f
            JOIN film_category fc
                ON fc.film_id = f.film_id
            JOIN category c
                ON c.category_id = fc.category_id
            WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT  f.title AS "title"
        ,t2.c_name AS "category"
        ,NTILE(4) OVER (ORDER BY f.rental_duration) AS "rental_quartile"
FROM film f
RIGHT JOIN t2
    ON t2.id = f.film_id
ORDER BY 3 ASC
;

/* Note about query 2.-: A more comprehensive way of doing this would be to create a subquery that returns the quantiles of
    all the categories, and then (in the main query) select the titles that are from the family-friendly categories.
    
    There is also the option to CREATE a #temporary_table with the family-friendly categories so all the queries using that
    category would be faster to write. However, I fell that having all the statements needed to pull the data in the same 
    query results in an easier to understand query.

    Notice that I have used A RIGHT JOIN. The objective was to be sure that the query returns every family-friendly title. 
    */

/* 3.- Provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies 
    within each combination of film category for each corresponding rental duration category. The resulting table should 
    have three columns:

        - Category
        - Rental length category
        - Count
    */
    
WITH t3 AS (SELECT  c.name AS "category"
                    ,NTILE(4) OVER (ORDER BY f.rental_duration) AS "rental_length_q"
            FROM film f
            JOIN film_category fc
                ON fc.film_id = f.film_id
            JOIN category c
                ON c.category_id = fc.category_id
            WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT  t3.category AS "Category"
        ,t3.rental_length_q AS "Rental Length Category"
        ,COUNT(t3.rental_length_q) AS "Titles Count"
FROM t3
GROUP BY 1, 2
ORDER BY 1, 2 ASC
;

/* 4.- We want to know on which day of the week are family-friendly films more commonly rented. We have already defined the 
    family-friendly categories. To solve this question, we will calculate the mode of the rental day of the family-friendly 
    category and compare it with the non-family-friendly. */

WITH t4 AS (SELECT  CASE WHEN c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') THEN 'f_friendly'
                        ELSE 'normal'
                    END AS "category_group"
                    ,CASE WHEN EXTRACT(DOW FROM r.rental_date) = '0' THEN 'Sunday'
                        WHEN EXTRACT(DOW FROM r.rental_date) = '1' THEN 'Monday'
                        WHEN EXTRACT(DOW FROM r.rental_date) = '2' THEN 'Tuesday'
                        WHEN EXTRACT(DOW FROM r.rental_date) = '3' THEN 'Thursday'
                        WHEN EXTRACT(DOW FROM r.rental_date) = '4' THEN 'Wednesday'
                        WHEN EXTRACT(DOW FROM r.rental_date) = '5' THEN 'Friday'
                        ELSE 'Saturday'
                    END AS "week_day"
            FROM film f
            JOIN film_category fc
                ON fc.film_id = f.film_id
            JOIN category c
                ON c.category_id = fc.category_id
            JOIN inventory i
                ON i.film_id = f.film_id
            JOIN rental r
                ON r.inventory_id = i.inventory_id),
t5 AS (SELECT   category_group 
                ,week_day AS "mode"
                ,COUNT(*) AS "family_friendly_count"
                ,SUM(COUNT(*)) OVER (PARTITION BY week_day) AS "global_count"
        FROM t4
        GROUP BY week_day, category_group
        ORDER BY 3 DESC)

SELECT  CASE WHEN category_group ='f_friendly' THEN 'f_friendly'
            ELSE 'all'
        END AS "Category"
        ,mode AS "Mode"
        ,CASE WHEN category_group = 'f_friendly' THEN family_friendly_count
            ELSE global_count
        END AS "frequency"
FROM t5 -- This query has been ran without the WHERE clause to pick up the whole week, and then with it to get both modes.
WHERE family_friendly_count >= ALL (SELECT COUNT(*) FROM t4 GROUP BY week_day, category_group)
    OR global_count >= ALL (SELECT COUNT(*) FROM t4 GROUP BY week_day, category_group)
;
/* The WHERE clause has been inspired by: https://stackoverflow.com/a/34229964 */