# 다중 매장 테이블 오더 (Table Order) 쿼리 실행 결과 (Phase 2)

`B5-1-2/output_simple_2/results/` 디렉터리에 저장된 총 21개 검증 쿼리 및 보너스 과제 결과를 순서대로 종합한 결과 문서입니다.

---
## 목차

- **1. 기본 조회 쿼리 (WHERE, ORDER BY, LIMIT)**
  - `query_01.txt`
  - `query_02.txt`
  - `query_03.txt`
  - `query_04.txt`
- **2. 관계형 조인 쿼리 (INNER JOIN, LEFT JOIN)**
  - `query_05.txt`
  - `query_06.txt`
  - `query_07.txt`
  - `query_08.txt`
- **3. 집계 쿼리 (COUNT, SUM, AVG, GROUP BY, HAVING)**
  - `query_09.txt`
  - `query_10.txt`
  - `query_11.txt`
- **4. 서브쿼리 (단일행 & 다중행 서브쿼리)**
  - `query_12.txt`
  - `query_13.txt`
- **5. 데이터 수정 및 삭제 (UPDATE, DELETE)**
  - `query_14.txt`
  - `query_15.txt`
- **6. 보너스 과제 쿼리 및 데이터 정합성 실습**
  - `query_bonus_1_join.txt`
  - `query_bonus_1_subquery.txt`
  - `bonus_2_fk_integrity_error.txt`
  - `query_bonus_3_metric_1.txt`
  - `query_bonus_3_metric_2.txt`
  - `query_bonus_3_metric_3.txt`

---

## 1. 기본 조회 쿼리 (WHERE, ORDER BY, LIMIT)

### 01. `query_01.txt`

```text
=== -- [Q01] 가격이 10,000원 이상인 프리미엄 메뉴 목록 조회 ===
[SQL]:
SELECT id, store_id, name, price, category
FROM menu
WHERE price >= 10000
ORDER BY price DESC;

[EXECUTION RESULT]:
id | store_id | name | price | category
---------------------------------------
113 | 6 | 모둠 초밥 set | 18000 | 메인
115 | 8 | 에그 베네딕트 | 15000 | 메인
105 | 2 | 해산물 토마토 리조또 | 14900 | 메인
104 | 2 | 까르보나라 파스타 | 13900 | 메인
108 | 3 | 큐브 스테이크 덮밥 | 13500 | 메인
107 | 3 | 연어 덮밥 | 12500 | 메인
102 | 1 | 아보카도 베이컨버거 | 11900 | 메인
110 | 4 | 퀘사디아 | 11000 | 메인
114 | 7 | 로제 떡볶이 | 11000 | 메인
(Total rows: 9)
```

### 02. `query_02.txt`

```text
=== -- [Q02] 최근 등록된 상위 5개 매장 정보 조회 ===
[SQL]:
SELECT id, name, business_number, phone, created_at
FROM store
ORDER BY created_at DESC
LIMIT 5;

[EXECUTION RESULT]:
id | name | business_number | phone | created_at
------------------------------------------------
10 | 잠실 돈까스 하우스 | 000-44-55555 | 02-000-1111 | 2026-01-30 13:10:00
9 | 건대 피자 팩토리 | 999-33-44444 | 02-999-0000 | 2026-01-29 15:45:00
8 | 압구정 브런치 카페 | 888-22-33333 | 02-888-9999 | 2026-01-28 09:00:00
7 | 신촌 떡볶이 천국 | 555-11-22222 | 02-555-6666 | 2026-01-25 10:15:00
6 | 여의도 스시 집 | 123-88-11111 | 02-333-4444 | 2026-01-22 11:30:00
(Total rows: 5)
```

### 03. `query_03.txt`

