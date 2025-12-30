/*
* =========================================================================================================
* | 1번 (2025.12.01)
* | 영화 제목에 'Love' 또는 'love'라는 글자가 포함된 영화의 제목과 개봉 연도, 평점을 조회하는 쿼리를 작성해주세요. 
* | 결과는 평점이 높은 순으로 정렬, 만약 평점이 같다면 개봉 연도가 최근인 영화부터 출력되어야 합니다.
* =========================================================================================================
*/

SELECT title, year, rating
FROM movies
where title = '%Love%' or title = '%love%'
ORDER BY rating DESC, year DESC;


/*
* =====================================================================================
* | 2번 (2025.12.02)
* | 2022년 12월 중 초미세먼지(PM2.5) 농도가 9㎍/㎥ 이하인 날을 출력하는 쿼리를 작성해주세요.
* | 컬럼명은 day로 날짜 컬럼 하나만 오름차순으로 출력해주세요.   
* =====================================================================================
*/

SELECT dates AS 'day'
FROM measurements
WHERE (dates BETWEEN '2022-12-01' and '2022-12-31') and pm2_5 <= 9
ORDER BY dates;


/*
* ============================================================================
* | 3번 (2025.12.03)
* | puppies 테이블에서 강아지의 종, 몸무게를 출력하는 쿼리를 작성해주세요.
* | 강아지의 종 또는 몸무게가 없는 데이터를 제외하고 출력해주세요.  
* | 몸무게가 무거운 순서로 출력, 몸무게가 같다면 종의 이름으로 오름차순 정렬해주세요.
* ============================================================================
*/
SELECT species, weights
FROM puppies
where species IS NOT NULL AND weights IS NOT NULL
ORDER BY weights DESC, species;


/*
* ============================================================================
* | 4번 (2025.12.05)
* | 2020년 12월 동안 모든 주문의 매출 합계가 1000$ 이상인 고객 ID를 출력하세요.
* ============================================================================
*/
SELECT customer_id
FROM records
WHERE strftime('%Y-%m', order_date) = '2020-12'
GROUP BY customer_id
HAVING sum(sales) >= 1000;


/*
* ==========================================================================================
* | 5번 (2025.12.05) -> 다시 풀어보기!
* | 금액이 25 달러 이상인 경우 스탬프를 2개, 15달러 이상인 경우 1개, 이외에는 스탬프를 찍어주지 않아요.
* | 영수증 별로 받을 스탬프 개수를 계산한 후 스탬프 개수 별로 영수증 개수를 집계하는 쿼리를 작성해주세요.
* | 스탬프 개수 기준 오름차순으로 정렬하고 스탬프 개수, 영수증 개수만 출력해주세요.
* ===========================================================================================
*/
SELECT 
    CASE 
        WHEN total_bill >= 25 THEN 2
        WHEN total_bill >= 15 THEN 1
        ELSE 0
    END AS stamp,
    COUNT(*) AS count_bill
FROM tips
GROUP BY stamp
ORDER BY stamp;


/*
* ==========================================================================================
* | 6번 (2025.12.06) 
* | 대여점의 활성 고객 중 대여 횟수가 35회 이상인 고객 ID 를 출력하는 쿼리를 작성하세요.
* ===========================================================================================
*/
SELECT customer_id
FROM (
  SELECT c.customer_id, count(rental_id) AS rental_cnt
  FROM customer as c
  LEFT JOIN rental as r ON c.customer_id = r.customer_id
  WHERE active = true
  GROUP BY c.customer_id )
WHERE rental_cnt >= 35;

# --- 더 쉬운 풀이 방법 ---
# 서브 쿼리 없이 HAVING 이용하기
SELECT c.customer_id
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.customer_id
WHERE c.active = true
GROUP BY c.customer_id
HAVING COUNT(rental_id) >= 35;


/*
* ==========================================================================================
* | 7번 (2025.12.08) 
* | 이틀 연속 미세먼지 수치가 증가하여 그 다음 날이 30㎍/㎥ 이상이 된 날을 추출하는 쿼리를 작성해주세요. 
* | 그 다음 날 추출
* ===========================================================================================
*/

SELECT measured_at 
FROM (SELECT measured_at, pm10, 
              LAG(measured_at) OVER (ORDER BY measured_at) AS yesterday,
              LAG(pm10) OVER (ORDER BY measured_at) AS yesterday_pm10, 
              LAG(measured_at, 2) OVER (ORDER BY measured_at) AS two,
              LAG(pm10,2) OVER (ORDER BY measured_at) AS two_pm10
  FROM measurements) AS bad30
