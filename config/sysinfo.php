<!doctype html>

<html lang="en">
	<head>
	  <meta charset="utf-8">

	  <title>SysInfo</title>
	  <link rel="stylesheet" href="style.css">
	</head>
	<body>
	
<?php

// Дополнительно вверху страницы надо выводить:
// адрес клиента который обращается к ресурсу, его порт
// адрес nginx который обращается к apache, его порт, версию nginx (в nginx добавить в проксируемый запрос заголовок X-NGX-VERSION).
echo "Client addr=".$_SERVER['HTTP_X_FORWARDED_FOR']."<br>";
echo "Client port=".$_SERVER['REMOTE_PORT']."<br>";

echo "Nginx addr=".$_SERVER['REMOTE_ADDR']."<br>";
echo "Nginx port=".$_SERVER['SERVER_PORT']."<br>";
echo "HTTP_X_NGX_VERSION=".$_SERVER['HTTP_X_NGX_VERSION']."<br>";
//echo var_dump($_SERVER);

// Соединяемся, выбираем базу данных
	$mysqli = new mysqli('localhost', 'root', 'mysqlpass',"sysinfo");

// Test for loggin worked
    $resl = $mysqli->query("SELECT  id,date FROM log ORDER BY id DESC LIMIT 1;");
    $rowl = $resl->fetch_assoc();
    $date_last=strtotime($rowl['date']);
    $date_current=time();
    $date_diff=$date_current-$date_last;
    if ($date_diff>65){
			$header_class="fail";
    }else{
			$header_class="ok";
    };
//  end Test for loggin worked


	$id=intval($_GET["q"]);
	if ($id>0){
		// выводим историю
		$res = $mysqli->query("SELECT  id,date FROM log WHERE id=$id;");
	}
	else{
		// выводим последние данные
		$res = $mysqli->query("SELECT  id,date FROM log ORDER BY id DESC LIMIT 1;");
	}

	$row = $res->fetch_assoc();
	$log_id=$row['id'];
	$date=$row['date'];
 
 	//  current data button
 	if ($id>0){
 		echo "<a href='sysinfo'><button>Current data</button></a>";
 	}
 	// Prev data button
	if($log_id>1){
			echo "<a href='sysinfo?q=".($log_id-1)."'><button>Prev data</button></a>";
	};	

// show data log
	echo "<h1 class='$header_class'>Datetime (UTC): $date  id: $log_id</h1>";

	$res = $mysqli->query("SELECT  name,data FROM section  WHERE log_id=$log_id ORDER BY id");

while ($section = $res->fetch_assoc()) {
	$name= $section['name'];
	$data = $section['data'];
	// заголовок секции	
	echo "<h2>$name</h2>";
	// строка данных
	echo "<pre>$data</pre><hr>";
}

?>
	</body>
</html>