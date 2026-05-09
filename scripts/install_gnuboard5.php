<?php
declare(strict_types=1);

/**
 * 그누보드5 자동 셋팅 + 고객사 커스터마이즈 스크립트.
 *
 * 동작:
 *   - GitHub 공식 저장소(gnuboard/gnuboard5) zip 다운로드 → htdocs 경로에 해제
 *   - MySQL DB · 사용자 생성
 *   - 그누보드 install/gnuboard5.sql 임포트 (전체 스키마)
 *   - g5_config 기본 행 INSERT, 회사 정보(cf_1..cf_6 + cf_*_subj 라벨)는 프로파일에서
 *   - 관리자 계정 INSERT (sql_password 호환 해시)
 *   - g5_content (페이지) · g5_group · g5_board · g5_write_<보드> 생성
 *   - 로고 이미지 복사
 *   - data/dbconfig.php 작성 → 이 시점부터 install.php 마법사는 자동으로 차단됨
 *
 * install/ 디렉터리는 사용자 요청에 따라 그대로 둡니다 (dbconfig.php가 있으면 어차피 차단).
 *
 * 사용법:
 *   php scripts/install_gnuboard5.php --profile=customers/example.json \
 *     --target=C:/xampp/htdocs/gnuboard5
 *
 *   --profile 없이 실행하면 회사 정보 없는 baseline 설치.
 */

const REPO_OWNER   = 'gnuboard';
const REPO_NAME    = 'gnuboard5';
const ZIP_URL_TPL  = 'https://codeload.github.com/%s/%s/zip/refs/heads/%s';
const TABLE_PREFIX = 'g5_';

main($argv);

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

function main(array $argv): void
{
    fwrite(STDOUT, "그누보드5 자동 셋팅 + 커스터마이즈\n");
    fwrite(STDOUT, "==========================================\n");

    check_php_requirements();
    $opts    = parse_args($argv);
    $profile = $opts['profile'] !== null ? load_profile($opts['profile']) : default_profile();
    $opts    = merge_profile_defaults($opts, $profile);
    $opts    = prompt_missing($opts);

    $target = realpath_create($opts['target']);
    fwrite(STDOUT, "[1/6] 대상: {$target}\n");

    $branch = $opts['branch'];
    $tmpZip = sys_get_temp_dir() . DIRECTORY_SEPARATOR
            . "gnuboard5-{$branch}-" . bin2hex(random_bytes(4)) . '.zip';

    fwrite(STDOUT, "[2/6] 소스 다운로드 (branch={$branch})\n");
    download_zip($branch, $tmpZip);

    fwrite(STDOUT, "[3/6] 압축 해제\n");
    extract_zip($tmpZip, $target, $opts['force']);
    @unlink($tmpZip);

    fwrite(STDOUT, "[4/6] DB · 사용자 생성\n");
    $admin = connect_admin($opts);
    create_database_and_user($admin, $opts);
    $admin->close();

    fwrite(STDOUT, "[5/6] 스키마 임포트 + 데이터 INSERT\n");
    $db = connect_app($opts);
    import_schema($db, $target);
    insert_default_config($db, $opts, $profile);
    insert_default_qa_config($db);
    insert_admin_user($db, $opts, $profile);
    insert_pages($db, $profile);
    insert_default_faq($db);
    insert_groups_and_boards($db, $target, $profile);
    $db->close();

    fwrite(STDOUT, "[6/6] dbconfig.php 작성 + 로고 복사\n");
    write_dbconfig($target, $opts);
    if (!empty($profile['site']['logo'])) {
        copy_logo($profile['site']['logo'], $opts['profile'] ?? getcwd(), $target);
    }

    print_next_steps($opts, $target);
}

// ---------------------------------------------------------------------------
// CLI / args / prompts
// ---------------------------------------------------------------------------

