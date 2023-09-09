select * from hotel2018;
select * from hotel2019;
select * from hotel2020;
select * from market_segment;
select * from meal_cost;

-- 1 Is hotel revenue increasing year on year?
Select h.arrival_date_year as year,
		sum(
        (
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children) * m.cost)
			+
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
        ) * (1 - seg.discount)
        ) as yearly_rev
	from 
    (
		SELECT * FROM hotel2018
        union
        SELECT * FROM hotel2019
        union
        SELECT * FROM hotel2020
    )
    as h inner join meal_cost as m on h.meal = m.meal
	inner join market_segment as seg 
	on seg.market_segment = h.market_segment
	 where h.is_canceled = 0
group by 1;
-- 2 What market segment are major contributors of the revenue per year? In there a change year on year?
select market_segment, max(year2018)as year2018, max(year2019) as year2019, max(year2020)as year2020 from        
(select
  market_segment,

case
	when year = 2018 then yearly_rev
    else 0
    end as year2018,
case
	when year = 2019 then yearly_rev
    else 0
    end as year2019,
case
	when year = 2020 then yearly_rev
    else 0
    end as year2020    
from(        
select h.arrival_date_year as year , seg.market_segment ,
		sum((((h.stays_in_week_nights+h.stays_in_weekend_nights) * (h.adults + h.children + h.babies) * m.cost)
			+
			((h.stays_in_week_nights+h.stays_in_weekend_nights) * h.adr)
        ) * ( 1- seg.discount)) as yearly_rev
        from
        (
			select * from hotel2018
			UNION
			select * from hotel2019
            UNION
			select * from hotel2020
		)
        AS h inner join meal_cost as m on h.meal=m.meal
        inner join market_segment as seg
        on  seg.market_segment=h.market_segment
        where h.is_canceled = 0
        group by 1,2) as temp) as temp2 group by 1;
-- 3 When is the hotel at maximum occupancy? Is the period consistent across the years?
SELECT arrival_date_month, count2018, count2019 , count2020
FROM
(SELECT arrival_date_month, max(count2018) as count2018, max(count2019) as count2019 , max(count2020) as count2020, max(week_num) as week_num  FROM 

(SELECT 
 arrival_date_month, week_num, 
CASE 
	WHEN year = 2018 THEN cnt
    ELSE 0
END as count2018,
CASE 
	WHEN year = 2019 THEN cnt
    ELSE 0
END as count2019,
CASE 
	WHEN year = 2020 THEN cnt
    ELSE 0
END as count2020
FROM (
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2018 group by 1,2
UNION
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2019 group by 1,2
UNION
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2020 group by 1,2) as temp) as temp2 
GROUP BY 1 ORDER BY 5) as temp3 ;
-- 4  When are people cancelling the most?
SELECT arrival_date_month, count2018, count2019 , count2020
FROM
(SELECT arrival_date_month,max(count2018) as count2018, max(count2019) as count2019 , max(count2020) as count2020, max(week_num) as week_num 
FROM 
(SELECT 
 arrival_date_month, week_num,
CASE 
	WHEN arrival_date_year = 2018 THEN cnt
    ELSE 0
END as count2018,
CASE 
	WHEN arrival_date_year = 2019 THEN cnt
    ELSE 0
END as count2019,
CASE 
	WHEN arrival_date_year = 2020 THEN cnt
    ELSE 0
END as count2020
FROM (
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num,count(*) as cnt from hotel2018 WHERE is_canceled = 1 group by 1,2 
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2019 WHERE is_canceled = 1 group by 1,2
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2020 WHERE is_canceled = 1 group by 1,2) as temp) as temp2 
GROUP BY 1 ORDER BY 5) as temp3 ;

-- 5 Are families with kids more likely to cancel the hotel booking?
select * from
(SELECT 2018 as year_, totb.family_flag,  (canceled_bookings / total_bookings)*100 as percentage_cancel
 FROM 
 (SELECT family_flag, count(*) as total_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp GROUP BY 1) as totb
 inner join 
 (
  SELECT family_flag, count(*) as canceled_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp WHERE is_canceled = 1 GROUP BY 1
 ) as cancelb ON totb.family_flag = cancelb.family_flag
 UNION
 SELECT 2019 as year_, totb.family_flag,  (canceled_bookings / total_bookings)*100 as percentage_cancel
 FROM 
 (SELECT family_flag, count(*) as total_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2019) as temp GROUP BY 1) as totb
 inner join 
 (
  SELECT family_flag, count(*) as canceled_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2019) as temp WHERE is_canceled = 1 GROUP BY 1
 ) as cancelb ON totb.family_flag = cancelb.family_flag
UNION
  SELECT 2020 as year_, totb.family_flag,  (canceled_bookings / total_bookings)*100 as percentage_cancel
 FROM 
 (SELECT family_flag, count(*) as total_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2020) as temp GROUP BY 1) as totb
 inner join 
 (
  SELECT family_flag, count(*) as canceled_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2020) as temp WHERE is_canceled = 1 GROUP BY 1
 ) as cancelb ON totb.family_flag = cancelb.family_flag) AS temp;
-- *******************************************************************
-- 6 repeated_guest OR NOT
select arrival_date_year as year_, count(*) as repeated_guest from hotel2018 where is_canceled = 0 AND is_repeated_guest = 1 group by 1
union
select arrival_date_year as year_, count(*) as repeated_guest from hotel2019 where is_canceled = 0 AND is_repeated_guest = 1 group by 1
union
select arrival_date_year as year_, count(*) as repeated_guest from hotel2020 where is_canceled = 0 AND is_repeated_guest = 1 group by 1;
