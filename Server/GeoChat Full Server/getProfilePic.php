<?php
	$userPath = $_POST["path"];
	echo file_get_contents(__DIR__.$userPath.'profile.png');
?>