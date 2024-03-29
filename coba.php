<?php
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
                $sql = "INSERT INTO JASA_KIRIM (nama, lama_kirim, tarif) values ('$namaJasa', '$lamaKirim', '$inputTarif')";
                $result = pg_query($conn, $sql); 
            }

        }

    }
      if($result){
        $_SESSION['message'] = "JASA KIRIM BERHASIL DITAMBAHKAN";
        header("location: add_jasa_kirim.php");
    }else{
        $error_message = pg_last_error();
        echo "ERROR WITH QUERY: " . $error_message;
        exit();
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
                        <input type="text" class="form-control" id="inputNamaJasa" name="namaJasa" placeholder="Nama" required>
                    </div>
                    <div class="form-group">
                        <label for="inputLamaKirim">Lama Kirim</label>
                        <input type="text" class="form-control" id="inputLamaKirim" name="lamaKirim" placeholder="Lama Kirim" required>
                    </div>
                    <div class="form-group">
                        <label for="inputTarif">Tarif</label>
                        <input type="number" min="0" step=".01" class="form-control" id="inputTarif" name="tarif" placeholder="Tarif" required>
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