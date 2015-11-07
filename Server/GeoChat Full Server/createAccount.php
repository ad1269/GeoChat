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

    $dbhost = 'mysql.hostinger.in';
    $dbname = 'u327808112_users';
    $dbuser = 'u327808112_admin';
    $dbpass = 'admin123';

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

    //Separate the data into the individual parts needed to create the account
    $xml = simplexml_load_string($data) or die("Error: Cannot create object");
    $username = $xml->Username;
    $userPass = $xml->Password;
    $userEmail = $xml->Email;
    $userPhone = $xml->Phone;
    $userDOB = $xml->DOB;
    $userFullName = $xml->Name;

    //Checks if the user already exists
    $con = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname) or die('Cannot connect to the DB') && exit();

    $sql = 'SELECT * FROM `Users` WHERE Username=\''.$username.'\' OR Email=\''.$userEmail.'\' OR Phone=\''.$userPhone.'\' LIMIT 0, 30 ';

    $result = mysqli_query($con, $sql);

    $row = mysqli_fetch_array($result);

    mysqli_close($con);

    //Insert the data into the table
    if(count($row) == 0) {
        $con2 = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname) or die('Cannot connect to the DB') && exit();
        $sql2 = 'INSERT INTO `Users` (`Username`, `Password`, `Name`, `Email`, `Phone`, `DOB`) VALUES (\''.$username.'\', \''.$userPass.'\', \''.$userFullName.'\', \''.$userEmail.'\', \''.$userPhone.'\', \''.$userDOB.'\')';
        $result2 = mysqli_query($con2, $sql2);
        $created = No;

        if($result2) {
            $created = Yes;
        }

        mysqli_close($con2);

        //Send response to client
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>'.$created.'</Success>
            </Root>');
    }
    else 
    {

        //Send response to client
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>No</Success>
            </Root>');
    }
?>