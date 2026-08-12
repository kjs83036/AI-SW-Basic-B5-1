# 🍽️ 다중 매장 테이블 오더 (Table Order) SQL 데이터베이스 - Phase 2 최종 보고서 (보너스 과제 포함)

본 프로젝트는 **B5-1-2 SQL 기반 도메인 데이터베이스** 미션 요구사항에 따라 구축된 **다중 매장 테이블 오더 시스템 데이터베이스 Phase 2 산출물 디렉토리**입니다.

이전 Phase 1 프로토타입(`store`, `menu` 2개 테이블)에서 확장하여 **4개 테이블 전범위 스키마 구축, 10~25행 데이터 입력, 15종 핵심 SQL 및 5종 보너스 쿼리 작성, 파이썬 자동 실행 파이프라인, 보너스 과제 3종 종합 리포트**를 완성하였습니다.

---

## 1. 📐 Phase 2 데이터베이스 ERD 및 관계 구조

```text
+-----------------------------------+       1:N       +-----------------------------------+
|               store               | <-------------> |               menu                |
+-----------------------------------+ (FK: store_id)  +-----------------------------------+
| id (PK) INTEGER                   |                 | id (PK) INTEGER                   |
| name TEXT NOT NULL                |                 | store_id (FK) INTEGER NOT NULL    |
| business_number TEXT UNIQUE       |                 | name TEXT NOT NULL                |
| phone TEXT NOT NULL               |                 | price INTEGER NOT NULL            |
| created_at TEXT NOT NULL          |                 | category TEXT NOT NULL            |
+-----------------------------------+                 | is_available INTEGER NOT NULL     |
                  |                                   +-----------------------------------+
                  | 1:N                                                 |
                  v (FK: store_id)                                      | 1:N
+-----------------------------------+                                   | (FK: menu_id)
|              orders               |                                   |
+-----------------------------------+       1:N                         v
| id (PK) INTEGER                   | <-------------> +-----------------------------------+
| store_id (FK) INTEGER NOT NULL    | (FK: order_id)  |            order_item             |
| table_number INTEGER NOT NULL     |                 +-----------------------------------+
| total_amount INTEGER NOT NULL     |                 | id (PK) INTEGER                   |
| status TEXT NOT NULL              |                 | order_id (FK) INTEGER NOT NULL    |
| created_at TEXT NOT NULL          |                 | menu_id (FK) INTEGER NOT NULL     |
+-----------------------------------+                 | quantity INTEGER NOT NULL         |
                                                      | subtotal_price INTEGER NOT NULL   |
                                                      +-----------------------------------+
```

---

## 2. 📂 산출물 파일 구조 및 구성

```text
output_simple_2/
├── 01_schema.sql         # [DDL] 4개 테이블 생성, PK/FK/제약조건, 복합 인덱스 스크립트
├── 02_data.sql           # [DML] 부모-자식 참조 순서 준수 샘플 데이터 (테이블당 10~25행)
├── 03_queries.sql        # [DQL] 핵심 SQL 15종 + 보너스 쿼리 5종 및 주석 해설
├── run_queries.py        # [Python] SQL 자동 실행, FK 에러 테스트 및 results/ 채록 스크립트
├── docs/                 # [Doc] 상세 기술 문서 및 결과 종합 문서 폴더
│   ├── db설계 흐름.md    # DB 설계 4단계 프로세스, 유스케이스 및 액터 명세서
│   ├── index_정리.md     # B-Tree 인덱스 이론, 물리 구조, CUD 메커니즘 & 실무 튜닝 문서
│   └── result.md         # 21개 검증 쿼리 및 보너스 과제 종합 실행 결과 문서
├── results/              # [Output] 15개 핵심 쿼리 + 보너스 쿼리 실행 결과 텍스트 포맷팅 폴더
│   ├── query_01.txt ~ query_15.txt
│   ├── query_bonus_1_join.txt
│   ├── query_bonus_1_subquery.txt
│   ├── bonus_2_fk_integrity_error.txt
│   ├── query_bonus_3_metric_1.txt
│   ├── query_bonus_3_metric_2.txt
│   └── query_bonus_3_metric_3.txt
└── README.md             # [Doc] 본 최종 종합 보고서 (보너스 과제 3종 통합 리포트 포함)
```

