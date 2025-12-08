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