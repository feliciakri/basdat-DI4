#tambah produk
INSERT INTO PRODUK(kode_produk,nama,harga,deskripsi) VALUES ('S0000251','Streamlined Pakaian Anak Perempuan Fuscia','821000','Streamlined Pakaian Anak Perempuan Fuscia  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');

#tambah produk
INSERT INTO SHIPPED_PRODUK(kode_produk,kategori,nama_toko,is_asuransi,stok,is_baru,min_order,min_grosir,max_grosir,harga_grosir,foto)
VALUES ('S0000251','SK001','explicit Clothing','false',10000,'true',1,12,500,3500000,'explicitClothing.png');

#lihat stok produk
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';

#tambah list item
INSERT INTO LIST_ITEM(no_invoice,kode_produk,berat,kuantitas,harga,sub_total) 
VALUES ('V0000501','S0000251',9,2,3500000,7137000);

#lihat stok produk, harusnya berkurang
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';

#new kode != null, ga ada kuantitas --> test kalo ini eror
UPDATE LIST_ITEM SET berat = 4 WHERE kode_produk = 'S0000251';

#lihat stok produk
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';

#kuantitas lebih dari sebelumnya
UPDATE LIST_ITEM SET kuantitas = 5 WHERE kode_produk = 'S0000251';

#lihat stok produk
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';

#kuantitas kurang dari sebelumnya
UPDATE LIST_ITEM SET kuantitas = 1 WHERE kode_produk = 'S0000251';

#lihat stok produk
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';

#delete list
DELETE FROM LIST_ITEM WHERE kode_produk = 'S0000251';

#lihat stok produk
SELECT * FROM SHIPPED_PRODUK WHERE kode_produk = 'S0000251';