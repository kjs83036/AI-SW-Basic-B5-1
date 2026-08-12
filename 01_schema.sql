-- ==========================================
-- 과제: 다중 매장 테이블 오더 (Table Order) 스키마
-- Phase 2: Full Schema DDL (4개 테이블 및 인덱스)
-- ==========================================

-- SQLite 참조 무결성(외래키) 활성화
PRAGMA foreign_keys = ON;

-- 기존 테이블 삭제 (의존성 역순: 자식 테이블 -> 부모 테이블)
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS store;

-- 1. 부모 테이블: store (식당/매장)
-- 식당 기본 정보 관리 및 사업자등록번호 UNIQUE 제약조건 적용
CREATE TABLE store (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    business_number TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- 2. 자식 테이블: menu (식당별 메뉴)
-- 특정 식당(store_id)에 귀속되는 1:N 관계 정의 및 외래키(FK) 제약조건 설정
CREATE TABLE menu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    price INTEGER NOT NULL,
    category TEXT NOT NULL,
    is_available INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (store_id) REFERENCES store(id) ON DELETE CASCADE
);

-- 3. 자식 테이블: orders (테이블 오더 주문 헤더)
-- 식당(store_id)과의 1:N 외래키 관계 정의 및 테이블 번호, 총액, 상태 관리
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    table_number INTEGER NOT NULL,
    total_amount INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'ORDERED', -- ORDERED, COOKING, PAID, CANCELLED
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (store_id) REFERENCES store(id) ON DELETE CASCADE
);

-- 4. 자식 테이블: order_item (주문별 상세 메뉴 항목)
-- 주문(order_id) 및 메뉴(menu_id)와의 N:M 해소를 위한 N:1 릴레이션 테이블
CREATE TABLE order_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    menu_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    subtotal_price INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE CASCADE
);

-- 5. 인덱스 정의: orders 매장별 최신 주문 검색 성능 최적화
-- 특정 매장(store_id) 데이터 필터링과 최신순(created_at) 정렬 연산(Filesort 방지)을 동시에 최적화하기 위함
CREATE INDEX idx_orders_store_created ON orders (store_id, created_at);
