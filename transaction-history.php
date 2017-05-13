<?php
session_start();
$_SESSION['loggeduser']="astandell6g@washington.edu";

include('dbconnect.php');
debug("included");
function selectTransaksi(){
  try {
    $conn = connectDB();
    $loggeduid = $_SESSION['loggeduser'];
    $sql = "SELECT no_invoice, nama_toko, tanggal, waktu_bayar, alamat_kirim, biaya_kirim, no_resi, nama_jasa_kirim FROM transaksi_shipped WHERE email_pembeli=$loggeduid";
    $q = $conn->query($sql);
    $q->setFetchMode(PDO::FETCH_ASSOC);
		debug("inhere");
    return $q;
  } catch (PDOException $e){
    die("Could not connect to the database $conn.$dbname :" . $e->getMessage());
  }

}
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
	<link rel="stylesheet" type="text/css" href="src/css/transaction-history.css">

	<!-- insert more css file here -->

</head>
<body>
	<?php
		include("include/navbar.php");
	?>
	<div class="container">
		<div class="row">
			<div class="wrap">
				<h1>TRANSACTION HISTORY</h1>
				<div class="divider"></div>
			</div>
			<div class="row">
				<div class="cd-tabs">
					<nav>
						<ul class="cd-tabs-navigation">
							<li><a data-content="inbox" class="selected" href="#0">Pulsa</a></li>
							<li><a data-content="store" href="#0">Shipped</a></li>
							<li><a data-content="new" href="#0">Daftar Produk</a></li>
						</ul> <!-- cd-tabs-navigation -->
					</nav>

					<ul class="cd-tabs-content">
						<li data-content="inbox" class="selected">
							<div class="container demo">
								<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingOne">
											<h4 class="panel-title">
												<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #1<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseOne" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
											<div class="panel-body">
												<b>Detail</b><br>

												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingTwo">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseTwo" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingThree">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseThree" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingThree">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

								</div><!-- panel-group -->
							</div>
						</li>

						<li data-content="new">
							<div class="container demo">

								<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingOne2">
											<h4 class="panel-title">
												<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne2" aria-expanded="true" aria-controls="collapseOne2">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #1<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseOne2" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne2">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.<br>
												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingTwo2">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo2" aria-expanded="false" aria-controls="collapseTwo2">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseTwo2" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo2">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingThree2">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseThree2" aria-expanded="false" aria-controls="collapseThree2">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseThree2" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingThree2">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

								</div><!-- panel-group -->
							</div>
						</li>

						<li data-content="store">
							<div class="container demo">


								<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingOne3">
											<h4 class="panel-title">
												<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne3" aria-expanded="true" aria-controls="collapseOne3">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #1<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseOne3" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne3">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.<br>
												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingTwo3">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo3" aria-expanded="false" aria-controls="collapseTwo3">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseTwo3" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo3">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

									<div class="panel panel-default">
										<div class="panel-heading" role="tab" id="headingThree3">
											<h4 class="panel-title">
												<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseThree3" aria-expanded="false" aria-controls="collapseThree3">
													<i class="more-less glyphicon glyphicon-plus"></i>
													Nomor Produk #2<br>Tanggal Beli<br>
												</a>
											</h4>
										</div>
										<div id="collapseThree3" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingThree3">
											<div class="panel-body">
												<b>Detail</b><br>
												Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident. Ad vegan excepteur butcher vice lomo. Leggings occaecat craft beer farm-to-table, raw denim aesthetic synth nesciunt you probably haven't heard of them accusamus labore sustainable VHS.
												<button>Ulas</button>
											</div>
										</div>
									</div>

								</div><!-- panel-group -->
							</div>
						</li>

					</ul> <!-- cd-tabs-content -->
				</div> <!-- cd-tabs -->

			</div><!--End of row1-->
			<div class="row">
			</div><!--End of row1-->
			<div class="row">
			</div><!--End of row1-->
		</div>
	</div>


	<!--<script type="text/javascript" src="src/js/modernizr.js"></script>-->
	<script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
	<script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
	<script type="text/javascript" src="src/js/script.js"></script>
	<script type="text/javascript" src="src/js/transaction-history.js"></script>
	<script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
	<!-- insert more js file here -->
</body>
</html>
