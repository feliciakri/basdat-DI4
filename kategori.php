<?php
	session_start();
	include 'dbconnect.php';
    $conn = connectDB();

    $sql = "SET search_path TO tokokeren";
    $result = pg_query($conn, $sql);

	if ($_SERVER['REQUEST_METHOD'] === 'POST') {
		$command = $_POST['command'];
		if($command == "getKategori") {
			$sql = "SELECT * FROM kategori_utama";
	    	$result = pg_query($conn, $sql);
	    	if (pg_num_rows($result) > 0) {
	    		echo "<option>Choose one</option>";
		        while($row = pg_fetch_assoc($result)) {
		        	echo "<option value='$row[kode]'>$row[nama]</option>";
		        }
		    }
		} elseif($command == "getSubkategori") {
			$kategori = $_POST['kategori'];
			if($kategori != null) {
				$sql = "SELECT S.kode, S.nama FROM kategori_utama K, sub_kategori S
					WHERE K.kode = S.kode_kategori
					AND S.kode_kategori = '$kategori'";
		    	$result = pg_query($conn, $sql);
		    	if (pg_num_rows($result) > 0) {
		    		echo "<option>Choose one</option>";
			        while($row = pg_fetch_assoc($result)) {
			        	echo "<option value='$row[kode]'>$row[nama]</option>";
			        }
			    }
			}
		}
	}

    pg_close($conn);
?>
