<?php
    /*session_start();
    if (!isset($_SESSION['loggeduser'])) {
        header('location: login');
    }
    
    include('dbconnect.php');

	$nomoriduser = $_SESSION['loggedusernumber'];*/
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>TokoKeren - Dinego Aja Shay, Pasti Cincay!</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="src/img/favicon.ico?" rel="icon" type="image/x-icon">
    <link type="text/css" rel="stylesheet" href="libs/bootstrap/dist/css/bootstrap.min.css">
    <link type="text/css" rel="stylesheet" href="libs/materialize/css/materialize.min.css"  media="screen,projection"/>
    <link rel="stylesheet" type="text/css" href="src/css/style.css">
    <link rel="stylesheet" type="text/css" href="src/css/navbar.css">
    <!-- insert more css file here -->

</head>
<body>
		<?php
            /*include('navbar.php');*/
        ?>	
    <div class="container">
        <div class="row">
            <div class="wrap">
                <h1>SHIPPED PRODUCT</h1>
                <div class="divider"></div>
            </div>
            <div class="row">
                <div class="col s12 cards-container">
                    
                </div>
            </div>
        </div>
    </div>
	
	
	
    <script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
    <!-- insert more js file here -->
</body>
</html>		