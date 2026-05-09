<?php
declare(strict_types=1);

/**
 * 그누보드5 자동 셋팅 스크립트 (XAMPP/AAMPP htdocs 대상)
 *
 * 범위:
 *   - GitHub 공식 저장소(gnuboard/gnuboard5)에서 소스 zip 다운로드
 *   - 사용자가 지정한 htdocs 하위 경로에 압축 해제
 *   - 지정한 MySQL 계정/DB 생성
 *
 * 작성하지 않는 것:
 *   - data/dbconfig.php  → 그누보드 install.php 마법사가 직접 작성하므로
 *                         스크립트가 미리 만들면 install.php가 막힙니다.
 *   - 웹서버 vhost / 권한 / install 자동 응답
 */

const REPO_OWNER  = 'gnuboard';
const REPO_NAME   = 'gnuboard5';
const ZIP_URL_TPL = 'https://codeload.github.com/%s/%s/zip/refs/heads/%s';

main($argv);

function main(array $argv): void
{
    fwrite(STDOUT, "그누보드5 자동 셋팅 스크립트\n");
    fwrite(STDOUT, "==========================================\n");

    check_php_requirements();

    $opts = parse_args($argv);
    $opts = prompt_missing($opts);

    $target = realpath_create($opts['target']);
    fwrite(STDOUT, "[1/4] 대상 경로: {$target}\n");

    $branch = $opts['branch'];
    $tmpZip = sys_get_temp_dir() . DIRECTORY_SEPARATOR
            . "gnuboard5-{$branch}-" . bin2hex(random_bytes(4)) . '.zip';

    fwrite(STDOUT, "[2/4] 소스 다운로드 (branch={$branch}) ...\n");
    download_zip($branch, $tmpZip);

    fwrite(STDOUT, "[3/4] 압축 해제 → {$target}\n");
    extract_zip($tmpZip, $target, $opts['force']);
    @unlink($tmpZip);

    fwrite(STDOUT, "[4/4] DB 생성 ({$opts['db-name']} / {$opts['db-user']}@{$opts['db-host']}) ...\n");
    create_database_and_user($opts);

    print_next_steps($opts);
}

function check_php_requirements(): void
{
    $missing = [];
    foreach (['mysqli', 'zip'] as $ext) {
        if (!extension_loaded($ext)) {
            $missing[] = $ext;
        }
    }
    if (!function_exists('curl_init') && !ini_get('allow_url_fopen')) {
        $missing[] = 'curl 또는 allow_url_fopen';
    }
    if ($missing) {
        fail('필수 PHP 확장이 부족합니다: ' . implode(', ', $missing));
    }
}

function parse_args(array $argv): array
{
    $opts = [
        'target'        => null,
        'db-host'       => '127.0.0.1',
        'db-port'       => '3306',
        'db-name'       => null,
        'db-user'       => null,
        'db-pass'       => null,
        'db-admin-user' => 'root',
        'db-admin-pass' => '',
        'branch'        => 'master',
        'force'         => false,
    ];
    foreach (array_slice($argv, 1) as $arg) {
        if ($arg === '-h' || $arg === '--help') {
            print_help();
            exit(0);
        }
        if ($arg === '--force') {
            $opts['force'] = true;
            continue;
        }
        if (!preg_match('/^--([a-z\-]+)=(.*)$/', $arg, $m)) {
            fail("알 수 없는 인자: {$arg}");
        }
        if (!array_key_exists($m[1], $opts)) {
            fail("알 수 없는 옵션: --{$m[1]}");
        }
        $opts[$m[1]] = $m[2];
    }
    return $opts;
}

function prompt_missing(array $opts): array
{
    $required = ['target', 'db-name', 'db-user', 'db-pass'];
    foreach ($required as $key) {
        if ($opts[$key] === null || $opts[$key] === '') {
            $hidden = ($key === 'db-pass');
            $opts[$key] = ask("입력하세요 [--{$key}]: ", $hidden);
            if ($opts[$key] === '') {
                fail("--{$key} 값이 필요합니다.");
            }
        }
    }
    return $opts;
}

