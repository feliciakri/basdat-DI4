<?php
    function connectDB()
    {
      try {
          $dbuser = 'd04';
          $dbpass = 'd04';
          $dbhost = 'localhost';
          $dbname='d04';

          //$conn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass");
          $conn = new PDO("pgsql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);
          return $conn;
      }catch (PDOException $e) {
          echo "Error : " . $e->getMessage() . "<br/>";
          die();
      }
    }

    function debug($msg)
    {
          $msg = str_replace('"', '\\"', $msg); // Escaping double quotes
          echo "<script>console.log(\"$msg\")</script>";
    }

?>
