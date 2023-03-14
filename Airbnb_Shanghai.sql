--- Note: Codes in this script are for mySQL servers.

--- create project database

/* command line
create database airbnb_shanghai;
*/

--- create tables for the csv files

drop table listing_URL;
drop table listing_availability;
drop table listing_property;
drop table listing_review;
drop table listing_text;
drop table listing_host;
drop table listings;
drop table reviews;

create table listings(
	id int primary key,
	listing_url varchar(255) null,
	scrape_id int null,
	last_scraped varchar(255) null,
	name text,
	description text,
	neighbourhood_overview text,
	picture_url varchar(255) null,
	host_id int null,
	host_url varchar(255) null,
	host_name varchar(255) null,
	host_since varchar(255) null,	
	host_location varchar(255) null,
	host_about text null,
	host_response_time varchar(255) null, 	
	host_response_rate varchar(255) null,
	host_acceptance_rate varchar(255) null,	
	host_is_superhost varchar(255) null,
	host_thumbnail_url varchar(255) null,
	host_picture_url varchar(255) null,
	host_neighbourhood varchar(255) null,
	host_listings_count	numeric null,
	host_total_listings_count numeric null,	
	host_verifications varchar(255) null,
	host_has_profile_pic varchar(255) null,
	host_identity_verified varchar(255) null,
	neighbourhood varchar(255) null,	
	neighbourhood_cleansed varchar(255) null,	
	neighbourhood_group_cleansed varchar(255) null,	
	latitude float(9) null,	
	longitude float(9) null,	
	property_type varchar(255) null,	
	room_type varchar(255) null,	
	accommodates int null,	
	bathrooms numeric null,	
	bathrooms_text varchar(255) null,	
	bedrooms numeric null,	
	beds numeric null,	
	amenities varchar(255) null,	
	price varchar(255) null,	
	minimum_nights int null,		
	maximum_nights int null,		
	minimum_minimum_nights int null,		
	maximum_minimum_nights int null,		
	minimum_maximum_nights int null,		
	maximum_maximum_nights int null,		
	minimum_nights_avg_ntm int null,		
	maximum_nights_avg_ntm int null,		
	calendar_updated varchar(255) null,	
	has_availability varchar(255) null,	
	availability_30 int null,	
	availability_60 int null,	
	availability_90 int null,	
	availability_365 int null,	
	calendar_last_scraped varchar(255) null,
	number_of_reviews int null,
	number_of_reviews_ltm int null,	
	number_of_reviews_l30d int null,	
	first_review varchar(255) null,	
	last_review varchar(255) null,	
	review_scores_rating numeric(3,2) null,	
	review_scores_accuracy numeric(3,2) null,
	review_scores_cleanliness numeric(3,2) null,	
	review_scores_checkin numeric(3,2) null,	
	review_scores_communication numeric(3,2) null,	
	review_scores_location numeric(3,2) null,	
	review_scores_value numeric(3,2) null,	
	license	varchar(255) null,
	instant_bookable varchar(255) null,	
	calculated_host_listings_count int null,	
	calculated_host_listings_count_entire_homes int null,
	calculated_host_listings_count_private_rooms int null,	
	calculated_host_listings_count_shared_rooms int null,	
	reviews_per_month numeric(3,2) null
);
create table reviews(
	listing_id int not null,
	id int primary key,
	date date not null,
	reviewer_id int not null,
	reviewer_name varchar(255) null,
	comments text
);

--- Import csv into the database

/*commend line
mysql -u root -p --local-infile
set global local_infile = 1;

LOAD DATA LOCAL INFILE 'c:/Users/sean_/Documents/Code/Airbnb_CN/reviews.csv'
INTO TABLE reviews 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'c:/Users/sean_/Documents/Code/Airbnb_CN/listings.csv'
INTO TABLE listings 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

--- Backup  

create table listings_original (select * from listings);
create table reviews_original (select * from reviews);


/*
select distinct * from listings;
select * from reviews;
describe listings;
describe reviews;
select * from information_schema.REFERENTIAL_CONSTRAINTS;
describe listing_url 
*/

--- Drop irrelevant columns

create table listings_removed_columns (
select id, scrape_id, last_scraped, calendar_updated,calendar_last_scraped,
	bathrooms,neighbourhood_group_cleansed,license
from listings)

alter table listings 
drop column scrape_id, 
drop column last_scraped, 
drop column calendar_updated, 
drop column calendar_last_scraped, 
drop column bathrooms, 
drop column neighbourhood_group_cleansed,
drop column license;

--- Check duplicated rows 

select name, count(*) as number_of_duplicates
from listings 
group by name 
having count(*)>1
order by count(*) desc;

