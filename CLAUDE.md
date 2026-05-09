# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

"Comtest" — 그누보드5(Gnuboard5)를 로컬 XAMPP / AAMPP 환경에 자동 셋팅하기 위한 PHP CLI 도구를 담는 레포입니다. 운영용 서비스 코드가 아니라 개발자 워크스테이션의 셋업 자동화가 목적입니다.

## Layout

- `scripts/install_gnuboard5.php` — 단일 파일 PHP CLI 설치 스크립트 (다운로드+DB+스키마+커스터마이즈 전부)
- `customers/example.json` — 고객사 프로파일 템플릿. 사본을 만들어 회사별로 사용
- `README.md` — 사용자 입장에서의 실행 방법
- `test.py` — **사용하지 않음.** 비표준 placeholder 내용(`Test.py`, `/**/`, `import * 4421`)이며 Python 모듈이 아닙니다. 이 파일을 import하거나 실행하거나 모범으로 삼지 말 것.
- `.gitignore` — Python 표준 패턴 (레포 초기 흔적). PHP 산출물이 추가되면 보강 필요.

## Architecture (`scripts/install_gnuboard5.php`)

이 스크립트는 **install.php 마법사를 완전히 우회**합니다. 그누보드 install_db.php 의 로직을 PHP 측에서 그대로 재현하고, 추가로 고객사 프로파일을 적용합니다.

스크립트가 하는 일 (in order):
1. PHP 확장 검사 (`mysqli`, `zip`, `curl` or `allow_url_fopen`)
2. CLI 인자 파싱, 프로파일(`--profile=<json>`) 로드
3. 누락된 필수 값은 대화식 프롬프트
4. `https://codeload.github.com/gnuboard/gnuboard5/zip/refs/heads/<branch>` 에서 zip 다운로드
5. 압축 해제 → 대상 htdocs 경로로 이동
6. 관리자 자격으로 MySQL 접속 → DB·사용자 생성·`GRANT`·`FLUSH`
7. 새로 만든 사용자로 재접속 → `install/gnuboard5.sql` 임포트 (라인주석 제거 + `g5_` prefix 치환 후 `;` 단위로 실행)
8. `g5_config` 기본 행 INSERT (회사 정보는 `cf_1..cf_6` + `cf_*_subj` 라벨)
9. `g5_qa_config`, `g5_member`(admin), `g5_content`(pages), `g5_faq_master` INSERT
10. 프로파일의 그룹/게시판마다 `g5_group`/`g5_board` INSERT + `g5_write_<bo_table>` CREATE (`adm/sql_write.sql`의 `__TABLE_NAME__` 치환)
11. 로고 파일 복사 → `<target>/data/logo.<ext>`
12. `data/dbconfig.php` 작성 → 이후 install.php 는 차단됨

스크립트가 **하지 않는** 일:
- **install/ 디렉터리 정리.** 사용자 결정에 따라 그대로 둡니다 (dbconfig.php가 존재하면 마법사가 차단되므로 안전).
- **테마 파일 수정.** 로고는 `data/logo.*` 에 복사만 하며 테마가 직접 참조해야 합니다.
- **웹서버 vhost / 권한 / `.htaccess`.** XAMPP/AAMPP가 처리한다고 가정.

### 그누보드 호환성 핵심 포인트 (변경 시 반드시 확인)