```text
=== -- [Q03] 현재 주문 및 판매 가능한 상태(is_available = 1)인 메뉴 조회 ===
[SQL]:
SELECT id, store_id, name, price, category
FROM menu
WHERE is_available = 1;

[EXECUTION RESULT]:
id | store_id | name | price | category
---------------------------------------
101 | 1 | 클래식 치즈버거 | 8900 | 메인
102 | 1 | 아보카도 베이컨버거 | 11900 | 메인
103 | 1 | 감자튀김 | 3500 | 사이드
104 | 2 | 까르보나라 파스타 | 13900 | 메인
105 | 2 | 해산물 토마토 리조또 | 14900 | 메인
106 | 2 | 청포도 에이드 | 4500 | 음료
107 | 3 | 연어 덮밥 | 12500 | 메인
108 | 3 | 큐브 스테이크 덮밥 | 13500 | 메인
109 | 4 | 소고기 타코 | 9500 | 메인
110 | 4 | 퀘사디아 | 11000 | 메인
111 | 5 | 돈코츠 라멘 | 9000 | 메인
112 | 5 | 차슈 추가 | 2500 | 사이드
113 | 6 | 모둠 초밥 set | 18000 | 메인
114 | 7 | 로제 떡볶이 | 11000 | 메인
(Total rows: 14)
```

### 04. `query_04.txt`

```text
=== -- [Q04] 결제 완료(PAID) 상태의 주문 내역 조회 ===
[SQL]:
SELECT id, store_id, table_number, total_amount, created_at
FROM orders
WHERE status = 'PAID'
ORDER BY total_amount DESC;

-- ------------------------------------------
-- 2. 관계형 조인 쿼리 (4개 이상: INNER JOIN 2+, LEFT JOIN 1+)
-- ------------------------------------------;

[EXECUTION RESULT]:
id | store_id | table_number | total_amount | created_at
--------------------------------------------------------
13 | 6 | 1 | 36000 | 2026-02-03 19:00:00
7 | 3 | 1 | 26000 | 2026-02-02 12:00:00
2 | 1 | 2 | 23800 | 2026-02-01 12:30:00
6 | 2 | 3 | 22900 | 2026-02-01 19:00:00
9 | 4 | 1 | 20500 | 2026-02-02 18:00:00
4 | 2 | 1 | 18400 | 2026-02-01 18:00:00
12 | 5 | 2 | 18000 | 2026-02-03 12:30:00
1 | 1 | 1 | 12400 | 2026-02-01 12:00:00
11 | 5 | 1 | 11500 | 2026-02-03 12:00:00
14 | 7 | 1 | 11000 | 2026-02-04 12:00:00
(Total rows: 10)
```

## 2. 관계형 조인 쿼리 (INNER JOIN, LEFT JOIN)

### 05. `query_05.txt`

```text
=== -- [Q05] 식당(store)별 관리 중인 메뉴(menu) 정보 결합 조회 (INNER JOIN) ===
[SQL]:
SELECT s.name AS store_name, m.name AS menu_name, m.price, m.category
FROM store s
INNER JOIN menu m ON s.id = m.store_id
ORDER BY s.name ASC, m.price DESC;

[EXECUTION RESULT]:
store_name | menu_name | price | category
-----------------------------------------
강남 델리 파스타 | 해산물 토마토 리조또 | 14900 | 메인
강남 델리 파스타 | 까르보나라 파스타 | 13900 | 메인
강남 델리 파스타 | 청포도 에이드 | 4500 | 음료
성수 수제버거 | 아보카도 베이컨버거 | 11900 | 메인
성수 수제버거 | 클래식 치즈버거 | 8900 | 메인
성수 수제버거 | 감자튀김 | 3500 | 사이드
신촌 떡볶이 천국 | 로제 떡볶이 | 11000 | 메인
압구정 브런치 카페 | 에그 베네딕트 | 15000 | 메인
여의도 스시 집 | 모둠 초밥 set | 18000 | 메인
이태원 멕시칸 타코 | 퀘사디아 | 11000 | 메인
이태원 멕시칸 타코 | 소고기 타코 | 9500 | 메인
혜화 라멘 공방 | 돈코츠 라멘 | 9000 | 메인
혜화 라멘 공방 | 차슈 추가 | 2500 | 사이드
홍대 덮밥 연구소 | 큐브 스테이크 덮밥 | 13500 | 메인
홍대 덮밥 연구소 | 연어 덮밥 | 12500 | 메인
(Total rows: 15)
```

### 06. `query_06.txt`

