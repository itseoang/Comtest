# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

"Comtest" — 그누보드5(Gnuboard5)를 로컬 XAMPP / AAMPP 환경에 자동 셋팅하기 위한 PHP CLI 도구를 담는 레포입니다. 운영용 서비스 코드가 아니라 개발자 워크스테이션의 셋업 자동화가 목적입니다.

## Layout

- `scripts/install_gnuboard5.php` — 단일 파일 PHP CLI 설치 스크립트 (현재 유일한 실 코드)
- `README.md` — 사용자 입장에서의 실행 방법
- `test.py` — **사용하지 않음.** 비표준 placeholder 내용(`Test.py`, `/**/`, `import * 4421`)이며 Python 모듈이 아닙니다. 이 파일을 import하거나 실행하거나 모범으로 삼지 말 것.
- `.gitignore` — Python 표준 패턴 (레포 초기 흔적). PHP 산출물이 추가되면 보강 필요.

## Architecture (`scripts/install_gnuboard5.php`)

이 스크립트는 **의도적으로 좁은 범위**를 가집니다. 그누보드5 설치 플로우 중 사람 손이 꼭 필요한 마법사 단계는 건드리지 않는 것이 핵심 설계입니다.

스크립트가 하는 일 (in order):
1. PHP 확장 검사 (`mysqli`, `zip`, `curl` or `allow_url_fopen`)
2. CLI 인자 파싱 → 누락된 필수 값은 대화식 프롬프트
3. `https://codeload.github.com/gnuboard/gnuboard5/zip/refs/heads/<branch>` 에서 zip 다운로드 (curl 우선, 없으면 stream wrapper)
4. 임시 디렉터리에 풀고 최상위 폴더(`gnuboard5-master/`)를 벗겨낸 뒤 대상 htdocs 경로로 이동
5. 관리자 자격(`--db-admin-user/-pass`, 기본 `root`/빈값)으로 MySQL 접속 → DB·사용자 생성·`GRANT`·`FLUSH`
6. 다음 단계(브라우저로 `install.php` 접속) 안내 출력

스크립트가 **하지 않는** 일과 그 이유:
- **`data/dbconfig.php` 작성 안 함.** 그누보드5의 `install/index.php`는 `dbconfig.php`가 존재하면 "이미 설치됨"으로 판단해 마법사를 차단합니다. 따라서 dbconfig 작성은 install.php에 위임합니다. 이 동작은 의도된 것이니 "config 파일도 자동 생성"하도록 바꾸려면 동시에 install.php의 schema/admin 단계도 대체해야 함을 기억할 것.
- **install.php 자동 응답 안 함.** 사용자가 브라우저에서 마법사를 진행합니다.
- **웹서버 vhost / 권한 / `.htaccess`.** XAMPP/AAMPP가 처리한다고 가정.

### 보안 관련 불변식

DB 식별자(database/user 이름)는 `validate_identifier()`에서 `^[A-Za-z0-9_]+$`로 화이트리스트 검사 후 backtick으로 감쌉니다. 비밀번호 등 값 문자열은 `mysqli::real_escape_string()` 후 작은따옴표로 감쌉니다. 이 두 경로 외에 사용자 입력을 SQL에 끼워 넣지 말 것.

### 크로스플랫폼 주의

XAMPP는 Windows/macOS/Linux 모두에서 돌아갑니다. 경로 분리자는 `DIRECTORY_SEPARATOR` 사용. 비밀번호를 가리는 `stty -echo`는 비-Windows에서만 적용됩니다(Windows에서는 평문 입력).

## Common Commands

```sh
# 문법 체크
php -l scripts/install_gnuboard5.php

# 도움말
php scripts/install_gnuboard5.php --help

# 비대화식 실행 예시
php scripts/install_gnuboard5.php \
  --target=C:/xampp/htdocs/gnuboard5 \
  --db-name=gnuboard5 --db-user=gnu --db-pass=secret
```

테스트 스위트는 아직 없습니다. 추가된다면 이 섹션에 실제 명령을 적을 것.

## Branch Convention

AI 보조 변경은 작업 단위로 부여된 `claude/...` 브랜치에서 진행합니다. 사용자가 명시적으로 허가한 브랜치 외에는 push하지 말 것.

## When Extending

- 새 기능을 더하기 전에 "install.php 마법사 차단" 불변식이 깨지지 않는지 확인할 것. dbconfig.php를 미리 쓰는 변경은 schema 임포트+관리자 INSERT까지 함께 해야 사용자가 막히지 않습니다.
- 새 의존성을 도입한다면 PHP 패키지 매니저(Composer)를 도입할지 사용자에게 먼저 확인할 것. 현재 레포는 의존성 매니저 없이 단일 PHP 파일로 동작합니다.
- `test.py`를 정리/삭제하려면 사용자에게 먼저 확인할 것. (의도적으로 남겨둔 placeholder일 수 있음.)
