# 🍽️ 다중 매장 테이블 오더 (Multi-Restaurant Table Order) SQL 데이터베이스 - Phase 1 프로토타입 문서

본 문서는 **소프트웨어 공학의 프로토타이핑 모형(Prototyping Model)**에 따라, 다중 매장 테이블 오더 시스템 데이터베이스 구축 과제의 **Phase 1 (요구사항 분석, 미니 ERD 설계, Rapid Prototyping 검증)**을 진행한 상세 기록 및 학습 문서입니다.

---

## 1. 📖 선행 학습 내용 (CS & Database Core)

### 1) 데이터베이스 (Database Core)
* **릴레이셔널 모델 (Relational Model)**:
  * 데이터를 테이블(Table, 릴레이션), 행(Row/Tuple, 튜플), 열(Column/Attribute, 속성)의 구조로 관리하는 모델입니다.
  * **엑셀 대비 RDBMS의 차이점**: 엑셀은 단순 평면 데이터 저장이지만, RDBMS는 테이블 간 **관계(Relationship)**를 정의하고 **데이터 무결성(Integrity)** 및 **ACID 트랜잭션**을 보장합니다.
* **키(Key)와 제약조건 (Constraints)**:
  * **PK (Primary Key)**: 각 행을 유일하게 식별하는 기본키 (유일성 + NOT NULL).
  * **FK (Foreign Key)**: 다른 테이블의 PK를 참조하여 **참조 무결성(Referential Integrity)**을 보장하는 외래키. 부모 테이블에 없는 값을 자식 테이블에 넣으려고 하면 DB 엔진 차원에서 에러를 발생시켜 차단합니다.
  * **NOT NULL**: 컬럼에 NULL 값이 들어오는 것을 방지.
  * **UNIQUE**: 해당 컬럼의 값이 중복되지 않도록 보장 (예: 사업자등록번호).
* **데이터 모델링 (1:N 관계)**:
  * 부모 테이블(1)과 자식 테이블(N) 관계에서 **FK는 항상 자식 테이블(N)**에 위치해야 합니다. (예: 식당 1곳이 여러 메뉴 N개를 가질 때, `menu` 테이블이 `store_id` FK를 소유).

### 2) SQL (Structured Query Language)
* **DDL (Data Definition Language)**: `CREATE TABLE`, `DROP TABLE`, `ALTER TABLE` 등 스키마 구조를 정의.
* **DML (Data Manipulation Language)**: `INSERT`, `UPDATE`, `DELETE`, `SELECT` 등 데이터를 조작/조회.
* **관계형 조회 (JOIN)**:
  * `INNER JOIN`: 두 테이블 간 조인 조건이 일치하는 행만 결합하여 조회.
  * `LEFT JOIN`: 왼쪽(부모) 테이블의 모든 행을 유지하면서, 오른쪽(자식) 테이블의 일치하는 데이터를 결합 (미존재 시 NULL).

### 3) 컴퓨터 스크립팅 및 환경 (CS / Tooling)
* **SQL 실행 순서 및 스크립트 종속성**:
  * DDL 생성 시: 부모 테이블(`store`) 생성 → 자식 테이블(`menu`) 생성.
  * DDL 삭제 시: 자식 테이블(`menu`) 삭제 → 부모 테이블(`store`) 삭제.
  * DML 삽입 시: 부모 데이터 `INSERT` → 자식 데이터 `INSERT`.
* **DB Client 사용법**: CLI (`sqlite3`) 또는 GUI 도구(DBeaver, TablePlus)를 통해 `.sql` 스크립트를 순차적으로 일괄 실행.

---

## 2. 📐 도메인 분석 및 미니 ERD 설계

### 1) 도메인 주제
* **주제**: 다중 매장 지원 테이블 오더 (Multi-Restaurant Table Order) 시스템
* **개념**: 손님이 식당/카페 자리에 앉아 태블릿이나 스마트폰으로 직접 메뉴를 확인하고 주문/결제하는 기기 및 서비스 시스템입니다.
* **핵심 요구사항**: 여러 식당(매장)이 시스템에 입점하여 자신의 메뉴를 자유롭게 관리할 수 있어야 합니다.

### 2) Phase 1 미니 ERD 및 테이블 명세
Phase 1 프로토타입 단계에서는 전체 요구사항 중 핵심이 되는 **[식당(1) : 메뉴(N)]** 1:N 관계 2개 테이블을 최초 모델링하였습니다.

```
+-----------------------------------+       1:N       +-----------------------------------+
|               store               | <-------------> |               menu                |
+-----------------------------------+ (FK: store_id)  +-----------------------------------+
| id (PK) INTEGER                   |                 | id (PK) INTEGER                   |
| name TEXT NOT NULL                |                 | store_id (FK) INTEGER NOT NULL    |
| business_number TEXT UNIQUE       |                 | name TEXT NOT NULL                |
| phone TEXT NOT NULL               |                 | price INTEGER NOT NULL            |
| created_at TEXT NOT NULL          |                 | category TEXT NOT NULL            |
+-----------------------------------+                 +-----------------------------------+
```

