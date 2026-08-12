# 📐 다중 매장 테이블 오더 시스템: DB 설계 4단계 프로세스 (db설계 흐름.md)

본 문서는 `B5-1-2/output_simple_2` 산출물인 **"다중 매장 테이블 오더(Table Order) 시스템"**을 도메인 예시로 활용하여, 데이터베이스 공학의 **DB 설계 4단계 프로세스(요구사항 분석 → 개념적 설계 → 논리적 설계 → 물리적 설계)**를 단계별로 체계적으로 해설하는 종합 데이터 모델링 지침서입니다.

---

## 📌 DB 설계 프로세스 4단계 개관

데이터베이스 설계는 단순한 테이블 생성이 아니라, **현실 세계의 비즈니스 요구사항을 컴퓨터 메모리 및 디스크상의 정형화된 데이터 구조로 변환하는 정교한 공학적 과정**입니다.

```text
[ 1단계: 요구사항 분석 ] ➔ [ 2단계: 개념적 설계 ] ➔ [ 3단계: 논리적 설계 ] ➔ [ 4단계: 물리적 설계 ]
  비즈니스 도메인 및           엔티티/관계 도출            정규화 및 RDBMS           데이터 타입, B-Tree 인덱스
  기능/비기능 요구사항 정의       ERD 다이어그램 작성         테이블 스키마 정의          DBMS 튜닝 및 DDL 구현
```

---

## 1️⃣ 1단계: 요구사항 분석 (Requirement Analysis)

### 1. 비즈니스 도메인 및 시나리오 정의
* **시스템명**: 다중 매장 테이블 오더 (Table Order) 관리 시스템
* **서비스 배경**:
  - 하나의 플랫폼에서 다수의 외식업 매장이 등록되어 운영됩니다.
  - 손님은 테이블에 비치된 오더 태블릿을 통해 매장의 메뉴를 확인하고 실시간으로 주문 및 결제 요청을 수행합니다.
  - 매장 관리자는 실시간 주문 접수, 매출 집계, 인기 메뉴 분석 및 취소율 관리를 수행합니다.

### 2. 유스케이스 분석 (Use Case Analysis)

데이터베이스 스키마 설계 전, 시스템과 상호작용하는 **주요 액터(Actor)**와 액터가 수행하는 **핵심 유스케이스(Use Case)**를 정의하여 데이터 흐름을 명확히 합니다.

#### ① 액터(Actor) 정의
* **손님 (Customer / Table Tablet)**: 테이블 오더 태블릿을 통해 메뉴를 확인하고 1개 이상의 상품과 수량을 지정하여 실시간 주문을 제출하는 주체.
* **매장 관리자 (Store Admin)**: 매장 정보 및 메뉴판을 관리하며, 테이블 주문 상태(결제 완료, 취소 등)를 변경하고 매출 분석 리포트를 확인하는 주체.
* **DB 및 시스템 엔진 (System/RDBMS)**: 외래키 제약조건으로 참조 무결성을 검증하고, 복합 인덱스 및 집계 쿼리를 통해 통계 지표 데이터를 산출하는 엔진 주체.

#### ② 핵심 유스케이스 명세 (Use Case Specification)

| 유스케이스 ID | 유스케이스명 | 주 액터 | 설명 및 관련 데이터베이스 동작 |
| :--- | :--- | :--- | :--- |
| **UC-01** | **매장 및 메뉴 등록 관리** | 매장 관리자 | 신규 매장을 등록(`store`)하고 매장별 판매 메뉴, 단가, 카테고리, 품절 상태(`menu`)를 생성/수정함. |
| **UC-02** | **테이블 주문 생성** | 손님 | 착석 테이블에서 메뉴를 선택하고 1회 주문에 다수의 메뉴 항목과 수량을 결합하여 주문 헤더(`orders`) 및 주문 상세(`order_item`)를 동시 생성함. |
| **UC-03** | **주문 결제 및 취소 처리** | 매장 관리자 | 손님의 결제 완료 요청 시 주문 상태를 `PAID`로 전환하거나, 조리 불가/요청 시 `CANCELLED`로 변경하여 취소 손실액을 기록함. |
| **UC-04** | **비즈니스 리포트 및 매출 분석** | 매장 관리자 | 매장별 총 결제 매출/객단가 순위, 가장 많이 판매된 TOP 3 인기 메뉴, 매장별 취소율 및 취소 손실 금액 등 3대 지표 분석 쿼리를 실행함. |