WHERE julianday(measured_at) - julianday(yesterday) = 1
      AND julianday(measured_at) - julianday(two) = 2
      AND pm10 >= 30 AND two_pm10 < yesterday_pm10 AND yesterday_pm10 < pm10


/*
* ==========================================================================================
* | 8번 (2025.12.08) 
* | 아래 조건을 만족하는 와인 목록을 출력해주세요.
* | 1. 화이트 와인일 것
* | 2. 와인 품질 점수가 7점 이상일 것
* | 3. 밀도와 잔여 설탕이 와인 전체의 해당 성분 평균 보다 높을 것
* | 4. 산도가 화이트 와인 전체 평균보다 낮고, 구연산 값이 화이트 와인 전체 평균 보다 높을 것
* ===========================================================================================
*/
SELECT *
FROM wines
WHERE color = 'white'
  AND quality >= 7
  AND density > (SELECT AVG(density) FROM wines)
  AND residual_sugar > (SELECT AVG(residual_sugar) FROM wines)
  AND pH < (SELECT AVG(pH) FROM wines WHERE color = 'white')
  AND citric_acid > (SELECT AVG(citric_acid) FROM wines WHERE color = 'white')


  /*
* ==========================================================================================
* | 9번 (2025.12.09) 
* | 한국 국가대표팀으로 여자 배구 종목에 연속 2회 이상 참가한 선수 id와 이름을 출력하세요.
* ===========================================================================================
*/

# 다시 풀어보기
SELECT DISTINCT athlete_id AS id, name
FROM (
  SELECT athlete_id, name, year, 
        LAG(year) OVER (PARTITION BY athlete_id ORDER BY year) AS prev_year
  FROM records r
  JOIN events e ON r.event_id = e.id
  JOIN teams t ON r.team_id = t.id
  JOIN games g ON r.game_id = g.id
  JOIN athletes a ON r.athlete_id = a.id
  WHERE e.event = 'Volleyball Women''s Volleyball' 
    AND t.team = 'KOR') AS new_table
WHERE year - prev_year = 4


  /*
* ==========================================================================================
* | 10번 (2025.12.12) 
* | 한국 국가대표팀으로 여자 배구 종목에 참가한 선수 메달을 딴 선수의 id와 이름, 메달 종류를 출력하세요.
* ===========================================================================================
*/
# 쉼표 추가해야할 땐 GROUP_CONCAT(컬럼명, ', ') 이용 ('쉼표+공백' 이어야함)
# 중복 제거, 정렬도 하고 싶을 땐 GROUP_CONCAT(DISTINCT 컬럼명 ORDER BY 정렬 대상 SEPARATOR ', ') 이용 (SEPARATOR : 구분자를 지정 '쉼표+공백') -> MYSQL
# GROUP_CONCAT(DISTINCT medal, ', ') -> SQLite
SELECT ath.id, name, 
      GROUP_CONCAT(DISTINCT medal ORDER BY medal SEPARATOR ', ') AS medals
FROM athletes ath
JOIN records r ON ath.id = athlete_id
JOIN events e ON r.event_id = e.id
JOIN teams t ON r.team_id = t.id
WHERE event = 'Volleyball Women''s Volleyball' AND team = 'KOR'AND medal IS NOT NULL
GROUP BY ath.id, name


  /*
* ==========================================================================================
* | 11번 (2025.12.12) 
* | 토/일요일의 경우 'weekend', 다른 요일의 경우 'weekday' 로 변환 후 
* | 주중, 주말의 합계 매출 규모를 집계하는 쿼리를 작성해주세요. 
* | week, sales 컬럼이 있어야하고 매출 합계 기준 내림차순으로 정렬하세요.
* ===========================================================================================
*/

# day = 'Sat' OR day = 'Sun' THEN 'weekend' 이거 대신  WHEN day IN ('Sat', 'Sun') THEN 'weekend' 이것도 가능
SELECT
  CASE WHEN day = 'Sat' OR day = 'Sun' THEN 'weekend'
    ELSE 'weekday' END AS week, SUM(total_bill) AS sales
