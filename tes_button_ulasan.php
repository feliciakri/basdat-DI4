<!DOCTYPE html>
<html>
<head>
	<title>Tes Button Ulasan</title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
</head>
<body>
	<h1>Tes Button Ulasan Produk</h1>
	<p>Print button ulasan di table lihat transaksi shipped dengan kode produk yang sesuai.</p>
	<table>
		<thead>
			<td>Kode Produk</td>
			<td>Nama Produk</td>
			<td>Ulas</td>
		</thead>
		<tbody>
			<tr>
				<td>S00001</td>
				<td>Produk 1</td>
				<td>
					<a class='btn btn-primary' href="ulasan?kode=S00001">ULAS</a>
				</td>
			</tr>
			<tr>
				<td>S00002</td>
				<td>Produk 2</td>
				<td>
					<a class='btn btn-primary' href="ulasan?kode=S00002">ULAS</a>
				</td>
			</tr>
		</tbody>
	</table>
</body>
</html>