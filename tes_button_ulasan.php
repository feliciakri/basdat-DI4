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
				<td>S0000003</td>
				<td>Produk 3</td>
				<td>
					<a class='btn btn-primary' href="ulasan?kode=S0000003">ULAS</a>
				</td>
			</tr>
			<tr>
				<td>S000025</td>
				<td>Produk 25</td>
				<td>
					<a class='btn btn-primary' href="ulasan?kode=S0000025">ULAS</a>
				</td>
			</tr>
		</tbody>
	</table>
</body>
</html>