select description, count(*) as number_of_duplicates
from listings
where description <> '' 
group by description 
having count(*)>1
order by count(*) desc;

select comments, count(*) as number_of_duplicates
from reviews
where comments <> '' 
group by comments 
having count(*)>1
order by count(*) desc;

--- Drop duplicated rows

delete from listings 
where id not in (
	select * from (
		select max(id) 
		from listings
		group by name) as Max_id_for_each_distinct_name);

delete from listings 
where id not in (
	select * from (
		select max(id) 
		from listings
		group by description) as Max_id_for_each_distinct_description);
	
delete from reviews
where comments like '系统自动评论:%' 
	or comments like '%This is an automated posting.';

--- Nulls

select first_review from listings 
where first_review = '0000-00-00' or first_review = '';
update listings 
set first_review = null
where first_review = '';
update listings 
set last_review = null
where last_review = '' or last_review = '4.98';
update listings 
set host_since = null
where host_since = '' or host_since = 'China';

update listings 
set host_response_rate = null
where host_response_rate = 'N/A'

--- Correct data types

update listings set price = replace(price,'$','');
update listings set price = replace(price,'.00','');
update listings set price = replace(price,',','');
alter table listings modify price int;

update listings set host_response_rate = replace(host_response_rate,'%','')/100;
alter table listings modify host_response_rate numeric(3,2);

update listings
set host_has_profile_pic = if(host_has_profile_pic='t',1,0);
update listings
set host_identity_verified = if(host_identity_verified='t',1,0);
update listings
set host_is_superhost = if(host_is_superhost='t',1,0);
update listings
set has_availability = if(has_availability='t',1,0);
update listings
set instant_bookable = if(instant_bookable='t',1,0);
alter table listings 
modify host_has_profile_pic tinyint,
modify host_identity_verified tinyint,
modify host_is_superhost tinyint,
modify has_availability tinyint,
modify instant_bookable tinyint;

alter table listings 
modify host_total_listings_count int,
modify host_listings_count int,
modify bedrooms int,
modify beds int,
modify first_review date,
modify last_review date,
modify host_since date;



--- Split tables by types of information

create table listing_URL
as select id,listing_url, picture_url, host_url, host_thumbnail_url, host_picture_url
from listings;
alter table listing_URL add primary key (id);
alter table listing_URL add foreign key (id) references listings(id) on delete cascade;

create table listing_availability
as select id,has_availability,availability_30,availability_60,availability_90, availability_365,
	minimum_nights, maximum_nights,minimum_minimum_nights, maximum_minimum_nights, 
	minimum_maximum_nights,maximum_maximum_nights,minimum_nights_avg_ntm,maximum_nights_avg_ntm
from listings;
alter table listing_availability add primary key (id);
alter table listing_availability add foreign key (id) references listings(id) on delete cascade;

create table listing_property
as select id,neighbourhood, neighbourhood_cleansed, latitude, longitude,
	property_type, room_type, accommodates, bathrooms_text, bedrooms, beds,
	amenities, price, instant_bookable
from listings;
alter table listing_property add primary key (id);
alter table listing_property add foreign key (id) references listings(id) on delete cascade;

create table listing_review
as select id,number_of_reviews, number_of_reviews_ltm, number_of_reviews_l30d, 
	first_review,last_review, review_scores_rating,review_scores_accuracy,
	review_scores_cleanliness,review_scores_checkin,review_scores_communication,
	review_scores_location,review_scores_value,	reviews_per_month
from listings;
alter table listing_review add primary key (id);
alter table listing_review add foreign key (id) references listings(id) on delete cascade;

create table listing_text
as select id,name, description, neighbourhood_overview
from listings;
alter table listing_text add primary key (id);
alter table listing_text add foreign key (id) references listings(id) on delete cascade;

create table listing_host
as select id,host_id, host_name, host_since, host_location, host_about,
	host_response_time, host_response_rate, host_acceptance_rate, host_is_superhost,
	host_neighbourhood, host_listings_count, host_total_listings_count, host_verifications, 
	host_has_profile_pic, host_identity_verified,
	calculated_host_listings_count,calculated_host_listings_count_entire_homes,
	calculated_host_listings_count_private_rooms,calculated_host_listings_count_shared_rooms
from listings;
alter table listing_host add primary key (id);
alter table listing_host add foreign key (id) references listings(id) on delete cascade;


--- Remove duplicates in host table

delete from listing_host 
where id not in (
	select * from (
		select max(id) 
		from listing_host
		group by host_id) as Max_id_for_each_distinct_host);
select * from listing_host; 