---

## 3. 🚀 실행 가이드

로컬 환경에서 Python을 사용하여 15개 핵심 쿼리 및 보너스 테스트를 자동으로 재실행하고 텍스트 리포트를 생성할 수 있습니다.

```bash
cd "B5-1-2/output_simple_2"
python run_queries.py
```
* **결과**: `table_order_p2.db` SQLite 데이터베이스가 자동으로 생성되고, `results/` 폴더 내 21개 결과 텍스트 파일이 자동 갱신됩니다.

---

## 4. 🎁 보너스 과제 3종 통합 리포트

### 1) [보너스 1] 조인 1개를 두 방식으로 풀기 (JOIN vs 서브쿼리 비교)

- **요구사항**: "주문 내역이 존재하는 매장의 이름과 전화번호 목록 조회"

#### ① INNER JOIN 방식 (`query_bonus_1_join.txt`)
```sql
SELECT DISTINCT s.id, s.name AS store_name, s.phone
FROM store s
INNER JOIN orders o ON s.id = o.store_id
ORDER BY s.id ASC;
```

#### ② 서브쿼리 IN 방식 (`query_bonus_1_subquery.txt`)
```sql
SELECT id, name AS store_name, phone
FROM store
WHERE id IN (SELECT DISTINCT store_id FROM orders)
ORDER BY id ASC;
```

#### ③ 실행 결과 및 비교 분석
```text
id | store_name | phone
-----------------------------
1 | 성수 수제버거 | 02-123-4567
2 | 강남 델리 파스타 | 02-987-6543
3 | 홍대 덮밥 연구소 | 02-111-2222
4 | 이태원 멕시칸 타코 | 02-444-5555
5 | 혜화 라멘 공방 | 02-777-8888
6 | 여의도 스시 집 | 02-333-4444
7 | 신촌 떡볶이 천국 | 02-555-6666
(Total rows: 7)
```
- **결과 비교**: 두 방식 모두 동일한 7개 매장 결괏값을 정확히 반환합니다.
- **차이점 분석**:
  - `INNER JOIN`: 두 테이블의 카테시안 곱 후 조인 조건 필터링 및 `DISTINCT` 중복 제거를 수행합니다. 결합할 컬럼(주문 금액 등)이 추가될 때 유연합니다.
  - `Subquery (IN)`: 자식 테이블(`orders`)에서 `store_id` 집합을 먼저 추출한 뒤 부모 테이블의 PK 필터링에 사용합니다. 주 테이블의 데이터 구조가 단순할 때 가독성이 뛰어납니다.

---

### 2) [보너스 2] 데이터 정합성 깨뜨려 보기 (FK 에러 파괴 및 복구)

#### ① 의도적 FK 에러 유발 시도
- **상황**: 부모 테이블(`store`)에 존재하지 않는 `store_id = 999`를 참조하여 신규 메뉴를 삽입 시도.
```sql
INSERT INTO menu (store_id, name, price, category) 
VALUES (999, '유령 메뉴', 10000, '사이드');
```

#### ② 차단 결과 및 에러 로그 (`bonus_2_fk_integrity_error.txt`)
```text
[차단 결과]: sqlite3.IntegrityError 예외 수신 (성공)
[오류 메시지]: FOREIGN KEY constraint failed
```

#### ③ 원인 분석 및 해결 방법
- **원인 분석**: `PRAGMA foreign_keys = ON;`으로 활성화된 RDBMS 엔진이 **참조 무결성(Referential Integrity)** 제약 조건을 검증하여, 부모 테이블에 없는 키 값을 자식 레코드로 허용하지 않고 즉시 거부(`IntegrityError`)함.
- **해결 방법**:
  1. 부모 테이블(`store`)에 id=999 레코드를 먼저 삽입 후 메뉴를 등록.
  2. 올바른 기존 부모 키(예: `store_id = 1`)를 참조하도록 DML 수정.

---

### 3) [보너스 3] 미니 리포트 만들기 (3대 핵심 비즈니스 지표)