function ask(string $prompt, bool $hidden = false): string
{
    fwrite(STDOUT, $prompt);
    $isWindows = stripos(PHP_OS, 'WIN') === 0;
    if ($hidden && !$isWindows) {
        @system('stty -echo');
        $value = trim((string)fgets(STDIN));
        @system('stty echo');
        fwrite(STDOUT, "\n");
        return $value;
    }
    return trim((string)fgets(STDIN));
}

function realpath_create(string $path): string
{
    if (!file_exists($path)) {
        if (!@mkdir($path, 0755, true) && !is_dir($path)) {
            fail("대상 디렉터리를 만들 수 없습니다: {$path}");
        }
    } elseif (!is_dir($path)) {
        fail("대상 경로가 디렉터리가 아닙니다: {$path}");
    }
    $real = realpath($path);
    if ($real === false) {
        fail("realpath 실패: {$path}");
    }
    return $real;
}

function download_zip(string $branch, string $destPath): void
{
    $url = sprintf(ZIP_URL_TPL, REPO_OWNER, REPO_NAME, rawurlencode($branch));
    $fp  = fopen($destPath, 'wb');
    if (!$fp) {
        fail("임시 파일을 열 수 없습니다: {$destPath}");
    }

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_FILE           => $fp,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_FAILONERROR    => true,
            CURLOPT_USERAGENT      => 'gnuboard5-installer',
            CURLOPT_CONNECTTIMEOUT => 15,
            CURLOPT_TIMEOUT        => 300,
        ]);
        $ok  = curl_exec($ch);
        $err = curl_error($ch);
        curl_close($ch);
        fclose($fp);
        if ($ok === false) {
            @unlink($destPath);
            fail("다운로드 실패: {$err} ({$url})");
        }
    } else {
        $src = @fopen($url, 'rb');
        if (!$src) {
            fclose($fp);
            @unlink($destPath);
            fail("다운로드 실패: {$url}");
        }
        stream_copy_to_stream($src, $fp);
        fclose($src);
        fclose($fp);
    }

    if (filesize($destPath) < 1024) {
        fail("다운로드된 파일이 너무 작습니다. URL을 확인하세요: {$url}");
    }
}

function extract_zip(string $zipPath, string $targetDir, bool $force): void
{
    $existing = array_values(array_diff(scandir($targetDir), ['.', '..']));
    if ($existing && !$force) {
        fail("대상 디렉터리가 비어있지 않습니다: {$targetDir} (덮어쓰려면 --force)");
    }
    if ($existing && $force) {
        foreach ($existing as $e) {
            $p = $targetDir . DIRECTORY_SEPARATOR . $e;
            is_dir($p) ? rmdir_recursive($p) : @unlink($p);
        }
    }

    $tmpDir = $targetDir . DIRECTORY_SEPARATOR . '.gb5-extract-' . bin2hex(random_bytes(3));
    if (!mkdir($tmpDir, 0755, true)) {
        fail("임시 디렉터리 생성 실패: {$tmpDir}");
    }

    $zip = new ZipArchive();
    if ($zip->open($zipPath) !== true) {
        fail("zip 열기 실패: {$zipPath}");
    }
    if (!$zip->extractTo($tmpDir)) {
        $zip->close();
        fail('압축 해제 실패');
    }
    $zip->close();

    $entries = array_values(array_diff(scandir($tmpDir), ['.', '..']));
    if (count($entries) !== 1 || !is_dir($tmpDir . DIRECTORY_SEPARATOR . $entries[0])) {
        fail('zip 내부 구조가 예상과 다릅니다.');
    }
    $sourceRoot = $tmpDir . DIRECTORY_SEPARATOR . $entries[0];

    foreach (array_diff(scandir($sourceRoot), ['.', '..']) as $item) {
        $from = $sourceRoot . DIRECTORY_SEPARATOR . $item;
        $to   = $targetDir  . DIRECTORY_SEPARATOR . $item;
        if (!@rename($from, $to)) {
            fail("이동 실패: {$from} → {$to}");
        }
    }
    rmdir_recursive($tmpDir);
}