#### ③ 액터-유스케이스 상호작용 매핑
```text
  [ 액터 (Actor) ]                   [ 유스케이스 (Use Case) ]               [ 관련 DB 테이블 ]

  +--------------+               +-------------------------------+
  |  손님 (Tablet) | ------------> | UC-02: 테이블 주문 생성         | -------> orders, order_item
  +--------------+               +-------------------------------+
                                                |
  +--------------+               +--------------v----------------+
  | 매장 관리자   | ------------> | UC-01: 매장 및 메뉴 등록 관리   | -------> store, menu
  | (Store Admin)| ------------> | UC-03: 주문 결제 및 취소 처리   | -------> orders (status UPDATE)
  +--------------+               +--------------Wait-------------+
                                                |
                                 +--------------v----------------+
                                 | UC-04: 비즈니스 매출 분석      | -------> store, orders, order_item, menu
                                 +-------------------------------+          (JOIN & GROUP BY)
```

### 3. 핵심 기능 요구사항 (Functional Requirements)
1. **매장 정보 관리**: 식당명, 사업자등록번호, 대표 전화번호를 독립적으로 식별하여 저장해야 합니다.
2. **메뉴 관리**: 식당별로 판매할 메뉴(메뉴명, 단가, 카테고리, 품절 여부)를 등록 및 유지보수해야 합니다.
3. **주문 헤더 관리**: 각 테이블에서 발생한 주문(테이블 번호, 총 결제 금액, 주문 상태[`ORDERED`, `PAID`, `CANCELLED`], 발생 시각)을 관리합니다.
4. **주문 상세 내역 관리**: 1건의 주문에는 여러 종류의 메뉴와 수량이 포함될 수 있으며, 개별 상품의 단가 및 소계 금액을 추적해야 합니다.

### 4. 비기능 및 기술 제약 요구사항 (Non-Functional Requirements)
* **데이터 정합성 (Data Integrity)**: 부모 레코드(예: 매장, 메뉴)가 없는 고아 주문 데이터 생성을 원천 차단해야 합니다.
* **조회 성능 (Query Performance)**: 일자별/매장별 매출 집계 및 특정 시간대 주문 조회가 대용량 환경에서도 지연 없이 수행되어야 합니다.
* **표준 기술 사용**: 순수 RDBMS 및 SQL 표준을 사용하여 백엔드 프레임워크 의존성을 배제합니다.

---

## 2️⃣ 2단계: 개념적 설계 (Conceptual Design)

요구사항 분석에서 도출된 비즈니스 객체들을 **엔티티(Entity)**와 **관계(Relationship)**로 추상화하여 **ERD (Entity-Relationship Diagram)**를 구축합니다.

### 1. 핵심 엔티티(Entity) 도출
* `store` (매장): 시스템에 등록된 외식업 매장 주체
* `menu` (메뉴): 매장에서 손님에게 제공하는 음식/음료 상품
* `orders` (주문 헤더): 테이블 손님이 실행한 1회의 거래 건
* `order_item` (주문 상세): 1회 거래 내역에 담긴 세부 메뉴 품목 및 수량

### 2. 엔티티 간 관계(Relationship) 정의
* **`store` (1) : `menu` (N)** (1대 다 관계)
  - 하나의 매장(1)은 여러 개의 상품 메뉴(N)를 등록할 수 있습니다.
* **`store` (1) : `orders` (N)** (1대 다 관계)
  - 하나의 매장(1)에서는 시간에 따라 다수의 테이블 주문(N)이 발생합니다.
* **`orders` (1) : `order_item` (N)** (1대 다 관계)
  - 1건의 주문(1)에는 여러 개의 개별 메뉴 항목(N)이 포함됩니다.
* **`menu` (1) : `order_item` (N)** (1대 다 관계)
  - 메뉴 1개는 여러 주문의 상세 내역에 반복 포함될 수 있습니다.
  - 💡 **N:M(다대다) 관계 해소**: `orders`와 `menu` 간의 교차 엔티티로 `order_item`을 배치하여 N:M 관계를 1:N 관계 2개로 분해했습니다.

