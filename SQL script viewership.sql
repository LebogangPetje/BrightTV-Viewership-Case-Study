---TO VIEW TABLES 
SELECT *
FROM BRIGHTV.TV.USERPROFILE;

SELECT *
FROM BRIGHTV.TV.VIEWERSHIP;

---DETAILS ON DEMOGRAPHICS
SELECT COUNT(USERID) AS total_viewers
FROM brightv.tv.userprofile;

SELECT DISTINCT province,
FROM brightv.tv.userprofile;

--AGES range from 0 to 114 (use this for case statements)
SELECT MIN(age) AS min_age
FROM brightv.tv.userprofile;

SELECT MAX(AGE) AS max_age
FROM brightv.tv.userprofile;

SELECT AVG(age) AS average_age
FROM brightv.tv.userprofile;

--race and gender counts
SELECT count(userid) 
FROM brightv.tv.userprofile
WHERE gender = 'male';

SELECT count(userid)
FROM brightv.tv.userprofile
WHERE gender = 'female';


---viewership table details 

SELECT COUNT(CHENNEL) AS number_of_channels, 
FROM BRIGHTV.TV.VIEWERSHIP;

---11:29:28 MAX, 00:00:00 MIN
SELECT min(duration) AS total_duration,
FROM BRIGHTV.TV.VIEWERSHIP;

SELECT duration,
FROM brightv.tv.viewership;



--- TO create channel buckets 
---channel o, kyknet, trace tv, cnn, vuzu, DSTV Events 1, MK, Wimbledon, cartoon network, m-net, break in transmission, boomerang, supersport live events, E! Entertainment, Africa Magic, SuperSport Live Events, ICC Cricket World Cup 2011, SawSee, Live on SuperSport, SuperSport Blitz,Sawsee,
--- CNN as News Channels 
--- Channel O, Trace TV, MK as Music Channels 
--- M-Net, Vuzu, E! Entertainment, kyknet, Africa Magic as Entertainment and LIfestyle CHannels 
--- Supersport Live Events, SuperSport Blitz, Live on SuperSport, Wimbledon, ICC Cricket World Cup 2011 as Sports Channels and Events 
---Cartoon Network, Boomerang as Childrens CHannels 
--- DSTv Events 1, Break in Transmission as Broadcast and Events 
---sawsee?????
SELECT DISTINCT chennel 
FROM BRIGHTV.TV.VIEWERSHIP;

---to seperate record date and time 
SELECT 
recorddate,
 TO_TIMESTAMP(recorddate, 'YYYY/MM/DD HH24:MI:SS') AS record_timestamp,
 TO_DATE(record_timestamp)AS record_date_only,
 TO_TIME(record_timestamp) AS record_time,
 DATEADD(HOUR,2, record_time) AS record_time_adjusted,
 FROM BRIGHTV.TV.VIEWERSHIP;

---case statements
CASE
   WHEN record_date_only IN ('Sun','Sat') THEN 'Weekend'
   ELSE 'Weekday'
   END AS day_classification,
   
   
 CASE
  WHEN duration BETWEEN '00:00:00' AND '05:59:59' THEN 'Early_morning'
  WHEN duration BETWEEN '06:00:00' AND '11:59:59' THEN 'late_morning'
  WHEN duration BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
  WHEN duration >= '18:00:00' THEN 'Night'
  END AS time_buckets,







---main code 
SELECT
user_id,
chennel,
COALESCE(a.gender, 'Unknown') AS gender,
COALESCE(a.province, 'Unknown') AS province,

TO_TIMESTAMP(recorddate, 'YYYY/MM/DD HH24:MI:SS') AS record_timestamp,
 TO_DATE(record_timestamp)AS record_date_only,
 TO_TIME(record_timestamp) AS record_time,
 DATEADD(HOUR,2, record_time) AS record_time_adjusted,

    DAYNAME( record_date_only) AS day_name,
    MONTHNAME(record_date_only) AS month_name,
    HOUR(record_time_adjusted) AS hour_of_day,

CASE
   WHEN day_name IN ('Sun','Sat') THEN 'Weekend'
   ELSE 'Weekday'
   END AS day_classification,   

CASE
 WHEN age BETWEEN '0' AND '18' THEN 'minor'
 WHEN age BETWEEN '19' AND '35' THEN ' young adult'
 WHEN age BETWEEN '36' AND '60' THEN 'adult'
 ELSE 'elder'
 END AS age_group,
 
CASE
   WHEN age = 0 THEN NULL
   ELSE age 
END AS age_clean,

CASE
   WHEN gender = 'None' THEN 'not specified'
   ELSE gender
END AS gender_clean,

CASE
   WHEN province = 'none' THEN 'not specified'
   ELSE province
END AS province_clean,

CASE
   WHEN race = 'none' THEN 'not specified'
   ELSE race
END AS race_clean,

CASE
  WHEN record_time_adjusted BETWEEN '00:00:00' AND '05:59:59' THEN 'Early_morning'
  WHEN record_time_adjusted BETWEEN '06:00:00' AND '11:59:59' THEN 'late_morning'
  WHEN record_time_adjusted BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
  WHEN record_time_adjusted >= '18:00:00' THEN 'Night'
  END AS time_bucket,
---classify channels under buckets 
CASE 
   WHEN CHENNEL IN ('CNN') THEN 'News'
   WHEN CHENNEL IN ('Channel O', 'Trace TV', 'MK') THEN 'Music'
   WHEN CHENNEL IN ('M-Net', 'Vuzu', 'E! Entertainment', 'kyknet', 'Africa Magic') THEN 'Entertainment and LIfestyle'
   WHEN CHENNEL IN ('Supersport Live Events', 'SuperSport Blitz', 'Live on SuperSport', 'Wimbledon', 'ICC Cricket World Cup 2011') THEN 'Sports and Events'
   WHEN CHENNEL IN ('Cartoon Network', 'Boomerang') THEN 'Children'
   WHEN CHENNEL IN ('DSTv Events 1', 'Break in Transmission') THEN 'Broadcast'
   ELSE 'other'
   END AS Channel_category,
   
CASE
 WHEN DURATION BETWEEN '00:00:00' AND '00:09:59' THEN 'low watch time'
 WHEN DURATION BETWEEN '00:10:00' AND '00:29:59' THEN 'moderate watch time'
 WHEN duration BETWEEN '00:30:00' AND '00:59:59' THEN 'average watch time'
 ELSE 'high watch time'
 END AS Watchtime

FROM brightv.tv.userprofile AS a
LEFT JOIN brightv.tv.viewership AS b
ON a.userid=b.user_id

GROUP BY
COALESCE(a.gender, 'Unknown'),
COALESCE(a.province, 'Unknown'),
user_id,
race,
age,
province,
gender,
chennel,
day_classification,
b.recorddate,
time_bucket,
channel_category,
day_name,
month_name,
hour_of_day,
watchtime

ORDER BY
gender_clean,
province_clean,
race_clean,
recorddate,
time_bucket,
day_name,
month_name,
hour_of_day,
watchtime,
chennel,
age_clean,
age_group,
channel_category;