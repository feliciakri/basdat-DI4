<html>
    <body>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    Friend ID
                </td>
                <td>
                    First Name
                </td>
                <td>
                    Surname
                </td>
                <td>
                    Email Address
                </td>
            </tr>
        <?php
        include('dbconnect.php');
        $none = connectDB();
        $loggeduid = ("astandell6g@washington.edu");
        $query = "SELECT * FROM tokokeren.transaksi_shipped
                  WHERE email_pembeli = '$loggeduid'";

        $result = pg_query($query);
        if (!$result) {
            echo "Problem with query " . $query . "<br/>";
            echo pg_last_error();
            exit();
        }

        while($myrow = pg_fetch_assoc($result)) {
            echo ("<tr><td>".$myrow['no_invoice']."</td><td>".($myrow['nama_toko'])."</td><td>".$myrow['alamat_kirim']."</td><td>".($myrow['tanggal'])."</td></tr>");
        }
        ?>
        </table>
    </body>
</html
