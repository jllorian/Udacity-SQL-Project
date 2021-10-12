SELECT  f.title AS movie_title
                    ,AGE(r.return_date::TIMESTAMP, r.rental_date::TIMESTAMP)
            FROM rental r
            JOIN inventory i
                ON i.inventory_id = r.inventory_id
            JOIN film f
                ON f.film_id = i.film_id
            GROUP BY 1, r.return_date, r.rental_date