### 3. 개념적 ERD 구조
```text
+-----------------------------------+       1:N       +-----------------------------------+
|               store               | <-------------> |               menu                |
| (매장 식별자, 매장명, 사업자번호)  | (FK: store_id)  | (메뉴 식별자, 메뉴명, 가격, 상태) |
+-----------------------------------+                 +-----------------------------------+
                  |                                                     |
                  | 1:N                                                 | 1:N
                  v (FK: store_id)                                      | (FK: menu_id)
+-----------------------------------+                                   |
|              orders               |                                   |
| (주문 식별자, 테이블번호, 총금액)  |       1:N                         v
+-----------------------------------+ <-------------> +-----------------------------------+
                                      (FK: order_id)  |            order_item             |
                                                      | (상세 식별자, 수량, 소계금액)     |
                                                      +-----------------------------------+
```

---

## 3️⃣ 3단계: 논리적 설계 (Logical Design)

개념적 설계 모델을 **관계형 데이터베이스(RDBMS)**의 테이블 구조로 매핑하고, **정규화 이론(Normalization)**을 적용하여 이상 현상을 제거합니다.

### 1. 정규화 이론 적용 (테이블 분할 이유)
모든 데이터를 하나의 단일 거대 테이블(엑셀 방식)로 저장할 경우 다음과 같은 **데이터 이상 현상(Anomaly)**이 발생합니다.

* **수정 이상 (Update Anomaly)**: 매장 전화번호 변경 시, 과거 발생한 수만 건의 주문 행을 일일이 수정해야 하며 누락 시 데이터 불일치가 발생합니다.
* **삽입 이상 (Insertion Anomaly)**: 신규 매장이나 신규 메뉴를 등록하려 해도 아직 발생한 주문이 없으면 주문 관련 컬럼(`NOT NULL`) 제약 조건에 막혀 등록이 불가능합니다.
* **삭제 이상 (Deletion Anomaly)**: 주문 기록을 취소/삭제할 때 해당 매장의 기본 정보나 메뉴 정보까지 함께 삭제되는 데이터 손실이 일어납니다.

👉 **해결책**: **단일 책임 원칙(SRP)**에 따라 데이터 속성의 주체별로 4개 테이블로 분할하여 1NF~3NF를 충족시켰습니다.

### 2. 논리적 테이블 스키마 명세

#### ① `store` (매장 테이블)
| 컬럼명 (Column) | 논리 데이터 타입 | 제약 조건 (Constraints) | 비즈니스 설명 |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | `PRIMARY KEY AUTOINCREMENT` | 매장 고유 식별자 |
| `name` | TEXT | `NOT NULL` | 매장명 |
| `business_number` | TEXT | `UNIQUE NOT NULL` | 사업자등록번호 (중복 금지) |
| `phone` | TEXT | `NOT NULL` | 매장 대표 전화번호 |
| `created_at` | TEXT | `NOT NULL` | 입점 등록 일시 |

#### ② `menu` (메뉴 테이블)
| 컬럼명 (Column) | 논리 데이터 타입 | 제약 조건 (Constraints) | 비즈니스 설명 |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | `PRIMARY KEY AUTOINCREMENT` | 메뉴 고유 식별자 |
| `store_id` | INTEGER | `FOREIGN KEY (store.id) NOT NULL` | 소속 매장 식별자 |
| `name` | TEXT | `NOT NULL` | 메뉴 상품명 |
| `price` | INTEGER | `NOT NULL` | 메뉴 판매 단가 |
| `category` | TEXT | `NOT NULL` | 메뉴 카테고리 (메인, 사이드 등) |
| `is_available` | INTEGER | `NOT NULL DEFAULT 1` | 판매 가능 여부 (1: 가능, 0: 품절) |

#### ③ `orders` (주문 헤더 테이블)
| 컬럼명 (Column) | 논리 데이터 타입 | 제약 조건 (Constraints) | 비즈니스 설명 |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | `PRIMARY KEY AUTOINCREMENT` | 주문 고유 식별자 |
| `store_id` | INTEGER | `FOREIGN KEY (store.id) NOT NULL` | 주문 발생 매장 식별자 |
| `table_number` | INTEGER | `NOT NULL` | 손님 테이블 번호 |
| `total_amount` | INTEGER | `NOT NULL` | 주문 총 결제 금액 |
| `status` | TEXT | `NOT NULL DEFAULT 'ORDERED'` | 주문 상태 (`ORDERED`, `PAID`, `CANCELLED`) |
| `created_at` | TEXT | `NOT NULL` | 주문 시각 |

