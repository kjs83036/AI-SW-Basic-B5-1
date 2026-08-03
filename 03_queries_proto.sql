-- ==========================================
-- 과제: 다중 매장 테이블 오더 (Table Order) 검증 쿼리
-- Phase 1: Rapid Prototyping (기초 SELECT 및 JOIN DQL)
-- ==========================================

-- 1. 기본 조회 쿼리 (WHERE 조건절 필터링)
-- 설명: 등록된 메뉴 중 가격이 10,000원 이상인 프리미엄 메뉴 목록 조회
SELECT id, store_id, name, price, category
FROM menu
WHERE price >= 10000;

-- 2. 관계형 조인 쿼리 (INNER JOIN 1:N 결합)
-- 설명: 각 식당(store)별로 관리하고 있는 메뉴(menu)의 이름, 가격, 카테고리 정보 조회
SELECT 
    s.name AS store_name,
    m.name AS menu_name,
    m.price,
    m.category
FROM store s
INNER JOIN menu m ON s.id = m.store_id
ORDER BY s.name ASC, m.price DESC;
