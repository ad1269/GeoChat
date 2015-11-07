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
    $userLat = $xml->Latitude;
    $userLong = $xml->Longitude;
    
    //Get all posts from the database and store in an array
    $con = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname) or die('Cannot connect to the DB') && exit();

    $sql = 'SELECT * FROM `Posts`';

    $result = mysqli_query($con, $sql);

    while($oRow = mysqli_fetch_assoc($result)){
        $row[] = $oRow;
    }

    $postsToDisplay = [];

    function distanceBetweenPostAndUser($pLat, $pLong, $userLat, $userLong) {
        $Radius = 6371000;
        $phi1 = $userLat * M_PI / 180;
        $phi2 = $pLat * M_PI / 180;
        $deltaPhi = ($pLat-$userLat) * M_PI / 180;
        $deltaLambda = ($pLong-$userLong) * M_PI / 180;

        $a = sin($deltaPhi/2) * sin($deltaPhi/2) + cos($phi1) * cos($phi2) * sin($deltaLambda/2) * sin($deltaLambda/2);
        $c = 2 * atan2(sqrt($a), sqrt(1-$a));

        $d = $Radius * $c;
        return $d;
    }

    function array_to_xml($array, &$xml) {
        foreach($array as $key => $value) {
            if(is_array($value)) {
                if(!is_numeric($key)){
                    $subnode = $xml->addChild("$key");
                    array_to_xml($value, $subnode);
                }
                else{
                    $subnode = $xml->addChild("item$key");
                    array_to_xml($value, $subnode);
                }
            }
            else {
                $xml->addChild("$key",htmlspecialchars("$value"));
            }
        }
    }

    $num = 0;

    foreach ($row as $post) {
        $pLat = $post['latitude'];
        $pLong = $post['longitude'];

        if(distanceBetweenPostAndUser($pLat, $pLong, $userLat, $userLong) <= 160000) {
            array_push($postsToDisplay, $post);
            $num++;
        }
    }

    //Convert $postsToDisplay here into XML to send to the client
    $postXML = new SimpleXMLElement('<?xml version="1.0"?><Root></Root>');
    array_to_xml($postsToDisplay, $postXML);

    $postStr = $postXML->asXML();

    //Send back the posts to be displayed
    sendResponse(201, 
            '<?xml version="1.0" encoding="UTF-8"?>
            <Root>
                <Success>Yes</Success>
                <Data>'.str_replace('<', '@', $postStr).'</Data>
                <Number>'.$num.'</Number>
            </Root>');
?>