function rmdir_recursive(string $dir): void
{
    if (!is_dir($dir)) {
        return;
    }
    foreach (array_diff(scandir($dir), ['.', '..']) as $item) {
        $p = $dir . DIRECTORY_SEPARATOR . $item;
        is_dir($p) ? rmdir_recursive($p) : @unlink($p);
    }
    @rmdir($dir);
}

function create_database_and_user(array $opts): void
{
    validate_identifier('db-name', $opts['db-name']);
    validate_identifier('db-user', $opts['db-user']);

    $admin = @new mysqli(
        $opts['db-host'],
        $opts['db-admin-user'],
        $opts['db-admin-pass'],
        '',
        (int)$opts['db-port']
    );
    if ($admin->connect_errno) {
        fail("MySQL 관리자 접속 실패: ({$admin->connect_errno}) {$admin->connect_error}");
    }
    $admin->set_charset('utf8mb4');

    $db   = "`{$opts['db-name']}`";
    $user = $admin->real_escape_string($opts['db-user']);
    $pass = $admin->real_escape_string($opts['db-pass']);

    $statements = [
        "CREATE DATABASE IF NOT EXISTS {$db} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
        "CREATE USER IF NOT EXISTS '{$user}'@'localhost' IDENTIFIED BY '{$pass}'",
        "CREATE USER IF NOT EXISTS '{$user}'@'%'         IDENTIFIED BY '{$pass}'",
        "GRANT ALL PRIVILEGES ON {$db}.* TO '{$user}'@'localhost'",
        "GRANT ALL PRIVILEGES ON {$db}.* TO '{$user}'@'%'",
        'FLUSH PRIVILEGES',
    ];
    foreach ($statements as $sql) {
        if (!$admin->query($sql)) {
            fail("SQL 실패: {$sql}\n  → {$admin->error}");
        }
    }
    $admin->close();
}

function validate_identifier(string $label, string $value): void
{
    if (!preg_match('/^[A-Za-z0-9_]+$/', $value)) {
        fail("유효하지 않은 식별자(--{$label}): '{$value}' — 영숫자/언더스코어만 허용");
    }
}

function print_next_steps(array $opts): void
{
    fwrite(STDOUT, "\n----------------------------------------\n");
    fwrite(STDOUT, "셋업 완료. 다음 단계:\n");
    fwrite(STDOUT, "  1) 브라우저에서 install.php 접속\n");
    fwrite(STDOUT, "       예) htdocs/gnuboard5 에 설치했다면\n");
    fwrite(STDOUT, "           http://localhost/gnuboard5/install/\n");
    fwrite(STDOUT, "  2) 마법사에 다음 DB 정보 입력:\n");
    fwrite(STDOUT, "       호스트:   {$opts['db-host']}\n");
    fwrite(STDOUT, "       DB명:     {$opts['db-name']}\n");
    fwrite(STDOUT, "       사용자:   {$opts['db-user']}\n");
    fwrite(STDOUT, "       비밀번호: (입력하신 값)\n");
    fwrite(STDOUT, "  3) 마법사가 data/dbconfig.php · 테이블 · 관리자 계정을 생성합니다.\n");
}

function print_help(): void
{
    fwrite(STDOUT, <<<TXT
사용법:
  php scripts/install_gnuboard5.php [옵션]

필수:
  --target=PATH         설치 경로 (예: C:/xampp/htdocs/gnuboard5)
  --db-name=NAME        생성할 DB 이름 (영숫자/언더스코어)
  --db-user=USER        그누보드용 MySQL 사용자
  --db-pass=PASS        그누보드용 MySQL 비밀번호

선택:
  --db-host=HOST        기본 127.0.0.1
  --db-port=PORT        기본 3306
  --db-admin-user=USER  DB 생성용 관리자 (기본 root)
  --db-admin-pass=PASS  관리자 비밀번호 (기본 빈 문자열, XAMPP 초기값)
  --branch=BRANCH       gnuboard5 GitHub 브랜치 (기본 master)
  --force               대상 디렉터리가 비어있지 않아도 진행 (기존 파일 제거)

생략된 필수 값은 대화식으로 입력받습니다.
TXT);
    fwrite(STDOUT, "\n");
}

function fail(string $msg)
{
    fwrite(STDERR, "오류: {$msg}\n");
    exit(1);
}
