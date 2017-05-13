<?php
    session_start();
    include "dbconnect.php";
    $conn = connectDB();

    $sql = "SET search_path TO tokokeren";
    $result = pg_query($conn, $sql);
    
    parse_str(file_get_contents("php://input"), $_POST);
    if(isset($_POST)) {
        if(isset($_POST['command'])) {
            if($_POST['command'] == 'addJasaKirim') {
                $namaJasa =  pg_escape_string($_POST['namaJasa']);
                $lamaKirim =  pg_escape_string($_POST['lamaKirim']);
                $inputTarif =  pg_escape_string($_POST['tarif']);

                if($namaJasa == "") {
                    $_SESSION['error']['namaKosong'] = "Kolom nama jasa kirim tidak boleh kosong";
                } else {
                    $sql = "SELECT * FROM jasa_kirim WHERE nama = $1";
                    $result = pg_query_params($conn, $sql,array($namaJasa));
                    if (pg_num_rows($result) > 0) {
                      $_SESSION['error']['namaDuplikat'] = "Nama jasa kirim harus unik";
                    } 
                }

                if($lamaKirim == "") {
                    $_SESSION['error']['lamaKirimKosong'] = "Kolom lama kirim tidak boleh kosong";
                } else {
                    $waktuPasti = preg_match('/^[1-9][0-9]*$/', $lamaKirim);
                    $rangeWaktu = preg_match('/^[1-9][0-9]* - [1-9][0-9]*$/', $lamaKirim);
                    if(!($waktuPasti or $rangeWaktu)) {
                        $_SESSION['error']['lamaKirimInvalid'] = "Lama kirim merupakan angka > 0";
                    }
                }
                
                if($inputTarif == "") {
                    $_SESSION['error']['tarifKosong'] = "Kolom tarif tidak boleh kosong";
                } elseif(!preg_match('/^[1-9][0-9]*$/', $inputTarif)) {
                    $_SESSION['error']['tarifInvalid'] = "Tarif merupakan angka > 0";
                }

                if (isset($_SESSION['error'])) {
                    foreach ($_SESSION['error'] as $message) {
                        echo "<div class='alert alert-danger text-center alert-dismissible fade in' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span></button>".$message."</div>";
                    } 
                } else {
                    $sql = "INSERT INTO JASA_KIRIM (nama, lama_kirim, tarif) values ('$namaJasa', '$lamaKirim', '$inputTarif')";
                    $result = pg_query($conn, $sql);
                    if($result){
                        $_SESSION['message']="Jasa Kirim Berhasil Ditambahkan";
                    } else{
                        $_SESSION['message']='Operasi Gagal';
                        header("location: add_jasa_kirim.php");
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

    

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tambah Jasa Kirim</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>

<div class="container">
    <div class="jumbotron">
        <h2 class="text-center">Tambah Jasa Kirim</h2>
        <div class="row">
            <div class="col-sm-12">
                <form id="formTambahJasaKirim" action="add_jasa_kirim.php" method="post">
                    <div class="form-group">
                        <label for="inputNamaJasa">Nama</label>
                        <input type="text" class="form-control" id="inputNamaJasa" name="namaJasa" placeholder="Nama">
                    </div>
                    <div class="form-group">
                        <label for="inputLamaKirim">Lama Kirim</label>
                        <input type="text" class="form-control" id="inputLamaKirim" name="lamaKirim" placeholder="Lama Kirim">
                    </div>
                    <div class="form-group">
                        <label for="inputTarif">Tarif</label>
                        <input type="number" step=".01" class="form-control" id="inputTarif" name="tarif" placeholder="Tarif">
                        <input type="hidden" name="command" value="addJasaKirim">
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