#### ④ `order_item` (주문 상세 테이블)
| 컬럼명 (Column) | 논리 데이터 타입 | 제약 조건 (Constraints) | 비즈니스 설명 |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | `PRIMARY KEY AUTOINCREMENT` | 주문 상세 고유 식별자 |
| `order_id` | INTEGER | `FOREIGN KEY (orders.id) NOT NULL` | 소속 주문 헤더 식별자 |
| `menu_id` | INTEGER | `FOREIGN KEY (menu.id) NOT NULL` | 주문한 메뉴 식별자 |
| `quantity` | INTEGER | `NOT NULL` | 주문 수량 |
| `subtotal_price` | INTEGER | `NOT NULL` | 개별 품목 소계 금액 (`price * quantity`) |

---

## 4️⃣ 4단계: 물리적 설계 (Physical Design)

특정 DBMS(본 프로젝트: SQLite)의 엔진 특성을 반영하여 **컬럼 데이터 타입 결정, 성능 튜닝 인덱스 생성, 참조 무결성 제약 물리 스크립트(DDL)**를 완성합니다.

### 1. 컬럼 데이터 타입 선정 배경 및 이유
* **`INTEGER` 타입 선정 사유**:
  - `id`, `store_id`, `menu_id`, `order_id`: 정수형 식별자를 사용하여 메모리 사용량을 최소화하고 빠른 `JOIN` 연산 보장.
  - `price`, `quantity`, `total_amount`, `subtotal_price`: 한국 원화(KRW) 금액과 수량 데이터는 부동소수점(`FLOAT`) 사용 시 발생하는 **IEEE 754 부동소수점 오차(소수점 0.000000000000001 계산 오류)를 완전 차단**하기 위해 완벽한 정수형(`INTEGER`)으로 처리.
* **`TEXT` 타입 선정 사유**:
  - `business_number` (사업자등록번호): 앞자리가 '0'으로 시작하는 번호(예: `012-34-56789`) 유실 방지 및 하이픈 기호 보존을 위해 숫자가 아닌 문자열 지정.
  - `created_at`: 표준 **ISO-8601 문자열 포맷(`YYYY-MM-DD HH:MM:SS`)**을 사용하여 DB 전반의 날짜 정렬과 정규식 검색 최적화.

### 2. 물리적 성능 튜닝 (Index B-Tree 설계)
* **복합 인덱스 생성 DDL**:
  ```sql
  CREATE INDEX idx_orders_store_created ON orders (store_id, created_at);
  ```
* **인덱스 적용 사유 및 튜닝 메커니즘**:
  - **조회 패턴**: 실무 POS/테이블 오더에서 가장 빈번한 쿼리는 **"특정 매장(`store_id`)의 최근 일자별(`created_at`) 주문 내역 조회"**입니다.
  - **풀 테이블 스캔 한계**: 인덱스가 없을 경우 테이블 전체를 처음부터 탐색하는 **Full Table Scan ($O(N)$)**이 발생합니다.
  - **B-Tree 인덱스 효과**: `(store_id, created_at)` 복합 B-Tree 인덱스를 적용하면 선두 컬럼(`store_id`)으로 탐색 대상을 수렴시킨 후 날짜 순으로 연속 스캔하는 **Index Range Scan ($O(\log N)$)**으로 전환되어 대용량 환경에서도 즉각적인 속도를 보장합니다.

### 3. DBMS 특성 반영 및 무결성 제약 튜닝
* **SQLite 외래키 제약조건 기본 비활성화 해제**:
  SQLite 엔진은 하위 호환성을 위해 외래키 감지가 기본 `OFF`로 설정되어 있습니다. 물리 DDL 및 Connection 실행 시 최상단에 다음을 명시해야 합니다.
  ```sql
  PRAGMA foreign_keys = ON;
  ```
* **DDL 재생성 시 자식/부모 삭제 순서 의존성 제어**:
  부모 테이블을 먼저 삭제할 경우 자식 테이블의 FK가 고아 상태(Orphan Reference)가 되므로, 삭제 시에는 반드시 자식 테이블부터 역순으로 삭제합니다.
  ```sql
  DROP TABLE IF EXISTS order_item;
  DROP TABLE IF EXISTS orders;
  DROP TABLE IF EXISTS menu;
  DROP TABLE IF EXISTS store;
  ```