#### 📊 지표 1: 매장별 누적 결제 매출액 및 주문 건수 순위 (`query_bonus_3_metric_1.txt`)
```sql
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
```
- **실행 결과**:
```text
store_name | paid_order_count | total_revenue | avg_order_value
---------------------------------------------------------------
성수 수제버거 | 3 | 48600 | 16200.0
강남 델리 파스타 | 2 | 41300 | 20650.0
여의도 스시 집 | 1 | 36000 | 36000.0
혜화 라멘 공방 | 2 | 29500 | 14750.0
홍대 덮밥 연구소 | 1 | 26000 | 26000.0
이태원 멕시칸 타코 | 1 | 20500 | 20500.0
신촌 떡볶이 천국 | 1 | 11000 | 11000.0
```
- **비즈니스 인사이트**: `성수 수제버거`(48,600원, 3건)와 `강남 델리 파스타`(41,300원, 2건)가 최고 매출을 기록 중이며, `여의도 스시 집`은 단 1건의 주문만으로 객단가(36,000원)가 가장 높은 프리미엄 매장임을 알 수 있습니다.

---

#### 🍔 지표 2: 전체 매장 통합 가장 많이 판매된 TOP 3 인기 메뉴 (`query_bonus_3_metric_2.txt`)
```sql
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
```
- **실행 결과**:
```text
menu_name | store_name | total_quantity_sold | total_menu_revenue
-----------------------------------------------------------------
청포도 에이드 | 강남 델리 파스타 | 4 | 18000
소고기 타코 | 이태원 멕시칸 타코 | 3 | 28500
돈코츠 라멘 | 혜화 라멘 공방 | 3 | 27000
```
- **비즈니스 인사이트**: 수량 기준 가장 많이 팔린 효자 상품 1위는 `청포도 에이드`(4개, 18,000원)이며, 뒤이어 `소고기 타코`(3개, 28,500원)와 `돈코츠 라멘`(3개, 27,000원)이 인기 메뉴 TOP 3를 구성하고 있습니다.

---

#### ⚠️ 지표 3: 매장별 주문 취소율 및 취소 손실 금액 분석 (`query_bonus_3_metric_3.txt`)
```sql
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
```
- **실행 결과**:
```text
store_name | total_orders | cancelled_orders | cancellation_rate | lost_revenue
--------------------------------------------------------------------------------
홍대 덮밥 연구소 | 2 | 1 | 50.0% | 12500
성수 수제버거 | 4 | 1 | 25.0% | 11900
강남 델리 파스타 | 3 | 0 | 0.0% | 0
이태원 멕시칸 타코 | 2 | 0 | 0.0% | 0
혜화 라멘 공방 | 2 | 0 | 0.0% | 0
여의도 스시 집 | 1 | 0 | 0.0% | 0
신촌 떡볶이 천국 | 1 | 0 | 0.0% | 0
```
- **비즈니스 인사이트**: `홍대 덮밥 연구소`는 주문 2건 중 1건(취소율 50.0%, 손실 12,500원)이 취소되어 매장 운영 개선(조리 지연 점검 등)이 필요함을 도출할 수 있습니다.

---

## 5. 📊 평가 기준 통과 검증표 (15/15 Pass + 보너스 완수)

