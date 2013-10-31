<?php

define("READ_START_SYMBOL", "# ---auto update---");
define("READ_END_SYMBOL", "# ---/auto update---");

// 
function notify_update($name, $from, $to) {
    echo "updated '".$name."' from ".$from." to ".$to."\n";
}

function fetch_new_version($resource) {
    $url = "https://api.github.com/repos/boxen/puppet-".$resource."/tags";

    $res = file_get_contents($url);
    $json = json_decode($res);

    return $json[0]->name;
}

function update_version($line) {
    // 空行、コメントの行、githubで始まらない行は対象外
    if ( strlen($line) === 0 || $line[0] === "#" || strpos($line, "github") === false ) {
        return $line;
    }

    // 現在Puppetfileに書かれているResourcesとバージョンを取得
    preg_match("/^github \"(\w+)\",\s*\"(\d+\.\d+\.\d+)\"/", $line, $match);
    $name = $match[1];
    $version = $match[2];

    // Github APIを利用して最新バージョンを取得
    $new_version = fetch_new_version($name);

    // 500等でバージョンの取得に失敗した場合更新をかけない
    if ( $new_version == null ) return $line;

    // アップデートがあれば標準出力にて通知
    if ( $new_version !== $version ) notify_update($name, $version, $new_version);

    // バージョンの部分を最新バージョンに置き換え
    return str_replace($version, $new_version, $line);
}

$Puppetfile = file_get_contents("./Puppetfile");
$Puppetfile = explode("\n", $Puppetfile);

// 自動更新する範囲を取得
$read_flg = false;

$Puppetfile = array_map(function($line) {
    global $read_flg;

    // 読み取り開始/終了
    if ( strpos($line, READ_START_SYMBOL) !== false ) $read_flg = true;
    if ( strpos($line, READ_END_SYMBOL) !== false ) $read_flg = false;

    if ( $read_flg ) {
        // 自動更新の範囲内なら更新を行う
        return update_version($line);
    } else {
        return $line;   // 何もしない
    }
}, $Puppetfile);

// 変更した内容でPuppetfileを上書き
file_put_contents("./Puppetfile", implode("\n", $Puppetfile));
