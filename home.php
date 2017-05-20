<?php
    session_start();
    include('dbconnect.php');
    
    function debug($msg) {
       $msg = str_replace('"', '\\"', $msg); // Escaping double quotes 
        echo "<script>console.log(\"$msg\")</script>";
    }

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
                echo '<script language="javascript">alert("Alamat email ini sudah terdaftar, harap ganti dengan alamat email lain")</script>';
            } else {
                $sql = "INSERT into pengguna(email, password, nama, jenis_kelamin, tgl_lahir, no_telp, alamat) values ('$email', '$password', '$nama', '$jenis_kelamin', '$tgl_lahir', '$no_telp', '$alamat')";    
                if($result = pg_query($conn, $sql)) {
                    echo '<script language="javascript">alert("Berhasil daftar. Masuk ke halaman utama...")</script>';
                    //header("Location: ../homeOther.php");
                } else {
                    die("Error: $sql");
                }
            }
        }
        pg_close($conn);
    }

    function logging() {
        $conn = connectDB();

        $email = pg_escape_string($_POST['email']);
        $password = pg_escape_string($_POST['password']);        
        
        $set = "SET search_path TO TOKOKEREN";
        if($result = pg_query($conn, $set)) {
            $checkEmail = "SELECT * FROM pengguna WHERE password = '$password' AND email = '$email'";
            $checkResult = pg_query($conn, $checkEmail);
            if(pg_num_rows($checkResult) > 0) {
                echo '<script language="javascript">alert("GA MASUK")</script>';
                $checkAdmin = "SELECT * FROM pelanggan WHERE email = '$email'";
                $checkResult1 = pg_query($conn, $checkAdmin);
                if(pg_num_rows($checkResult1) > 0) {
                    echo '<script language="javascript">alert("KE SINI NIH")</script>';
                    $checkPenjual = "SELECT * FROM pelanggan WHERE email = '$email' AND is_penjual = TRUE";
                    $checkResult2 = pg_query($conn, $checkPenjual);
                    if(pg_num_rows($checkResult2)  > 0) {
                        echo '<script language="javascript">alert("JUAL")</script>';
                        $_SESSION['loggedrole'] = "penjual";
                        $_SESSION['loggeduser'] = $email;
                        header("Location: home.php");
                    } else if(pg_num_rows($checkResult2)  < 1){
                        echo '<script language="javascript">alert("BELI")</script>';
                        $_SESSION['loggedrole'] = "pembeli";
                        $_SESSION['loggeduser'] = $email;
                        header("Location:home.php");
                    }
                } else {
                    echo '<script language="javascript">alert("ADMIN")</script>';
                    $_SESSION['loggedrole'] = "admin";
                    $_SESSION['loggeduser'] = $email;
                    header("Location: home.php");
                }
                echo '<script language="javascript">alert("Berhasil login. Masuk ke halaman utama...")</script>';
            } else {
                echo '<script language="javascript">alert("Login error : email/password salah")</script>';
            }
        }
        pg_close($conn);
    }

    if (isset ($_REQUEST['command']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
        if($_POST['command'] === 'register') {
            register();
        } else if($_POST['command'] === 'logging') {
            logging();
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
		<link rel="stylesheet" type="text/css" href="src/css/navbar.css">
		<script type="text/javascript" src="src/js/navbar.js"></script>
	</head>
	<body>
		<?php
			include('include/navbar.php');
		?>
		
	    <div class="modal fade" id="daftarModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
	        <div class="modal-dialog" role="document">
	            <div class="modal-content">
	                <div class="modal-header">
	                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	                    <h4 class="modal-title" id="daftarModalLabel">Form Pendaftaran Pengguna</h4>
	                    <h6>Mohon mengisi form sesuai dengan ketentuan. Tidak boleh ada field yang kosong. </h6>
	                </div>
	            <div class="modal-body">
	                <form name="form-regis" action="home.php" method="POST">
	                    <div class="form-group">
	                        <label for="email">E-mail</label>
	                        <input type="text" class="form-control" id="insert-email" name="email" placeholder="Alamat email yang valid memiliki format alamat@contoh.com" required pattern="^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$" title="Masukkan email dengan format alamat@contoh.com atau alamat@mail.ac.id">
	                    </div>
	                    <div class="form-group">
	                        <label for="password">Password</label>
	                        <input type="password" class="form-control" id="insert-password" name="password" placeholder="Password minimal terdiri atas 6 karakter" required pattern=".{6,}" title="Password minimal terdiri atas 6 karakter">
	                    </div>
	                    <div class="form-group">
	                        <label for="re-password">Ulangi Password</label>
	                        <input type="password" class="form-control" id="re-password" name="re-password" placeholder="Masukkan kembali password Anda" required pattern=".{6,}" title="Password harus sama" onchange="validatePassword()">
	                    </div>
	                    <div class="form-group">
	                        <label for="nama">Nama Lengkap</label>
	                        <input type="text" class="form-control" id="insert-nama" name="nama" placeholder="Masukkan nama lengkap Anda" required>
	                    </div>
	                    <div class="form-group">
	                        <label for="jenis_kelamin">Jenis Kelamin</label><br>
	                        <select class="form-control" id="insert-jenis-kelamin" name="jenis_kelamin" required>
	                            <option value="">Pilih satu</option>
	                            <option value="L">Laki-laki</option>
	                            <option value="P">Perempuan</option>
	                        </select>
	                    </div>
	                    <div class="form-group">
	                        <label for="tgl_lahir">Tanggal Lahir</label>
	                        <input type="text" class="form-control" id="insert-alamat" name="tgl_lahir" placeholder="Tanggal lahir yang valid memiliki format dd/mm/yyyy" required pattern="(^(((0[1-9]|1[0-9]|2[0-8])[\/](0[1-9]|1[012]))|((29|30|31)[\/](0[13578]|1[02]))|((29|30)[\/](0[4,6,9]|11)))[\/](19|[2-9][0-9])\d\d$)|(^29[\/]02[\/](\d\d|[0-9][0-9]))" title="Tanggal lahir yang valid memiliki format dd/mm/yyyy">
	                    </div>
	                    <div class="form-group">
	                        <label for="no_telp">Nomor Telepon</label>
	                        <input type="text" class="form-control" id="insert-no-telp" name="no_telp" placeholder="Nomor telepon yang dapat dihubungi memiliki maksimal 12 digit" required pattern="(08)(\d{10})" title="Masukkan 12 digit angka diawali 08">
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
	                <form action="home.php" method="POST">
	                    <div class="form-group">
	                        <label for="email">E-mail</label>
	                        <input type="text" class="form-control" id="insert-email" name="email" placeholder="E-mail Anda" required>
	                    </div>
	                    <div class="form-group">
	                        <label for="password">Password</label>
	                        <input type="password" class="form-control" id="insert-password" name="password" placeholder="Password Anda" required>
	                    </div>
	                        <input type="hidden" id="insert-command" name="command" value="logging">
	                        <button type="submit" class="btn btn-info">Login</button>
	                </form>
	                </div>
	            </div>
	        </div>  
	    </div>
	    <script type="text/javascript">
	        function validatePassword() {
	            var a = document.forms["form-regis"]["password"].value;
	            var b = document.forms["form-regis"]["re-password"].value;
	            if(!(a == b)) {
	                alert("Password harus sama");
	                return false;
	            }
	            return true;
	        }
	    </script>
	    <script type="text/javascript">
	            $('[data-toggle="tooltip"]').tooltip();
	    </script>
	    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
	    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
		
		<script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
		<script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
		<script type="text/javascript" src="src/js/script.js"></script>
		<script type="text/javascript" src="src/js/navbar.js"></script>
		<script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
	</body>
</html>

<!--<!DOCTYPE html>
<html lang="en">
	<head>
		<title>TokoKeren - Dinego Aja Shay, Pasti Cincay!</title>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" type="text/css" href="src/css/styleBoot.css">	
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	</head>
	<body>
		<div>
			<nav class="navbar navbar-default">
			<div class="container-fluid">
				<ul class="nav navbar-nav">
					<li><a href="index" class="brand-logo"><img src="src/img/logo-tokokeren-horizontal.png" height="32px"></a></li>
					<li><a href="">Buat kategori</a></li>
					<li><a href="">Buat Jasa Kirim</a></li>
					<li><a href="">Buat Promo</a></li>
					<li><a href="">Tambah Produk</a></li>
				</ul>
				<ul class="nav navbar-nav navbar-right">
					<li><a href="">Anda login sebagai admin | </a></li>
					<li><a href="zaza/registration.php"><strong>Logout</strong></a></li>
				</ul>
			</div>
			</nav>	
		</div>
	</body>
</html>
-->