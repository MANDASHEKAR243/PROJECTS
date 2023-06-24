use music_store;
desc employe;
show tables;
select * from employee;
	#                           PHASE-------I                                                   #
#1. Who is the senior most employee based on job title?
#*************************** 1st type based on level  main one ************************************************************************************
select concat(first_name," ",last_name) as full_name_of_senior,title 
from employes ORDER BY levels desc limit 1;

#*****************  2nd type position wise senior based on hire_date******************************************************************************************

select concat(first_name," ",last_name) as full_name_of_senior,title from employes where 
hire_date=(select min(hire_date) from employee);

# ***************** 3rd type :  based on different job title wise seniors******************************************************************************
with cte as(select last_name,title,hire_date,
dense_rank() over(partition by title order by last_name) as title_wise_senior from employes)
select * from cte where title_wise_senior=1
order by hire_date;

#********************************************************************************************************************************
#2.Which countries have the most Invoices?
                  # count#  main one
select * from invoice;
select billing_country ,count(*) as count_wise_most_invoices from invoice
group by billing_country
order by count_wise_most_invoices desc;

#**************************************************************************************************************************************

#3. What are top 3 values of total invoice? 

# ***************************MAIN ONE IS***********************

SELECT TOTAL FROM INVOICE ORDER BY TOTAL DESC LIMIT 3;


#**************************************BASED ON COUNT***************************#
select * from invoice;
select billing_country ,count(total) as count_wise_most_invoices FROM invoice
group by billing_country
order by count_wise_most_invoices desc limit 3;
 #*******************BASED ON MAX*****************************************************************************************************
select total,max(total)  from invoice
group by total order by total desc limit 3;





#*******************************************************************************************************************************
#4. Which city has the best customers? We would like to throw a promotional Music Festival
#in the city we made the most money. Write a query that returns one city that has the highest 
#sum of invoice totals. Return both the city name & sum of all invoice totals 

select * from customer;
select * from invoice;
          # best customer city#MAIN ONE 

select billing_city,round(sum(total),2) as sum_wise_most_invoice_totals FROM 
invoice group by billing_city
order by sum_wise_most_invoice_totals DESC limit 1;
     # customer name best city#  ID NEED CUSTOMER IN RESULT

select b.billing_city,concat(a.first_name," ",a.last_name) as best_customer ,round(sum(b.total),2) as sum_wise_most_invoice_totals FROM 
customer a join invoice b on a.customer_id=b.customer_id
group by concat(a.first_name," ",a.last_name),b.billing_city
order by sum_wise_most_invoice_totals desc limit 1;
#*************************************************************************************************************************************

#5. Who is the best customer?
#The customer who has spent the most money will be declared the best customer. 
#Write a query that returns the person who has spent the most money 
select concat(a.first_name," ",a.last_name) as best_customer ,round(sum(b.total),2) as spent_most_money_totals FROM 
customer a join invoice b on a.customer_id=b.customer_id
group by concat(a.first_name," ",a.last_name)
order by spent_most_money_totals desc limit 1;
 #***********************************#********************************************************************************
# ***********************PHASE - II--*********************************************************************************************
#1.Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 #Return your list ordered alphabetically by email starting with A 
 
   # IN THIS NEED GENRE NAME THAT ID PRESENT IN TRACK BUT TRACK ID PRESENT CONNECTION TO INVOICE_LINE AND THAT WILL CONNECT
   # TO INVOICE AND CUSTOMER CONNECT WITH INVOICE SO AFTER THESE CONNECTION GOT OUTPUT.
 select * from albums;
 select * from artist;
 select * from TRACK;
 select * from genre;
 select * from invoice;
 select * from invoice_line;
 select * from media_type;
 select * from playlist;
 select * from playlist_track;
 select * from track;
select * from employee;
SELECT DISTINCT CONCAT(C.FIRST_NAME," ",C.LAST_NAME),C.EMAIL,G.NAME AS GENRE_NAME
FROM CUSTOMER C 
JOIN INVOICE I ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID=I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN GENRE G ON G.GENRE_ID=T.GENRE_ID
WHERE G.NAME LIKE "ROCK" AND EMAIL LIKE "A%"
ORDER BY 1;
  
  
#2.Let's invite the artists who have written the most rock music in our dataset.
#Write a query that returns the Artist name and total track count of the top 10 rock bands 
SELECT AR.NAME,
COUNT(T.NAME) AS TOTAL_COUNT_OF_ROCK_BANDS
FROM TRACK T
JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
JOIN ALBUMS AL ON AL.ALBUM_ID = T.ALBUM_ID
JOIN ARTIST AR ON AR.ARTIST_ID = AL.ARTIST_ID
WHERE G.NAME = 'Rock'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;
  