```text
=== -- [Q06] 주문 내역과 주문이 발생한 식당 정보 결합 조회 (INNER JOIN) ===
[SQL]:
SELECT o.id AS order_id, s.name AS store_name, o.table_number, o.total_amount, o.status
FROM orders o
INNER JOIN store s ON o.store_id = s.id;

[EXECUTION RESULT]:
order_id | store_name | table_number | total_amount | status
------------------------------------------------------------
1 | 성수 수제버거 | 1 | 12400 | PAID
2 | 성수 수제버거 | 2 | 23800 | PAID
3 | 성수 수제버거 | 3 | 12400 | ORDERED
4 | 강남 델리 파스타 | 1 | 18400 | PAID
5 | 강남 델리 파스타 | 2 | 29800 | COOKING
6 | 강남 델리 파스타 | 3 | 22900 | PAID
7 | 홍대 덮밥 연구소 | 1 | 26000 | PAID
8 | 홍대 덮밥 연구소 | 2 | 12500 | CANCELLED
9 | 이태원 멕시칸 타코 | 1 | 20500 | PAID
10 | 이태원 멕시칸 타코 | 2 | 19000 | ORDERED
11 | 혜화 라멘 공방 | 1 | 11500 | PAID
12 | 혜화 라멘 공방 | 2 | 18000 | PAID
13 | 여의도 스시 집 | 1 | 36000 | PAID
14 | 신촌 떡볶이 천국 | 1 | 11000 | PAID
15 | 성수 수제버거 | 4 | 11900 | CANCELLED
(Total rows: 15)
```

### 07. `query_07.txt`

```text
=== -- [Q07] 주문 상세 내역(주문번호, 매장명, 메뉴명, 수량, 소계) 3개 테이블 결합 조회 (INNER JOIN) ===
[SQL]:
SELECT o.id AS order_id, s.name AS store_name, m.name AS menu_name, oi.quantity, oi.subtotal_price
FROM orders o
INNER JOIN store s ON o.store_id = s.id
INNER JOIN order_item oi ON o.id = oi.order_id
INNER JOIN menu m ON oi.menu_id = m.id;

[EXECUTION RESULT]:
order_id | store_name | menu_name | quantity | subtotal_price
-------------------------------------------------------------
1 | 성수 수제버거 | 클래식 치즈버거 | 1 | 8900
1 | 성수 수제버거 | 감자튀김 | 1 | 3500
2 | 성수 수제버거 | 아보카도 베이컨버거 | 2 | 23800
3 | 성수 수제버거 | 클래식 치즈버거 | 1 | 8900
3 | 성수 수제버거 | 감자튀김 | 1 | 3500
4 | 강남 델리 파스타 | 까르보나라 파스타 | 1 | 13900
4 | 강남 델리 파스타 | 청포도 에이드 | 1 | 4500
5 | 강남 델리 파스타 | 해산물 토마토 리조또 | 2 | 29800
6 | 강남 델리 파스타 | 까르보나라 파스타 | 1 | 13900
6 | 강남 델리 파스타 | 청포도 에이드 | 2 | 9000
7 | 홍대 덮밥 연구소 | 연어 덮밥 | 1 | 12500
7 | 홍대 덮밥 연구소 | 큐브 스테이크 덮밥 | 1 | 13500
8 | 홍대 덮밥 연구소 | 연어 덮밥 | 1 | 12500
9 | 이태원 멕시칸 타코 | 소고기 타코 | 1 | 9500
9 | 이태원 멕시칸 타코 | 퀘사디아 | 1 | 11000
10 | 이태원 멕시칸 타코 | 소고기 타코 | 2 | 19000
11 | 혜화 라멘 공방 | 돈코츠 라멘 | 1 | 9000
11 | 혜화 라멘 공방 | 차슈 추가 | 1 | 2500
12 | 혜화 라멘 공방 | 돈코츠 라멘 | 2 | 18000
13 | 여의도 스시 집 | 모둠 초밥 set | 2 | 36000
14 | 신촌 떡볶이 천국 | 로제 떡볶이 | 1 | 11000
15 | 성수 수제버거 | 아보카도 베이컨버거 | 1 | 11900
1 | 성수 수제버거 | 감자튀김 | 1 | 3500
4 | 강남 델리 파스타 | 청포도 에이드 | 1 | 4500
7 | 홍대 덮밥 연구소 | 연어 덮밥 | 1 | 12500
(Total rows: 25)
```

### 08. `query_08.txt`

