-- ==========================================
-- 과제: 다중 매장 테이블 오더 (Table Order) 스키마
-- Phase 1: Rapid Prototyping (미니 스키마 DDL)
-- ==========================================

-- SQLite 참조 무결성(외래키) 활성화
PRAGMA foreign_keys = ON;

-- 의존성에 따른 기존 테이블 삭제 (자식 테이블 -> 부모 테이블)
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS store;

-- 1. 부모 테이블: store (식당/매장)
-- 식당 기본 정보 관리 및 사업자등록번호 고유성(UNIQUE) 제약조건 적용
CREATE TABLE store (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    business_number TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- 2. 자식 테이블: menu (식당별 메뉴)
-- 특정 식당(store_id)에 귀속되는 1:N 관계 정의 및 외래키(Foreign Key) 제약조건 설정
CREATE TABLE menu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    price INTEGER NOT NULL,
    category TEXT NOT NULL,
    is_available INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (store_id) REFERENCES store(id) ON DELETE CASCADE
);
