import sqlite3
import os
import re

def run_queries():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    results_dir = os.path.join(base_dir, "results")
    os.makedirs(results_dir, exist_ok=True)

    db_path = os.path.join(base_dir, "table_order_p2.db")
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    cursor = conn.cursor()

    schema_file = os.path.join(base_dir, "01_schema.sql")
    with open(schema_file, "r", encoding="utf-8") as f:
        cursor.executescript(f.read())

    data_file = os.path.join(base_dir, "02_data.sql")
    with open(data_file, "r", encoding="utf-8") as f:
        cursor.executescript(f.read())

    # [보너스 2] 외래키 정합성 파괴 실습 루틴
    bonus_2_output = []
    bonus_2_output.append("=== [보너스 2] 데이터 정합성 깨뜨려 보기 (FK 에러 테스트) ===")
    bonus_2_output.append("[상황 설명]: 존재하지 않는 store_id(=999) 참조 메뉴 등록 시도")
    bonus_2_output.append("[시도 SQL]:\nINSERT INTO menu (store_id, name, price, category) VALUES (999, '유령 메뉴', 10000, '사이드');\n")
    try:
        cursor.execute("INSERT INTO menu (store_id, name, price, category) VALUES (999, '유령 메뉴', 10000, '사이드');")
        conn.commit()
    except sqlite3.IntegrityError as e:
        bonus_2_output.append("[차단 결과]: sqlite3.IntegrityError 예외 수신 (성공)")
        bonus_2_output.append(f"[오류 메시지]: {e}")
        bonus_2_output.append("\n[원인 분석]: DB 엔진의 참조 무결성(Referential Integrity) 제약 조건에 의해 부모 테이블(store)에 id=999가 존재하지 않으므로 자식 레코드 추가가 거부됨.")
        bonus_2_output.append("[해결 방법]: 부모 테이블(store)에 id=999 레코드를 선행 INSERT 하거나, 이미 존재하는 올바른 store_id를 지정하여 입력해야 함.")

    with open(os.path.join(results_dir, "bonus_2_fk_integrity_error.txt"), "w", encoding="utf-8") as bf:
        bf.write("\n".join(bonus_2_output) + "\n")
    print("저장 완료: bonus_2_fk_integrity_error.txt")

    # 쿼리 파싱 및 실행
    queries_file = os.path.join(base_dir, "03_queries.sql")
    with open(queries_file, "r", encoding="utf-8") as f:
        queries_content = f.read()

    # 파싱 대상: -- [Q01] ~ [Q15] 및 -- [QB01A] ~ [QB03C]
    raw_queries = re.split(r'(--\s*\[Q[A-Z0-9]+\][^\n]*)', queries_content)
    
    query_blocks = []
    current_comment = ""
    for part in raw_queries:
        if part.strip().startswith("-- [Q"):
            current_comment = part.strip()
        elif current_comment and part.strip():
            sql = part.strip().rstrip(';')
            if sql:
                query_blocks.append((current_comment, sql + ";"))
            current_comment = ""

    print(f"파싱 완료된 쿼리 개수: {len(query_blocks)}")

    standard_idx = 1
    for comment, sql in query_blocks:
        # 파일명 매핑
        if "[Q" in comment and "QB" not in comment:
            file_name = f"query_{standard_idx:02d}.txt"
            standard_idx += 1
        elif "[QB01A]" in comment:
            file_name = "query_bonus_1_join.txt"
        elif "[QB01B]" in comment:
            file_name = "query_bonus_1_subquery.txt"
        elif "[QB03A]" in comment:
            file_name = "query_bonus_3_metric_1.txt"
        elif "[QB03B]" in comment:
            file_name = "query_bonus_3_metric_2.txt"
        elif "[QB03C]" in comment:
            file_name = "query_bonus_3_metric_3.txt"
        else:
            file_name = f"query_extra_{standard_idx}.txt"

        file_path = os.path.join(results_dir, file_name)

        output_lines = []
        output_lines.append(f"=== {comment} ===")
        output_lines.append(f"[SQL]:\n{sql}\n")
        output_lines.append("[EXECUTION RESULT]:")

        try:
            if sql.strip().upper().startswith("UPDATE") or sql.strip().upper().startswith("DELETE"):
                cursor.execute(sql)
                conn.commit()
                output_lines.append(f"SUCCESS: {cursor.rowcount} row(s) affected.")
            else:
                cursor.execute(sql)
                columns = [desc[0] for desc in cursor.description] if cursor.description else []
                rows = cursor.fetchall()

                if columns:
                    header = " | ".join(columns)
                    output_lines.append(header)
                    output_lines.append("-" * len(header))
                    for row in rows:
                        output_lines.append(" | ".join(str(val) for val in row))
                else:
                    output_lines.append("No result set returned.")
                output_lines.append(f"(Total rows: {len(rows)})")
        except Exception as e:
            output_lines.append(f"ERROR: {str(e)}")

        with open(file_path, "w", encoding="utf-8") as out_f:
            out_f.write("\n".join(output_lines) + "\n")
        print(f"저장 완료: {file_name}")

    conn.close()
    print("모든 쿼리 및 보너스 과제 실행 성공!")

if __name__ == "__main__":
    run_queries()
