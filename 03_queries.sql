-- ==========================================
-- 과제: 다중 매장 테이블 오더 (Table Order) 검증 쿼리
-- Phase 2: Core SQL Queries 15종 + 보너스 과제 쿼리
-- ==========================================

-- ------------------------------------------
-- 1. 기본 조회 쿼리 (4개 이상: WHERE, ORDER BY, LIMIT)
-- ------------------------------------------

-- [Q01] 가격이 10,000원 이상인 프리미엄 메뉴 목록 조회
SELECT id, store_id, name, price, category
FROM menu
WHERE price >= 10000
ORDER BY price DESC;

-- [Q02] 최근 등록된 상위 5개 매장 정보 조회
SELECT id, name, business_number, phone, created_at
FROM store
ORDER BY created_at DESC
LIMIT 5;

-- [Q03] 현재 주문 및 판매 가능한 상태(is_available = 1)인 메뉴 조회
SELECT id, store_id, name, price, category
FROM menu
WHERE is_available = 1;

-- [Q04] 결제 완료(PAID) 상태의 주문 내역 조회
SELECT id, store_id, table_number, total_amount, created_at
FROM orders
WHERE status = 'PAID'
ORDER BY total_amount DESC;

-- ------------------------------------------
-- 2. 관계형 조인 쿼리 (4개 이상: INNER JOIN 2+, LEFT JOIN 1+)
-- ------------------------------------------

-- [Q05] 식당(store)별 관리 중인 메뉴(menu) 정보 결합 조회 (INNER JOIN)
SELECT s.name AS store_name, m.name AS menu_name, m.price, m.category
FROM store s
INNER JOIN menu m ON s.id = m.store_id
ORDER BY s.name ASC, m.price DESC;

-- [Q06] 주문 내역과 주문이 발생한 식당 정보 결합 조회 (INNER JOIN)
SELECT o.id AS order_id, s.name AS store_name, o.table_number, o.total_amount, o.status
FROM orders o
INNER JOIN store s ON o.store_id = s.id;

-- [Q07] 주문 상세 내역(주문번호, 매장명, 메뉴명, 수량, 소계) 3개 테이블 결합 조회 (INNER JOIN)
SELECT o.id AS order_id, s.name AS store_name, m.name AS menu_name, oi.quantity, oi.subtotal_price
FROM orders o
INNER JOIN store s ON o.store_id = s.id
INNER JOIN order_item oi ON o.id = oi.order_id
INNER JOIN menu m ON oi.menu_id = m.id;

-- [Q08] 메뉴는 등록되었으나 주문 내역이 단 한 번도 없는 메뉴 조회 (LEFT JOIN & NULL)
SELECT m.id, m.name AS menu_name, m.price, m.category
FROM menu m
LEFT JOIN order_item oi ON m.id = oi.menu_id
WHERE oi.id IS NULL;

-- ------------------------------------------
-- 3. 집계 쿼리 (3개 이상: COUNT, SUM, AVG + GROUP BY, HAVING)
-- ------------------------------------------

-- [Q09] 매장별 평균 메뉴 가격 및 등록된 메뉴 수 집계 (AVG, COUNT, GROUP BY)
SELECT s.name AS store_name, COUNT(m.id) AS menu_count, AVG(m.price) AS avg_menu_price
FROM store s
INNER JOIN menu m ON s.id = m.store_id
GROUP BY s.id, s.name;

-- [Q10] 매장별 결제 완료(PAID) 누적 매출액 집계 (SUM, GROUP BY, ORDER BY)
SELECT s.name AS store_name, SUM(o.total_amount) AS total_sales
FROM store s
INNER JOIN orders o ON s.id = o.store_id
WHERE o.status = 'PAID'
GROUP BY s.id, s.name
ORDER BY total_sales DESC;

-- [Q11] 누적 매출액이 20,000원 이상인 우수 매장 집계 (SUM, GROUP BY, HAVING)
SELECT s.name AS store_name, SUM(o.total_amount) AS total_sales
FROM store s
INNER JOIN orders o ON s.id = o.store_id
WHERE o.status = 'PAID'
GROUP BY s.id, s.name
HAVING SUM(o.total_amount) >= 20000;

-- ------------------------------------------
-- 4. 서브쿼리 (2개 이상)
-- ------------------------------------------

-- [Q12] 전체 메뉴의 평균 단가보다 높은 가격을 가진 메뉴 목록 조회 (단일행 서브쿼리)
SELECT id, store_id, name, price, category
FROM menu
WHERE price > (SELECT AVG(price) FROM menu);

-- [Q13] 주문 내역이 0건인 미활성 매장 목록 조회 (다중행 서브쿼리)
SELECT id, name, business_number, phone
FROM store
WHERE id NOT IN (SELECT DISTINCT store_id FROM orders);

-- ------------------------------------------
-- 5. 데이터 수정 및 삭제 (2개 이상: UPDATE, DELETE)
-- ------------------------------------------

-- [Q14] 주문 ID 3번의 상태를 결제완료(PAID)로 변경 (UPDATE)
UPDATE orders
SET status = 'PAID'
WHERE id = 3;

-- [Q15] 취소된(CANCELLED) 주문의 상세 주문 항목 기록 삭제 (DELETE)
DELETE FROM order_item
WHERE order_id IN (SELECT id FROM orders WHERE status = 'CANCELLED');


-- ==========================================
-- 6. 보너스 과제 쿼리
-- ==========================================

-- [QB01A] 보너스 1: 조인 방식 - 주문 내역이 존재하는 매장 목록 조회 (INNER JOIN)
SELECT DISTINCT s.id, s.name AS store_name, s.phone
FROM store s
INNER JOIN orders o ON s.id = o.store_id
ORDER BY s.id ASC;

-- [QB01B] 보너스 1: 서브쿼리 방식 - 주문 내역이 존재하는 매장 목록 조회 (Subquery IN)
SELECT id, name AS store_name, phone
FROM store
WHERE id IN (SELECT DISTINCT store_id FROM orders)
ORDER BY id ASC;

-- [QB03A] 보너스 3 지표 1: 매장별 결제 완료 총 매출액 및 주문 건수 순위 (매출 실적 지표)
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

-- [QB03B] 보너스 3 지표 2: 전체 매장 통합 가장 많이 판매된 TOP 3 인기 메뉴 (상품성 분석 지표)
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

-- [QB03C] 보너스 3 지표 3: 매장별 주문 취소율 및 취소 손실 금액 분석 (운영/리스크 지표)
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
