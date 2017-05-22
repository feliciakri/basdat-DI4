
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
    <!-- insert more css file here -->

</head>
<body>
		<?php
            include('navbar.php');
        ?>
    <div class="container">
        <div class="row">
            <div class="wrap">
                <h1>PULSA PRODUCT</h1>
                <div class="divider"></div>
            </div>
            <div class="row">
              <?php
              session_start();
              include('dbconnect.php');
              $conn = connectDB();


              parse_str(file_get_contents("php://input"), $_POST);
              function buypulsa(){
                $no_invoice = "V000".rand(1,1000);
                $tanggal = date("Y-m-d");
                $waktu_bayar = date("Y-m-d");;
                $status = '2';
                $email_pembeli= $_SESSION['loggeduser'];
                $nominal = pg_escape_string($_POST['nominalval']);
                $nomor = pg_escape_string($_POST['noHP']);
                $kode_produk = pg_escape_string($_POST['optradio']);
                $sql = "INSERT INTO TRANSAKSI_PULSA (no_invoice, tanggal, waktu_bayar,status, email_pembeli, nominal,nomor,kode_produk)
                values ('$no_invoice','$tanggal', '$waktu_bayar', '$status', '$email_pembeli', '$nominal', '$nomor', '$kode_produk')";
                $result = pg_query($conn, $sql);
                if($result){
                    echo "Transaksi Pulsa Berhasil Ditambahkan";
                }
              }



              if (isset ($_REQUEST['command']) && $_SERVER['REQUEST_METHOD'] === 'POST') {
                  if($_POST['command'] === 'buypulsa') {
                      buypulsa();
                    }
              }
              ?>


              <!-- Products List Start -->
              <?php
              $result = pg_query($conn,"SET SEARCH_PATH TO TOKOKEREN;
              SELECT produk_pulsa.kode_produk as kode, produk.nama as nama, produk.harga as harga, produk.deskripsi as deskripsi, produk_pulsa.nominal as nominal
              FROM produk_pulsa
              INNER JOIN produk ON produk.kode_produk=produk_pulsa.kode_produk;");

              if (!$result) {
                  echo "Problem with query " . $query . "<br/>";
                  echo pg_last_error();
                  exit();
              }
              echo'
              <form id="formpulsa" action="pulsa.php" method="post">
              <table>
              <thead>
              <tr>
              <th>Nama produk</th>
              <th>Kode produk</th>
              <th>Harga</th>
              <th>Deskripsi</th>
              <th>Nominal</th>
              </tr>
              </thead>
              <tbody>';
              while($myrow = pg_fetch_assoc($result)) {
              echo '
              <tr>
                  <td>
                     <div class="radio">
                         <label><input type="radio" id="pulsa'.($myrow['kode']).'" name="optradio">'.($myrow['nama']).'</label>
                     </div>
                   </td>
                  <td>'.($myrow['kode']).'</td>
                  <td>'.($myrow['harga']).'</td>
                  <td>'.($myrow['deskripsi']).'</td>
                  <td><input type="hidden" name="nominalval" value="'.($myrow['nominal']).'">'.($myrow['nominal']).'</td>
              </tr>';
              }
              echo '</tbody>
              </table>';

              ?>

              <br><br>
              Nomor HP : <input type="text" id="inputNoHP" name="noHP" placeholder="Masukkan nomor HP anda disini">
              <input type="hidden" name="command" value="buypulsa">
              <br><button type="submit">Submit</button>
              </form>


            </div><!--End of row1-->
        </div>
    </div>


	<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.3/jquery.easing.min.js"></script>
    <script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
    <script type="text/javascript" src="src/js/script.js"></script>
    <script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
    <!-- insert more js file here -->
</body>
</html>
