<?php
$_SESSION['loggeduser'] = "UcokBaba@FooBar.my";
if (!isset($_SESSION['loggeduser'])) {
	echo '<div class="navbar-fixed">
        <nav>
            <div class="nav-wrapper">
              <a href="index" class="brand-logo"><img src="src/img/logo-tokokeren-horizontal.png" height="32px"></a>
              <a href="#" data-activates="mobile-menu" class="button-collapse"><i class="material-icons">menu</i></a>
              <ul id="nav-mobile" class="right hide-on-med-and-down">
                <li><a href="home.php">Home</a></li>
                <li>Not logged in</li>
                <li><a href="login.php" class="btn transparent nav-btn">Login</a></li>
								<li><a href="registration.php" class="btn transparent nav-btn">Register</a></li>
              </ul>
              <ul class="side-nav" id="mobile-menu">
								<li><a href="home.php">Home</a></li>
								<li>Not logged in</li>
								<li><a href="login.php" class="btn transparent nav-btn">Login</a></li>
								<li><a href="registration.php" class="btn transparent nav-btn">Register</a></li>
              </ul>
            </div>
        </nav>
    </div>';
} else {
	echo '<div class="navbar-fixed">
        <nav>
            <div class="nav-wrapper">
              <a href="index" class="brand-logo"><img src="src/img/logo-tokokeren-horizontal.png" height="32px"></a>
              <a href="#" data-activates="mobile-menu" class="button-collapse"><i class="material-icons">menu</i></a>
              <ul id="nav-mobile" class="right hide-on-med-and-down">';
	if (($_SESSION['loggedrole']) == "admin") {
		echo '<li><a href="add_promo.php">Add Promo</a></li>
					<li><a href="add_jasa_kirim.php">Add Jasa Kirim</a></li>';
	}
	$loggeduid = $_SESSION['loggeduser'];
	echo '<li><a href="home.php">Home</a></li>
                <li><a href="transaction-history.php">Transaction History</a></li>
								<li><a href="pulsa-product.php">Buy Pulsa</a></li>
								<li><a href="shipped-product.php">Buy Product</a></li>
                <li><p>Logged in as <b>' . $loggeduid . '</b></p></li>
                <li><a href="logout.php" class="btn transparent nav-btn">Log Out</a></li>
              </ul>
               <ul class="side-nav" id="mobile-menu">';
	if (($_SESSION['loggedrole']) == "admin") {
		echo '<li><a href="config">Add Books</a></li>';
	}
	$loggeduid = $_SESSION['loggeduser'];
	echo '<li><a href="home.php">Home</a></li>
                <li><a href="transaction-history.php">Transaction History</a></li>
								<li><a href="pulsa-product.php">Buy Pulsa</a></li>
								<li><a href="shipped-product.php">Buy Product</a></li>
                <li><p>Logged in as <b>' . $loggeduid . '</b></p></li>
                <li><a href="logout.php" class="btn transparent nav-btn">Log Out</a></li>
              </ul>
            </div>
          </nav>
          </div>';
}
?>

<script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
<script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