```text
=== -- [Q08] 메뉴는 등록되었으나 주문 내역이 단 한 번도 없는 메뉴 조회 (LEFT JOIN & NULL) ===
[SQL]:
SELECT m.id, m.name AS menu_name, m.price, m.category
FROM menu m
LEFT JOIN order_item oi ON m.id = oi.menu_id
WHERE oi.id IS NULL;

-- ------------------------------------------
-- 3. 집계 쿼리 (3개 이상: COUNT, SUM, AVG + GROUP BY, HAVING)
-- ------------------------------------------;

[EXECUTION RESULT]:
id | menu_name | price | category
---------------------------------
115 | 에그 베네딕트 | 15000 | 메인
(Total rows: 1)
```

## 3. 집계 쿼리 (COUNT, SUM, AVG, GROUP BY, HAVING)

### 09. `query_09.txt`

```text
=== -- [Q09] 매장별 평균 메뉴 가격 및 등록된 메뉴 수 집계 (AVG, COUNT, GROUP BY) ===
[SQL]:
SELECT s.name AS store_name, COUNT(m.id) AS menu_count, AVG(m.price) AS avg_menu_price
FROM store s
INNER JOIN menu m ON s.id = m.store_id
GROUP BY s.id, s.name;

[EXECUTION RESULT]:
store_name | menu_count | avg_menu_price
----------------------------------------
성수 수제버거 | 3 | 8100.0
강남 델리 파스타 | 3 | 11100.0
홍대 덮밥 연구소 | 2 | 13000.0
이태원 멕시칸 타코 | 2 | 10250.0
혜화 라멘 공방 | 2 | 5750.0
여의도 스시 집 | 1 | 18000.0
신촌 떡볶이 천국 | 1 | 11000.0
압구정 브런치 카페 | 1 | 15000.0
(Total rows: 8)
```

### 10. `query_10.txt`

```text
=== -- [Q10] 매장별 결제 완료(PAID) 누적 매출액 집계 (SUM, GROUP BY, ORDER BY) ===
[SQL]:
SELECT s.name AS store_name, SUM(o.total_amount) AS total_sales
FROM store s
INNER JOIN orders o ON s.id = o.store_id
WHERE o.status = 'PAID'
GROUP BY s.id, s.name
ORDER BY total_sales DESC;

[EXECUTION RESULT]:
store_name | total_sales
------------------------
강남 델리 파스타 | 41300
성수 수제버거 | 36200
여의도 스시 집 | 36000
혜화 라멘 공방 | 29500
홍대 덮밥 연구소 | 26000
이태원 멕시칸 타코 | 20500
신촌 떡볶이 천국 | 11000
(Total rows: 7)
```

### 11. `query_11.txt`

```text
=== -- [Q11] 누적 매출액이 20,000원 이상인 우수 매장 집계 (SUM, GROUP BY, HAVING) ===
[SQL]:
SELECT s.name AS store_name, SUM(o.total_amount) AS total_sales
FROM store s
INNER JOIN orders o ON s.id = o.store_id
WHERE o.status = 'PAID'
GROUP BY s.id, s.name
HAVING SUM(o.total_amount) >= 20000;

-- ------------------------------------------
-- 4. 서브쿼리 (2개 이상)
-- ------------------------------------------;

[EXECUTION RESULT]:
store_name | total_sales
------------------------
성수 수제버거 | 36200
강남 델리 파스타 | 41300
홍대 덮밥 연구소 | 26000
이태원 멕시칸 타코 | 20500
혜화 라멘 공방 | 29500
여의도 스시 집 | 36000
(Total rows: 6)
```

## 4. 서브쿼리 (단일행 & 다중행 서브쿼리)

### 12. `query_12.txt`

```text
=== -- [Q12] 전체 메뉴의 평균 단가보다 높은 가격을 가진 메뉴 목록 조회 (단일행 서브쿼리) ===
[SQL]:
SELECT id, store_id, name, price, category
FROM menu
WHERE price > (SELECT AVG(price) FROM menu);

[EXECUTION RESULT]:
id | store_id | name | price | category
---------------------------------------
102 | 1 | 아보카도 베이컨버거 | 11900 | 메인
104 | 2 | 까르보나라 파스타 | 13900 | 메인
105 | 2 | 해산물 토마토 리조또 | 14900 | 메인
107 | 3 | 연어 덮밥 | 12500 | 메인
108 | 3 | 큐브 스테이크 덮밥 | 13500 | 메인
110 | 4 | 퀘사디아 | 11000 | 메인
113 | 6 | 모둠 초밥 set | 18000 | 메인
114 | 7 | 로제 떡볶이 | 11000 | 메인
115 | 8 | 에그 베네딕트 | 15000 | 메인
(Total rows: 9)
```

