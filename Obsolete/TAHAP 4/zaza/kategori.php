<!DOCTYPE html>
	<html lang="en">
	<head>
		<title>Kategori</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
		<link rel="stylesheet" type="text/css" href="home.css">
	</head>
	<body>
		<div  id="kategoriModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
			<div class="modal-content" role="document">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" id="daftarModalLabel">Form Membuat Kategori dan Sub Kategori</h4>
				</div>
				<div class="modal-body">
					<form>
						<div class="form-group">
							<label for="kode-kategori">Kode Kategori</label>
							<input type="text" class="form-control" id="insert-kode-kategori" name="kode-kategori" placeholder="Kode kategori">
						</div>
						<div class="form-group">
							<label for="nama-kategori">Nama Kategori</label>
							<input type="text" class="form-control" id="insert-nama-kategori" name="nama-kategori" placeholder="Nama kategori">
						</div>
						<div class="modal-header">
							<h4 class="modal-title" id="tambahSub">Sub Kategori</h4>
						</div>
						<br>
				       	<div id="tambah-sub">
				            <label for="sub-kategori-1">Sub Kategori 1</label>
					        <div class="content">
					            <span>Nama: <input type="text" name="sub-nama" value="" /></span>
					            <span>Kode: <input type="text" name="sub-kode" value="" /></span>
					   	    </div>
					        <br>
				        </div>
				        <input type="button" class="btn btn-default" id="more_fields" onclick="add_fields();" value="Tambah Sub Kategori" />
			        	<hr>
			        	<input type="hidden" id="add-category" name="command" value="addCategory">
						<button type="submit" class="btn btn-info">Tambah</button>
			        </form>
		        </div>
		    </div>
		</div>
        <script type="text/javascript">
        	var counter = 1;
			function add_fields() {
			    counter++;
			    var objTo = document.getElementById('tambah-sub');
			    var divtest = document.createElement("div");
			    divtest.innerHTML = '<label for="sub-kategori-' + counter + '">Sub Kategori ' + counter +'</label><div class="content"><span>Nama: <input type="text" " name="sub-nama" value="" /></span>&nbsp<span>Kode: <input type="text"  name="sub-kode" value="" /></span></div><br>';
			    
			    objTo.appendChild(divtest);
			}
      
        </script>
	</body>
</html>