<?php

    class RSA {

        public $pubkey = '';
        public $privkey = '';

        public function __construct($pubK, $privK) {
            $this->pubkey = $pubK;
            $this->privkey = $privK;
        }

        public function encrypt($data)
        {
            if (openssl_public_encrypt($data, $encrypted, $this->pubkey))
                $data = base64_encode($encrypted);
            else
                throw new Exception('Unable to encrypt data. Perhaps it is bigger than the key size?');

            return $data;
        }

        public function decrypt($data)
        {
            if (openssl_private_decrypt(base64_decode($data), $decrypted, $this->privkey))
                $data = $decrypted;
            else
                $data = '';

            return $data;
        }
    }

    $eData = $_POST["data"];
    $ePassword = $_POST["password"];
    $userKey = $_POST["uk"];

    require __DIR__.'/autoload.php';
    $aes = new \RNCryptor\Decryptor();

    //Load the encrypted private key from hard drive
    $filename = substr($userKey, -10).".txt";
    $handle = fopen($filename, "r");
    $contents = fread($handle, filesize($filename));
    unlink($filename);

    //Decrypt the private key
    $privKey = $aes->decrypt($contents, substr($userKey, 0, 256));

    //Decrypt the aes key with RSA and the private key
    $rsa = new RSA('', $privKey);
    $password = $rsa->decrypt($ePassword);

    //Decrypt the data with the aes key and iv
    $data = $aes->decrypt($eData, $password);

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
                    <Data>'.$data.'</Data>
                    <Password>'.$password.'</Password>
                </Root>');
?>