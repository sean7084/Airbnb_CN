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
select  * from listings;
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
where host_response_rate = 'N/A';
update listings 
set host_acceptance_rate = null
where host_acceptance_rate = 'N/A';

delete from listings 
where room_type = '16' or bedrooms = '0'

delete from reviews
where comments like '系统自动评论:%' 
	or comments like '%This is an automated posting.';


--- Correct data types

update listings set price = replace(price,'$','');
update listings set price = replace(price,'.00','');
update listings set price = replace(price,',','');
alter table listings modify price int;

update listings set host_response_rate = replace(host_response_rate,'%','')/100;
alter table listings modify host_response_rate numeric(3,2);
update listings set host_acceptance_rate = replace(host_acceptance_rate,'%','')/100;
alter table listings modify host_acceptance_rate numeric(3,2);

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

--- 修正‘host_neighbourhood'列

update listings
set host_neighbourhood = 
	case
       when host_neighbourhood =  'Xintiandi' then '新天地'
       when host_neighbourhood =  'Conservatory' then '音乐学院'
       when host_neighbourhood =  'Putuo' then '普陀'
       when host_neighbourhood =  'Quyang' then '曲阳' 
	   when host_neighbourhood =  'None' then ''
       when host_neighbourhood =  'Pudong' then '浦东'
       when host_neighbourhood =  'Hongkou' then '虹口'
       when host_neighbourhood =  'Caojiadu' then '曹家渡'
       when host_neighbourhood =  'Nanjing Road West' then '南京西路'
       when host_neighbourhood =  'Zhongshan Park' then '中山公园'
       when host_neighbourhood =  'Songjiang' then '松江'
       when host_neighbourhood =  'Xinhua Road' then '新华路'
       when host_neighbourhood =  'Hengshan' then '衡山'
       when host_neighbourhood =  'Jinqiao' then '金桥'
       when host_neighbourhood =  'Huangpu' then '黄埔' 
       when host_neighbourhood =  'Xuhui' then '徐汇'
       when host_neighbourhood =  'Baoshan' then '宝山'
       when host_neighbourhood =  'Qingpu' then '青浦' 
       when host_neighbourhood =  "Jing'an" then '静安'
       when host_neighbourhood =  'Changning' then '长宁'
       when host_neighbourhood =  'Lu Jia Zui' then '陆家嘴' 
       when host_neighbourhood =  'Luwan' then '黄埔'
       when host_neighbourhood =  'Temple' then '城隍庙'
       when host_neighbourhood =  'Cypress' then '龙柏新村'
       when host_neighbourhood =  'Changshou Road' then '常熟路'
       when host_neighbourhood =  'Yangpu' then '杨浦' 
       when host_neighbourhood =  'Zhabei' then '闸北'
       when host_neighbourhood =  'Chunshen' then '春申'
       when host_neighbourhood =  'Tongle Fang' then '同乐坊'
       when host_neighbourhood =  'Gubei' then '古北'
       when host_neighbourhood =  'Jiading' then '嘉定' 
       when host_neighbourhood =  "People's Square" then '人民广场'
       when host_neighbourhood =  'Dapuqiao' then '打浦桥' 
       when host_neighbourhood =  'Meichuan Road' then '梅川路'
       when host_neighbourhood =  'Xujiahui' then '徐家汇'
       when host_neighbourhood =  'Fengxian' then '奉贤'
       when host_neighbourhood =  'Hongmei Road' then '虹梅路'
       when host_neighbourhood =  'Minhang' then '闵行'
       when host_neighbourhood =  'Longhua' then '龙华'
       when host_neighbourhood =  'Xinjiekou' then '新街口'
       when host_neighbourhood =  'Weifang New Village' then '潍坊新村' 
       when host_neighbourhood =  'Old Minhang' then '闵行'
       when host_neighbourhood =  'Lujiazui' then '陆家嘴'
       when host_neighbourhood =  'Hongqiao' then '虹桥'
       when host_neighbourhood =  'Tangqiao' then '塘桥'
       when host_neighbourhood =  'Zhenru' then '真如'
       when host_neighbourhood =  "Jing'an Temple" then '静安寺'
       when host_neighbourhood =  'Dongjiadu' then '董家渡'
       when host_neighbourhood =  "Ren Min Guang Chang" then '人民广场'
       when host_neighbourhood =  'Jinshan' then '金山'
       when host_neighbourhood =  'Nanfang Shangcheng' then '南方商城'
       when host_neighbourhood =  'Changfeng Park' then '长风公园'
       when host_neighbourhood =  'Pujiang Town' then '浦江镇'
       when host_neighbourhood =  'Haining Road' then '海宁路'
       when host_neighbourhood =  'Pengpuxincun' then '彭浦新村'
       when host_neighbourhood =  'Huǒchē' then ''
       when host_neighbourhood =  'Waigaoqiao' then '外高桥' 
       when host_neighbourhood =  'Linyi New Village' then '临沂新村'
       when host_neighbourhood =  'Hongqiao Town' then '虹桥'
       when host_neighbourhood =  'Chuansha' then '川沙'
       when host_neighbourhood =  'Jing An Si' then '静安寺'
       when host_neighbourhood =  'Huo Che Zhan' then '上海火车站'
       when host_neighbourhood =  'Hong Qiao' then '虹桥'
       when host_neighbourhood =  'Shi Ji Gong Yuan' then '世纪公园'
       when host_neighbourhood =  'Chuan Sha' then '川沙'
       when host_neighbourhood =  'Xin Zhuang' then '莘庄' 
       when host_neighbourhood =  'Huai Hai Lu Dong Duan' then '淮海东路'
       when host_neighbourhood =  'Wai Tan' then '外滩'
       when host_neighbourhood =  'Da Pu Qiao' then '打浦桥'
       when host_neighbourhood =  'Wan Ti Guan' then '万体馆' 
       when host_neighbourhood =  'Nanjing West Road' then '南京西路'
       when host_neighbourhood =  'Xu Jia Hui' then '徐家汇'
       when host_neighbourhood =  'Wu Ke Song' then '五棵松'
       when host_neighbourhood =  'Zhong Shan Bei Lu' then '中山北路' 
       when host_neighbourhood =  'Si Chuan Bei Lu' then '四川北路'
       when host_neighbourhood =  'Nan Jing Dong Lu' then '南京东路'
       when host_neighbourhood =  'Waitan' then '外滩'       
	   when host_neighbourhood =  'Bang Kapi' then '嘉定'       
	   when host_neighbourhood =  'Yaohan' then '陆家嘴'       
	   when host_neighbourhood =  'Lower Sukhumvit' then '外滩'
       when host_neighbourhood =  'Wu Yi Shang Quan' then '宝山'       
       when host_neighbourhood =  'Østerbro' then '静安'       
	   when host_neighbourhood =  'Watertown' then '闵行'       
	   when host_neighbourhood =  'Southern Region' then ''       
	   when host_neighbourhood =  'Soho' then '静安'       
	   when host_neighbourhood =  'Shek Kip Mei' then '世纪公园'
       when host_neighbourhood =  'North Lake Waco' then '川沙'       
	   when host_neighbourhood =  'Old Simon' then '老西门'       
	   when host_neighbourhood =  'Fortress Hill' then ''       
	   when host_neighbourhood =  'Klong Toey' then '外滩'       
	   when host_neighbourhood =  'Caohejing/TianLin' then '漕河泾'
       when host_neighbourhood =  "St John's Wood" then '外滩'       
	   when host_neighbourhood =  'Palmera-Bellavista' then '人民广场'       
	   when host_neighbourhood =  'Xiang Gang Lu Can Yin Jie' then '崇明'       
	   when host_neighbourhood =  'Corey Hill' then '音乐学院'
       when host_neighbourhood =  'East Village' then '崇明'       
	   when host_neighbourhood =  'Pinklao' then '临港新城'       
	   when host_neighbourhood =  '新槎浦' then ''
	   else host_neighbourhood
	end;
	

