USE music_store;

-- Q1 : Top 3 most tenured employees ?

SELECT first_name,last_name, str_to_date(hire_date,'%d-%m-%Y') as hireDate
from employee
order by hireDate desc
limit 3;

-- Q2 : Which country has most number of invoices ?

select billing_country, count(billing_country) as count_country
from invoice
group by billing_country
order by count_country desc;

-- Q3 : Top 5 countries with max spent ?

select billing_country, round(sum(total),2)  as amount_spent
from invoice
group by billing_country
order by amount_spent desc
limit 5;

-- Q4 : Music company wants to organize a music festival in the city which has maximum amount spent

select billing_country, billing_city, round(sum(total),2)  as amount_spent
from invoice
group by billing_city, billing_country
order by amount_spent desc
limit 5;

-- Q5 : Find the best 5 customers who has spend maximum money is store ?

SELECT c.customer_id, c.first_name, c.last_name, round(sum(i.total),2) as amount_spent 
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by amount_spent desc
limit 5;

-- Q6 : write a query to return First name, last name, email who listen to rock genre, with email adresses sorted ?

select distinct c.first_name, c.last_name, c.email
from customer c
join invoice i   on i.customer_id = c.customer_id
join invoice_line il  on il.invoice_id = i.invoice_id
join track t  on t.track_id = il.track_id
join Genre g  on g.Genre_Id = t.Genre_Id
where g.genre_id = (select Genre_Id from Genre where Name = "rock")
order by c.email;

-- same query with more optimized solution

select distinct c.first_name, c.last_name, c.email
from customer c
join invoice i   on i.customer_id = c.customer_id
join invoice_line il  on il.invoice_id = i.invoice_id
where track_id IN ( select track_id from track t 
join genre g on g.genre_id = t.genre_id
where g.name = "rock" )
order by c.email;

-- Q7 : write a query to return artist id, name , number of songs in desc order who wrote rock songs ?

select ar.artist_id, ar.name, count(*) as count_of_songs
from artist ar
join album2 al on ar.artist_id = al.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like "rock"
group by ar.artist_id, ar.name
order by count_of_songs desc;

-- Q8 : return name and milisecond of all the songs which more than the average song length and in desc order ?

select name, milliseconds 
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- Q9 : Find how much amount spend by each customer on artists ? write a query to return customer name, artist name and total spent ?

 select c.customer_id,c.first_name as customer_firstname, c.last_name as customer_lastname,a.name as artist, round(sum(i.total),2) as amount_spent
 from customer c
 join invoice i on c.customer_id = i.customer_id
 join invoice_line il on i.invoice_id = il.invoice_id
 join track t on t.track_id = il.track_id
 join album2 al on al.album_id = t.album_id
 join artist a on a.artist_id = al.artist_id
 group by c.customer_id,c.first_name, c.last_name,a.name
 order by amount_spent desc;
 
-- Q10 : we want to find out the most popular music genre for each country based on most number of purchases ?  

with count_table as ( 
select i.billing_country,  g.name, count(*) as count
from invoice i
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by i.billing_country, g.name
order by billing_country 
) 

select billing_country, name, max(count) as max_count 
from count_table
group by billing_country, name
order by max_count desc ;

-- Q11 : Write a query that determines the customer that has spent the most on music for each country ?
-- Write a query that returns the country along with the top customer and how much they spent ?

with country_count as ( 
select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as sum_amount
, row_number() over(partition by i.billing_country order by sum(i.total) desc) as rw
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name, i.billing_country
order by billing_country )

select first_name, last_name, billing_country, round(sum_amount,2)  as amount_spent
from country_count
where rw = 1
order by billing_country , amount_spent desc;
