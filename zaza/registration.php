<?php
    session_start();
    include('dbconnect.php');
  
    function register() {
        $conn = connectDB();

        console.log("3333");

        $email = pg_escape_string($_POST['email']);
        $password = pg_escape_string($_POST['password']);
        $nama = pg_escape_string($_POST['nama']);
        $jenis_kelamin = pg_escape_string($_POST['jenis_kelamin']);
        $tgl_lahir = pg_escape_string($_POST['tgl_lahir']);
        $no_telp = pg_escape_string($_POST['no_telp']);
        $alamat = pg_escape_string($_POST['alamat']);

        console.log("heyy");

        $sql = "INSERT into pengguna(email, password, nama, jenis_kelamin, tgl_lahir, no_telp, alamat) values ('$email', '$password', '$nama', '$jenis_kelamin', '$tgl_lahir', '$no_telp', '$alamat')";
        
        if($result = pg_query($conn, $sql)) {
            print "Data added.<br/>";
            header("Location: registration.php");
        } else {
            die("Error: $sql");
        }

        pg_close($conn);
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if($_POST['command'] === 'register') {
            register();
        }
    }

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <title>Home</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <link rel="stylesheet" type="text/css" href="home.css">
</head>
<body>
    <div class="text-center">
        <div class="jumbotron">
            <h2>Sudahkah Anda #keren hari ini?</h2>
            <button type="button" class="btn btn-info" data-toggle="modal" data-target="#daftarModal">Register</button>
            <button type="submit" class="btn btn-info" data-toggle="modal" data-target="#loginModal">Log in</button>
            <br><br>
            <h5>#KerenAdalahHakSegalaBangsa</h5>
        </div>
    </div>
    <div class="modal fade" id="daftarModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="daftarModalLabel">Form Pendaftaran Pengguna<h4>
                </div>
            <div class="modal-body">
                <form action="registration.php" method="POST">
                    <div class="form-group">
                        <label for="email">E-mail</label>
                        <input type="text" class="form-control" id="insert-email" name="email" placeholder="E-mail Anda">
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="text" class="form-control" id="insert-password" name="password" placeholder="Password Anda">
                    </div>
                    <div class="form-group">
                        <label for="re-password">Ulangi Password</label>
                        <input type="text" class="form-control" id="re-password" name="re-password" placeholder="Masukkan kembali password Anda">
                    </div>
                    <div class="form-group">
                        <label for="nama">Nama Lengkap</label>
                        <input type="text" class="form-control" id="insert-nama" name="nama" placeholder="Masukkan nama">
                    </div>
                    <div class="form-group">
                        <label for="jenis_kelamin">Jenis Kelamin</label><br>
                        <select classs="form-control" id="insert-jenis-kelamin" name="jenis_kelamin">
                            <option value="L">Laki-laki</option>
                            <option value="P">Perempuan</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="tgl_lahir">Tanggal Lahir</label>
                        <input type="text" class="form-control" id="insert-alamat" name="tgl_lahir" placeholder="Masukkan tanggal lahir dengan format dd/mm/yy">
                    </div>
                    <div class="form-group">
                        <label for="no_telp">Nomor Telepon</label>
                        <input type="text" class="form-control" id="insert-no-telp" name="no_telp" placeholder="Nomor telepon yang dapat dihubungi">
                    </div>
                    <div class="form-group">
                        <label for="alamat">Alamat</label>
                        <input type="text" class="form-control" id="insert-alamat" name="alamat" placeholder="Alamat kediaman Anda">
                    </div>
                        <input type="hidden" id="insert-command" name="command" value="register">
                        <button type="submit" class="btn btn-info">Daftar</button>
                </form>
                </div>
            </div>
        </div>  
    </div>
    <div class="modal fade" id="loginModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="loginModalLabel">Login<h4>
                </div>
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <label for="email">E-mail</label>
                        <input type="text" class="form-control" id="insert-email" name="email" placeholder="E-mail Anda">
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="text" class="form-control" id="insert-password" name="password" placeholder="Password Anda">
                    </div>
                        <input type="hidden" id="insert-command" name="command">
                        <button type="submit" class="btn btn-info">Login</button>
                </form>
                </div>
            </div>
        </div>  
    </div>
</body>