---

## 🏁 최종 산출물 DDL (01_schema.sql)

DB 설계 4단계를 완결하는 최종 물리적 DDL 생성 스크립트 예시입니다.

```sql
-- [1. 환경 설정] 외래키 제약 조건 활성화
PRAGMA foreign_keys = ON;

-- [2. 기존 테이블 역순 삭제]
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS store;

-- [3. 매장 테이블 (부모)]
CREATE TABLE store (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    business_number TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- [4. 메뉴 테이블 (자식: store 참조)]
CREATE TABLE menu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    price INTEGER NOT NULL,
    category TEXT NOT NULL,
    is_available INTEGER NOT NULL DEFAULT 1 CHECK(is_available IN (0, 1)),
    FOREIGN KEY (store_id) REFERENCES store(id) ON DELETE CASCADE
);

-- [5. 주문 헤더 테이블 (자식: store 참조)]
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    table_number INTEGER NOT NULL,
    total_amount INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'ORDERED' CHECK(status IN ('ORDERED', 'PAID', 'CANCELLED')),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (store_id) REFERENCES store(id) ON DELETE CASCADE
);

-- [6. 주문 상세 테이블 (자식: orders, menu 참조)]
CREATE TABLE order_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    menu_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    subtotal_price INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE RESTRICT
);

-- [7. B-Tree 복합 인덱스 생성]
CREATE INDEX idx_orders_store_created ON orders (store_id, created_at);
```

---

## 5️⃣ 핵심 4개 테이블 모델의 설계 배경 (MVP 관점)

`output_simple_2` 모델은 실제 상용 서비스의 14~30여 개 테이블 구조와 달리 **핵심 도메인 4개 테이블(`store`, `menu`, `orders`, `order_item`)**에 집중하여 설계되었습니다. 이러한 단추화된 모델링은 다음과 같은 명확한 목표와 요구사항에 기반합니다.

### 1. 최소 기능 모델 (MVP, Minimum Viable Product) 접근법
- **핵심 RDBMS 원리 검증**: 관계형 데이터베이스의 가장 본질적인 요소인 **기본키(PK), 외래키(FK), 1:N 관계 결합, 정규화(1NF~3NF)를 통한 이상 현상(Anomaly) 방지**를 직관적이고 완결성 있게 입증하기 위함입니다.
- **도메인 노이즈 제거**: 초기 설계 단계에서 착석 세션, 복합 옵션, HW 관제, PG 승인 연동 등 부차적인 기능 테이블이 대거 포함되면 스키마의 시각적 복잡도와 조인 난이도가 높아져 RDBMS 핵심 개념 학습 본질이 모호해집니다.

### 2. 학습 및 검증 가성비 극대화
- 4개 테이블 구조만으로도 **1:N 관계 4쌍 수립, 15종 표준 SQL(조회, 조인, 집계, 서브쿼리, DML), B-Tree 인덱스 튜닝 및 외래키 참조 무결성 검증** 등 실무 요구사항의 100%를 깔끔하게 대응할 수 있는 가장 효율적인 최소 스키마입니다.

---

## 6️⃣ 실무 상용급 DB로의 확장을 위해 보충해야 할 요소 (Phase 3 기반)

현실 세계의 상용 테이블 오더 서비스(예: 티오더, 캐치테이블, POS 시스템 등)로 서비스를 고도화하기 위해서는 `output_simple_3`(14개 테이블) 및 엔터프라이즈 아키텍처 수준의 보충이 필요합니다.

```text
+----------------------------------------------------------------------------------------------------+
|                               실무 생산급 DB 확장 로드맵 (보충 필요 요소)                            |
+----------------------------------------------------------------------------------------------------+
| 1. 착석 세션 (table_sessions)   | 2. 가격 스냅샷 (order_items snapshot) | 3. 3단계 옵션 (menu_options)   |
| 4. HW 태블릿 관제 (devices)     | 5. 실시간 재고 락 (menu_stocks)      | 6. 더치페이 (payment_splits)   |
| 7. Multi-Tenant 샤딩 격리        | 8. 비동기 Outbox PG 승인 멱등성       | 9. 오프라인 이벤트 로컬 Sync    |
+----------------------------------------------------------------------------------------------------+
```

