<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tambah Jasa Kirim</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
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
                <li class="active"><a href=#>Tambah Jasa Kirim</a></li>
            </ul>
        </div>
    </div>
</nav>
<div class="container">
    <div class="jumbotron">
        <h2 class="text-center">Tambah Jasa Kirim</h2>
        <div class="row">
	        <div class="col-sm-12">
	            <form id="formTambahJasaKirim">
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