### 13. `query_13.txt`

```text
=== -- [Q13] 주문 내역이 0건인 미활성 매장 목록 조회 (다중행 서브쿼리) ===
[SQL]:
SELECT id, name, business_number, phone
FROM store
WHERE id NOT IN (SELECT DISTINCT store_id FROM orders);

-- ------------------------------------------
-- 5. 데이터 수정 및 삭제 (2개 이상: UPDATE, DELETE)
-- ------------------------------------------;

[EXECUTION RESULT]:
id | name | business_number | phone
-----------------------------------
8 | 압구정 브런치 카페 | 888-22-33333 | 02-888-9999
9 | 건대 피자 팩토리 | 999-33-44444 | 02-999-0000
10 | 잠실 돈까스 하우스 | 000-44-55555 | 02-000-1111
(Total rows: 3)
```

## 5. 데이터 수정 및 삭제 (UPDATE, DELETE)

### 14. `query_14.txt`

```text
=== -- [Q14] 주문 ID 3번의 상태를 결제완료(PAID)로 변경 (UPDATE) ===
[SQL]:
UPDATE orders
SET status = 'PAID'
WHERE id = 3;

[EXECUTION RESULT]:
SUCCESS: 1 row(s) affected.
```

### 15. `query_15.txt`

```text
=== -- [Q15] 취소된(CANCELLED) 주문의 상세 주문 항목 기록 삭제 (DELETE) ===
[SQL]:
DELETE FROM order_item
WHERE order_id IN (SELECT id FROM orders WHERE status = 'CANCELLED');


-- ==========================================
-- 6. 보너스 과제 쿼리
-- ==========================================;

[EXECUTION RESULT]:
SUCCESS: 2 row(s) affected.
```

## 6. 보너스 과제 쿼리 및 데이터 정합성 실습

### 16. `query_bonus_1_join.txt`

```text
=== -- [QB01A] 보너스 1: 조인 방식 - 주문 내역이 존재하는 매장 목록 조회 (INNER JOIN) ===
[SQL]:
SELECT DISTINCT s.id, s.name AS store_name, s.phone
FROM store s
INNER JOIN orders o ON s.id = o.store_id
ORDER BY s.id ASC;

[EXECUTION RESULT]:
id | store_name | phone
-----------------------
1 | 성수 수제버거 | 02-123-4567
2 | 강남 델리 파스타 | 02-987-6543
3 | 홍대 덮밥 연구소 | 02-111-2222
4 | 이태원 멕시칸 타코 | 02-444-5555
5 | 혜화 라멘 공방 | 02-777-8888
6 | 여의도 스시 집 | 02-333-4444
7 | 신촌 떡볶이 천국 | 02-555-6666
(Total rows: 7)
```

### 17. `query_bonus_1_subquery.txt`

```text
=== -- [QB01B] 보너스 1: 서브쿼리 방식 - 주문 내역이 존재하는 매장 목록 조회 (Subquery IN) ===
[SQL]:
SELECT id, name AS store_name, phone
FROM store
WHERE id IN (SELECT DISTINCT store_id FROM orders)
ORDER BY id ASC;

[EXECUTION RESULT]:
id | store_name | phone
-----------------------
1 | 성수 수제버거 | 02-123-4567
2 | 강남 델리 파스타 | 02-987-6543
3 | 홍대 덮밥 연구소 | 02-111-2222
4 | 이태원 멕시칸 타코 | 02-444-5555
5 | 혜화 라멘 공방 | 02-777-8888
6 | 여의도 스시 집 | 02-333-4444
7 | 신촌 떡볶이 천국 | 02-555-6666
(Total rows: 7)
```

### 18. `bonus_2_fk_integrity_error.txt`

