<?php
session_start();
$_SESSION['loggeduser'] = "astandell6g@washington.edu";
include('dbconnect.php');
function selectTransaksi(){
		debug("masuktrans");
    $conn = connectDB();
    $loggeduid = ($_SESSION['loggeduser']);
    $sql = "SELECT no_invoice, nama_toko, tanggal, waktu_bayar, alamat_kirim, biaya_kirim, no_resi, nama_jasa_kirim FROM tokokeren.transaksi_shipped WHERE email_pembeli=$loggeduid";
    $result = pg_query($conn, $sql);
    return $result;
}

function cekStatus($idStatus){
	if ($idStatus == 1){
		return "Transaksi dilakukan";
	} else if ($idStatus == 2) {
		return "Barang sudah dibayar";
	} else if ($idStatus == 3) {
		return "Barang sudah dikirim";
	} else if ($idStatus == 4) {
		return "Barang sudah diterima";
	}
}

function cekStatusPulsa($idStatus){
	if ($idStatus == 1){
		return "Belum dibayar";
	} else if ($idStatus == 2) {
		return "Sudah dibayar";
	}
}

function fetchNamaPulsa($kodeProduk){
	$query = "SELECT * FROM tokokeren.produk
						WHERE kode_produk = '$kodeProduk'";

	$result = pg_query($query);
	if (!$result) {
			echo "Problem with query " . $query . "<br/>";
			echo pg_last_error();
			exit();
	}

	$myrow = pg_fetch_assoc($result);

	return $myrow['nama'];
}

function fetchNamaProduk($kodeProduk){
	$query = "SELECT * FROM tokokeren.produk
						WHERE kode_produk = '$kodeProduk'";

	$result = pg_query($query);
	if (!$result) {
			echo "Problem with query " . $query . "<br/>";
			echo pg_last_error();
			exit();
	}

	$myrow = pg_fetch_assoc($result);

	return $myrow['nama'];
}

