<?php

	$userKey = $_POST["key"];

	$config = array(
	    "digest_alg" => "sha512",
	    "private_key_bits" => 2048,
	    "private_key_type" => OPENSSL_KEYTYPE_RSA,
	);
    
	// Create the keypair
	$res = openssl_pkey_new($config);

	// Get private key
    openssl_pkey_export($res, $privKey);

    //Load Encryptor and encrypt private key to server hard drive
    require __DIR__.'/autoload.php';
    $aes = new \RNCryptor\Encryptor();
    $EncryptedData = $aes->encrypt($privKey, substr($userKey, 0, 256));
	file_put_contents(substr($userKey, -10).".txt", $EncryptedData);

	//Delete the private key and user key from memory
	unset($privKey);
	unset($userKey);

	// Get public key
	$pubKey = openssl_pkey_get_details($res);
    $pubKey = $pubKey["key"];

	function getStatusCodeMessage($status) {
        $codes = parse_ini_file("codes.ini");
        return (isset($codes[$status])) ? $codes[$status] : '';
    }

    function sendResponse($status, $body = '', $content_type = 'text/html') {
        $status_header = 'HTTP/1.1 ' . $status . ' ' . getStatusCodeMessage($status);
        header($status_header);
        header('Content-type: ' . $content_type);
        echo $body;
    }

      sendResponse(201, 
                '<?xml version="1.0" encoding="UTF-8"?>
                <Root>
                    <Success>Yes</Success>
                    <Key>'.$pubKey.'</Key>
                </Root>');
?>