```text
=== [보너스 2] 데이터 정합성 깨뜨려 보기 (FK 에러 테스트) ===
[상황 설명]: 존재하지 않는 store_id(=999) 참조 메뉴 등록 시도
[시도 SQL]:
INSERT INTO menu (store_id, name, price, category) VALUES (999, '유령 메뉴', 10000, '사이드');

[차단 결과]: sqlite3.IntegrityError 예외 수신 (성공)
[오류 메시지]: FOREIGN KEY constraint failed

[원인 분석]: DB 엔진의 참조 무결성(Referential Integrity) 제약 조건에 의해 부모 테이블(store)에 id=999가 존재하지 않으므로 자식 레코드 추가가 거부됨.
[해결 방법]: 부모 테이블(store)에 id=999 레코드를 선행 INSERT 하거나, 이미 존재하는 올바른 store_id를 지정하여 입력해야 함.
```

### 19. `query_bonus_3_metric_1.txt`

```text
=== -- [QB03A] 보너스 3 지표 1: 매장별 결제 완료 총 매출액 및 주문 건수 순위 (매출 실적 지표) ===
[SQL]:
SELECT 
    s.name AS store_name, 
    COUNT(o.id) AS paid_order_count, 
    SUM(o.total_amount) AS total_revenue,
    ROUND(AVG(o.total_amount), 0) AS avg_order_value
FROM store s
INNER JOIN orders o ON s.id = o.store_id
WHERE o.status = 'PAID'
GROUP BY s.id, s.name
ORDER BY total_revenue DESC;

[EXECUTION RESULT]:
store_name | paid_order_count | total_revenue | avg_order_value
---------------------------------------------------------------
성수 수제버거 | 3 | 48600 | 16200.0
강남 델리 파스타 | 2 | 41300 | 20650.0
여의도 스시 집 | 1 | 36000 | 36000.0
혜화 라멘 공방 | 2 | 29500 | 14750.0
홍대 덮밥 연구소 | 1 | 26000 | 26000.0
이태원 멕시칸 타코 | 1 | 20500 | 20500.0
신촌 떡볶이 천국 | 1 | 11000 | 11000.0
(Total rows: 7)
```

### 20. `query_bonus_3_metric_2.txt`

```text
=== -- [QB03B] 보너스 3 지표 2: 전체 매장 통합 가장 많이 판매된 TOP 3 인기 메뉴 (상품성 분석 지표) ===
[SQL]:
SELECT 
    m.name AS menu_name, 
    s.name AS store_name, 
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal_price) AS total_menu_revenue
FROM order_item oi
INNER JOIN menu m ON oi.menu_id = m.id
INNER JOIN store s ON m.store_id = s.id
GROUP BY m.id, m.name, s.name
ORDER BY total_quantity_sold DESC, total_menu_revenue DESC
LIMIT 3;

[EXECUTION RESULT]:
menu_name | store_name | total_quantity_sold | total_menu_revenue
-----------------------------------------------------------------
청포도 에이드 | 강남 델리 파스타 | 4 | 18000
소고기 타코 | 이태원 멕시칸 타코 | 3 | 28500
돈코츠 라멘 | 혜화 라멘 공방 | 3 | 27000
(Total rows: 3)
```

### 21. `query_bonus_3_metric_3.txt`

```text
=== -- [QB03C] 보너스 3 지표 3: 매장별 주문 취소율 및 취소 손실 금액 분석 (운영/리스크 지표) ===
[SQL]:
SELECT 
    s.name AS store_name,
    COUNT(o.id) AS total_orders,
    SUM(CASE WHEN o.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(CAST(SUM(CASE WHEN o.status = 'CANCELLED' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(o.id) * 100, 1) || '%' AS cancellation_rate,
    SUM(CASE WHEN o.status = 'CANCELLED' THEN o.total_amount ELSE 0 END) AS lost_revenue
FROM store s
INNER JOIN orders o ON s.id = o.store_id
GROUP BY s.id, s.name
ORDER BY cancelled_orders DESC, lost_revenue DESC;

[EXECUTION RESULT]:
store_name | total_orders | cancelled_orders | cancellation_rate | lost_revenue
-------------------------------------------------------------------------------
홍대 덮밥 연구소 | 2 | 1 | 50.0% | 12500
성수 수제버거 | 4 | 1 | 25.0% | 11900
강남 델리 파스타 | 3 | 0 | 0.0% | 0
이태원 멕시칸 타코 | 2 | 0 | 0.0% | 0
혜화 라멘 공방 | 2 | 0 | 0.0% | 0
여의도 스시 집 | 1 | 0 | 0.0% | 0
신촌 떡볶이 천국 | 1 | 0 | 0.0% | 0
(Total rows: 7)
```