#3.Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT * FROM TRACK;
select name,milliseconds from track where milliseconds >
(select avg(milliseconds) from track)
order by milliseconds desc;
#****************************  PHASE---III*************************************************************************************************
#1.Find how much amount spent by each customer on artists?
#Write a query to return customer name, artist name and total spent 
#********************BASED ON INVOICE LINE TOTAL FIND
SELECT DISTINCT CONCAT(C.FIRST_NAME," ",C.LAST_NAME) AS CUSTOMER_NAME,AR.NAME AS ARTIST_NAME,
ROUND(SUM(IL.unit_price*IL.quantity),2)AS total_SPENT
FROM CUSTOMER C 
JOIN INVOICE I ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID=I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN ALBUMS AL ON AL.ALBUM_ID=T.ALBUM_ID
JOIN ARTIST AR ON AR.ARTIST_ID=AL.ARTIST_ID
group by CONCAT(C.FIRST_NAME," ",C.LAST_NAME),AR.NAME
ORDER BY TOTAL_SPENT DESC;
 #*****************BASED ON INVOICE TOTAL********************MAIN TYPE*********************************************************************
SELECT DISTINCT CONCAT(C.FIRST_NAME," ",C.LAST_NAME) AS CUSTOMER_NAME,AR.NAME AS ARTIST_NAME, ROUND(sum(I.TOTAL),2)AS TOTAL_SPENT
FROM CUSTOMER C 
JOIN INVOICE I ON C.CUSTOMER_ID=I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID=I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN ALBUMS AL ON AL.ALBUM_ID=T.ALBUM_ID
JOIN ARTIST AR ON AR.ARTIST_ID=AL.ARTIST_ID
GROUP BY CONCAT(C.FIRST_NAME," ",C.LAST_NAME) ,AR.NAME 
ORDER BY TOTAL_SPENT DESC;

#***************************************************************************************************************#

#2.We want to find out the most popular music Genre for each country. 
#We determine the most popular genre as the genre with the highest amount of purchases.
#Write a query that returns each country along with the top Genre. 
#For countries where the maximum number of purchases is shared return all Genres
WITH CTE AS(SELECT  I.billing_country AS BILLING_COUNTRY ,G.NAME AS NAME,round(SUM(I.TOTAL),2)AS TOL
FROM INVOICE I
JOIN INVOICE_LINE IL ON I.INVOICE_ID=IL.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID=IL.TRACK_ID
JOIN GENRE G ON G.GENRE_ID=T.GENRE_ID
GROUP BY G.NAME,I.billing_country),

MAX_SPEND AS (
SELECT BILLING_COUNTRY,(MAX(TOL)) AS MAX_SPEND FROM CTE
GROUP BY BILLING_COUNTRY)

SELECT
W.BILLING_COUNTRY,W.NAME,count(ms.MAX_SPEND ) FROM CTE W JOIN MAX_SPEND MS ON W.BILLING_COUNTRY=MS.BILLING_COUNTRY
AND W.TOL=MS.MAX_SPEND
group by 1,2
ORDER BY W.BILLING_COUNTRY;

#*******************************************************************************************************************************************
#3.Write a query that determines the customer that has spent the most on music for each country. 
#Write a query that returns the country along with the top customer and how much they spent. 
#For countries where the top amount spent is shared, provide all customers who spent this amount 
select * from  customer;
select * from invoice;
select * from invoice_line;
select * from playlist;
select * from playlist_track;
select * from track;
with cte as(select concat(c.first_name," ",c.last_name) as top_customer,c.country,pl.name,round(sum(i.total),2)as sum_total
from customer c 
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join playlist_track pt on pt.track_id=il.track_id
join playlist pl on pl.playlist_id=pt.playlist_id
where pl.name like "music"
group by 1,2,3
order by sum_total desc),

max_spent as(select top_customer,country,name,max(sum_total) as total_spent from cte
group by  1,2,3)
select f.top_customer,f.country,f.name,m.total_spent
from cte f join max_spent m on f.country=m.country and f.sum_total=m.total_spent
order by m.total_spent desc;

#*******************************END*****************************************
