<?php

ini_set('post_max_size', '300M');
ini_set('upload_max_filesize', '300M');

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
    $postBody = $xml->PostBody;
    $imgString = $xml->ImgString;
    $lat = $xml->Latitude;
    $long = $xml->Longitude;
    $userPath = $xml->UserPath;
    $timePosted = $xml->TimePosted;
    $isPublic = $xml->IsPublic;

    //Create image path on server hard drive
    $imgPath = __DIR__.'/Images/'.substr(md5(rand()), 0, 10).'.jpg';

    //Decode image
    $data = base64_decode($imgString);

    //Write to disk
    $file = fopen($imgPath, 'w');
    fwrite($file, $data);
    fclose($file);

    //Insert post into database
    $con = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname) or die('Cannot connect to the DB') && exit();
    $sql = 'INSERT INTO `Posts` (`postBody`, `imgPath`, `latitude`, `longitude`, `timePosted`, `userPath`, `isPublic`) VALUES (\''.$postBody.'\', \''.$imgPath.'\', \''.$lat.'\', \''.$long.'\', \''.$timePosted.'\', \''.$userPath.'\', \''.$isPublic.'\')';
    $result = mysqli_query($con, $sql);

    //Send back validity
    if($result == 1) {
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>Yes</Success>
            </Root>');
    }
    else {
        sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>No</Success>
            </Root>');
    }


?>