- **비밀번호 해시**: 그누보드 `sql_password()` = MariaDB/MySQL 5.x `PASSWORD()` 결과 = `'*' . strtoupper(sha1(sha1($v, true)))`. `gnuboard_password_hash()` 가 동일 결과를 반환하므로 INSERT 후 평소 로그인 플로우와 호환. **MySQL 8.0** 은 `PASSWORD()` 함수가 제거되어 로그인이 깨질 수 있음 — 이 경우 그누보드 측 `G5_STRING_ENCRYPT_FUNCTION = 'create_hash'` 활성화 + `password_hash()` 기반 해시로 교체 필요.
- **회사정보 매핑**: 코어 `g5_config` 에 `cf_company_*` 가 없어서 `cf_1..cf_6` + `cf_*_subj` 라벨 슬롯을 사용. 영카트(`g5_shop_*`)에는 전용 컬럼이 있지만 본 도구는 코어만 다룸. 이 매핑을 바꾸려면 README도 같이 갱신할 것.
- **스키마 임포트 방식**: install_db.php 가 사용하는 `eval()` 변수 보간은 사용하지 않음. 현재 `gnuboard5.sql` 에는 `{$...}` 토큰이 없어 안전. 그누보드가 SQL 안에 변수를 삽입하기 시작하면 import_schema()를 다시 손봐야 함.
- **쓰기 테이블 스키마**: `adm/sql_write.sql` 의 `__TABLE_NAME__` 치환 로직은 install_db.php 와 동일. semicolon은 모두 제거 후 단일 query로 실행.

### 보안 관련 불변식

DB 식별자(database/user 이름, `bo_table`, `gr_id`, `co_id`, `mb_id`)는 `validate_identifier()`에서 `^[A-Za-z0-9_]+$`로 화이트리스트 검사 후 backtick으로 감쌉니다. 비밀번호 등 값 문자열은 `mysqli::real_escape_string()` 후 작은따옴표로 감쌉니다. 이 두 경로 외에 사용자 입력을 SQL에 끼워 넣지 말 것. **새 컬럼을 INSERT 셋업에 추가할 때 같은 패턴을 유지**: 식별자 후보 → 화이트리스트, 값 → real_escape_string.

### 크로스플랫폼 주의

XAMPP는 Windows/macOS/Linux 모두에서 돌아갑니다. 경로 분리자는 `DIRECTORY_SEPARATOR` 사용. 비밀번호를 가리는 `stty -echo`는 비-Windows에서만 적용됩니다(Windows에서는 평문 입력).

## Common Commands

```sh
# 문법 체크
php -l scripts/install_gnuboard5.php

# 도움말
php scripts/install_gnuboard5.php --help

# 고객사 프로파일로 일괄 설치
php scripts/install_gnuboard5.php \
  --profile=customers/acme.json \
  --target=C:/xampp/htdocs/acme \
  --db-name=acme --db-user=acme --db-pass=secret

# 프로파일 없이 baseline 설치 (회사 정보·커스텀 게시판 없음)
php scripts/install_gnuboard5.php \
  --target=C:/xampp/htdocs/gnuboard5 \
  --db-name=gnuboard5 --db-user=gnu --db-pass=secret
```

테스트 스위트는 아직 없습니다. 실제 동작 검증은 XAMPP/AAMPP + MariaDB 가 깔린 환경에서 한 번 돌려서 install.php 자동 차단·관리자 로그인·기본 게시판 노출까지 수동 확인하는 것이 현재 절차.

## Branch Convention

AI 보조 변경은 작업 단위로 부여된 `claude/...` 브랜치에서 진행합니다. 사용자가 명시적으로 허가한 브랜치 외에는 push하지 말 것.

## When Extending

- **그누보드 버전 호환성**: install_db.php 의 default 컬럼 셋이 바뀌면 본 스크립트의 `insert_default_config()` / `insert_one_board()` 도 같이 갱신해야 합니다. 변경 감지는 GitHub `gnuboard/gnuboard5` 의 `install/install_db.php` diff 를 보는 것이 가장 빠름.
- **새 프로파일 키 추가**: `default_profile()` 에 fallback 값을 같이 넣고, README의 매핑 표도 갱신할 것.
- **새 의존성**: 도입 시 Composer 도입 여부를 사용자에게 먼저 확인할 것. 현재 레포는 의존성 매니저 없이 단일 PHP 파일로 동작합니다.
- `test.py` 를 정리/삭제하려면 사용자에게 먼저 확인할 것. (의도적으로 남겨둔 placeholder 일 수 있음.)