FROM tips
GROUP BY week
ORDER BY sales DESC

  /*
* ==========================================================================================
* | 12번 (2025.12.12) 
* | 게임 출시 연도 기준 2011년부터 2015년까지 각 장르의 점수 평균을 계산하는 쿼리를 작성해주세요.
* | 평균 점수가 없는 게임은 계산에서 제외되어야하고 소수점 아래 셋째 자리에서 반올림 해주세요.
* | 컬럼은 genere(장르 이름), score_2011(2011년 평균 점수), score_2012, score_2013, 
* |       score_2014, score_2015 가 있어야 합니다.
* ===========================================================================================
*/
WITH join_table AS (
  SELECT gm.year, gr.name, gm.critic_score
  FROM games gm
  JOIN genres gr ON gm.genre_id = gr.genre_id
  WHERE critic_score IS NOT NULL AND year BETWEEN 2011 AND 2015)

SELECT name AS genre,
  ROUND(AVG(CASE WHEN year = 2011 THEN critic_score END), 2) AS score_2011,
  ROUND(AVG(CASE WHEN year = 2012 THEN critic_score END), 2) AS score_2012,
  ROUND(AVG(CASE WHEN year = 2013 THEN critic_score END), 2) AS score_2013,
  ROUND(AVG(CASE WHEN year = 2014 THEN critic_score END), 2) AS score_2014,
  ROUND(AVG(CASE WHEN year = 2015 THEN critic_score END), 2) AS score_2015
FROM join_table
GROUP BY name


/*
* ==============================================================================================
* | 13번 (2025.12.15) 
* | 배우별 대여 매출 합계를 계산하고, 그 중 상위 5명 배우의 이름, 성, 총매출을 출력하는 쿼리를 작성해주세요. 
* ===============================================================================================
*/
SELECT first_name, last_name, SUM(amount) AS total_revenue
FROM actor a
LEFT JOIN film_actor f_a ON a.actor_id = f_a.actor_id
LEFT JOIN film f ON f_a.film_id = f.film_id
LEFT JOIN inventory i on f.film_id = i.film_id
LEFT JOIN rental r on i.inventory_id = r.inventory_id
LEFT JOIN payment p on r.rental_id = p.rental_id
GROUP BY a.actor_id
ORDER BY SUM(amount) DESC
LIMIT 5

/*
* ===============================================================================================
* | 14번 (2025.12.15) 
* |  작품, 연도 상관 없이 2회 이상 등재 / 해당 작가 작품들의 평균 사용자 평점이 4.5점 이상 
* |  / 해당 작가 작품들의 평균 리뷰 수가 소설 분야 작품들의 평균 리뷰 수 이상인 소설 작가 이름을 출력해주세요.
* ================================================================================================
*/
SELECT author
FROM books
WHERE genre = 'Fiction'
group by author
HAVING count(*) >= 2 AND AVG(user_rating) >= 4.5 AND AVG(reviews) >= (SELECT AVG(reviews) FROM books WHERE genre = 'Fiction' )
ORDER BY author


/*
* ===============================================================================================
* | 15번 (2025.12.15) 
* |  작품 중 한국 감독의 영화를 찾아, 감독 이름과 작품명을 출력하는 쿼리를 작성해주세요. 
* ================================================================================================
*/
# --- 정확한 문자열 외 문자열 포함 찾을땐 = 가 아니라 LIKE ---
SELECT name AS artist, title
FROM artworks w
JOIN artworks_artists aa on w.artwork_id = aa.artwork_id
JOIN artists t ON aa.artist_id = t.artist_id
WHERE classification LIKE 'Film%' AND nationality = 'Korean'


/*
* =====================================================================================================
* | 16번 (2025.12.23) 
* | 친구 관계인 두 사용자 ID의 합이 적은 순으로 상위 0.1%에 들어오는 모든 친구 관계를 출력하는 쿼리를 작성해주세요. 
* | 상위 % = 해당 친구 관계의 순위 / 전체 친구 관계의 수
* | 만약, 상위 0.1%의 경계 부분에서 id_sum 값이 같은 게 여러개 있는 경우 다 포함합니다.
* ======================================================================================================
*/
SELECT user_a_id, user_b_id, id_sum
FROM (SELECT RANK()OVER(ORDER BY (user_a_id + user_b_id)) AS rnk, Count(*) over() AS total_cnt,
      (user_a_id + user_b_id) AS id_sum, user_a_id, user_b_id FROM edges)
WHERE rnk *100.0 / total_cnt <= 0.1


/*
* =====================================================================================================
* | 17번 (2025.12.23) 
* | 모든 카테고리와 서브 카테고리의 조합에 대해 각 사용자의 첫 구매로 주문된 건수를 집계하고
* | 많은 순서대로 내림차순 정렬하는 쿼리를 작성해주세요. 
* ======================================================================================================
*/
SELECT category, sub_category, COUNT(DISTINCT c_s.customer_id) AS cnt_orders
FROM customer_stats c_s
JOIN records r ON r.customer_id = c_s.customer_id
WHERE order_date = first_order_date
GROUP BY category, sub_category
ORDER BY cnt_orders DESC


