<?php
    function connectDB()
    {
      try {
          $dbuser = 'd04';
          $dbpass = 'd04';
          $host = 'localhost';
          $dbname='d04';

          $conn = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);
          return $conn;
      }catch (PDOException $e) {
          echo "Error : " . $e->getMessage() . "<br/>";
          die();
      }
    }
?>
