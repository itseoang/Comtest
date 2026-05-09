# Comtest

그누보드5(Gnuboard5)를 로컬 XAMPP / AAMPP 에 자동 셋팅하는 PHP CLI 도구.
**고객사별 프로파일 JSON** 한 장이면 회사 정보·관리자·게시판·페이지·로고까지
한 번에 끝납니다.

## 요구사항

- PHP 7.4+ (XAMPP/AAMPP 내장 PHP)
- 활성화 상태의 PHP 확장: `mysqli`, `zip`, `curl` (또는 `allow_url_fopen=On`)
- MySQL/MariaDB 관리자 권한 (DB·사용자 생성용; XAMPP 기본값은 `root` / 빈 비밀번호)

## 빠른 시작 — 고객사 단위 자동 설치

1. `customers/example.json`을 복사해서 고객사 정보를 채웁니다.

   ```sh
   cp customers/example.json customers/acme.json
   # 에디터로 열어 회사명 / 관리자 / 게시판 등을 수정
   ```

2. 한 번의 명령으로 끝.

   ```sh
   php scripts/install_gnuboard5.php \
     --profile=customers/acme.json \
     --target=C:/xampp/htdocs/acme \
     --db-name=acme --db-user=acme --db-pass=secret
   ```

3. 브라우저에서 `http://localhost/acme/` 접속 → 바로 운영 화면. install.php
   마법사는 자동으로 차단됩니다 (`data/dbconfig.php` 가 작성되었기 때문).

## 프로파일 JSON 구조

`customers/example.json` 참고. 핵심 키:

| 키                | 채워지는 곳                                                    |
|-------------------|---------------------------------------------------------------|
| `company.*`       | `g5_config.cf_1`~`cf_6` (회사명/대표/사업자번호/주소/전화/팩스) <br>라벨은 `cf_1_subj`~`cf_6_subj` |
| `site.title`      | `g5_config.cf_title`                                          |
| `site.logo`       | `data/logo.<ext>` 로 복사 (테마에서 직접 참조)                 |
| `admin.*`         | `g5_member` 관리자 계정 (`mb_level=10`)                       |
| `groups[]`        | `g5_group` 게시판 그룹                                         |
| `groups[].boards[]` | `g5_board` + `g5_write_<id>` 테이블 자동 생성                |
| `pages[]`         | `g5_content` 일반 페이지                                       |

비밀번호는 그누보드 `sql_password()` 와 동일한 포맷
(`*` + SHA1(SHA1(plain)) 대문자 hex)으로 저장하므로 로그인이 정상 동작합니다.

## 옵션

```sh
php scripts/install_gnuboard5.php --help
```

`--profile` 없이 실행하면 회사 정보 없는 baseline 설치 (기본 4개 게시판 +
3개 페이지) 가 진행됩니다.

## 동작 단계

1. PHP 확장 검사
2. `https://codeload.github.com/gnuboard/gnuboard5/zip/refs/heads/master` 다운로드
3. 대상 디렉터리에 압축 해제
4. 관리자 자격으로 MySQL 접속 → DB · 사용자 생성 · `GRANT`
5. `install/gnuboard5.sql` 임포트 (전체 스키마)
6. `g5_config`, `g5_qa_config`, `g5_member`, `g5_content`, `g5_faq_master`,
   `g5_group`, `g5_board` INSERT + `g5_write_<board>` CREATE
7. 로고 복사
8. `data/dbconfig.php` 작성 (이 시점부터 install.php 마법사 차단)

## 주의

- **install/ 디렉터리는 그대로 둡니다.** 보안을 위해 운영 환경에서는 수동으로
  지우거나 이름 변경 권장.
- **회사 정보는 `cf_1`~`cf_6` 슬롯에 저장**됩니다. 이는 그누보드 코어에
  회사 전용 컬럼이 없어서 사용한 우회 방법입니다 (영카트 쇼핑몰 모듈에는
  `g5_shop_default.de_admin_company_*` 가 있지만 본 도구는 코어 설치만 다룸).
  사이트 푸터/약관에 회사 정보를 노출하려면 테마에서 `$config['cf_1']` 등을
  직접 참조하세요.
- **MySQL 8.0** 환경에서는 `PASSWORD()` 함수가 제거되어 그누보드 로그인이
  실패할 수 있습니다. XAMPP 기본 MariaDB는 영향 없음.
