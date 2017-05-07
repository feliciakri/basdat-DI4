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
                <h1>PULSA PRODUCT</h1>
                <div class="divider"></div>
            </div>
            <div class="row">
                 <!-- multistep form -->
                    <form id="msform">
                      <!-- progressbar -->
                      <ul id="progressbar">
                        <li class="active">Pick a Provider</li>
                        <li>Pick Your Package</li>
                        <li>Phone and Payment Details</li>
                      </ul>
                      <!-- fieldsets -->
                      <fieldset>
                        <h2 class="fs-title">Pick Your Package</h2>
                          <h3 class="fs-subtitle">Lengkap Shay</h3>
                        <input type="dropdown" name="package" placeholder="package" />
                        <input type="button" name="next" class="next action-button" value="Next" />
                      </fieldset>
                      <fieldset>
                        <h2 class="fs-title">Phone Detail</h2>
                        <h3 class="fs-subtitle">Dinego Shay</h3>
                        <input type="text" name="phone" placeholder="Phone" />
                        <input type="button" name="previous" class="previous action-button" value="Previous" />
                        <input type="button" name="next" class="next action-button" value="Next" />
                      </fieldset>
                      <fieldset>
                        <h2 class="fs-title">Payment Detail</h2>
                        <h3 class="fs-subtitle">Harga Cincay</h3>
                        <input type="text" name="payment" placeholder="Payment" />
                        <input type="button" name="previous" class="previous action-button" value="Previous" />
                          <input type="submit" name="submit" class="submit action-button" value="Submit" />
                      </fieldset>
                    </form>
            </div><!--End of row1-->
        </div>
    </div>
	
	
	<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.3/jquery.easing.min.js"></script>
    <script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
    <script type="text/javascript" src="src/js/script.js"></script>
    <script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
    <!-- insert more js file here -->
</body>
</html>		