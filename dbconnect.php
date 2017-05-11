<?php
    function connectDB()
    {
      try {
          $dbuser = 'd04';
          $dbpass = 'd04';
          $dbhost = 'localhost';
          $dbname='d04';

          $conn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass");
          //$conn = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);
          return $conn;
      }catch (PDOException $e) {
          echo "Error : " . $e->getMessage() . "<br/>";
          die();
      }
    }