/*
* =====================================================================================================
* | 18번 (2025.12.23) 
* | - 친구 수가 100명 이상
* | - 친구들의 친구 수의 합계(a)와 친구 수(b) 비율(a/b)가 높은 순으로 user_id 5명 선정
* | - 친구들의 친구 수 합계 계산에는 중복된 친구와 해당 user_id도 모두 포함
* | - 비율은 소수점 아래 셋째 자리에서 반올림하고 내림차순으로 정렬되어있어야합니다.
* | 위의 조건을 만족하는 쿼리를 작성해주세요. (self-join은 계산량이 많아 수행이 불가능합니다.)
* ======================================================================================================
*/
WITH all_links AS (
    -- A-B 관계를 A->B, B->A 로 변경 (모든 친구 관계 데이터 합침)
    SELECT user_a_id AS u1, user_b_id AS u2 FROM edges
    UNION ALL
    SELECT user_b_id AS u1, user_a_id AS u2 FROM edges
),
friend_counts AS (
    -- 각 유저별 친구 수 계산 (u1의 친구 수 계산)
    SELECT u1 AS user_id, COUNT(*) AS cnt
    FROM all_links
    GROUP BY u1
)

SELECT 
    c.user_id, -- u1
    c.cnt AS friends, -- u1의 친구 수(u2 의 수)
    SUM(f.cnt) AS friends_of_friends, -- u2의 친구 수 합계
    ROUND(SUM(f.cnt) * 1.0 / c.cnt, 2) AS ratio
FROM friend_counts c
JOIN all_links l ON c.user_id = l.u1     -- u1의 친구들(u2)을 찾기 위해 조인
JOIN friend_counts f ON l.u2 = f.user_id -- u2의 친구 수를 가져오기 위해 조인 (f 테이블)
WHERE c.cnt >= 100                       -- 친구 수가 100명 이상인 후보만 필터링
GROUP BY c.user_id, c.cnt
ORDER BY ratio DESC, c.user_id ASC         -- 비율 내림차순 (동일 비율 대비 id 정렬 추가)
LIMIT 5;


/*
* =====================================================================================================
* | 19번 (2025.12.29) 
* | 연도별 순매출을 조회하는 쿼리를 작성해주세요.  
* | 순매출은 반품되지 않은 거래 내역에 대해 주문 금액에서 할인 금액을 제외한 실제 결제 금액의 합을 의미합니다.
* ======================================================================================================
*/
-- strftime() 까먹지 말기, 'Y%'가 아니라 '%Y' 
SELECT strftime('%Y', purchased_at) AS year, SUM(total_price - discount_amount) AS net_sales
FROM transactions
WHERE is_returned = false
GROUP BY strftime('%Y', purchased_at)


/*
* =====================================================================================================
* | 20번 (2025.12.29) 
* | 현재 배송 옵션은 일반 배송(Standard), 빠른 배송(Express), 익일 특급(Overnight) 세 종류 입니다. 
* | 반품이 발생할 경우, 반품 회수를 위해 '일반 배송(Standard)' 서비스가 추가로 1회 이용됩니다. 
* | 배송 업체 이용 건수를 배송 옵션 별로 집계하는 쿼리를 작성해주세요. 
* | (year, standard, express, overnight 이 열로 있어야함.)
* ======================================================================================================
*/
-- SUM 대신 COUNT도 사용 가능, is_returned = true 에서 '=true'를 생략 가능
SELECT strftime('%Y', purchased_at) AS year,
      SUM(CASE WHEN shipping_method = 'Standard' then 1 ELSE 0 END) + SUM(CASE WHEN is_returned = true then 1 ELSE 0 END) AS standard,
      SUM(CASE WHEN shipping_method = 'Express' then 1 ELSE 0 END) AS express,
      SUM(CASE WHEN shipping_method = 'Overnight' then 1 ELSE 0 END) AS overnight
FROM transactions
WHERE is_online_order = true
GROUP BY strftime('%Y', purchased_at)