function parse_args(array $argv): array
{
    $opts = [
        'profile'       => null,
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

function merge_profile_defaults(array $opts, array $profile): array
{
    if ($opts['db-name'] === null && !empty($profile['_db']['name']))    $opts['db-name'] = $profile['_db']['name'];
    if ($opts['db-user'] === null && !empty($profile['_db']['user']))    $opts['db-user'] = $profile['_db']['user'];
    if ($opts['db-pass'] === null && !empty($profile['_db']['pass']))    $opts['db-pass'] = $profile['_db']['pass'];
    return $opts;
}

function prompt_missing(array $opts): array
{
    foreach (['target', 'db-name', 'db-user', 'db-pass'] as $key) {
        if ($opts[$key] === null || $opts[$key] === '') {
            $opts[$key] = ask("입력하세요 [--{$key}]: ", $key === 'db-pass');
            if ($opts[$key] === '') fail("--{$key} 값이 필요합니다.");
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

function print_help(): void
{
    fwrite(STDOUT, <<<TXT
사용법:
  php scripts/install_gnuboard5.php [옵션]

권장:
  --profile=PATH        고객사 프로파일 JSON (예: customers/foo.json)
                        있으면 회사 정보·관리자·게시판·페이지·로고가 자동 적용됨

필수 (프로파일에 없으면 묻습니다):
  --target=PATH         설치 경로 (예: C:/xampp/htdocs/gnuboard5)
  --db-name=NAME        그누보드 DB 이름
  --db-user=USER        그누보드용 MySQL 사용자
  --db-pass=PASS        그누보드용 MySQL 비밀번호

선택:
  --db-host=HOST        기본 127.0.0.1
  --db-port=PORT        기본 3306
  --db-admin-user=USER  DB 생성용 관리자 (기본 root)
  --db-admin-pass=PASS  관리자 비밀번호 (기본 빈 문자열, XAMPP 초기값)
  --branch=BRANCH       gnuboard5 GitHub 브랜치 (기본 master)
  --force               대상 디렉터리가 비어있지 않아도 진행 (기존 파일 제거)

TXT);
}

function fail(string $msg)
{
    fwrite(STDERR, "오류: {$msg}\n");
    exit(1);
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

function default_profile(): array
{
    return [
        'company' => [],
        'site'    => ['title' => 'gnuboard5', 'domain' => '', 'logo' => null],
        'admin'   => ['id' => 'admin', 'password' => null, 'name' => '관리자', 'nick' => '관리자', 'email' => 'admin@example.com'],
        'groups'  => [
            ['id' => 'community', 'subject' => '커뮤니티', 'boards' => [
                ['id' => 'notice', 'subject' => '공지사항', 'skin' => 'basic'],
                ['id' => 'free',   'subject' => '자유게시판', 'skin' => 'basic'],
                ['id' => 'qa',     'subject' => '질문답변', 'skin' => 'basic'],
                ['id' => 'gallery','subject' => '갤러리',   'skin' => 'gallery'],
            ]],
        ],
        'pages' => [
            ['id' => 'company',   'subject' => '회사소개',         'html' => '<p>회사소개에 대한 내용을 입력하십시오.</p>'],
            ['id' => 'privacy',   'subject' => '개인정보 처리방침', 'html' => '<p>개인정보 처리방침에 대한 내용을 입력하십시오.</p>'],
            ['id' => 'provision', 'subject' => '서비스 이용약관',  'html' => '<p>서비스 이용약관에 대한 내용을 입력하십시오.</p>'],
        ],
    ];
}

function load_profile(string $path): array
{
    if (!is_file($path)) fail("프로파일 파일을 찾을 수 없습니다: {$path}");
    $raw = file_get_contents($path);
    if ($raw === false) fail("프로파일 읽기 실패: {$path}");
    $data = json_decode($raw, true);
    if (!is_array($data)) fail("JSON 파싱 실패: {$path} — " . json_last_error_msg());

    $defaults = default_profile();
    $data['company'] = ($data['company'] ?? []) + ($defaults['company']);
    $data['site']    = ($data['site']    ?? []) + ($defaults['site']);
    $data['admin']   = ($data['admin']   ?? []) + ($defaults['admin']);
    if (!isset($data['groups']) || !is_array($data['groups']) || !$data['groups']) {
        $data['groups'] = $defaults['groups'];
    }
    if (!isset($data['pages']) || !is_array($data['pages'])) {
        $data['pages'] = $defaults['pages'];
    }
    foreach (['groups', 'pages'] as $listKey) {
        foreach ($data[$listKey] as $item) {
            if (empty($item['id'])) fail("프로파일 {$listKey}[].id 가 비어 있습니다.");
        }
    }
    return $data;
}

// ---------------------------------------------------------------------------
// Filesystem / network
// ---------------------------------------------------------------------------

function check_php_requirements(): void
{
    $missing = [];
    foreach (['mysqli', 'zip'] as $ext) {
        if (!extension_loaded($ext)) $missing[] = $ext;
    }
    if (!function_exists('curl_init') && !ini_get('allow_url_fopen')) {
        $missing[] = 'curl 또는 allow_url_fopen';
    }
    if ($missing) fail('필수 PHP 확장이 부족합니다: ' . implode(', ', $missing));
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
    if ($real === false) fail("realpath 실패: {$path}");
    return $real;
}

function download_zip(string $branch, string $destPath): void
{
    $url = sprintf(ZIP_URL_TPL, REPO_OWNER, REPO_NAME, rawurlencode($branch));
    $fp  = fopen($destPath, 'wb');
    if (!$fp) fail("임시 파일을 열 수 없습니다: {$destPath}");

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
        if (!$src) { fclose($fp); @unlink($destPath); fail("다운로드 실패: {$url}"); }
        stream_copy_to_stream($src, $fp);
        fclose($src);
        fclose($fp);
    }
    if (filesize($destPath) < 1024) fail("다운로드 파일이 너무 작습니다: {$url}");
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
    if (!mkdir($tmpDir, 0755, true)) fail("임시 디렉터리 생성 실패: {$tmpDir}");

    $zip = new ZipArchive();
    if ($zip->open($zipPath) !== true) fail("zip 열기 실패: {$zipPath}");
    if (!$zip->extractTo($tmpDir)) { $zip->close(); fail('압축 해제 실패'); }
    $zip->close();

    $entries = array_values(array_diff(scandir($tmpDir), ['.', '..']));
    if (count($entries) !== 1 || !is_dir($tmpDir . DIRECTORY_SEPARATOR . $entries[0])) {
        fail('zip 내부 구조가 예상과 다릅니다.');
    }
    $sourceRoot = $tmpDir . DIRECTORY_SEPARATOR . $entries[0];
    foreach (array_diff(scandir($sourceRoot), ['.', '..']) as $item) {
        $from = $sourceRoot . DIRECTORY_SEPARATOR . $item;
        $to   = $targetDir  . DIRECTORY_SEPARATOR . $item;
        if (!@rename($from, $to)) fail("이동 실패: {$from} → {$to}");
    }
    rmdir_recursive($tmpDir);
}

function rmdir_recursive(string $dir): void
{
    if (!is_dir($dir)) return;
    foreach (array_diff(scandir($dir), ['.', '..']) as $item) {
        $p = $dir . DIRECTORY_SEPARATOR . $item;
        is_dir($p) ? rmdir_recursive($p) : @unlink($p);
    }
    @rmdir($dir);
}

function copy_logo(string $logoRef, string $profilePath, string $targetDir): void
{
    $base = is_file($profilePath) ? dirname($profilePath) : $profilePath;
    $src  = $logoRef[0] === '/' || preg_match('/^[A-Za-z]:/', $logoRef)
          ? $logoRef
          : $base . DIRECTORY_SEPARATOR . $logoRef;
    if (!is_file($src)) {
        fwrite(STDOUT, "  ⚠ 로고 파일을 찾지 못해 건너뜁니다: {$src}\n");
        return;
    }
    $ext  = pathinfo($src, PATHINFO_EXTENSION) ?: 'png';
    $dest = $targetDir . DIRECTORY_SEPARATOR . 'data' . DIRECTORY_SEPARATOR . 'logo.' . $ext;
    @mkdir(dirname($dest), 0755, true);
    if (!@copy($src, $dest)) {
        fwrite(STDOUT, "  ⚠ 로고 복사 실패: {$src} → {$dest}\n");
        return;
    }
    fwrite(STDOUT, "  로고 복사: {$dest}\n");
}

// ---------------------------------------------------------------------------
// DB - bootstrap
// ---------------------------------------------------------------------------

function connect_admin(array $opts): mysqli
{
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
    return $admin;
}

function connect_app(array $opts): mysqli
{
    $db = @new mysqli(
        $opts['db-host'],
        $opts['db-user'],
        $opts['db-pass'],
        $opts['db-name'],
        (int)$opts['db-port']
    );
    if ($db->connect_errno) {
        fail("MySQL 앱 사용자 접속 실패: ({$db->connect_errno}) {$db->connect_error}");
    }
    $db->set_charset('utf8mb4');
    $db->query("SET SESSION sql_mode = ''");
    return $db;
}

function create_database_and_user(mysqli $admin, array $opts): void
{
    validate_identifier('db-name', $opts['db-name']);
    validate_identifier('db-user', $opts['db-user']);

    $db   = "`{$opts['db-name']}`";
    $user = $admin->real_escape_string($opts['db-user']);
    $pass = $admin->real_escape_string($opts['db-pass']);

    $statements = [
        "CREATE DATABASE IF NOT EXISTS {$db} CHARACTER SET utf8 COLLATE utf8_general_ci",
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
}

function validate_identifier(string $label, string $value): void
{
    if (!preg_match('/^[A-Za-z0-9_]+$/', $value)) {
        fail("유효하지 않은 식별자(--{$label}): '{$value}' — 영숫자/언더스코어만 허용");
    }
}

// ---------------------------------------------------------------------------
// DB - schema and seed data
// ---------------------------------------------------------------------------

function import_schema(mysqli $db, string $sourceRoot): void
{
    $sqlFile = $sourceRoot . '/install/gnuboard5.sql';
    if (!is_file($sqlFile)) fail("스키마 파일 없음: {$sqlFile}");
    $sql = file_get_contents($sqlFile);
    if ($sql === false) fail("스키마 읽기 실패: {$sqlFile}");

    // 그누보드 install_db.php와 동일하게 라인 주석 제거 + 테이블 prefix 치환.
    $sql = preg_replace('/^--.*$/m', '', $sql);
    $sql = preg_replace('/`g5_([^`]+`)/', '`' . TABLE_PREFIX . '$1', $sql);

    foreach (explode(';', $sql) as $stmt) {
        $stmt = trim($stmt);
        if ($stmt === '') continue;
        if (!$db->query($stmt)) {
            fail("스키마 SQL 실패: " . substr($stmt, 0, 80) . "...\n  → {$db->error}");
        }
    }
}

function insert_default_config(mysqli $db, array $opts, array $profile): void
{
    $title  = $profile['site']['title']  ?? 'gnuboard5';
    $admin  = $profile['admin']['id']    ?? 'admin';
    $email  = $profile['admin']['email'] ?? '';

    $cf = [
        'cf_title'                 => $title,
        'cf_theme'                 => 'basic',
        'cf_admin'                 => $admin,
        'cf_admin_email'           => $email,
        'cf_admin_email_name'      => $title,
        'cf_use_point'             => '1',
        'cf_use_copy_log'          => '1',
        'cf_login_point'           => '100',
        'cf_memo_send_point'       => '500',
        'cf_cut_name'              => '15',
        'cf_nick_modify'           => '60',
        'cf_new_skin'              => 'basic',
        'cf_new_rows'              => '15',
        'cf_search_skin'           => 'basic',
        'cf_connect_skin'          => 'basic',
        'cf_write_pages'           => '10',
        'cf_mobile_pages'          => '5',
        'cf_link_target'           => '_blank',
        'cf_delay_sec'             => '30',
        'cf_member_skin'           => 'basic',
        'cf_mobile_new_skin'       => 'basic',
        'cf_mobile_search_skin'    => 'basic',
        'cf_mobile_connect_skin'   => 'basic',
        'cf_mobile_member_skin'    => 'basic',
        'cf_faq_skin'              => 'basic',
        'cf_mobile_faq_skin'       => 'basic',
        'cf_editor'                => 'smarteditor2',
        'cf_captcha_mp3'           => 'basic',
        'cf_register_level'        => '2',
        'cf_register_point'        => '1000',
        'cf_icon_level'            => '2',
        'cf_leave_day'             => '30',
        'cf_search_part'           => '10000',
        'cf_email_use'             => '1',
        'cf_prohibit_id'           => 'admin,administrator,관리자,운영자,어드민,주인장,webmaster,웹마스터,sysop,시삽,시샵,manager,매니저,메니저,root,루트,su,guest,방문객',
        'cf_new_del'               => '30',
        'cf_memo_del'              => '180',
        'cf_visit_del'             => '180',
        'cf_popular_del'           => '180',
        'cf_use_member_icon'       => '2',
        'cf_member_icon_size'      => '5000',
        'cf_member_icon_width'     => '22',
        'cf_member_icon_height'    => '22',
        'cf_member_img_size'       => '50000',
        'cf_member_img_width'      => '60',
        'cf_member_img_height'     => '60',
        'cf_login_minutes'         => '10',
        'cf_image_extension'       => function_exists('imagewebp') ? 'gif|jpg|jpeg|png|webp' : 'gif|jpg|jpeg|png',
        'cf_flash_extension'       => 'swf',
        'cf_movie_extension'       => 'asx|asf|wmv|wma|mpg|mpeg|mov|avi|mp3',
        'cf_formmail_is_member'    => '1',
        'cf_page_rows'             => '15',
        'cf_mobile_page_rows'      => '15',
        'cf_cert_limit'            => '2',
        'cf_stipulation'           => '해당 홈페이지에 맞는 회원가입약관을 입력합니다.',
        'cf_privacy'               => '해당 홈페이지에 맞는 개인정보처리방침을 입력합니다.',
    ];

    // 회사 정보를 cf_1_subj/cf_1 ~ cf_6_subj/cf_6 에 매핑.
    $company = $profile['company'] ?? [];
    $slots = [
        ['회사명',         $company['name']      ?? ''],
        ['대표자',         $company['owner']     ?? ''],
        ['사업자등록번호', $company['saupja_no'] ?? ''],
        ['주소',           $company['address']   ?? ''],
        ['전화',           $company['tel']       ?? ''],
        ['팩스',           $company['fax']       ?? ''],
    ];
    foreach ($slots as $i => [$label, $value]) {
        $n = $i + 1;
        $cf["cf_{$n}_subj"] = $label;
        $cf["cf_{$n}"]      = $value;
    }

    $sets = [];
    foreach ($cf as $col => $val) {
        $sets[] = "`{$col}` = '" . $db->real_escape_string((string)$val) . "'";
    }
    $sql = 'INSERT INTO `' . TABLE_PREFIX . 'config` SET ' . implode(', ', $sets);
    if (!$db->query($sql)) fail("g5_config INSERT 실패: {$db->error}");
}

function insert_default_qa_config(mysqli $db): void
{
    $sql = "INSERT INTO `" . TABLE_PREFIX . "qa_config`
              ( qa_title, qa_category, qa_skin, qa_mobile_skin,
                qa_use_email, qa_req_email, qa_use_hp, qa_req_hp, qa_use_editor,
                qa_subject_len, qa_mobile_subject_len, qa_page_rows, qa_mobile_page_rows,
                qa_image_width, qa_upload_size, qa_insert_content )
            VALUES
              ('1:1문의','회원|포인트','basic','basic',
               '1','0','1','0','1',
               '60','30','15','15',
               '600','1048576','')";
    if (!$db->query($sql)) fail("g5_qa_config INSERT 실패: {$db->error}");
}

function insert_admin_user(mysqli $db, array $opts, array $profile): void
{
    $id    = $profile['admin']['id']       ?? 'admin';
    $name  = $profile['admin']['name']     ?? '관리자';
    $nick  = $profile['admin']['nick']     ?? $name;
    $email = $profile['admin']['email']    ?? '';
    $pass  = $profile['admin']['password'] ?? null;
    if ($pass === null || $pass === '') {
        $pass = ask("관리자 비밀번호 입력: ", true);
        if ($pass === '') fail('관리자 비밀번호가 필요합니다.');
    }

    validate_identifier('admin.id', $id);
    $hash = gnuboard_password_hash($pass);
    $now  = date('YmdHis');
    $ip   = '127.0.0.1';

    $cols = [
        'mb_id'            => $id,
        'mb_password'      => $hash,
        'mb_name'          => $name,
        'mb_nick'          => $nick,
        'mb_email'         => $email,
        'mb_level'         => '10',
        'mb_mailling'      => '1',
        'mb_open'          => '1',
        'mb_nick_date'     => $now,
        'mb_email_certify' => $now,
        'mb_datetime'      => $now,
        'mb_ip'            => $ip,
    ];
    $sets = [];
    foreach ($cols as $c => $v) {
        $sets[] = "`{$c}` = '" . $db->real_escape_string((string)$v) . "'";
    }
    $sql = 'INSERT INTO `' . TABLE_PREFIX . 'member` SET ' . implode(', ', $sets);
    if (!$db->query($sql)) fail("g5_member 관리자 INSERT 실패: {$db->error}");
}

function insert_pages(mysqli $db, array $profile): void
{
    foreach ($profile['pages'] ?? [] as $page) {
        $id      = (string)($page['id']      ?? '');
        $subject = (string)($page['subject'] ?? $id);
        $html    = (string)($page['html']    ?? '');
        if ($id === '') continue;
        validate_identifier('pages[].id', $id);
        $sql = sprintf(
            "INSERT INTO `%scontent` SET co_id='%s', co_html='1', co_subject='%s', co_content='%s', co_skin='basic', co_mobile_skin='basic'",
            TABLE_PREFIX,
            $db->real_escape_string($id),
            $db->real_escape_string($subject),
            $db->real_escape_string($html)
        );
        if (!$db->query($sql)) fail("g5_content INSERT 실패 ({$id}): {$db->error}");
    }
}

function insert_default_faq(mysqli $db): void
{
    $sql = "INSERT INTO `" . TABLE_PREFIX . "faq_master` SET fm_id='1', fm_subject='자주하시는 질문'";
    if (!$db->query($sql)) fail("g5_faq_master INSERT 실패: {$db->error}");
}

function insert_groups_and_boards(mysqli $db, string $sourceRoot, array $profile): void
{
    $writeSqlFile = $sourceRoot . '/adm/sql_write.sql';
    if (!is_file($writeSqlFile)) fail("쓰기테이블 스키마 없음: {$writeSqlFile}");
    $writeTpl = file_get_contents($writeSqlFile);
    $writeTpl = preg_replace('/^--.*$/m', '', $writeTpl);
    $writeTpl = str_replace(';', '', $writeTpl);

    foreach ($profile['groups'] ?? [] as $group) {
        $grId      = (string)($group['id']      ?? '');
        $grSubject = (string)($group['subject'] ?? $grId);
        if ($grId === '') continue;
        validate_identifier('groups[].id', $grId);

        $sql = sprintf(
            "INSERT INTO `%sgroup` SET gr_id='%s', gr_subject='%s'",
            TABLE_PREFIX,
            $db->real_escape_string($grId),
            $db->real_escape_string($grSubject)
        );
        if (!$db->query($sql)) fail("g5_group INSERT 실패 ({$grId}): {$db->error}");

        foreach ($group['boards'] ?? [] as $board) {
            insert_one_board($db, $writeTpl, $grId, $board);
        }
    }
}

function insert_one_board(mysqli $db, string $writeTableTpl, string $grId, array $board): void
{
    $boTable   = (string)($board['id']      ?? '');
    $boSubject = (string)($board['subject'] ?? $boTable);
    $boSkin    = (string)($board['skin']    ?? 'basic');
    if ($boTable === '') return;
    validate_identifier('boards[].id', $boTable);
    if (!preg_match('/^[A-Za-z0-9_\-]+$/', $boSkin)) fail("유효하지 않은 skin: {$boSkin}");

    $isPaid = in_array($boTable, ['gallery', 'qa'], true);
    $cols = [
        'bo_table'                 => $boTable,
        'gr_id'                    => $grId,
        'bo_subject'               => $boSubject,
        'bo_device'                => 'both',
        'bo_admin'                 => '',
        'bo_list_level'            => '1',
        'bo_read_level'            => '1',
        'bo_write_level'           => '1',
        'bo_reply_level'           => '1',
        'bo_comment_level'         => '1',
        'bo_html_level'            => '1',
        'bo_link_level'            => '1',
        'bo_count_modify'          => '1',
        'bo_count_delete'          => '1',
        'bo_upload_level'          => '1',
        'bo_download_level'        => '1',
        'bo_read_point'            => $isPaid ? '-1' : '0',
        'bo_write_point'           => $isPaid ? '5'  : '0',
        'bo_comment_point'         => $isPaid ? '1'  : '0',
        'bo_download_point'        => $isPaid ? '-20': '0',
        'bo_use_category'          => '0',
        'bo_category_list'         => '',
        'bo_use_sideview'          => '0',
        'bo_use_file_content'      => '0',
        'bo_use_secret'            => '0',
        'bo_use_dhtml_editor'      => '0',
        'bo_use_rss_view'          => '0',
        'bo_use_good'              => '0',
        'bo_use_nogood'            => '0',
        'bo_use_name'              => '0',
        'bo_use_signature'         => '0',
        'bo_use_ip_view'           => '0',
        'bo_use_list_view'         => '0',
        'bo_use_list_content'      => '0',
        'bo_use_email'             => '0',
        'bo_table_width'           => '100',
        'bo_subject_len'           => '60',
        'bo_mobile_subject_len'    => '30',
        'bo_page_rows'             => '15',
        'bo_mobile_page_rows'      => '15',
        'bo_new'                   => '24',
        'bo_hot'                   => '100',
        'bo_image_width'           => '835',
        'bo_skin'                  => $boSkin,
        'bo_mobile_skin'           => $boSkin,
        'bo_include_head'          => '_head.php',
        'bo_include_tail'          => '_tail.php',
        'bo_content_head'          => '',
        'bo_content_tail'          => '',
        'bo_mobile_content_head'   => '',
        'bo_mobile_content_tail'   => '',
        'bo_insert_content'        => '',
        'bo_gallery_cols'          => '4',
        'bo_gallery_width'         => '202',
        'bo_gallery_height'        => '150',
        'bo_mobile_gallery_width'  => '125',
        'bo_mobile_gallery_height' => '100',
        'bo_upload_count'          => '2',
        'bo_upload_size'           => '1048576',
        'bo_reply_order'           => '1',
        'bo_use_search'            => '0',
        'bo_order'                 => '0',
    ];
    $sets = [];
    foreach ($cols as $c => $v) {
        $sets[] = "`{$c}` = '" . $db->real_escape_string((string)$v) . "'";
    }
    $sql = 'INSERT INTO `' . TABLE_PREFIX . 'board` SET ' . implode(', ', $sets);
    if (!$db->query($sql)) fail("g5_board INSERT 실패 ({$boTable}): {$db->error}");

    $writeTable = TABLE_PREFIX . 'write_' . $boTable;
    $createSql  = str_replace('__TABLE_NAME__', $writeTable, $writeTableTpl);
    if (!$db->query($createSql)) fail("쓰기 테이블 생성 실패 ({$writeTable}): {$db->error}");
}

// ---------------------------------------------------------------------------
// dbconfig.php
// ---------------------------------------------------------------------------

function write_dbconfig(string $targetDir, array $opts): void
{
    $dataDir = $targetDir . DIRECTORY_SEPARATOR . 'data';
    @mkdir($dataDir, 0755, true);
    $path = $dataDir . DIRECTORY_SEPARATOR . 'dbconfig.php';

    $esc = function (string $v): string { return addcslashes($v, "\\'"); };
    $token = random_token_string(16);

    $body = "<?php\n";
    $body .= "if (!defined('_GNUBOARD_')) exit;\n";
    $body .= "define('G5_MYSQL_HOST',     '" . $esc((string)$opts['db-host']) . "');\n";
    $body .= "define('G5_MYSQL_USER',     '" . $esc((string)$opts['db-user']) . "');\n";
    $body .= "define('G5_MYSQL_PASSWORD', '" . $esc((string)$opts['db-pass']) . "');\n";
    $body .= "define('G5_MYSQL_DB',       '" . $esc((string)$opts['db-name']) . "');\n";
    $body .= "define('G5_MYSQL_SET_MODE', false);\n\n";
    $body .= "define('G5_TABLE_PREFIX', '" . TABLE_PREFIX . "');\n\n";
    $body .= "define('G5_TOKEN_ENCRYPTION_KEY', '{$token}');\n\n";
    $body .= "\$g5['write_prefix']                = G5_TABLE_PREFIX.'write_';\n";

    $tables = [
        'auth_table'                => 'auth',
        'config_table'              => 'config',
        'group_table'               => 'group',
        'group_member_table'        => 'group_member',
        'board_table'               => 'board',
        'board_file_table'          => 'board_file',
        'board_good_table'          => 'board_good',
        'board_new_table'           => 'board_new',
        'login_table'               => 'login',
        'mail_table'                => 'mail',
        'member_table'              => 'member',
        'member_auto_login_table'   => 'member_auto_login',
        'memo_table'                => 'memo',
        'poll_table'                => 'poll',
        'poll_etc_table'            => 'poll_etc',
        'point_table'               => 'point',
        'popular_table'             => 'popular',
        'scrap_table'               => 'scrap',
        'visit_table'               => 'visit',
        'visit_sum_table'           => 'visit_sum',
        'uniqid_table'              => 'uniqid',
        'autosave_table'            => 'autosave',
        'cert_history_table'        => 'cert_history',
        'qa_config_table'           => 'qa_config',
        'qa_content_table'          => 'qa_content',
        'content_table'             => 'content',
        'faq_table'                 => 'faq',
        'faq_master_table'          => 'faq_master',
        'new_win_table'             => 'new_win',
        'menu_table'                => 'menu',
        'social_profile_table'      => 'member_social_profiles',
        'member_cert_history_table' => 'member_cert_history',
    ];
    foreach ($tables as $key => $suffix) {
        $body .= "\$g5['{$key}'] = G5_TABLE_PREFIX.'{$suffix}';\n";
    }
    $body .= "\n?>\n";

    if (file_put_contents($path, $body) === false) {
        fail("dbconfig.php 작성 실패: {$path}");
    }
    fwrite(STDOUT, "  dbconfig.php 작성: {$path}\n");
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// 그누보드 sql_password() 의 결과(MariaDB/MySQL 5.x PASSWORD()와 동일 포맷)를
// 순수 PHP 로 재현. mb_password 컬럼에 직접 INSERT 가능.
function gnuboard_password_hash(string $plain): string
{
    return '*' . strtoupper(sha1(sha1($plain, true)));
}

function random_token_string(int $len = 16): string
{
    return substr(bin2hex(random_bytes($len)), 0, $len);
}

function print_next_steps(array $opts, string $target): void
{
    fwrite(STDOUT, "\n----------------------------------------\n");
    fwrite(STDOUT, "셋업 완료. 다음 단계:\n");
    fwrite(STDOUT, "  - 브라우저에서 사이트 접속:\n");
    fwrite(STDOUT, "      예) http://localhost/" . basename($target) . "/\n");
    fwrite(STDOUT, "  - 관리자 로그인 후 [환경설정 → 기본환경설정]에서\n");
    fwrite(STDOUT, "      회사정보(cf_1~cf_6)를 사이트 푸터/약관에 노출하도록 테마 수정\n");
    fwrite(STDOUT, "  - 로고는 data/logo.* 에 복사되어 있음 (테마에서 직접 참조)\n");
    fwrite(STDOUT, "  - install.php 는 dbconfig.php 가 작성되어 있어 자동 차단됨\n");
}
