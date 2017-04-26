CREATE SCHEMA TOKOKEREN;
SET SEARCH PATH TO TOKOKEREN;

CREATE TABLE PENGGUNA (email VARCHAR(50) NOT NULL, password VARCHAR(20) NOT NULL, nama VARCHAR(100) NOT NULL, jenis_kelamin CHAR(1) NOT NULL, tgl_lahir DATE NOT NULL, no_telp VARCHAR (20) NOT NULL, alamat TEXT NOT NULL, PRIMARY KEY (email), CONSTRAINT jenis_kelamin_chk CHECK (jenis_kelamin IN('L','P')));

CREATE TABLE PELANGGAN (email VARCHAR(50) NOT NULL, is_penjual BOOLEAN NOT NULL, nilai_reputasi NUMERIC(10,1), poin INT, PRIMARY KEY (email), FOREIGN KEY (email) REFERENCES PENGGUNA(email) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE TOKO (nama VARCHAR (100) NOT NULL, deskripsi TEXT, slogan VARCHAR(100), email_penjual VARCHAR(50) NOT NULL, FOREIGN KEY (email_penjual) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE JASA_KIRIM (nama VARCHAR(100) NOT NULL, lama_kirim VARCHAR(10) NOT NULL, tarif NUMERIC(10, 2) NOT NULL, PRIMARY KEY (nama));

CREATE TABLE TOKO_JASA_KIRIM (nama_toko VARCHAR(100) NOT NULL, jasa_kirim VARCHAR(100) NOT NULL, PRIMARY KEY (nama_toko, jasa_kirim), FOREIGN KEY (nama_toko) REFERENCES TOKO(nama) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (jasa_kirim) REFERENCES JASA_KIRIM(nama) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE KATEGORI_UTAMA (kode CHAR(3) NOT NULL, nama VARCHAR(100) NOT NULL, PRIMARY KEY (kode));

CREATE TABLE SUB_KATEGORI (kode CHAR(5) NOT NULL, kode_kategori CHAR(3) NOT NULL, nama VARCHAR(100) NOT NULL, PRIMARY KEY (kode), FOREIGN KEY (kode_kategori) REFERENCES KATEGORI_UTAMA(kode) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE PRODUK (kode_produk CHAR(8) NOT NULL, nama VARCHAR(100) NOT NULL, harga NUMERIC(10, 2) NOT NULL, deskripsi TEXT, PRIMARY KEY (kode_produk));

CREATE TABLE PRODUK_PULSA (kode_produk CHAR(8) NOT NULL, nominal INT NOT NULL, PRIMARY KEY (kode_produk), FOREIGN KEY (kode_produk) REFERENCES PRODUK(kode_produk ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE SHIPPED_PRODUK (kode_produk CHAR(8) NOT NULL, kategori CHAR(5) NOT NULL, nama_toko VARCHAR(100) NOT NULL, is_asuransi BOOLEAN NOT NULL, stok INT NOT NULL, is_baru BOOLEAN NOT NULL, min_order INT NOT NULL, min_grosir INT NOT NULL, max_grosir INT NOT NULL, harga_grosir NUMERIC(10,2) NOT NULL, foto VARCHAR(100) NOT NULL, PRIMARY KEY(kode_produk), FOREIGN KEY(kode_produk) REFERENCES PRODUK(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY(kategori) REFERENCES SUB_KATEGORI(kode) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY(nama_toko) REFERENCES TOKO(nama) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE TRANSAKSI_SHIPPED (no_invoice CHAR(10) NOT NULL, tanggal DATE NOT NULL, waktu_bayar TIMESTAMP, status SMALLINT NOT NULL, total_bayar NUMERIC(10, 2) NOT NULL, email_pembeli VARCHAR(50) NOT NULL, nama_toko VARCHAR(100) NOT NULL, alamat_kirim TEXT NOT NULL, biaya_kirim NUMERIC(10, 2) NOT NULL, no_resi CHAR(16), nama_jasa_kirim VARCHAR(16) NOT NULL, PRIMARY KEY (no_invoice), FOREIGN KEY (email_pembeli) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (nama_toko, nama_jasa_kirim) REFERENCES TOKO_JASA_KIRIM(nama_toko, jasa_kirim) ON UPDATE CASCADE ON DELETE RESTRICT CONSTRAINT status_chk CHECK (status IN('1','2','3','4')));

CREATE TABLE TRANSAKSI_PULSA (no_invoice CHAR(10) NOT NULL, tanggal DATE NOT NULL, waktu_bayar TIMESTAMP, status SMALLINT, total_bayar NUMERIC(10,2) NOT NULL, email_pembeli VARCHAR(50) NOT NULL, nominal INT NOT NULL, nomor VARCHAR(20) NOT NULL, kode_produk CHAR(8) NOT NULL, PRIMARY KEY (no_invoice), FOREIGN KEY (email_pembeli) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (kode_produk) REFERENCES PRODUK_PULSA(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT, CONSTRAINT status_pulsa_chk CHECK (status IN ('1','2'))
);

CREATE TABLE PROMO (id CHAR(6) NOT NULL, deskripsi TEXT NOT NULL, periode_awal DATE NOT NULL, periode_akhir DATE NOT NULL, kode VARCHAR(20) NOT NULL, PRIMARY KEY (id));

CREATE TABLE PROMO_PRODUK (id_promo CHAR(6) NOT NULL, kode_produk CHAR(8) NOT NULL, PRIMARY KEY (id_promo, kode_produk), FOREIGN KEY (id_promo) REFERENCES PROMO(id) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (kode_produk) REFERENCES PRODUK(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE ULASAN (email_pembeli VARCHAR(50) NOT NULL, kode_produk CHAR(8) NOT NULL, tanggal DATE NOT NULL, rating INT NOT NULL, komentar TEXT, PRIMARY KEY (email_pembeli, kode_produk), FOREIGN KEY (email_pembeli) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (kode_produk) REFERENCES SHIPPED_PRODUK(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE KOMENTAR_DISKUSI (pengirim VARCHAR(50) NOT NULL, penerima VARCHAR(50) NOT NULL, waktu TIMESTAMP NOT NULL, komentar TEXT NOT NULL, PRIMARY KEY (pengirim, penerima, waktu), FOREIGN KEY (pengirim) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY (penerima) REFERENCES PELANGGAN(email) ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE KERANJANG_BELANJA (pembeli VARCHAR(50) NOT NULL, kode_produk CHAR(8) NOT NULL, berat INT NOT NULL, kuantitas INT NOT NULL, harga NUMERIC(10,2) NOT NULL, sub_total NUMERIC(10,2) NOT NULL, PRIMARY KEY (pembeli, kode_produk), FOREIGN KEY(pembeli) REFERENCES PELANGGAN(is_penjual) ON UPDATE CASCADE ON DELETE RESTRICT, FOREIGN KEY(kode_produk) REFERENCES SHIPPED_PRODUK(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT);