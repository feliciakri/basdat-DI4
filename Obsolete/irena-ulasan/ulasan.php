<?php
    session_start();
    $_SESSION['loggeduser'] = "astandell6g@washington.edu";
    include "dbconnect.php";
    $conn = connectDB();

    $sql = "SET search_path TO tokokeren";
    $result = pg_query($conn, $sql);
    
    parse_str(file_get_contents("php://input"), $_POST);
    if(isset($_POST)) {
        if(isset($_POST['command'])) {
            if($_POST['command'] == 'ulasProduk') {
                $email = pg_escape_string($_SESSION['loggeduser']);
                $kodeProduk =  pg_escape_string($_GET['kode']);
                $tanggal = date("Y/m/d");
                $rating =  pg_escape_string($_POST['rating']);
                $komentar =  pg_escape_string($_POST['komentar']);

                if($rating == null) {
                    $_SESSION['error']['ratingKosong'] = "Kolom rating tidak boleh kosong";
                }
                if($komentar == null) {
                    $_SESSION['error']['komentarKosong'] = "Kolom komentar tidak boleh kosong";   
                }

                if (isset($_SESSION['error'])) {
                    echo "<br><br><br><br>";
                    foreach ($_SESSION['error'] as $message) {
                        echo "<div class='alert alert-danger text-center alert-dismissible fade in' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>".$message."</div>";
                    } 
                } else {
                    $sql = "INSERT INTO ULASAN (email_pembeli, kode_produk, tanggal, rating, komentar) values ('$email','$kodeProduk', '$tanggal', '$rating', '$komentar')";
                    $result = pg_query($conn, $sql);
                    if($result){
                        header("location: home.php");
                    }
                }

                session_unset($_SESSION['error']);
            }
        }
    }
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ulasan Produk</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
<link rel="stylesheet" type="text/css" href="css/star-rating.css" media="all">
</head>
<body>
<nav id="myNavbar" class="navbar navbar-default navbar-inverse navbar-fixed-top" role="navigation">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="container">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbarCollapse">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">TokoKeren</a>
        </div>
        <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse" id="navbarCollapse">
            <ul class="nav navbar-nav">
                <li class="active"><a href=#>Home</a></li>
            </ul>
        </div>
    </div>
</nav>
<div class="container">
    <div class="jumbotron">
        <h2 class="text-center">Ulasan</h2>
        <div class="row">
	        <div class="col-sm-12">
                <?php
                    $url = "ulasan.php?kode=" . $_GET['kode'];
                    echo "<form id='formUlasan' action='$url' method='post'>";
                ?>
	            <!-- <form id="formUlasan" action="" method="post"> -->
				    <div class="form-group">
				        <label for="kodeProduk" class="control-label">Kode Produk</label>
                        <h4>
                            <?php
                                if(isset($_GET['kode'])) {
                                    echo $_GET['kode'];
                                }
                            ?>
                        </h4>
				    </div>
				    <div class="form-group">
				        <label for="inputRating" class="control-label">Rating</label>
				        <input id="inputRating" name="rating" type="number" class="rating" min=0 max=5 step=1 data-size="sm">
				    </div>
				    <div class="form-group">
				        <label for="inputKomentar" class="control-label">Komentar</label>
                        <textarea id="inputKomentar" class="form-control" name="komentar" form="formUlasan"></textarea>
                        <input type="hidden" name="command" value="ulasProduk">
				    </div>
				    <button type="submit" class="btn btn-primary">Submit</button>
				</form>
	        </div>
	    </div>
    </div>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script src="js/star-rating.js" type="text/javascript"></script>
</body>
</html>                                		