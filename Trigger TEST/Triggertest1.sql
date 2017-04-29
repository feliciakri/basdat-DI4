###bikin pengguna & pembeli baru
INSERT INTO PENGGUNA(email,password,nama,jenis_kelamin,tgl_lahir,no_telp,alamat) 
VALUES ('emilystephens@dayrep.com','test1234','Emily Stephens','P','8/6/1997',086472637243,'Jl. Anggrek no. 666, Jakarta 16241');

INSERT INTO PELANGGAN(email,is_penjual,nilai_reputasi,poin) VALUES ('emilystephens@dayrep.com',false,NULL,0);

###Ini buat ngeliat poin pelanggan itu nol
SELECT * FROM PELANGGAN WHERE PELANGGAN.email = 'emilystephens@dayrep.com';
INSERT INTO TRANSAKSI_SHIPPED(no_invoice,tanggal,waktu_bayar,status,total_bayar,email_pembeli,nama_toko,alamat_kirim,biaya_kirim,no_resi,nama_jasa_kirim) 
VALUES ('V0000501','25/2/2017','22/02/2017 07:21',2,7137000,'emilystephens@dayrep.com','solution-oriented Electronics','Jl. Anggrek no. 666, Jakarta 16241',43000,'CGK8236508841823','J&T EXPRESS');
UPDATE TRANSAKSI_SHIPPED SET status = 4 WHERE no_invoice = 'V0000501';

###buat ngeliat poin pelanggan nambah
SELECT * FROM PELANGGAN WHERE PELANGGAN.email = 'emilystephens@dayrep.com';