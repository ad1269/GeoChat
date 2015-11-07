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

    $dbhost = 'mysql.hostinger.in';
    $dbname = 'u327808112_users';
    $dbuser = 'u327808112_admin';
    $dbpass = 'admin123';

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

    //Separate the data into the individual parts needed to create the account
    $xml = simplexml_load_string($data) or die("Error: Cannot create object");
    $username = $xml->Username;
    $userPass = $xml->Password;

    $successfulLogin = No;

    //Validate the username and password with the database
    if($username != '' || $userPass != '') {
        $con = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname) or die('Cannot connect to the DB') && exit();

        $sql = 'SELECT * FROM `Users` WHERE Username=\''.$username.'\'';

        $result = mysqli_query($con, $sql);

        $row = mysqli_fetch_array($result);

        $resU = $row['Username'];
        $resP = $row['Password'];

        if($resU == $username && $resP == $userPass) {
            $successfulLogin = Yes;
        }

        //Send back validity
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>'.$successfulLogin.'</Success>
            </Root>');
    }
    else {
        //Username or Password is blank
        //Change this so the app never sends the data if the username/password is blank
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>'.$successfulLogin.'</Success>
                <Error>Username or Password is blank</Error>
            </Root>');
    }
?>