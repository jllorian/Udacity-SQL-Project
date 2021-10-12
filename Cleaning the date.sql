
SELECT  (EXTRACT(epoch FROM r.return_date::TIMESTAMP) - EXTRACT(epoch FROM r.rental_date::TIMESTAMP))/60::INT
/* SOURCE: https://dba.stackexchange.com/questions/53924/how-do-i-get-the-difference-in-minutes-from-2-timestamp-columns
    and https://www.postgresql.org/docs/current/functions-datetime.html 
    Prior finding that post I tried the AGE function. However, this seems cleaner. */
FROM rental r