function fetchListItems($noInvoice){
	$query = "SELECT * FROM tokokeren.list_item
						WHERE no_invoice= '$noInvoice'";

	$result = pg_query($query);
	if (!$result) {
			echo "Problem with query " . $query . "<br/>";
			echo pg_last_error();
			exit();
	}

	$res = "";
	while($myrow = pg_fetch_assoc($result)) {
		$res = $res.'<tr>
				<td aria-label="Nama Produk">'.fetchNamaProduk($myrow['kode_produk']).'</td>
				<td aria-label="Berat">'.($myrow['berat']).'</td>
				<td aria-label="Kuantitas">'.($myrow['kuantitas']).'</td>
				<td aria-label="Harga">Rp'.($myrow['harga']).'</td>
				<td aria-label="Subtotal">Rp'.($myrow['sub_total']).'</td>
				<td aria-label="Ulas"><button>Ulas</button></td>
		</tr>'
	}
	return $res;

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
	<link rel="stylesheet" type="text/css" href="src/css/transaction-history.css">
	<link rel="stylesheet" type="text/css" href="src/css/navbar.css">
	<!-- insert more css file here -->

</head>
<body>
	<?php
		include("include/navbar.php");
	?>
	<div class="container">
		<div class="row">
			<div class="wrap">
				<h1>TRANSACTION HISTORY <?php
						$myrow = selectTransaksi();
						while($myrow){
							debug($myrow['nama_toko']);
						}
				?></h1>
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
									<?php
									$query = "SELECT * FROM tokokeren.transaksi_pulsa
														WHERE email_pembeli = '$loggeduid'";

									$result = pg_query($query);
									if (!$result) {
											echo "Problem with query " . $query . "<br/>";
											echo pg_last_error();
											exit();
									}

									$i = 1000;
									while($myrow = pg_fetch_assoc($result)) {
											echo('<div class="panel panel-default">
												<div class="panel-heading" role="tab" id="heading'.$i.'">
													<h4 class="panel-title">
														<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$i.'" aria-expanded="false" aria-controls="collapse'.$i.'">
															<i class="more-less glyphicon glyphicon-plus"></i>
															Invoice Number '.($myrow['no_invoice']).'<br>Nama produk '.fetchNamaPulsa($myrow['kode_produk']).'<br>
														</a>
													</h4>
												</div>
												<div id="collapse'.$i.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading'.$i.'">
													<div class="panel-body">
														<b>Detail</b><br>
														Tanggal = '.($myrow['tanggal']).'<br>
														Status = '.(cekStatusPulsa($myrow['status'])).'<br>
														Total bayar = '.($myrow['total_bayar']).'<br>
														Nominal = '.($myrow['nominal']).'<br>
														Nomor = '.($myrow['nomor']).'<br>
													</div>
												</div>
											</div>');
											$i++;
											//echo ("<tr><td>".$myrow['no_invoice']."</td><td>".($myrow['nama_toko'])."</td><td>".$myrow['alamat_kirim']."</td><td>".($myrow['tanggal'])."</td></tr>");
									}
									?>



								</div><!-- panel-group -->
							</div>
						</li>

						<li data-content="new">
							<div class="container demo">


								<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">

									<?php
									$query = "SELECT * FROM tokokeren.transaksi_shipped
														WHERE email_pembeli = '$loggeduid'";

									$result = pg_query($query);
									if (!$result) {
											echo "Problem with query " . $query . "<br/>";
											echo pg_last_error();
											exit();
									}

									$i2 = 2000;
									while($myrow = pg_fetch_assoc($result)) {
											echo('<div class="panel panel-default">
												<div class="panel-heading" role="tab" id="heading'.$i2.'">
													<h4 class="panel-title">
														<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$i2.'" aria-expanded="false" aria-controls="collapse'.$i2.'">
															<i class="more-less glyphicon glyphicon-plus"></i>
															Invoice Number '.($myrow['no_invoice']).'
														</a>
													</h4>
												</div>
												<div id="collapse'.$i2.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading'.$i2.'">
													<div class="panel-body">
														<b>Detail</b><br>
														<table>
															<thead>
																<tr>
																	<th>Nama Produk</th>
																	<th>Berat</th>
																	<th>Kuantitas</th>
																	<th>Harga</th>
																	<th>Subtotal</th>
																	<th>Ulas</th>
																</tr>
															</thead>
															<tbody></tbody>
														</table>
													</div>
												</div>
											</div>');
											$i2++;
									}
									?>

								</div><!-- panel-group -->
							</div>
						</li>

						<li data-content="store">
							<div class="container demo">


								<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
									<?php
									$query = "SELECT * FROM tokokeren.transaksi_shipped
														WHERE email_pembeli = '$loggeduid'";

									$result = pg_query($query);
									if (!$result) {
											echo "Problem with query " . $query . "<br/>";
											echo pg_last_error();
											exit();
									}

									$i3 = 3000;
									while($myrow = pg_fetch_assoc($result)) {
											echo('<div class="panel panel-default">
												<div class="panel-heading" role="tab" id="heading'.$i3.'">
													<h4 class="panel-title">
														<a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$i3.'" aria-expanded="false" aria-controls="collapse'.$i3.'">
															<i class="more-less glyphicon glyphicon-plus"></i>
															Invoice Number '.($myrow['no_invoice']).'<br>Bought on '.($myrow['nama_toko']).'<br>
														</a>
													</h4>
												</div>
												<div id="collapse'.$i3.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading'.$i3.'">
													<div class="panel-body">
														<b>Detail</b><br>
														Nama Toko = '.($myrow['nama_toko']).'<br>
														Status = '.(cekStatus($myrow['status'])).'<br>
														Total bayar = '.($myrow['total_bayar']).'<br>
														Alamat kirim = '.($myrow['alamat_kirim']).'<br>
														Biaya kirim = '.($myrow['biaya_kirim']).'<br>
														Nomor resi = '.($myrow['no_resi']).'<br>
														Jasa kirim = '.($myrow['nama_jasa_kirim']).'<br>
														<button>Ulas</button>
													</div>
												</div>
											</div>');
											$i3++;
											//echo ("<tr><td>".$myrow['no_invoice']."</td><td>".($myrow['nama_toko'])."</td><td>".$myrow['alamat_kirim']."</td><td>".($myrow['tanggal'])."</td></tr>");
									}
									?>


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



	<script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
	<script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
	<script type="text/javascript" src="src/js/script.js"></script>
	<script type="text/javascript" src="src/js/transaction-history.js"></script>
	<script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
	<!-- insert more js file here -->
</body>
</html>
