# Comtest

Company Test — 그누보드5 자동 셋팅 도구.

## 그누보드5 자동 셋팅 (XAMPP / AAMPP)

`scripts/install_gnuboard5.php`는 GitHub 공식 저장소(`gnuboard/gnuboard5`)에서
소스를 받아 사용자가 지정한 htdocs 경로에 풀고, MySQL DB와 계정을 생성합니다.
`data/dbconfig.php`는 그누보드 `install.php` 마법사가 직접 작성하므로
이 스크립트는 의도적으로 건드리지 않습니다.

### 요구사항

- PHP 7.4+ (XAMPP/AAMPP 내장 PHP 사용 가능)
- 활성화 상태의 PHP 확장: `mysqli`, `zip`, `curl` (또는 `allow_url_fopen=On`)
- MySQL 관리자 권한 (DB/사용자 생성용; XAMPP 기본값은 `root` / 빈 비밀번호)

### 실행

```sh
php scripts/install_gnuboard5.php \
  --target=C:/xampp/htdocs/gnuboard5 \
  --db-name=gnuboard5 \
  --db-user=gnu \
  --db-pass=secret
```

옵션을 생략하면 대화식으로 입력을 받습니다. 전체 옵션은 `--help` 참조.

### 실행 후

브라우저에서 `http://localhost/<설치 경로>/install/` 접속 → 마법사가
DB 정보 입력을 받아 `data/dbconfig.php`, 테이블, 관리자 계정을 생성합니다.
