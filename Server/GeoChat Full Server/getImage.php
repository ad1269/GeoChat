<?php
	$imgPath = $_POST["path"];
	echo file_get_contents(__DIR__.$imgPath);
?>