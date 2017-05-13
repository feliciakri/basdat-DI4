<?php
    function connectDB()
    {
      try {
          $dbuser = 'postgres';
          $dbpass = 'd03';
          $dbhost = 'localhost';
          $dbname='d03';

          $conn = pg_connect("host=$dbhost dbname=$dbname user=$dbuser password=$dbpass");
          //$conn = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);
          return $conn;
      }catch (PDOException $e) {
          echo "Error : " . $e->getMessage() . "<br/>";
          die();
      }
    }
