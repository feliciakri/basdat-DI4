<?php
    session_start();
    include('dbconnect.php');
  
    function register() {
        $conn = connectDB();

        $email = pg_escape_string($_POST['email']);
        $password = pg_escape_string($_POST['password']);
        $nama = pg_escape_string($_POST['nama']);
        $jenis_kelamin = pg_escape_string($_POST['jenis_kelamin']);
        $tgl_lahir = pg_escape_string($_POST['tgl_lahir']);
        $no_telp = pg_escape_string($_POST['no_telp']);
        $alamat = pg_escape_string($_POST['alamat']);

        $set = "SET search_path TO TOKOKEREN";
        if($result = pg_query($conn, $set)) {
            $checkEmail = "SELECT email FROM pengguna WHERE email = '$email'";
            $checkResult = pg_query($checkEmail);

            if(pg_num_rows($checkResult) > 0) {
                echo '<script language="javascript">alert("Email sudah ada")</script>';
            } else {
                $sql = "INSERT into pengguna(email, password, nama, jenis_kelamin, tgl_lahir, no_telp, alamat) values ('$email', '$password', '$nama', '$jenis_kelamin', '$tgl_lahir', '$no_telp', '$alamat')";    
                if($result = pg_query($conn, $sql)) {
                    print "Data added.<br/>";
                    header("Location: registration.php");
                } else {
                    die("Error: $sql");
                }
            }
        }

        pg_close($conn);
    }

    if (isset ($_REQUEST['command']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
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
  <link rel="stylesheet" type="text/css" href="home.css">
</head>
<body>
    <script>
        function validatePassword() {
            var a = document.forms["form-regis"]["password"].value;
            var b = document.forms["form-regis"]["re-password"].value;
            if(!(a == b)) {
                alert("Password salah");
                return false;
            }
            return true;
        }
    </script>
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
                    <h4 class="modal-title" id="daftarModalLabel">Form Pendaftaran Pengguna</h4>
                </div>
            <div class="modal-body">
                <form name="form-regis" action="registration.php" method="POST">
                    <div class="form-group">
                        <label for="email">E-mail</label>
                        <input type="text" class="form-control" id="insert-email" name="email" placeholder="E-mail Anda" required pattern="^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$" title="Masukkan email dengan format alamat@domain.com atau alamat@domain.ac.id">
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" class="form-control" id="insert-password" name="password" placeholder="Password Anda" required pattern=".{6,}" title="Password minimal terdiri atas 6 karakter">
                    </div>
                    <div class="form-group">
                        <label for="re-password">Ulangi Password</label>
                        <input type="password" class="form-control" id="re-password" name="re-password" placeholder="Masukkan kembali password Anda" required pattern=".{6,}" title="Password harus sama" onchange="validatePassword()">
                    </div>
                    <div class="form-group">
                        <label for="nama">Nama Lengkap</label>
                        <input type="text" class="form-control" id="insert-nama" name="nama" placeholder="Masukkan nama" required>
                    </div>
                    <div class="form-group">
                        <label for="jenis_kelamin">Jenis Kelamin</label><br>
                        <select classs="form-control" id="insert-jenis-kelamin" name="jenis_kelamin" required>
                            <option value="L">Laki-laki</option>
                            <option value="P">Perempuan</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="tgl_lahir">Tanggal Lahir</label>
                        <input type="text" class="form-control" id="insert-alamat" name="tgl_lahir" placeholder="Masukkan tanggal lahir dengan format dd/mm/yyyy" required pattern="(^(((0[1-9]|1[0-9]|2[0-8])[\/](0[1-9]|1[012]))|((29|30|31)[\/](0[13578]|1[02]))|((29|30)[\/](0[4,6,9]|11)))[\/](19|[2-9][0-9])\d\d$)|(^29[\/]02[\/](\d\d|[0-9][0-9]))" title="dd/mm/yyyy">
                    </div>
                    <div class="form-group">
                        <label for="no_telp">Nomor Telepon</label>
                        <input type="text" class="form-control" id="insert-no-telp" name="no_telp" placeholder="Nomor telepon yang dapat dihubungi" required pattern="(08)(\d{10})" title="Masukkan 12 digit angka diawali 08">
                    </div>
                    <div class="form-group">
                        <label for="alamat">Alamat</label>
                        <input type="text" class="form-control" id="insert-alamat" name="alamat" placeholder="Alamat kediaman Anda" required>
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
                    <h4 class="modal-title" id="loginModalLabel">Login</h4>
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
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="js.js"></script>
</body>
</html>