---

## 3. 🛠️ Rapid Prototyping 구현 및 검증 결과

### 1) 산출물 파일 구성
* [`01_schema_proto.sql`](01_schema_proto.sql): DDL 스크립트 (`store`, `menu` 테이블 생성 및 PK/FK/NOT NULL/UNIQUE 제약조건)
* [`02_data_proto.sql`](02_data_proto.sql): DML 스크립트 (`store` 2개 행, `menu` 6개 행 샘플 데이터)
* [`03_queries_proto.sql`](03_queries_proto.sql): DQL 스크립트 (기본 SELECT 및 INNER JOIN)

### 2) 쿼리 실행 결과 (SQLite 3 검증 로그)

#### [쿼리 1] 기본 SELECT (WHERE 조건절: 가격 10,000원 이상 메뉴 조회)
```sql
SELECT id, store_id, name, price, category FROM menu WHERE price >= 10000;
```
* **실행 결과**:
```text
102 | 1 | 아보카도 베이컨버거 | 11900 | 메인
104 | 2 | 까르보나라 파스타    | 13900 | 메인
105 | 2 | 해산물 토마토 리조또 | 14900 | 메인
```

#### [쿼리 2] 관계형 INNER JOIN (식당별 관리 메뉴 목록 결합 조회)
```sql
SELECT s.name AS store_name, m.name AS menu_name, m.price, m.category
FROM store s INNER JOIN menu m ON s.id = m.store_id
ORDER BY s.name ASC, m.price DESC;
```
* **실행 결과**:
```text
강남 델리 파스타 | 해산물 토마토 리조또 | 14900 | 메인
강남 델리 파스타 | 까르보나라 파스타    | 13900 | 메인
강남 델리 파스타 | 청포도 에이드       |  4500 | 음료
성수 수제버거   | 아보카도 베이컨버거 | 11900 | 메인
성수 수제버거   | 클래식 치즈버거    |  8900 | 메인
성수 수제버거   | 감자튀김          |  3500 | 사이드
```

### 3) 참조 무결성 (FK) 예외 검증 테스트
존재하지 않는 식당 번호(`store_id = 999`)를 가진 메뉴 등록 시도 시 SQLite 엔진에서 예외를 정상적으로 차단하는지 검증하였습니다.
```python
# 검증 코드 (파이썬 sqlite3 테스트)
cursor.execute("INSERT INTO menu (store_id, name, price, category) VALUES (999, '유령메뉴', 10000, '사이드');")
```
* **차단 결과**: `sqlite3.IntegrityError: FOREIGN KEY constraint failed` (정상 차단 성공)

---

## 4. 📊 과제 진행 상태 (Progress Status) & 향후 로드맵

### 1) 진행 상태 표 (Prototyping Roadmap)

| 단계 | 항목 | 주요 수행 내용 | 진행 상태 |
| :--- | :--- | :--- | :---: |
| **Phase 1** | **요구사항 분석 및 ERD** | 식당(store) - 메뉴(menu) 1:N 관계 미니 ERD 설계 | **[완료]** |
| | **Rapid Prototyping** | 스키마(DDL), 기초 데이터(DML), JOIN 쿼리 검증 | **[완료]** |
| | **문서화** | CS/DB 선행 지식 정리 및 검증 결과 기록 | **[완료]** |
| **Phase 2** | **스키마 전범위 확장** | 테이블 4개 이상 (`store`, `menu`, `orders`, `order_item`) 및 1:N 관계 2개 이상 확장 | **[대기]** |
| | **샘플 데이터 대량화** | 각 테이블당 최소 10행 이상의 의미있는 샘플 데이터 입력 | **[대기]** |
| | **핵심 SQL 15종 완성** | 집계(`GROUP BY`), `LEFT JOIN`, 서브쿼리, `UPDATE/DELETE`, `INDEX` 15개 완성 | **[대기]** |
| | **최종 산출물 패키징** | `.sql` 파일 3개 정교화, 캡처 자료 정리, 제출물 검증 | **[대기]** |

---

## 5. 🎯 결론 및 시사점 (Phase 1 요약)
1. **1:N 관계 무결성 검증 완료**: 부모(`store`) 및 자식(`menu`) 테이블을 분리함으로써 데이터 중복 없이 다중 식당 메뉴 관리가 가능함을 확인하였습니다.
2. **빠른 프로토타이핑 모형 효과**: 2개 핵심 테이블만으로 DB 접속, 제약조건, INNER JOIN 조회가 성공적으로 동작함을 선행 검증하여, Phase 2 전범위 확장 시 발생할 수 있는 결함을 사전에 방지하였습니다.
