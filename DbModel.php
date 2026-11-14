<?php

const WALLET_DIR = 'Wallet_ProyectoCineG8';
const DB_USER    = 'ADMIN';
const DB_PASS    = 'XlPlrK6rac#&';
const DB_ALIAS = '(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=g6508db35def194_proyectocineg8_low.adb.oraclecloud.com))(security=(MY_WALLET_DIRECTORY=C:/xampp/htdocs/G8_DB_Lang_Proyecto/Wallet_ProyectoCineG8)(ssl_server_dn_match=yes)))';
putenv('TNS_ADMIN=' . WALLET_DIR);

$conn = oci_connect(DB_USER, DB_PASS, DB_ALIAS, 'AL32UTF8');

if (!$conn) {
    $e = oci_error();
    http_response_code(500);
    exit('Connection failed: ' . htmlentities($e['message'], ENT_QUOTES));
}
 
echo "<h2>Connected to Oracle DB</h2>";

$sql  = "SELECT banner_full AS version, SYS_CONTEXT('USERENV','DB_NAME') AS db_name, SYSDATE AS now FROM v\$version FETCH FIRST 1 ROWS ONLY";
$stid = oci_parse($conn, $sql);
 
if (!oci_execute($stid)) {
    $e = oci_error($stid);
    exit('Query failed: ' . htmlentities($e['message'], ENT_QUOTES));
}
 
echo "<table border='1' cellpadding='6'>";
while (($row = oci_fetch_assoc($stid)) !== false) {
    foreach ($row as $col => $val) {
        echo '<tr><th>' . htmlentities($col) . '</th><td>' . htmlentities((string)$val) . '</td></tr>';
    }
}
echo "</table>";
 
oci_free_statement($stid);
oci_close($conn);