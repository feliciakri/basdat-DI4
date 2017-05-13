<?php
    function connectDB()
    {
      try {
          $dbuser = 'postgres';
          $dbpass = 'd03';
          $dbhost = 'localhost';
          $dbname='d03';

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