### 1. `output_simple_3` (14개 생산급 모델) 수준의 핵심 보충점
1. **테이블 착석 세션 라이프사이클 (`table_sessions`)**:
   - 1회성 주문 기록의 한계를 극복하고, 손님의 착석~퇴장 간 1차/2차 다중 주문을 UUID 세션 단위로 그룹핑하여 최종 후불 정산하는 구조 보충.
2. **주문 시점 스냅샷 패턴 (Snapshot Pattern, `order_items`, `order_item_options`)**:
   - 내일 메뉴판 단가(`menus.price`)가 인상되더라도 과거 결제 장부 매출 데이터가 변조되지 않도록 주문 시점의 상품명, 단가, 옵션가를 비정규화 불변 값으로 복사 보존하는 스냅샷 스키마 보충.
3. **3단계 다단계 메뉴 옵션 구조 (`categories`, `menu_option_groups`, `menu_options`)**:
   - 단일 메뉴 단가를 넘어 필수/선택 옵션, 맵기 조절, 토핑 추가금 등을 유연하게 처리하는 N:M 옵션 그룹 스키마 보충.
4. **하드웨어 태블릿 관제 (`devices`)**:
   - 매장 내 수십 대 태블릿의 배터리 잔량, 최신 헬스체크(Heartbeat) 시각을 기록하여 네트워크 단절 및 전원 꺼짐 기기를 자동 감지하는 모니터링 테이블 보충.
5. **1:1 한정 수량 실시간 재고 락 (`menu_stocks`)**:
   - 동시 주문 환경에서 동시성 제어(Race Condition)를 처리하고 0개 도달 시 자동 품절(`is_sold_out = 1`) 동기화 스키마 보충.
6. **N분의 1 더치페이 분할 결제 (`payments`, `payment_splits`)**:
   - PG 결제 승인 연동 및 복수 결제 수단(카드, 간편결제), 더치페이 분할 정산 테이블 보충.

### 2. 실제 상용 엔터프라이즈 DB (티오더/POS 등) 수준의 추가 보충점
* **Multi-Tenant Sharding & Data Isolation**: 수만 개 매장의 피크 타임 트래픽 분산을 위한 `store_id` 기반 Database Sharding 및 Row Level Security (RLS).
* **Transactional Outbox Pattern & PG Webhook 멱등성**: 네트워크 단절 시 PG 결제 중복 승인/유실 방지를 위한 멱등성 키(Idempotency Key) 스키마.
* **Offline Event Sourcing**: 매장 Wi-Fi 단절 시 태블릿 로컬 DB(Event Log)에 주문을 저장한 후 네트워크 복구 시 서버로 비동기 Sync하는 오프라인 무중단 스키마.
* **KDS (Kitchen Display System) 분할 라우팅**: 튀김/메인/바 주방 모니터 영역별로 주문서를 자동 쪼개어 전달하는 라우팅 스키마(`kds_stations`).
* **Redis Distributed Lock (Redlock)**: RDBMS DB Lock Wait 병목을 해소하기 위한 In-Memory Atomic 초고속 재고 차감 레이어 연동.

---

## 📊 요약: 설계 4단계 및 확장 체크리스트

| 설계 단계 | 주요 작업 내용 | 핵심 결과물 및 검증 |
| :---: | :--- | :--- |
| **1단계: 요구사항 분석** | 비즈니스 도메인 및 기능/비기능 요구사항 정의 | 요구사항 명세서 (SRS), 도메인 범위 확정 |
| **2단계: 개념적 설계** | 엔티티 및 1:N 관계 도출, N:M 교차 테이블 해소 | 개념적 ERD 다이어그램 |
| **3단계: 논리적 설계** | RDBMS 스키마 매핑, 정규화(1NF~3NF)로 이상 현상 방지 | 테이블 스키마 정의서, PK/FK 키 구조 |
| **4단계: 물리적 설계** | Data Type(원화 정수, ISO 날짜), B-Tree 인덱스, FK 활성화 | 실행 가능한 DDL 스크립트 (`01_schema.sql`) |
| **확장: 실무 생산급 (Phase 3)** | 착석 세션, 스냅샷, HW관제, 3단계 옵션, 더치페이 확장 | 14개 생산급 스키마 및 엔터프라이즈 아키텍처 |