--- Split tables by types of information

drop table if exists listing_URL;
create table listing_URL
as select id,listing_url, picture_url, host_url, host_thumbnail_url, host_picture_url
from listings;
alter table listing_URL add primary key (id);
alter table listing_URL add foreign key (id) references listings(id) on delete cascade;
select * from listing_URL;

drop table if exists listing_availability;
create table listing_availability
as select id,has_availability,availability_30,availability_60,availability_90, availability_365,
	minimum_nights, maximum_nights,minimum_minimum_nights, maximum_minimum_nights, 
	minimum_maximum_nights,maximum_maximum_nights,minimum_nights_avg_ntm,maximum_nights_avg_ntm,
	instant_bookable
from listings;
alter table listing_availability add primary key (id);
alter table listing_availability add foreign key (id) references listings(id) on delete cascade;
select * from listing_availability;

drop table if exists listing_property;
create table listing_property
as select id,neighbourhood, neighbourhood_cleansed, latitude, longitude,
	property_type, room_type, accommodates, bathrooms_text, bedrooms, beds,
	amenities, price
from listings;
alter table listing_property add primary key (id);
alter table listing_property add foreign key (id) references listings(id) on delete cascade;
select * from listing_property;
select distinct room_type, count(*) from listing_property group by room_type;

drop table if exists listing_review;
create table listing_review
as select id,number_of_reviews, number_of_reviews_ltm, number_of_reviews_l30d, 
	first_review,last_review, review_scores_rating,review_scores_accuracy,
	review_scores_cleanliness,review_scores_checkin,review_scores_communication,
	review_scores_location,review_scores_value,	reviews_per_month
from listings;
alter table listing_review add primary key (id);
alter table listing_review add foreign key (id) references listings(id) on delete cascade;
select * from listing_review;

drop table if exists listing_text;
create table listing_text
as select id,name, description, neighbourhood_overview
from listings;
alter table listing_text add primary key (id);
alter table listing_text add foreign key (id) references listings(id) on delete cascade;
select * from listing_text;

drop table if exists listing_host;
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
select * from listing_host;


--- Remove duplicates in host table

delete from listing_host 
where id not in (
	select * from (
		select max(id) 
		from listing_host
		group by host_id) as Max_id_for_each_distinct_host);
select * from listing_host; 


select min(datediff(lr.first_review,lh.host_since)) as days_to_get_1st_review  
from listing_review lr 
inner join listing_host lh on lr.id=lh.id
group by host_id

						where id in (
								select min(id),host_id 
								from listings
								group by host_id)