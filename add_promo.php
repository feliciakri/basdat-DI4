<?php
    session_start();
    include "dbconnect.php";
    $conn = connectDB();

    $sql = "SET search_path TO tokokeren";
    $result = pg_query($conn, $sql);

    $_SESSION['loggeduser'] = "UcokBaba@FooBar.my";

    
    parse_str(file_get_contents("php://input"), $_POST);
    if(isset($_POST)) {
        if(isset($_POST['command'])) {
            if($_POST['command'] == 'addPromo') {
                $id = getId();
                $deskripsi =  pg_escape_string($_POST['deskripsi']);
                $periodeAwal =  pg_escape_string($_POST['periodeAwal']);
                $periodeAkhir =  pg_escape_string($_POST['periodeAkhir']);
                $kodePromo =  pg_escape_string($_POST['kodePromo']);
                $kategori =  pg_escape_string($_POST['kategori']);
                $subKategori =  pg_escape_string($_POST['subKategori']);

                if($deskripsi == "") {
                    $_SESSION['error']['deskripsiKosong'] = "Kolom deskripsi tidak boleh kosong";
                }

                if($periodeAwal == "") {
                    $_SESSION['error']['periodeAwalKosong'] = "Kolom periode awal tidak boleh kosong";
                }
                
                if($periodeAkhir == "") {
                    $_SESSION['error']['periodeAkhirKosong'] = "Kolom periode akhir tidak boleh kosong";
                }

                if(strtotime($periodeAwal) > strtotime($periodeAkhir)) {
                    $_SESSION['error']['periodeInvalid'] = "Periode awal harus < periode akhir";   
                }

                if($kodePromo == "") {
                    $_SESSION['error']['kodeKosong'] = "Kolom kode promo tidak boleh kosong";
                }

                if($kategori == "Choose one") {
                    $_SESSION['error']['kategoriKosong'] = "Harus pilih salah satu kategori";
                }

                if($subKategori == "Choose one") {
                    $_SESSION['error']['subkategoriKosong'] = "Harus pilih salah satu subkategori";
                }

                if (isset($_SESSION['error'])) {
                    echo "<br><br><br>";
                    foreach ($_SESSION['error'] as $message) {
                        echo "<div class='alert alert-danger text-center alert-dismissible fade in' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>".$message."</div>";
                    } 
                } else {
                    $sql = "INSERT INTO promo (id, deskripsi, periode_awal, periode_akhir, kode)
                            values ('$id', '$deskripsi', '$periodeAwal', '$periodeAkhir', '$kodePromo')";
                    $result = pg_query($conn, $sql);

                    $sql = "SELECT kode_produk FROM shipped_produk
                            WHERE kategori = '$subKategori'";
                    $result = pg_query($conn, $sql);
                    if (pg_num_rows($result) > 0) {
                        while($row = pg_fetch_assoc($result)) {
                            $insertSql = "INSERT INTO promo_produk (id_promo, kode_produk)
                                          VALUES ('$id', '$row[kode_produk]')";
                            $query = pg_query($conn, $insertSql);
                            if(!$query) {
                                $_SESSION['message']="ERROR";
                            }
                        }
                    }

                    if($result){
                        $_SESSION['message']="Promo Berhasil Ditambahkan";
                        header("location: home.php");
                    } else{
                        $_SESSION['message']='Operasi Gagal';
                        header("location: add_promo.php");
                        exit();
                    }
                }

                if (isset($_SESSION['message'])) {
                    if ($_SESSION['message'] =="Jasa Kirim Berhasil Ditambahkan") {
                        echo "<div class='alert alert-success text-center alert-dismissible fade in' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>".$_SESSION['message']."</div>";
                    }
                    if ($_SESSION['message'] =="Operasi Gagal") {
                        echo "<div class='alert alert-danger text-center alert-dismissible fade in' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>".$_SESSION['message']."</div>";
                    }
                    
                }
                unset($_SESSION['message']);
                unset($_SESSION['error']);
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
	            <form id="formTambahPromo" action="add_promo.php" method="post">
                    <div class="form-group">
                        <label for="inputDeskripsiPromo" class="control-label">Deskripsi</label>
                        <input id="inputDeskripsiPromo" class="form-control" name="deskripsi"></input>
                    </div>
				    <div class="form-group">
				        <label for="inputPeriodeAwal">Periode Awal</label>
				        <input type="date" class="form-control" id="inputPeriodeAwal" name="periodeAwal">
				    </div>
                    <div class="form-group">
                        <label for="inputPeriodeAkhir">Periode Akhir</label>
                        <input type="date" class="form-control" id="inputPeriodeAkhir" name="periodeAkhir">
                    </div>
				    <div class="form-group">
				        <label for="inputLamaKirim">Kode Promo</label>
				        <input type="text" class="form-control" id="inputKodePromo" name="kodePromo" placeholder="kodePromo">
				    </div>
                    <div class="form-group">
                        <label for="inputKategori">Kategori</label>
                        <select class="form-control" id="inputKategori" name="kategori">
                            <option>Choose one</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="inputSubKategori">Sub Kategori</label>
                        <select class="form-control" id="inputSubKategori" name="subKategori">
                            <option>Choose one</option>
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
<script>
    $(document).ready(function() {
        $.post("kategori.php", {'command': 'getKategori'}, function(response) {
            $('#inputKategori').html(response);
        });

        $('#inputKategori').change(function() {
            var kategori = $('#inputKategori').val();
            $.post("kategori.php", {'command': 'getSubkategori', 'kategori': kategori}, function(response) {
                $('#inputSubKategori').html(response);
            });
        });
    });
</script>
</body>
</html>                                		