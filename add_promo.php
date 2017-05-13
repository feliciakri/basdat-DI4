<?php
    include "dbconnect.php";
    $conn = connectDB();

    $sql = "SET search_path TO tokokeren";
    $result = pg_query($conn, $sql);
    
    parse_str(file_get_contents("php://input"), $_POST);
    if(isset($_POST)) {
        if(isset($_POST['command'])) {
            if($_POST['command'] == 'addPromo') {
                $id = getId();
                $deskripsiPromo =  pg_escape_string($_POST['deskripsiPromo']);
                $periodeAwal =  pg_escape_string($_POST['periodeAwal']);
                $periodeAkhir =  pg_escape_string($_POST['periodeAkhir']);
                $kodePromo =  pg_escape_string($_POST['kodePromo']);
                $kategori =  pg_escape_string($_POST['kategori']);
                $subKategori =  pg_escape_string($_POST['subKategori']);
                $sql = "INSERT INTO JASA_KIRIM (deskripsiPromo, periodeAwal, periodeAkhir, kodePromo, kategori, subKategori) values ('$id', '$periodeAwal', '$periodeAkhir', '$kodePromo', '$kategori', '$subKategori')";
                $result = pg_query($conn, $sql); 
            }
        }
    }

    function getId(){
        $query = "SELECT * FROM PROMO";
        $num_data = pg_num_rows(pg_query($query))+1;
  
  

        if ($num_data > 9){
        $new_id = "R000".$num_data."";
        } else {
        $new_id = "R0000".$num_data.""; 
        }
  
        return $new_id;
        }
?>




<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tambah Promo</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
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
                <li><a href=#>Home</a></li>
                <li><a href=#>Tambah Jasa Kirim</a></li>
                <li class="active"><a href=#>Tambah Promo</a></li>
            </ul>
        </div>
    </div>
</nav>
<div class="container">
    <div class="jumbotron">
        <h2 class="text-center">Tambah Promo</h2>
        <div class="row">
	        <div class="col-sm-12">
	            <form id="formTambahPromo">
                    <div class="form-group">
                        <label for="inputDeskripsiPromo" class="control-label">Deskripsi</label>
                        <textarea id="inputDeskripsiPromo" class="form-control" name="deskripsiPromo" form="formTambahFrom" required></textarea>
                    </div>
				    <div class="form-group">
				        <label for="inputPeriodeAwal">Periode Awal</label>
				        <input type="date" class="form-control" id="inputPeriodeAwal" name="periodeAwal" required>
				    </div>
                    <div class="form-group">
                        <label for="inputPeriodeAkhir">Periode Akhir</label>
                        <input type="date" class="form-control" id="inputPeriodeAkhir" name="periodeAkhir" required>
                    </div>
				    <div class="form-group">
				        <label for="inputLamaKirim">Kode Promo</label>
				        <input type="text" class="form-control" id="inputKodePromo" name="kodePromo" placeholder="kodePromo" required>
				    </div>
                    <div class="form-group">
                        <label for="inputKategori">Kategori</label>
                        <select class="form-control" id="inputKategori" name="kategori" required>
                            <option>...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="inputSubKategori">Sub Kategori</label>
                        <select class="form-control" id="inputSubKategori" name="subKategori" required>
                            <option>...</option>
                        </select>
                        <input type="hidden" name="command" value="addPromo">
                    </div>
				    <button type="submit" class="btn btn-primary">Submit</button>
				</form>
	        </div>
	    </div>
    </div>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</body>
</html>                                		