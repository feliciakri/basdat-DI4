<?php
  session_start();
  session_destroy();
  header("Location: zaza/registration.php");
?>