| 번호 | 평가 항목 | 요건 및 통과 기준 | Phase 2 구현 결과 | 판정 |
| :---: | :--- | :--- | :--- | :---: |
| **1** | 테이블 구성 및 PK | 최소 4개 테이블 및 PK 부여 | `store`, `menu`, `orders`, `order_item` 4개 테이블 및 PK 설정 완료 (`01_schema.sql`) | **Pass** |
| **2** | 1:N 관계 및 FK | 1:N 외래키 관계 2개 이상 | `store-menu`, `store-orders`, `orders-order_item`, `menu-order_item` 4쌍 FK 적용 | **Pass** |
| **3** | 데이터 수량 | 모든 테이블 최소 10행 이상 | `store`(10행), `menu`(15행), `orders`(15행), `order_item`(25행) 입력 완료 (`02_data.sql`) | **Pass** |
| **4** | 핵심 쿼리 15개 | 범주별 조건 충족 15개 작성 | 기본조회 4개, 조인 4개, 집계 3개, 서브쿼리 2개, DML 2개 등 15종 구성 (`03_queries.sql`) | **Pass** |
| **5** | 결과 검증 자료 | 쿼리별 설명 및 결과 파일 제출 | 파이썬 자동화를 통해 `results/` 폴더 내 21개 텍스트 리포트 추출 완료 | **Pass** |
| **6** | 테이블 분할 이유 | 테이블 정규화 및 역할 서술 | SRP 단일책임원칙 및 수정/삽입/삭제 이상 현상 방지 정규화 이론 서술 (`docs/db설계 흐름.md` 3절) | **Pass** |
| **7** | 1:N 관계 도메인 의미 | 비즈니스 시나리오 예시 제공 | 식당-메뉴, 식당-주문, 주문-주문상세 간 비즈니스 결합 관계 상세 기술 (`docs/db설계 흐름.md` 2절) | **Pass** |
| **8** | 컬럼 타입 선정 이유 | 데이터 타입 배경 설명 | INTEGER(원화 오차 방지), TEXT(사업자번호 0보정, ISO 날짜) 이유 작성 (`docs/db설계 흐름.md` 4절) | **Pass** |
| **9** | 인덱스 적용 이유 | 특정 컬럼 인덱스 튜닝 배경 | `orders(store_id, created_at)` 복합 B-Tree 인덱스를 통한 Range Scan 튜닝 기술 (`docs/index_정리.md` 7절) | **Pass** |
| **10** | DB vs 엑셀 차이 | 비교 및 분할 저장 이유 서술 | 동시 제어(Row-Lock), ACID 트랜잭션, 물리적 FK 제약 유무 비교 서술 (`docs/db설계 흐름.md` 1절) | **Pass** |
| **11** | PK/FK 역할 및 연결 | 1:N 관계 연결 원리 설명 | 주 식별자(PK)와 포인터/참조자(FK) 및 참조 무결성 거부 동작 작성 (`docs/db설계 흐름.md` 3, 4절) | **Pass** |
| **12** | INNER vs LEFT JOIN | 조인 방식의 개념/결과 차이 | 교집합(Inner)과 부모 보존 NULL 채움(Left Join) 조인 매커니즘 기술 (`docs/result.md` Q05~Q08) | **Pass** |
| **13** | GROUP BY 동작 원리 | 그룹핑 및 집계 파이프라인 | Filtering $\rightarrow$ Bucket Partitioning $\rightarrow$ Aggregation $\rightarrow$ HAVING 단계 해설 (`docs/result.md` Q09~Q11) | **Pass** |
| **14** | 복잡한 쿼리 풀이 | 단계별 execution order 풀이 | Q11 우수 매장 집계 쿼리의 6단계 Logical Execution Order 상세 분석 (`docs/result.md` Q11) | **Pass** |
| **15** | 미션 트러블슈팅 | 겪은 어려움과 해결 수기 | SQLite `PRAGMA foreign_keys=ON;` 및 DDL 테이블 삭제 순서 해결 경험 수기 (`docs/db설계 흐름.md` 4절) | **Pass** |
| **B1** | 보너스 과제 1 | 조인 1개 두 방식 비교 풀이 | JOIN vs Subquery IN 비교, 쿼리 및 파이프라인 차이 서술 (`README.md` 4-1절) | **완수** |
| **B2** | 보너스 과제 2 | FK 정합성 파괴 실습 | FK 위반 에러 유발, 원인 분석 및 부모 선행 입력 해결법 서술 (`README.md` 4-2절) | **완수** |
| **B3** | 보너스 과제 3 | 미니 리포트 3대 지표 | 매출 순위, TOP 3 인기 메뉴, 취소율/손실 분석 3대 지표 SQL 및 작성 (`README.md` 4-3절) | **완수** |

---

## 🎯 결론
- `B5-1-2/output_simple_2` 구축으로 백엔드 프레임워크 없는 순수 SQL 기반 RDBMS 도메인 모델링, 블랙박스 단위 테스트, 15개 요구사항 및 보너스 과제 3종이 완벽히 검증 및 통합되었습니다.
