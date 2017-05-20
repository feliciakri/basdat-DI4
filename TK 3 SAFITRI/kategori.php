<?php
	session_start();
	include 'dbconnect.php';

	function addCategory() {
		$conn = connectDB();

		$kode_kategori = pg_escape_string($_POST['kode-kategori']);
		$nama_kategori = pg_escape_string($_POST['nama-kategori']);

		$set = "SET search_path TO TOKOKEREN";
        if($result = pg_query($conn, $set)) {
            $checkCategory = "SELECT * FROM kategori_utama WHERE kode = '$kode_kategori'";
            $checkResult = pg_query($conn, $checkCategory);

            if(pg_num_rows($checkResult) > 0) {
                echo '<script language="javascript">alert("Kategori sudah ada, harap mengganti input kode dan nama kategori")</script>';
            } else {
            	$sqlCat = "INSERT into kategori_utama(kode, nama) values ('$kode_kategori', '$nama_kategori')";
            	$resCat = pg_query($conn, $sqlCat);

            	$counter = 1;
            	$sub_nama = 'sub-nama-' . $counter;
            	$sub_kode = 'sub-kode-' . $counter;

            	while(isset($_POST[$sub_nama]) && isset($_POST[$sub_kode])) {
            		$sname = pg_escape_string($_POST[$sub_nama]);
					$scode = pg_escape_string($_POST[$sub_kode]);

					$checkSub = "SELECT * FROM sub_kategori WHERE kode = '$scode'";
        			$checkSubRes = pg_query($conn, $checkSub);
            		if(pg_num_rows($checkSubRes) > 0) {
            			echo '<script language="javascript">alert("Sub kategori sudah ada, harap mengganti dengan sub kategori yang belum ada di database kami")</script>';
            			$sqlDel = "DELETE FROM kategori_utama WHERE kode = '$kode_kategori'";
            			$resDel = pg_query($conn, $sqlDel);
            		} else {
            			$sqlSub = "INSERT into sub_kategori(kode, kode_kategori, nama) values ('$scode', '$kode_kategori', '$sname')";
            			$resSub = pg_query($conn, $sqlSub);
            		}

            		$counter+= 1;
            		$sub_nama = 'sub-nama-' . $counter;
            		$sub_kode = 'sub-kode-' . $counter;

            		echo '<script language="javascript">alert("Berhasil menambahkan kategori dan sub kategori!")</script>';
            	}
            }
        }
        pg_close($conn);
	}

	if (isset ($_REQUEST['command']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
        if($_POST['command'] === 'addCategory') {
            addCategory();
        }
    }
?>
<!DOCTYPE html>
	<html lang="en">
	<head>
		<title>Kategori</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	</head>
	<body>
		<div id="kategoriModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
			<div class="modal-content" role="document">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="daftarModalLabel">Form Membuat Kategori dan Sub Kategori</h4>
				</div>
				<div class="modal-body">
					<form action="kategori.php" method="POST">
						<div class="form-group">
							<label for="kode-kategori">Kode Kategori</label>
							<input type="text" class="form-control" id="insert-kode-kategori" name="kode-kategori" placeholder="Kode kategori" required>
						</div>
						<div class="form-group">
							<label for="nama-kategori">Nama Kategori</label>
							<input type="text" class="form-control" id="insert-nama-kategori" name="nama-kategori" placeholder="Nama kategori" required>
						</div>
						<div class="modal-header">
							<h4 class="modal-title" id="tambahSub">Sub Kategori</h4>
						</div>
						<br>
				       	<div id="tambah-sub">
				            <label for="sub-kategori-1">Sub Kategori 1</label>
					        <div class="content">
					            <span>Nama: <input type="text" id="insert-nama-sub" name="sub-nama-1" required/></span>
					            <span>Kode: <input type="text" id="insert-kode-sub" name="sub-kode-1" required/></span>
					   	    </div>
					        <br>
				        </div>
				        <input type="button" class="btn btn-default" id="more_fields" onclick="add_fields();" value="Tambah Sub Kategori" />
			        	<hr>
			        	<input type="hidden" id="add-category" name="command" value="addCategory">
						<button type="submit" class="btn btn-info">Tambah</button>
			        </form>
		        </div>
		    </div>
		</div>
        <script type="text/javascript">
        	var counter = 1;
			function add_fields() {
			    counter++;
			    var objTo = document.getElementById('tambah-sub');
			    var divtest = document.createElement("div");
			    divtest.innerHTML = '<label for="sub-kategori-' + counter + '">Sub Kategori ' + counter +'</label><div class="content"><span>Nama: <input type="text" id="insert-nama-sub" " name="sub-nama-' + counter + '" required /></span>&nbsp<span>Kode: <input type="text" id="insert-kode-sub" name="sub-kode-' + counter + '" required /></span></div><br>';
			    console.log(counter);
			    objTo.appendChild(divtest);
			}
      
        </script>
	</body>
</html>