/*
* =====================================================================================================
* | 21번 (2025.12.29) 
* | 고객ID가 10으로 나눈 나머지가 0인 사용자를 그룹 A, 나머지 사용자를 그룹 B에 배정한 쿼리를 작성해주세요.
* | customer_id, bucket(할당된 사용자 그룹 -> A,B)이 열로 들어가있어야합니다.
* ======================================================================================================
*/
SELECT customer_id, (CASE WHEN customer_id % 10 = 0 THEN 'A' ELSE 'B' END) AS bucket
FROM transactions
GROUP BY customer_id


/*
* =====================================================================================================
* | 22번 (2025.12.29) 
* | 2023년 11월, 12월 온라인 주문에 대하여 order_date(주문일), weekday(요일)(Sunday, Monday 등),
* | num_orders_today(주문일 당일의 주문 건수), 
* | num_orders_from_yesterday(주문일 하루 이전 날짜부터 주문일 당일까지 연속된 이틀간의 합계 주문 건수의 합)
* | 을 구하시오.
* ======================================================================================================
*/
-- 더 간단한 방법 
---> strftime('%A') 쓰기 : Sunday, Monday 로 나옴 / %a : Sun, Mon 등 약어로 나옴 
---> Between 말고 IN ('2023-11', '2023-12') 도 가능
WITH daily_counts AS (
  SELECT 
    date(purchased_at) AS order_date,
    COUNT(transaction_id) AS num_orders
  FROM transactions
  WHERE is_online_order = true AND date(purchased_at) BETWEEN '2023-11-01' AND '2023-12-31'
  GROUP BY date(purchased_at)
)

SELECT 
  order_date,
  CASE CAST(strftime('%w', order_date) AS INTEGER)
    WHEN 0 THEN 'Sunday'
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
  END AS weekday,
  num_orders AS num_orders_today,
  SUM(num_orders) OVER (ORDER BY order_date ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS num_orders_from_yesterday
FROM daily_counts
ORDER BY order_date


/*
* =====================================================================================================
* | 23번 (2025.12.30) 
* | customer_id 가 10으로 나누어 떨어지는 사용자를 A, 나머지를 B로 버킷을 할당합니다.
* | 버킷, 버킷별 사용자 수, 평균 주문 수, 평균 주문 금액을 구하는 쿼리를 작성해주세요.
* | 평균 집계에 사용되는 주문에는 반품된 주문은 제외하고, 평균값은 반올림해서 소수점 둘째 자리까지 표현해주세요.
* ======================================================================================================
*/
--- customer_id 는 거래 수 만큼 생성이 되므로 is_returned 가 true 여도 주문만 있다면 customer_id 값은 있음
---> 따라서 where is_returned = false 를 서브쿼리로 안 써도 된다.
WITH bucket_table AS (
  SELECT customer_id,
    (CASE WHEN customer_id % 10 = 0 THEN 'A' ELSE 'B' END) AS bucket,
    SUM(CASE WHEN transaction_id IS NOT NULL THEN 1 ELSE 0 END)AS cnt_orders, 
    SUM(total_price) AS user_price
  FROM transactions
  WHERE is_returned = false
  GROUP BY customer_id)

SELECT bucket, COUNT(customer_id) AS user_count, 
  ROUND(AVG(cnt_orders),2) AS avg_orders,
  ROUND(AVG(user_price),2) AS avg_revenue
FROM bucket_table
GROUP BY bucket


/*
* =====================================================================================================
* | 24번 (2025.12.30) 
* | 고객별 순매출을 집계한 뒤, 각 도시별 최고 순매출 고객을 추출하는 쿼리를 작성해주세요.
* | 고객별 순매출은 주문 금액에서 할인 금액을 제외한 금액을 의미하고 반품 주문은 집계에서 제외해주세요.
* | city_id, customer_id, total_spent(해당 고객의 순 매출)의 컬럼만 출력해주세요.
* ======================================================================================================
*/
WITH customer_spent AS (
  SELECT customer_id, SUM(total_price - discount_amount) AS total_spent, city_id
  FROM transactions
  WHERE is_returned = false
  GROUP BY customer_id, city_id
),
  ranked AS (
    SELECT 
      city_id,
      customer_id,
      total_spent,
      ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY total_spent DESC) AS rnk
    FROM customer_spent
)


SELECT city_id, customer_id, total_spent
FROM ranked
WHERE rnk = 1

/*
* =====================================================================================================
* | 25번 (2025.12.30) 
* | 'Ho Ho Ho' 가 출력되는 쿼리를 작성해주세요. 고생했습니다.
* ======================================================================================================
*/
SELECT 'Ho Ho Ho'

-------------------------------------------------------------------------------------------------------------------------------------------------