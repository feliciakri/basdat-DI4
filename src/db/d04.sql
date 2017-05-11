--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tokokeren; Type: SCHEMA; Schema: -; Owner: d04
--

CREATE SCHEMA tokokeren;


ALTER SCHEMA tokokeren OWNER TO d04;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = tokokeren, pg_catalog;

--
-- Name: hitung_poin(); Type: FUNCTION; Schema: tokokeren; Owner: d04
--

CREATE FUNCTION hitung_poin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF(TG_OP = 'UPDATE') THEN
  IF(NEW.status = 4) THEN
    UPDATE PELANGGAN SET poin = NEW.total_bayar * 0.01
    WHERE PELANGGAN.email = NEW.email_pembeli;
  END IF;
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION tokokeren.hitung_poin() OWNER TO d04;

--
-- Name: upd_stok(); Type: FUNCTION; Schema: tokokeren; Owner: d04
--

CREATE FUNCTION upd_stok() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF(TG_OP = 'INSERT') THEN
 UPDATE SHIPPED_PRODUK SP SET stok = stok - NEW.kuantitas
 WHERE SP.kode_produk = NEW.kode_produk;
 RETURN NEW;
END IF;

IF(TG_OP = 'UPDATE') THEN
 IF(NEW.kode_produk IS NOT NULL) THEN
  UPDATE SHIPPED_PRODUK SP SET stok = stok + NEW.kuantitas
  WHERE SP.kode_produk = OLD.kode_produk;

  UPDATE SHIPPED_PRODUK SP SET stok = stok - NEW.kuantitas
  WHERE SP.kode_produk = NEW.kode_produk;
 END IF;
 IF(NEW.kuantitas IS NOT NULL) THEN
  IF(NEW.kuantitas < OLD.kuantitas) THEN
   UPDATE SHIPPED_PRODUK SP SET stok = stok + (OLD.kuantitas - NEW.kuantitas)
   WHERE SP.kode_produk = OLD.kode_produk;
  END IF;
  IF(NEW.kuantitas > OLD.kuantitas) THEN
   UPDATE SHIPPED_PRODUK SP SET stok = stok - (NEW.kuantitas - OLD.kuantitas)
   WHERE SP.kode_produk = OLD.kode_produk;
  END IF;
 END IF;
 RETURN NEW;
END IF;

IF(TG_OP = 'DELETE') THEN
 UPDATE SHIPPED_PRODUK SP SET stok = stok + OLD.kuantitas
 WHERE SP.kode_produk = OLD.kode_produk;
END IF;
 RETURN OLD;
END;
$$;


ALTER FUNCTION tokokeren.upd_stok() OWNER TO d04;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: jasa_kirim; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE jasa_kirim (
    nama character varying(100) NOT NULL,
    lama_kirim character varying(10) NOT NULL,
    tarif numeric(10,2) NOT NULL
);


ALTER TABLE jasa_kirim OWNER TO d04;

--
-- Name: kategori_utama; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE kategori_utama (
    kode character(3) NOT NULL,
    nama character varying(100) NOT NULL
);


ALTER TABLE kategori_utama OWNER TO d04;

--
-- Name: keranjang_belanja; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE keranjang_belanja (
    pembeli character varying(50) NOT NULL,
    kode_produk character(8) NOT NULL,
    berat integer NOT NULL,
    kuantitas integer NOT NULL,
    harga numeric(10,2) NOT NULL,
    sub_total numeric(10,2) NOT NULL
);


ALTER TABLE keranjang_belanja OWNER TO d04;

--
-- Name: komentar_diskusi; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE komentar_diskusi (
    pengirim character varying(50) NOT NULL,
    penerima character varying(50) NOT NULL,
    waktu timestamp without time zone NOT NULL,
    komentar text NOT NULL
);


ALTER TABLE komentar_diskusi OWNER TO d04;

--
-- Name: list_item; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE list_item (
    no_invoice character(10) NOT NULL,
    kode_produk character(8) NOT NULL,
    berat integer NOT NULL,
    kuantitas integer NOT NULL,
    harga numeric(10,2) NOT NULL,
    sub_total numeric(10,2) NOT NULL
);


ALTER TABLE list_item OWNER TO d04;

--
-- Name: pelanggan; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE pelanggan (
    email character varying(50) NOT NULL,
    is_penjual boolean NOT NULL,
    nilai_reputasi numeric(10,1),
    poin integer
);


ALTER TABLE pelanggan OWNER TO d04;

--
-- Name: pengguna; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE pengguna (
    email character varying(50) NOT NULL,
    password character varying(20) NOT NULL,
    nama character varying(100) NOT NULL,
    jenis_kelamin character(1) NOT NULL,
    tgl_lahir date NOT NULL,
    no_telp character varying(20) NOT NULL,
    alamat text NOT NULL,
    CONSTRAINT jenis_kelamin_chk CHECK ((jenis_kelamin = ANY (ARRAY['L'::bpchar, 'P'::bpchar])))
);


ALTER TABLE pengguna OWNER TO d04;

--
-- Name: produk; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE produk (
    kode_produk character(8) NOT NULL,
    nama character varying(100) NOT NULL,
    harga numeric(10,2) NOT NULL,
    deskripsi text
);


ALTER TABLE produk OWNER TO d04;

--
-- Name: produk_pulsa; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE produk_pulsa (
    kode_produk character(8) NOT NULL,
    nominal integer NOT NULL
);


ALTER TABLE produk_pulsa OWNER TO d04;

--
-- Name: promo; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE promo (
    id character(6) NOT NULL,
    deskripsi text NOT NULL,
    periode_awal date NOT NULL,
    periode_akhir date NOT NULL,
    kode character varying(20) NOT NULL
);


ALTER TABLE promo OWNER TO d04;

--
-- Name: promo_produk; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE promo_produk (
    id_promo character(6) NOT NULL,
    kode_produk character(8) NOT NULL
);


ALTER TABLE promo_produk OWNER TO d04;

--
-- Name: shipped_produk; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE shipped_produk (
    kode_produk character(8) NOT NULL,
    kategori character(5) NOT NULL,
    nama_toko character varying(100) NOT NULL,
    is_asuransi boolean NOT NULL,
    stok integer NOT NULL,
    is_baru boolean NOT NULL,
    min_order integer NOT NULL,
    min_grosir integer NOT NULL,
    max_grosir integer NOT NULL,
    harga_grosir numeric(10,2) NOT NULL,
    foto character varying(100) NOT NULL
);


ALTER TABLE shipped_produk OWNER TO d04;

--
-- Name: sub_kategori; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE sub_kategori (
    kode character(5) NOT NULL,
    kode_kategori character(3) NOT NULL,
    nama character varying(100) NOT NULL
);


ALTER TABLE sub_kategori OWNER TO d04;

--
-- Name: toko; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE toko (
    nama character varying(100) NOT NULL,
    deskripsi text,
    slogan character varying(100),
    email_penjual character varying(50) NOT NULL,
    lokasi text
);


ALTER TABLE toko OWNER TO d04;

--
-- Name: toko_jasa_kirim; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE toko_jasa_kirim (
    nama_toko character varying(100) NOT NULL,
    jasa_kirim character varying(100) NOT NULL
);


ALTER TABLE toko_jasa_kirim OWNER TO d04;

--
-- Name: transaksi_pulsa; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE transaksi_pulsa (
    no_invoice character(10) NOT NULL,
    tanggal date NOT NULL,
    waktu_bayar timestamp without time zone,
    status smallint,
    total_bayar numeric(10,2) NOT NULL,
    email_pembeli character varying(50) NOT NULL,
    nominal integer NOT NULL,
    nomor character varying(20) NOT NULL,
    kode_produk character(8) NOT NULL,
    CONSTRAINT status_pulsa_chk CHECK ((status = ANY (ARRAY['1'::smallint, '2'::smallint])))
);


ALTER TABLE transaksi_pulsa OWNER TO d04;

--
-- Name: transaksi_shipped; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE transaksi_shipped (
    no_invoice character(10) NOT NULL,
    tanggal date NOT NULL,
    waktu_bayar timestamp without time zone,
    status smallint NOT NULL,
    total_bayar numeric(10,2) NOT NULL,
    email_pembeli character varying(50) NOT NULL,
    nama_toko character varying(100) NOT NULL,
    alamat_kirim text NOT NULL,
    biaya_kirim numeric(10,2) NOT NULL,
    no_resi character(16),
    nama_jasa_kirim character varying(16) NOT NULL,
    CONSTRAINT status_chk CHECK ((status = ANY (ARRAY['1'::smallint, '2'::smallint, '3'::smallint, '4'::smallint])))
);


ALTER TABLE transaksi_shipped OWNER TO d04;

--
-- Name: ulasan; Type: TABLE; Schema: tokokeren; Owner: d04
--

CREATE TABLE ulasan (
    email_pembeli character varying(50) NOT NULL,
    kode_produk character(8) NOT NULL,
    tanggal date NOT NULL,
    rating integer NOT NULL,
    komentar text
);


ALTER TABLE ulasan OWNER TO d04;

--
-- Data for Name: jasa_kirim; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY jasa_kirim (nama, lama_kirim, tarif) FROM stdin;
JNE REGULER	1-3	8000.00
JNE YES	1	15000.00
JNE OKE	2-4	5000.00
TIKI REGULER	1-3	9000.00
POS PAKET BIASA	1-3	7000.00
POS PAKET KILAT	1-2	12000.00
WAHANA	1-3	8000.00
J&T EXPRESS	1-2	14000.00
PAHALA	2-3	7000.00
LION PARCEL	1-3	10000.00
\.


--
-- Data for Name: kategori_utama; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY kategori_utama (kode, nama) FROM stdin;
K01	Fashion Wanita
K02	Fashion Pria
K03	Fashion Muslim
K04	Fashion Anak
K05	Kecantikan
K06	Kesehatan
K07	Ibu & Bayi
K08	Rumah Tangga
K09	Handphone & Tablet
K10	Laptop & Aksesoris
K11	Komputer & Aksesoris
K12	Elektronik
K13	Kamera, Foto & Video
K14	Otomotif
K15	Olahraga
K16	Film, Musik & Game
K17	Dapur
K18	Office & Stationery
K19	Souvenir, Kado & Hadiah
K20	Mainan & Hobi
K21	Makanan & Minuman
K22	Buku
\.


--
-- Data for Name: keranjang_belanja; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY keranjang_belanja (pembeli, kode_produk, berat, kuantitas, harga, sub_total) FROM stdin;
ggamesonx@webs.com	S000010 	16	44	781012.00	34364528.00
pnursey4r@myspace.com	S0000154	67	17	279604.00	4753268.00
mdraysay5z@weibo.com	S000062 	78	32	273085.00	8738720.00
pworsfold3n@chron.com	S0000131	37	4	443611.00	1774444.00
erihanek66@surveymonkey.com	S0000148	51	2	244846.00	489692.00
mvern3p@godaddy.com	S00009  	55	34	619377.00	21058818.00
fburkman2b@twitpic.com	S000090 	23	19	163657.00	3109483.00
vgissing12@google.fr	S000028 	93	31	901110.00	27934410.00
jsedgeman20@sourceforge.net	S000054 	53	2	342024.00	684048.00
astandell6g@washington.edu	S0000106	10	45	766156.00	34477020.00
mtooley1s@storify.com	S0000234	72	14	659869.00	9238166.00
abinnes6o@pcworld.com	S0000186	2	10	178087.00	1780870.00
awestphalen3s@desdev.cn	S0000201	67	18	882763.00	15889734.00
gzapata4o@slideshare.net	S0000154	84	11	279604.00	3075644.00
umordacai5g@last.fm	S0000172	51	13	863981.00	11231753.00
kde3g@ebay.co.uk	S0000247	96	27	527345.00	14238315.00
gzapata4o@slideshare.net	S00004  	100	40	791828.00	31673120.00
adortonl@nytimes.com	S0000111	74	34	951890.00	32364260.00
ldoore32@loc.gov	S000093 	32	50	729715.00	36485750.00
yseago4v@geocities.com	S000058 	98	27	317767.00	8579709.00
csaladine6a@businesswire.com	S0000239	97	6	454345.00	2726070.00
bbryant56@bbc.co.uk	S0000192	29	1	783450.00	783450.00
gcopes1@earthlink.net	S0000106	73	44	766156.00	33710864.00
agatrell49@slate.com	S0000185	29	39	945514.00	36875046.00
rhallick2d@shutterfly.com	S0000194	77	25	448878.00	11221950.00
lcolicot4d@behance.net	S0000198	63	28	149065.00	4173820.00
cchastenet44@jiathis.com	S0000223	47	11	157071.00	1727781.00
epotte5n@redcross.org	S000073 	45	4	261010.00	1044040.00
elamcken27@hud.gov	S000083 	58	23	476827.00	10967021.00
jradage2l@blogtalkradio.com	S000040 	88	17	954150.00	16220550.00
tjohnsson35@gizmodo.com	S0000124	46	7	751784.00	5262488.00
claraway1l@parallels.com	S0000139	43	11	366291.00	4029201.00
ireadhead3k@is.gd	S0000139	50	45	366291.00	16483095.00
jwillard5r@51.la	S0000197	44	24	968802.00	23251248.00
dhurne4@nydailynews.com	S0000186	77	25	178087.00	4452175.00
kde3g@ebay.co.uk	S0000141	80	35	322959.00	11303565.00
ptesh5a@salon.com	S000096 	33	41	369672.00	15156552.00
lgreenig18@loc.gov	S0000143	32	3	270766.00	812298.00
elamcken27@hud.gov	S000061 	33	20	132579.00	2651580.00
mvern3p@godaddy.com	S0000144	61	48	889488.00	42695424.00
boxtoby2f@zdnet.com	S0000119	15	8	976015.00	7808120.00
awinchurst5v@cloudflare.com	S0000173	30	3	702073.00	2106219.00
nleither16@google.it	S0000163	79	25	386749.00	9668725.00
adortonl@nytimes.com	S000070 	81	8	209745.00	1677960.00
cseamans2c@indiatimes.com	S000053 	22	39	988733.00	38560587.00
fburkman2b@twitpic.com	S000068 	22	46	398594.00	18335324.00
jradage2l@blogtalkradio.com	S0000178	17	6	110984.00	665904.00
claraway1l@parallels.com	S0000229	35	27	115579.00	3120633.00
jalenshev3l@sciencedaily.com	S0000242	1	31	340815.00	10565265.00
mdraysay5z@weibo.com	S000063 	80	49	273085.00	13381165.00
\.


--
-- Data for Name: komentar_diskusi; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY komentar_diskusi (pengirim, penerima, waktu, komentar) FROM stdin;
tjohnsson35@gizmodo.com	sjobern2j@mozilla.org	2017-03-03 07:37:58	Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.
ebridgwoodb@fotki.com	rhallick2d@shutterfly.com	2015-06-29 10:29:09	Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.
erihanek66@surveymonkey.com	kkilmister3q@indiatimes.com	2017-03-26 11:36:20	Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.
ebridgwoodb@fotki.com	rtrevain2c@posterous.com	2017-04-10 03:59:01	Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
mbompas2@netvibes.com	cmiddler2g@flickr.com	2015-04-15 22:59:27	Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.
lgreenig18@loc.gov	mheildsi@yahoo.co.jp	2016-05-14 17:26:11	Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.
cvigars47@irs.gov	rdidball53@webs.com	2016-05-16 09:50:35	In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
jspenleyh@cisco.com	mquittonden51@acquirethisname.com	2016-07-16 09:28:55	In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.
tgingold1b@histats.com	hwillden1i@fastcompany.com	2015-05-13 13:14:42	In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.
kmiddlemiss6e@umn.edu	kviles24@1688.com	2016-11-04 20:33:32	Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.
rmouland4l@psu.edu	dbasire4n@nasa.gov	2016-01-01 02:41:43	Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.
vgissing12@google.fr	mbompas2@netvibes.com	2016-02-21 03:58:42	Sed sagittis.
mworwood24@1688.com	rwhitemanf@microsoft.com	2015-01-04 00:22:37	Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.
mskaife2r@ca.gov	sjobern2j@mozilla.org	2016-07-04 20:40:37	Morbi a ipsum.
acallum26@jiathis.com	dshowering5@elegantthemes.com	2016-04-30 14:23:03	Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
wleavesley1p@reddit.com	jvennard1s@unc.edu	2015-12-15 22:48:40	Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.
rinesont@wikipedia.org	jwillard5r@51.la	2016-06-26 12:18:13	Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.
castlesa@paginegialle.it	lcolicot4d@behance.net	2016-08-07 00:43:27	Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.
hgisborne28@slashdot.org	jalenshev3l@sciencedaily.com	2015-07-31 17:13:55	Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.
mheildsi@yahoo.co.jp	ghurleston45@netlog.com	2017-04-04 19:21:21	Sed accumsan felis. Ut at dolor quis odio consequat varius.
nleither16@google.it	djessope2i@yellowpages.com	2016-12-29 02:35:31	Pellentesque ultrices mattis odio. Donec vitae nisi.
ccheale1p@bbc.co.uk	bbryant56@bbc.co.uk	2015-02-16 02:01:11	Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.
atrowler5j@apple.com	boxtoby2f@zdnet.com	2015-03-31 23:34:16	Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.
bfalshaw2@about.me	bghidolid@feedburner.com	2015-10-10 21:58:10	Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.
kdawdary1t@springer.com	sjobern2j@mozilla.org	2015-02-23 14:02:59	Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.
lbambrick2p@sfgate.com	teykelhof1h@com.com	2017-03-20 12:39:54	Suspendisse potenti.
fburkman2b@twitpic.com	tmeader1n@fotki.com	2015-07-12 10:14:31	Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.
ryedall62@arizona.edu	nleither16@google.it	2015-08-26 22:05:37	Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.
cmiddler2g@flickr.com	gtofanon@ustream.tv	2015-12-31 10:46:40	Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.
vgissing12@google.fr	aodevey2z@prlog.org	2016-10-28 09:06:35	Morbi a ipsum. Integer a nibh. In quis justo.
pnursey4r@myspace.com	evinas1f@stanford.edu	2015-09-29 14:52:26	Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
medgell65@arizona.edu	twormleightonk@dagondesign.com	2016-02-22 18:59:29	Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
lkyston1l@unblog.fr	pworsfold3n@chron.com	2016-07-31 04:18:04	Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.
rmouland4l@psu.edu	vgissing12@google.fr	2015-01-14 04:21:48	Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
cmcwhin4g@gizmodo.com	apetrasek3x@cocolog-nifty.com	2015-03-16 09:14:35	Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.
mheildsi@yahoo.co.jp	mkeays6h@posterous.com	2015-02-02 00:15:09	Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.
rinesont@wikipedia.org	vgissing12@google.fr	2015-10-14 00:03:04	Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
uguiducci43@istockphoto.com	bbisseker4m@g.co	2016-08-03 06:56:11	Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.
amilstead5i@umich.edu	ahinkley16@quantcast.com	2016-12-03 07:44:00	In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.
habrahamovitzb@ameblo.jp	tmeader1n@fotki.com	2016-05-24 00:31:45	Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
bambersonv@wp.com	rpigott17@vimeo.com	2015-06-18 01:51:05	Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.
jpaschke22@java.com	agatrell49@slate.com	2016-06-29 01:41:18	Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.
rhallick2d@shutterfly.com	mheildsi@yahoo.co.jp	2017-04-13 21:59:54	Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
dbeagin5d@barnesandnoble.com	bstukings1o@elpais.com	2016-07-08 17:02:39	Nulla ac enim.
dshowering5@elegantthemes.com	cmiddler2g@flickr.com	2015-07-15 12:07:47	Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.
gtaggett5t@over-blog.com	hwillden1i@fastcompany.com	2016-06-09 21:48:24	Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
cmiddler2g@flickr.com	pworsfold3n@chron.com	2015-05-11 05:35:35	Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.
agatrell49@slate.com	kdawdary1t@springer.com	2015-11-13 00:03:05	Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
rjodrelle1c@latimes.com	bambersonv@wp.com	2015-09-24 14:20:41	Suspendisse accumsan tortor quis turpis. Sed ante.
dajsikp@yale.edu	fboheao@baidu.com	2015-11-02 18:52:20	Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.
\.


--
-- Data for Name: list_item; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY list_item (no_invoice, kode_produk, berat, kuantitas, harga, sub_total) FROM stdin;
V0000339  	S000075 	9	4	210648.00	3549000.00
V0000182  	S0000117	2	2	595375.00	4578000.00
V0000298  	S0000176	3	9	588149.00	3447000.00
V0000463  	S000056 	1	8	793166.00	2375000.00
V000014   	S00007  	8	7	825127.00	6551000.00
V0000339  	S0000160	6	6	150634.00	3549000.00
V000043   	S000078 	3	1	292372.00	6063000.00
V000046   	S000085 	8	6	966700.00	6498000.00
V0000306  	S000040 	10	10	451419.00	653000.00
V0000492  	S000050 	5	6	611213.00	9215000.00
V0000111  	S000043 	9	1	917810.00	2155000.00
V0000403  	S0000164	6	10	247144.00	5479000.00
V0000213  	S0000102	2	2	6416.00	7111000.00
V0000313  	S000037 	4	3	104770.00	3688000.00
V0000130  	S000086 	3	8	301903.00	4243000.00
V0000259  	S0000242	5	9	474150.00	9011000.00
V000044   	S0000144	9	9	90059.00	2965000.00
V0000172  	S0000135	7	3	826060.00	421000.00
V0000291  	S0000106	6	3	835538.00	8414000.00
V0000319  	S0000177	10	2	781962.00	1551000.00
V0000405  	S000074 	4	10	859771.00	2629000.00
V000066   	S000034 	6	3	710282.00	4086000.00
V0000148  	S0000209	1	4	951637.00	3323000.00
V0000158  	S0000170	7	4	140729.00	6917000.00
V0000146  	S0000235	4	6	509335.00	2642000.00
V00007    	S0000151	1	4	293586.00	5267000.00
V0000175  	S0000114	7	8	882536.00	8391000.00
V0000129  	S0000202	8	2	381269.00	8048000.00
V0000303  	S0000231	6	8	149737.00	7442000.00
V0000290  	S000053 	7	3	609660.00	4542000.00
V0000275  	S000057 	8	4	597836.00	5580000.00
V0000131  	S0000129	10	5	950593.00	5585000.00
V0000201  	S0000244	10	1	635633.00	3270000.00
V000073   	S000028 	3	2	193935.00	1011000.00
V000038   	S000055 	5	3	360221.00	4920000.00
V0000148  	S0000106	6	10	835538.00	3323000.00
V0000129  	S000093 	3	2	135186.00	8048000.00
V0000300  	S000012 	1	7	284549.00	5517000.00
V0000435  	S0000250	2	3	744079.00	7914000.00
V00001    	S0000226	2	1	114249.00	4074000.00
V0000415  	S0000114	7	6	882536.00	109000.00
V0000209  	S0000141	2	6	247401.00	3807000.00
V0000362  	S0000127	4	10	205371.00	8899000.00
V0000433  	S0000236	6	5	865708.00	5042000.00
V0000271  	S0000250	3	7	744079.00	8721000.00
V0000381  	S0000241	9	9	782966.00	9963000.00
V0000211  	S000017 	7	8	173318.00	7844000.00
V0000334  	S0000181	3	3	734851.00	9191000.00
V0000288  	S0000232	3	5	11804.00	1211000.00
V000053   	S0000216	7	10	122362.00	4231000.00
V0000472  	S000098 	9	6	602906.00	8670000.00
V0000134  	S0000147	5	8	877351.00	2495000.00
V000094   	S000017 	3	2	173318.00	1627000.00
V0000125  	S0000182	10	6	256560.00	7679000.00
V000086   	S000094 	3	4	360121.00	8029000.00
V0000129  	S0000216	9	2	122362.00	8048000.00
V0000232  	S0000169	1	6	659235.00	6565000.00
V000069   	S0000142	9	6	289898.00	4804000.00
V00003    	S0000132	4	1	400171.00	1123000.00
V0000454  	S000043 	10	10	917810.00	9585000.00
V0000326  	S000076 	2	7	361822.00	8510000.00
V00009    	S0000222	5	7	593023.00	5860000.00
V0000391  	S0000225	3	4	235421.00	1532000.00
V0000107  	S000063 	7	6	554.00	947000.00
V0000261  	S0000107	5	4	688007.00	4391000.00
V0000467  	S0000212	10	10	495617.00	338000.00
V0000174  	S0000185	1	6	918522.00	4131000.00
V000039   	S0000118	1	3	583138.00	3885000.00
V0000264  	S000037 	5	8	104770.00	911000.00
V0000158  	S0000197	5	9	69687.00	6917000.00
V0000261  	S000033 	10	10	658266.00	4391000.00
V0000333  	S0000248	1	5	93555.00	9948000.00
V0000292  	S0000124	5	3	903018.00	725000.00
V000062   	S0000175	7	8	115761.00	2375000.00
V0000349  	S0000170	3	9	140729.00	6118000.00
V000033   	S00004  	9	9	470694.00	173000.00
V0000358  	S0000114	7	7	882536.00	1324000.00
V0000174  	S000031 	9	5	359577.00	4131000.00
V0000419  	S000023 	8	4	630680.00	6062000.00
V0000391  	S0000111	5	4	344071.00	1532000.00
V0000469  	S000050 	9	10	611213.00	5926000.00
V0000389  	S000046 	7	1	338218.00	6051000.00
V0000498  	S000057 	1	8	597836.00	551000.00
V0000477  	S0000109	1	2	23674.00	7462000.00
V00004    	S0000190	8	5	942849.00	3756000.00
V0000489  	S0000165	4	7	338832.00	5097000.00
V0000112  	S000086 	6	4	301903.00	1934000.00
V0000231  	S0000117	9	8	595375.00	3632000.00
V000039   	S0000143	6	10	658589.00	3885000.00
V0000233  	S0000217	3	3	193002.00	3689000.00
V000085   	S000077 	5	8	939216.00	7254000.00
V0000185  	S0000129	8	8	950593.00	170000.00
V0000384  	S0000194	4	8	873946.00	3247000.00
V0000485  	S0000113	8	8	279266.00	8197000.00
V0000427  	S0000190	9	6	942849.00	9396000.00
V000096   	S0000190	9	9	942849.00	3201000.00
V0000235  	S0000118	3	8	583138.00	8564000.00
V0000461  	S000031 	5	9	359577.00	5288000.00
V0000209  	S000079 	5	1	797783.00	3807000.00
V000030   	S000057 	9	6	597836.00	9254000.00
V0000393  	S0000190	4	10	942849.00	1032000.00
V0000107  	S0000167	1	3	955885.00	947000.00
V000082   	S0000216	2	9	122362.00	9694000.00
V0000221  	S0000243	8	9	902067.00	460000.00
V000087   	S000031 	5	10	359577.00	1323000.00
V000017   	S0000128	8	1	888318.00	8165000.00
V0000304  	S0000114	5	7	882536.00	2480000.00
V000098   	S0000201	6	10	480700.00	5953000.00
V0000102  	S0000245	3	2	268609.00	1449000.00
V0000332  	S0000215	7	9	918114.00	708000.00
V000095   	S000092 	9	3	294908.00	934000.00
V0000169  	S000037 	2	3	104770.00	4660000.00
V0000287  	S000039 	5	10	929519.00	8238000.00
V0000342  	S0000193	3	4	875495.00	868000.00
V0000208  	S0000231	4	10	149737.00	8962000.00
V000086   	S000065 	2	9	592870.00	8029000.00
V0000150  	S0000216	3	3	122362.00	5179000.00
V0000455  	S000096 	4	5	468631.00	3978000.00
V0000189  	S0000168	10	4	934926.00	3873000.00
V0000250  	S0000114	10	7	882536.00	2446000.00
V0000247  	S0000160	3	1	150634.00	8290000.00
V0000196  	S0000155	9	5	208067.00	5100000.00
V0000251  	S0000139	1	10	3485.00	4695000.00
V0000167  	S0000207	2	10	843223.00	9234000.00
V0000108  	S000084 	7	8	772416.00	9398000.00
V0000402  	S0000205	7	9	844098.00	3067000.00
V0000458  	S000066 	9	9	892876.00	5061000.00
V0000477  	S000068 	6	8	583853.00	7462000.00
V0000126  	S000030 	6	10	185796.00	8623000.00
V0000249  	S0000176	9	9	588149.00	8988000.00
V0000321  	S0000113	6	6	279266.00	743000.00
V0000485  	S0000162	5	1	43628.00	8197000.00
V0000383  	S0000232	8	10	11804.00	7290000.00
V0000350  	S00004  	7	6	470694.00	7515000.00
V0000445  	S0000139	10	8	3485.00	5158000.00
V0000154  	S0000192	2	2	902721.00	1980000.00
V000079   	S000046 	2	7	338218.00	563000.00
V0000500  	S0000176	9	5	588149.00	5351000.00
V0000115  	S000037 	7	7	104770.00	59000.00
V0000172  	S0000102	7	8	6416.00	421000.00
V0000235  	S0000179	1	5	313830.00	8564000.00
V0000383  	S0000167	8	10	955885.00	7290000.00
V0000488  	S000057 	8	4	597836.00	2535000.00
V0000283  	S000048 	1	7	544664.00	9232000.00
V0000100  	S0000152	5	4	58225.00	6292000.00
V0000421  	S0000152	1	7	58225.00	5856000.00
V0000243  	S000018 	2	3	248384.00	6147000.00
V0000403  	S000023 	7	6	630680.00	5479000.00
V000019   	S0000105	10	7	194202.00	2695000.00
V000066   	S000058 	7	2	318891.00	4086000.00
V0000230  	S0000227	7	6	947455.00	2808000.00
V0000162  	S0000200	9	7	438617.00	6402000.00
V0000420  	S000065 	6	1	592870.00	3962000.00
V0000286  	S000077 	8	5	939216.00	5411000.00
V0000210  	S0000172	8	1	365621.00	5084000.00
V0000228  	S0000200	6	4	438617.00	2963000.00
V0000332  	S0000237	10	4	694090.00	708000.00
V0000453  	S0000191	10	3	273435.00	2195000.00
V000043   	S0000167	8	1	955885.00	6063000.00
V000027   	S000048 	4	4	544664.00	8238000.00
V000011   	S0000223	5	2	912544.00	5901000.00
V0000208  	S000087 	6	9	760984.00	8962000.00
V0000473  	S0000121	4	5	425952.00	8651000.00
V0000363  	S0000244	9	2	635633.00	5097000.00
V0000132  	S0000145	6	1	271759.00	853000.00
V000055   	S0000217	1	6	193002.00	2253000.00
V0000244  	S0000159	9	3	819865.00	3351000.00
V0000155  	S0000245	3	3	268609.00	788000.00
V0000146  	S0000192	10	1	902721.00	2642000.00
V0000148  	S0000178	9	1	633218.00	3323000.00
V0000374  	S0000190	4	5	942849.00	5024000.00
V000079   	S0000232	5	4	11804.00	563000.00
V0000237  	S0000171	8	7	875127.00	7002000.00
V0000382  	S000072 	5	7	753044.00	5484000.00
V0000406  	S0000205	2	9	844098.00	1813000.00
V0000332  	S000032 	5	2	92195.00	708000.00
V0000470  	S00008  	2	5	779781.00	1481000.00
V0000142  	S0000151	2	9	293586.00	7666000.00
V000098   	S0000247	7	4	266902.00	5953000.00
V0000449  	S0000151	10	2	293586.00	7130000.00
V0000406  	S0000134	10	2	796207.00	1813000.00
V0000347  	S000068 	5	4	583853.00	598000.00
V000028   	S0000236	6	10	865708.00	4772000.00
V0000492  	S000090 	6	3	981861.00	9215000.00
V0000159  	S0000189	3	8	462431.00	5693000.00
V0000464  	S0000210	9	8	908350.00	8949000.00
V0000108  	S000028 	2	4	193935.00	9398000.00
V0000124  	S0000234	8	9	124374.00	5336000.00
V0000198  	S0000198	9	7	396607.00	8969000.00
V0000351  	S000098 	6	10	602906.00	7865000.00
V0000431  	S0000145	2	7	271759.00	9824000.00
V0000115  	S0000138	4	2	412255.00	59000.00
V0000347  	S000034 	1	4	710282.00	598000.00
V0000266  	S0000111	2	9	344071.00	8036000.00
V0000375  	S0000141	9	3	247401.00	8899000.00
V0000155  	S0000208	7	7	478724.00	788000.00
V0000289  	S000057 	2	4	597836.00	6109000.00
V0000432  	S000039 	2	6	929519.00	8292000.00
V000058   	S0000175	8	7	115761.00	4202000.00
V0000435  	S000097 	3	9	761494.00	7914000.00
V000022   	S0000204	2	7	587837.00	7622000.00
V0000316  	S000023 	10	5	630680.00	112000.00
V0000263  	S000090 	5	10	981861.00	8326000.00
V0000469  	S0000116	7	10	328460.00	5926000.00
V0000425  	S0000159	6	3	819865.00	368000.00
V0000268  	S0000242	1	6	474150.00	2879000.00
V0000255  	S000020 	10	7	21690.00	8396000.00
V0000126  	S0000173	10	2	277515.00	8623000.00
V0000298  	S000082 	1	4	735757.00	3447000.00
V0000110  	S000069 	4	1	37235.00	4462000.00
V0000343  	S000019 	9	5	192485.00	5397000.00
V0000300  	S000017 	6	9	173318.00	5517000.00
V0000164  	S000043 	7	9	917810.00	4096000.00
V0000384  	S000070 	4	8	285708.00	3247000.00
V000052   	S000091 	3	10	283341.00	4322000.00
V000080   	S0000168	7	6	934926.00	8790000.00
V0000463  	S0000167	7	1	955885.00	2375000.00
V0000448  	S000071 	3	7	176879.00	4689000.00
V0000282  	S0000125	4	8	176104.00	8184000.00
V0000202  	S0000142	4	8	289898.00	6930000.00
V0000243  	S000026 	2	10	625885.00	6147000.00
V0000419  	S000072 	2	7	753044.00	6062000.00
V0000339  	S0000127	4	2	205371.00	3549000.00
V0000493  	S0000215	3	8	918114.00	7903000.00
V0000287  	S000063 	7	2	554.00	8238000.00
V0000128  	S0000171	3	8	875127.00	6354000.00
V0000246  	S00008  	1	4	779781.00	9209000.00
V0000414  	S000062 	8	7	804056.00	4430000.00
V0000498  	S0000161	2	2	704054.00	551000.00
V0000100  	S0000213	1	1	704486.00	6292000.00
V0000439  	S000079 	3	8	797783.00	2330000.00
V000091   	S000077 	10	5	939216.00	2236000.00
V0000106  	S0000240	4	10	583093.00	4509000.00
V0000454  	S0000105	10	8	194202.00	9585000.00
V000094   	S0000222	6	6	593023.00	1627000.00
V000063   	S0000240	7	10	583093.00	4394000.00
V00006    	S0000213	1	8	704486.00	7286000.00
V0000392  	S000060 	10	10	695695.00	3152000.00
V000077   	S000011 	8	8	360180.00	4289000.00
V0000249  	S00007  	9	7	825127.00	8988000.00
V000072   	S000013 	9	2	766951.00	9377000.00
V0000490  	S000077 	4	3	939216.00	3437000.00
V0000469  	S000011 	9	9	360180.00	5926000.00
V0000486  	S0000242	5	3	474150.00	2545000.00
V0000411  	S0000225	7	5	235421.00	3259000.00
V0000187  	S000045 	5	5	447138.00	2544000.00
V0000113  	S00006  	2	1	807568.00	5531000.00
V000010   	S0000143	7	1	658589.00	2078000.00
V000039   	S000062 	9	1	804056.00	3885000.00
V0000104  	S000079 	8	2	797783.00	9783000.00
V0000387  	S000064 	9	6	73363.00	4024000.00
V0000326  	S0000126	6	1	760092.00	8510000.00
V0000415  	S00001  	1	2	754067.00	109000.00
V0000487  	S000097 	9	6	761494.00	3249000.00
V0000337  	S0000162	3	4	43628.00	228000.00
V0000283  	S000036 	1	5	271392.00	9232000.00
V0000442  	S0000134	3	4	796207.00	5605000.00
V000073   	S000038 	8	2	172468.00	1011000.00
V0000109  	S000085 	6	2	966700.00	181000.00
V0000260  	S0000162	3	10	43628.00	4924000.00
V0000368  	S00007  	10	1	825127.00	2742000.00
V0000434  	S000071 	2	1	176879.00	8070000.00
V0000231  	S000045 	6	7	447138.00	3632000.00
V000095   	S000075 	9	3	210648.00	934000.00
V0000154  	S0000117	6	8	595375.00	1980000.00
V0000378  	S000025 	7	6	317629.00	9223000.00
V0000302  	S0000119	1	1	600809.00	677000.00
V0000240  	S000023 	5	9	630680.00	8952000.00
V000030   	S0000178	10	9	633218.00	9254000.00
V0000399  	S0000142	7	1	289898.00	7349000.00
V0000300  	S0000143	10	9	658589.00	5517000.00
V0000191  	S0000155	7	7	208067.00	8324000.00
V0000334  	S0000108	9	6	704199.00	9191000.00
V0000138  	S0000236	5	8	865708.00	8580000.00
V0000278  	S0000132	7	10	400171.00	8801000.00
V000084   	S000068 	7	1	583853.00	4284000.00
V000076   	S0000148	3	7	850812.00	7257000.00
V0000289  	S000022 	6	8	456179.00	6109000.00
V0000471  	S0000109	10	3	23674.00	9726000.00
V0000373  	S000050 	3	1	611213.00	8898000.00
V000025   	S000038 	1	5	172468.00	8930000.00
V000075   	S0000210	7	6	908350.00	4782000.00
V0000172  	S0000182	2	3	256560.00	421000.00
V0000270  	S0000119	3	2	600809.00	265000.00
V0000491  	S000066 	6	1	892876.00	2335000.00
V00004    	S0000147	7	5	877351.00	3756000.00
V0000219  	S0000192	3	2	902721.00	29000.00
V000057   	S0000210	6	6	908350.00	2329000.00
V0000171  	S0000204	4	1	587837.00	504000.00
V0000180  	S0000192	6	4	902721.00	764000.00
V000036   	S0000172	6	8	365621.00	6533000.00
V0000497  	S000040 	8	9	451419.00	2792000.00
V0000432  	S0000221	7	6	967645.00	8292000.00
V0000257  	S0000202	10	6	381269.00	9898000.00
V0000124  	S0000241	10	10	782966.00	5336000.00
V0000434  	S000061 	1	8	597925.00	8070000.00
V000065   	S000093 	8	8	135186.00	7439000.00
V00002    	S000056 	9	5	793166.00	6690000.00
V0000263  	S0000248	4	7	93555.00	8326000.00
V0000263  	S0000166	2	3	698576.00	8326000.00
V000024   	S0000223	10	10	912544.00	963000.00
V0000454  	S0000145	3	6	271759.00	9585000.00
V0000418  	S000075 	3	4	210648.00	1113000.00
V0000156  	S0000207	9	8	843223.00	7120000.00
V00004    	S0000168	6	6	934926.00	3756000.00
V0000201  	S0000248	4	10	93555.00	3270000.00
V0000110  	S00004  	6	8	470694.00	4462000.00
V0000171  	S0000222	6	6	593023.00	504000.00
V000083   	S0000248	1	10	93555.00	8546000.00
V0000369  	S000090 	2	1	981861.00	1259000.00
V0000376  	S0000231	3	8	149737.00	2715000.00
V0000497  	S000015 	4	5	379100.00	2792000.00
V0000343  	S000053 	4	8	609660.00	5397000.00
V00003    	S0000144	6	8	90059.00	1123000.00
V0000345  	S000045 	8	9	447138.00	532000.00
V000078   	S0000177	1	10	781962.00	920000.00
V0000245  	S000036 	9	4	271392.00	4462000.00
V0000315  	S00008  	9	5	779781.00	5440000.00
V0000230  	S0000181	3	1	734851.00	2808000.00
V0000143  	S0000182	10	10	256560.00	5554000.00
V0000127  	S000020 	9	5	21690.00	3574000.00
V00009    	S000046 	9	8	338218.00	5860000.00
V00002    	S000039 	3	10	929519.00	6690000.00
V0000286  	S000097 	9	8	761494.00	5411000.00
V0000380  	S000088 	3	10	468264.00	6726000.00
V0000183  	S0000245	5	4	268609.00	2570000.00
V0000121  	S000049 	4	9	232876.00	7597000.00
V0000490  	S0000227	4	9	947455.00	3437000.00
V0000431  	S000065 	6	1	592870.00	9824000.00
V0000332  	S0000183	8	5	243214.00	708000.00
V0000104  	S0000134	9	10	796207.00	9783000.00
V0000434  	S000087 	2	3	760984.00	8070000.00
V0000274  	S0000185	2	6	918522.00	8077000.00
V0000169  	S000049 	2	2	232876.00	4660000.00
V000077   	S0000116	3	10	328460.00	4289000.00
V0000434  	S0000149	7	1	114740.00	8070000.00
V0000482  	S0000180	7	3	495727.00	7127000.00
V0000283  	S0000194	9	8	873946.00	9232000.00
V0000292  	S000064 	8	8	73363.00	725000.00
V000059   	S00005  	10	8	16020.00	8715000.00
V0000330  	S000025 	7	7	317629.00	8639000.00
V0000100  	S000069 	9	8	37235.00	6292000.00
V0000406  	S0000135	4	2	826060.00	1813000.00
V0000467  	S000071 	8	9	176879.00	338000.00
V0000101  	S0000206	1	5	386772.00	3657000.00
V0000463  	S000071 	1	8	176879.00	2375000.00
V0000255  	S0000211	1	10	420332.00	8396000.00
V0000251  	S000026 	3	3	625885.00	4695000.00
V0000213  	S0000143	3	2	658589.00	7111000.00
V0000258  	S0000186	6	3	516523.00	264000.00
V0000287  	S0000134	9	8	796207.00	8238000.00
V0000244  	S000094 	3	1	360121.00	3351000.00
V000054   	S000099 	10	1	466014.00	3080000.00
V0000234  	S0000152	1	2	58225.00	4636000.00
V0000293  	S0000140	5	4	240447.00	7802000.00
V0000203  	S0000151	8	5	293586.00	7135000.00
V0000282  	S0000145	5	5	271759.00	8184000.00
V0000374  	S000053 	1	8	609660.00	5024000.00
V0000109  	S0000114	6	5	882536.00	181000.00
V0000473  	S0000154	9	7	202477.00	8651000.00
V0000421  	S000064 	2	7	73363.00	5856000.00
V000064   	S000046 	5	8	338218.00	4091000.00
V0000403  	S0000200	3	3	438617.00	5479000.00
V000041   	S000084 	8	10	772416.00	8499000.00
V0000201  	S000066 	4	7	892876.00	3270000.00
V0000488  	S0000187	7	2	57520.00	2535000.00
V0000424  	S0000197	9	2	69687.00	6957000.00
V0000310  	S0000127	6	10	205371.00	6753000.00
V0000220  	S0000138	1	9	412255.00	8315000.00
V0000159  	S00003  	7	7	940943.00	5693000.00
V000037   	S0000244	1	1	635633.00	672000.00
V0000436  	S0000207	10	4	843223.00	6545000.00
V0000409  	S0000168	6	7	934926.00	5899000.00
V0000319  	S0000244	6	3	635633.00	1551000.00
V000046   	S00006  	6	1	807568.00	6498000.00
V0000159  	S0000217	6	9	193002.00	5693000.00
V0000148  	S000038 	2	10	172468.00	3323000.00
V0000485  	S0000226	6	9	114249.00	8197000.00
V0000266  	S0000194	10	9	873946.00	8036000.00
V000058   	S000056 	9	4	793166.00	4202000.00
V0000387  	S00003  	7	4	940943.00	4024000.00
V0000264  	S0000108	1	3	704199.00	911000.00
V0000481  	S000045 	1	8	447138.00	8302000.00
V0000314  	S0000244	10	3	635633.00	5433000.00
V0000229  	S000049 	1	2	232876.00	2707000.00
V0000385  	S0000185	5	2	918522.00	7512000.00
V000077   	S000079 	1	6	797783.00	4289000.00
V000030   	S0000202	3	4	381269.00	9254000.00
V0000387  	S0000128	3	8	888318.00	4024000.00
V0000341  	S000079 	9	4	797783.00	6357000.00
V0000368  	S0000146	7	8	890641.00	2742000.00
V0000390  	S0000139	1	10	3485.00	1711000.00
V0000121  	S0000234	8	8	124374.00	7597000.00
V0000347  	S000099 	3	9	466014.00	598000.00
V0000227  	S000059 	10	2	224387.00	1725000.00
V0000500  	S000097 	9	6	761494.00	5351000.00
V000076   	S0000174	6	4	532517.00	7257000.00
V000015   	S0000239	9	2	67372.00	5719000.00
V000040   	S0000140	5	6	240447.00	4922000.00
V000044   	S0000183	6	5	243214.00	2965000.00
V0000424  	S0000138	2	10	412255.00	6957000.00
V0000181  	S0000213	4	2	704486.00	2427000.00
V0000490  	S0000144	2	3	90059.00	3437000.00
V000099   	S000091 	1	5	283341.00	1216000.00
V0000310  	S0000130	8	1	13137.00	6753000.00
V0000479  	S0000144	5	6	90059.00	7273000.00
V0000360  	S000074 	8	7	859771.00	548000.00
V000041   	S0000119	1	10	600809.00	8499000.00
V0000195  	S0000235	7	8	509335.00	6883000.00
V0000221  	S0000188	2	5	920322.00	460000.00
V000072   	S000050 	8	3	611213.00	9377000.00
V0000147  	S0000234	5	8	124374.00	5101000.00
V0000475  	S000013 	9	3	766951.00	2167000.00
V0000474  	S0000112	1	10	506803.00	5268000.00
V0000435  	S0000202	2	2	381269.00	7914000.00
V0000236  	S0000108	2	9	704199.00	9335000.00
V0000430  	S0000228	3	8	232606.00	6419000.00
V0000433  	S0000120	10	10	726454.00	5042000.00
V0000304  	S0000116	3	9	328460.00	2480000.00
V0000217  	S0000175	8	9	115761.00	7707000.00
V0000468  	S0000247	4	10	266902.00	9301000.00
V0000136  	S0000153	9	3	657533.00	2711000.00
V000049   	S0000231	1	6	149737.00	2617000.00
V000020   	S000031 	1	1	359577.00	6743000.00
V0000400  	S0000183	3	4	243214.00	7403000.00
V0000256  	S000092 	10	7	294908.00	8990000.00
V0000222  	S0000242	3	2	474150.00	5798000.00
V0000391  	S0000248	5	4	93555.00	1532000.00
V0000430  	S0000248	5	9	93555.00	6419000.00
V000078   	S000087 	2	4	760984.00	920000.00
V000093   	S0000106	1	1	835538.00	550000.00
V000049   	S000019 	2	8	192485.00	2617000.00
V000069   	S000078 	4	2	292372.00	4804000.00
V0000432  	S0000111	9	6	344071.00	8292000.00
V0000292  	S0000112	2	7	506803.00	725000.00
V0000360  	S0000185	5	8	918522.00	548000.00
V0000432  	S000082 	2	8	735757.00	8292000.00
V000013   	S000034 	3	1	710282.00	8715000.00
V0000280  	S0000140	5	4	240447.00	8330000.00
V000099   	S0000118	5	1	583138.00	1216000.00
V0000463  	S0000187	2	4	57520.00	2375000.00
V0000121  	S00002  	3	2	169643.00	7597000.00
V000030   	S0000108	7	4	704199.00	9254000.00
V0000253  	S000055 	4	1	360221.00	8655000.00
V0000466  	S0000105	10	1	194202.00	8463000.00
V000063   	S0000186	6	9	516523.00	4394000.00
V0000495  	S0000118	8	4	583138.00	4247000.00
V0000391  	S0000103	2	2	550870.00	1532000.00
V0000408  	S0000242	6	9	474150.00	9543000.00
V0000203  	S0000228	9	8	232606.00	7135000.00
V000041   	S0000212	1	1	495617.00	8499000.00
V0000270  	S0000177	5	1	781962.00	265000.00
V0000355  	S0000230	7	4	178919.00	1167000.00
V0000173  	S000084 	8	2	772416.00	1865000.00
V0000230  	S000055 	1	7	360221.00	2808000.00
V000072   	S000031 	7	1	359577.00	9377000.00
V000017   	S0000219	1	5	740107.00	8165000.00
V0000229  	S000014 	1	1	932664.00	2707000.00
V0000236  	S0000150	3	7	36613.00	9335000.00
V0000322  	S000056 	4	5	793166.00	7276000.00
V0000449  	S000047 	10	8	711867.00	7130000.00
V0000100  	S0000232	3	4	11804.00	6292000.00
V0000375  	S000053 	3	10	609660.00	8899000.00
V000036   	S0000199	2	4	625636.00	6533000.00
V0000278  	S0000217	7	8	193002.00	8801000.00
V0000443  	S0000181	6	2	734851.00	1811000.00
V000025   	S000042 	9	9	276014.00	8930000.00
V0000443  	S000042 	4	3	276014.00	1811000.00
V000023   	S0000231	4	8	149737.00	474000.00
V0000232  	S0000146	2	8	890641.00	6565000.00
V0000475  	S000042 	6	8	276014.00	2167000.00
V00007    	S0000223	7	9	912544.00	5267000.00
V0000453  	S0000179	5	2	313830.00	2195000.00
V0000445  	S000086 	2	2	301903.00	5158000.00
V0000421  	S000076 	1	1	361822.00	5856000.00
V000059   	S0000171	5	4	875127.00	8715000.00
V0000439  	S000084 	6	6	772416.00	2330000.00
V0000275  	S0000229	2	3	179010.00	5580000.00
V0000435  	S0000201	10	5	480700.00	7914000.00
V0000382  	S000032 	10	9	92195.00	5484000.00
V0000316  	S0000145	7	6	271759.00	112000.00
V000020   	S0000174	10	6	532517.00	6743000.00
V0000195  	S0000150	2	7	36613.00	6883000.00
V000080   	S0000120	4	4	726454.00	8790000.00
V0000153  	S0000147	7	9	877351.00	1322000.00
V0000351  	S0000133	6	9	252486.00	7865000.00
V0000406  	S0000143	9	3	658589.00	1813000.00
V0000205  	S000025 	1	6	317629.00	1613000.00
V000017   	S0000244	5	6	635633.00	8165000.00
V0000354  	S000083 	3	5	635220.00	7383000.00
V0000405  	S0000241	4	6	782966.00	2629000.00
V0000276  	S0000219	9	2	740107.00	9844000.00
V0000210  	S0000242	4	5	474150.00	5084000.00
V0000340  	S0000208	8	9	478724.00	5019000.00
V0000189  	S0000191	2	1	273435.00	3873000.00
V0000490  	S0000197	2	1	69687.00	3437000.00
V0000200  	S0000143	1	10	658589.00	4648000.00
V0000430  	S000061 	4	4	597925.00	6419000.00
V0000356  	S0000247	3	6	266902.00	3703000.00
V0000152  	S000071 	7	6	176879.00	9223000.00
V0000449  	S0000249	5	3	908248.00	7130000.00
V0000125  	S0000165	3	7	338832.00	7679000.00
V0000427  	S0000165	3	2	338832.00	9396000.00
V000086   	S000062 	2	8	804056.00	8029000.00
V0000464  	S000014 	6	10	932664.00	8949000.00
V0000369  	S0000152	10	2	58225.00	1259000.00
V0000481  	S0000139	4	1	3485.00	8302000.00
V000076   	S000048 	1	2	544664.00	7257000.00
V0000248  	S0000189	10	5	462431.00	3984000.00
V0000466  	S0000233	4	1	457239.00	8463000.00
V0000181  	S0000189	4	10	462431.00	2427000.00
V0000166  	S00008  	9	9	779781.00	2345000.00
V0000447  	S0000199	6	6	625636.00	8094000.00
V0000232  	S000025 	9	3	317629.00	6565000.00
V0000159  	S0000232	8	8	11804.00	5693000.00
V0000477  	S000043 	6	2	917810.00	7462000.00
V000067   	S000076 	7	9	361822.00	2753000.00
V0000293  	S000098 	7	3	602906.00	7802000.00
V0000138  	S000056 	3	10	793166.00	8580000.00
V0000412  	S000044 	2	3	64538.00	8556000.00
V0000404  	S0000206	5	7	386772.00	7853000.00
V0000202  	S0000238	10	2	749502.00	6930000.00
V0000489  	S0000209	4	4	951637.00	5097000.00
V0000261  	S0000113	3	3	279266.00	4391000.00
V0000447  	S000067 	1	5	325691.00	8094000.00
V0000449  	S0000129	6	1	950593.00	7130000.00
V0000258  	S000079 	2	5	797783.00	264000.00
V0000346  	S000021 	3	5	457012.00	9139000.00
V000054   	S000094 	3	6	360121.00	3080000.00
V0000118  	S000035 	1	6	234142.00	6054000.00
V0000283  	S0000185	10	9	918522.00	9232000.00
V0000393  	S0000133	5	9	252486.00	1032000.00
V0000482  	S0000101	5	7	601618.00	7127000.00
V0000393  	S000029 	9	5	21269.00	1032000.00
V0000144  	S0000108	1	4	704199.00	1300000.00
V0000357  	S0000150	1	4	36613.00	1816000.00
V0000106  	S000021 	10	8	457012.00	4509000.00
V0000394  	S0000141	6	7	247401.00	1443000.00
V0000284  	S000081 	1	7	477553.00	7884000.00
V0000164  	S000092 	9	3	294908.00	4096000.00
V0000150  	S000045 	10	5	447138.00	5179000.00
V0000404  	S0000227	3	6	947455.00	7853000.00
V0000427  	S000031 	5	9	359577.00	9396000.00
V0000468  	S0000224	1	4	242642.00	9301000.00
V0000279  	S0000191	10	2	273435.00	5334000.00
V0000239  	S000080 	3	6	167442.00	8314000.00
V0000259  	S000048 	1	3	544664.00	9011000.00
V0000282  	S0000170	6	7	140729.00	8184000.00
V0000251  	S000027 	7	8	508865.00	4695000.00
V0000354  	S000073 	10	8	418512.00	7383000.00
V0000124  	S000077 	3	4	939216.00	5336000.00
V000045   	S0000250	2	4	744079.00	1849000.00
V0000374  	S00006  	3	8	807568.00	5024000.00
V0000495  	S0000242	3	6	474150.00	4247000.00
V0000151  	S000074 	1	3	859771.00	6519000.00
V0000243  	S000027 	5	5	508865.00	6147000.00
V0000431  	S0000109	6	2	23674.00	9824000.00
V0000255  	S000041 	6	4	198252.00	8396000.00
V0000396  	S0000246	5	1	791706.00	5229000.00
V0000384  	S000010 	4	6	523225.00	3247000.00
V0000361  	S0000136	9	9	304282.00	7922000.00
V0000326  	S00005  	3	2	16020.00	8510000.00
V0000377  	S0000173	3	1	277515.00	1971000.00
V0000427  	S000068 	10	1	583853.00	9396000.00
V00004    	S00004  	6	3	470694.00	3756000.00
V000032   	S000010 	8	1	523225.00	9642000.00
V000012   	S000040 	1	7	451419.00	6986000.00
V0000256  	S0000184	5	3	634948.00	8990000.00
V0000397  	S0000216	3	3	122362.00	6388000.00
V0000488  	S0000190	8	7	942849.00	2535000.00
V000087   	S0000134	3	10	796207.00	1323000.00
V00001    	S0000126	4	10	760092.00	4074000.00
V0000304  	S0000208	7	10	478724.00	2480000.00
V0000120  	S000037 	9	1	104770.00	6317000.00
V000015   	S0000111	3	1	344071.00	5719000.00
V0000145  	S000071 	7	5	176879.00	6151000.00
V0000491  	S0000238	5	8	749502.00	2335000.00
V0000469  	S000060 	5	8	695695.00	5926000.00
V0000365  	S000027 	7	5	508865.00	5498000.00
V000041   	S0000162	8	7	43628.00	8499000.00
V0000285  	S0000120	3	9	726454.00	6325000.00
V0000470  	S0000246	8	10	791706.00	1481000.00
V0000430  	S0000209	6	4	951637.00	6419000.00
V0000161  	S0000112	3	7	506803.00	1739000.00
V000067   	S0000204	2	1	587837.00	2753000.00
V000062   	S0000241	1	10	782966.00	2375000.00
V0000309  	S000021 	5	7	457012.00	112000.00
V0000334  	S0000142	1	5	289898.00	9191000.00
V0000461  	S0000173	5	5	277515.00	5288000.00
V0000126  	S000025 	9	3	317629.00	8623000.00
V0000354  	S000095 	1	6	611382.00	7383000.00
V0000243  	S00007  	2	4	825127.00	6147000.00
V0000206  	S0000202	4	8	381269.00	293000.00
V0000203  	S000019 	8	8	192485.00	7135000.00
V0000492  	S0000177	5	7	781962.00	9215000.00
V0000298  	S0000129	5	8	950593.00	3447000.00
V0000125  	S0000139	1	2	3485.00	7679000.00
V0000494  	S000017 	2	8	173318.00	4106000.00
V0000455  	S000019 	5	3	192485.00	3978000.00
V0000382  	S0000223	7	2	912544.00	5484000.00
V0000212  	S0000161	4	6	704054.00	4192000.00
V0000230  	S0000114	2	3	882536.00	2808000.00
V0000137  	S0000245	5	1	268609.00	857000.00
V0000368  	S000058 	3	3	318891.00	2742000.00
V00005    	S0000122	7	8	84465.00	6938000.00
V000071   	S000010 	6	8	523225.00	2718000.00
V0000246  	S0000200	9	8	438617.00	9209000.00
V00006    	S000079 	8	5	797783.00	7286000.00
V0000350  	S0000134	9	6	796207.00	7515000.00
V0000108  	S000074 	4	5	859771.00	9398000.00
V0000421  	S000018 	1	6	248384.00	5856000.00
V0000122  	S0000196	8	5	612371.00	8181000.00
V0000136  	S0000124	4	7	903018.00	2711000.00
V0000167  	S000088 	8	4	468264.00	9234000.00
V0000256  	S0000115	2	6	870609.00	8990000.00
V000093   	S000079 	6	7	797783.00	550000.00
V0000236  	S0000244	4	6	635633.00	9335000.00
V000054   	S0000230	2	8	178919.00	3080000.00
V0000382  	S0000216	4	1	122362.00	5484000.00
V0000195  	S000017 	3	7	173318.00	6883000.00
V000057   	S0000219	9	3	740107.00	2329000.00
V000031   	S0000195	9	2	28155.00	3696000.00
V0000194  	S00003  	3	10	940943.00	1404000.00
V0000250  	S00005  	1	9	16020.00	2446000.00
V0000417  	S000059 	10	3	224387.00	9287000.00
V000017   	S000028 	8	4	193935.00	8165000.00
V0000175  	S0000151	2	3	293586.00	8391000.00
V0000256  	S000039 	1	10	929519.00	8990000.00
V0000479  	S0000235	5	10	509335.00	7273000.00
V0000356  	S00006  	7	7	807568.00	3703000.00
V0000436  	S0000212	7	3	495617.00	6545000.00
V0000171  	S0000218	3	1	732825.00	504000.00
V0000487  	S000010 	7	2	523225.00	3249000.00
V0000348  	S000066 	6	1	892876.00	6822000.00
V0000213  	S0000157	10	9	527739.00	7111000.00
V0000382  	S00005  	6	10	16020.00	5484000.00
V0000344  	S0000139	9	5	3485.00	1909000.00
V000058   	S0000228	5	5	232606.00	4202000.00
V0000364  	S0000141	6	9	247401.00	4650000.00
V0000116  	S0000111	7	5	344071.00	7255000.00
V0000205  	S0000230	1	6	178919.00	1613000.00
V0000446  	S0000231	1	6	149737.00	3200000.00
V000015   	S0000213	5	2	704486.00	5719000.00
V0000467  	S000057 	3	6	597836.00	338000.00
V0000465  	S00007  	3	10	825127.00	3821000.00
V0000369  	S0000226	1	4	114249.00	1259000.00
V0000217  	S000084 	1	5	772416.00	7707000.00
V0000287  	S0000108	8	2	704199.00	8238000.00
V0000375  	S0000165	5	2	338832.00	8899000.00
V0000447  	S0000239	9	6	67372.00	8094000.00
V000015   	S0000242	6	8	474150.00	5719000.00
V0000419  	S000013 	5	2	766951.00	6062000.00
V0000246  	S0000149	6	5	114740.00	9209000.00
V0000303  	S000074 	6	3	859771.00	7442000.00
V0000182  	S0000227	5	10	947455.00	4578000.00
V00005    	S000033 	7	6	658266.00	6938000.00
V0000157  	S0000242	7	7	474150.00	9839000.00
V0000110  	S000062 	7	7	804056.00	4462000.00
V000027   	S000042 	3	7	276014.00	8238000.00
V0000452  	S000023 	5	6	630680.00	5520000.00
V000046   	S000087 	9	2	760984.00	6498000.00
V0000218  	S0000174	8	5	532517.00	3479000.00
V0000228  	S0000126	9	3	760092.00	2963000.00
V000016   	S0000111	9	7	344071.00	782000.00
V0000388  	S000094 	8	4	360121.00	7800000.00
V0000385  	S0000121	4	2	425952.00	7512000.00
V000018   	S0000167	2	1	955885.00	4674000.00
V0000461  	S0000122	2	7	84465.00	5288000.00
V0000343  	S000096 	2	10	468631.00	5397000.00
V0000254  	S0000178	1	4	633218.00	9799000.00
V0000390  	S0000199	10	4	625636.00	1711000.00
V0000162  	S000092 	8	4	294908.00	6402000.00
V0000290  	S0000146	1	9	890641.00	4542000.00
V0000133  	S000096 	6	9	468631.00	5315000.00
V0000388  	S000085 	5	3	966700.00	7800000.00
V0000433  	S000075 	1	8	210648.00	5042000.00
V0000341  	S0000124	1	4	903018.00	6357000.00
V0000159  	S000025 	8	9	317629.00	5693000.00
V0000437  	S0000227	1	5	947455.00	4852000.00
V000081   	S000066 	3	8	892876.00	8752000.00
V000061   	S0000199	5	2	625636.00	4204000.00
V0000403  	S000047 	4	4	711867.00	5479000.00
V0000251  	S0000190	2	2	942849.00	4695000.00
V0000319  	S0000109	1	8	23674.00	1551000.00
V0000417  	S0000250	10	1	744079.00	9287000.00
V0000233  	S0000111	10	8	344071.00	3689000.00
V0000389  	S000013 	9	3	766951.00	6051000.00
V0000150  	S000042 	4	6	276014.00	5179000.00
V0000151  	S000077 	7	5	939216.00	6519000.00
V0000362  	S0000205	10	7	844098.00	8899000.00
V0000152  	S0000188	2	7	920322.00	9223000.00
V0000330  	S0000154	6	2	202477.00	8639000.00
V000049   	S000032 	9	7	92195.00	2617000.00
V00004    	S0000102	5	3	6416.00	3756000.00
V0000257  	S000096 	7	5	468631.00	9898000.00
V0000372  	S00008  	3	6	779781.00	7976000.00
V0000246  	S0000141	1	2	247401.00	9209000.00
V0000242  	S000082 	4	1	735757.00	3057000.00
V000083   	S0000221	2	5	967645.00	8546000.00
V000096   	S00008  	8	6	779781.00	3201000.00
V0000313  	S000030 	3	2	185796.00	3688000.00
V0000348  	S000020 	10	7	21690.00	6822000.00
V000072   	S0000139	10	6	3485.00	9377000.00
V0000392  	S000019 	10	7	192485.00	3152000.00
V000042   	S000069 	5	8	37235.00	4034000.00
V0000275  	S000021 	5	7	457012.00	5580000.00
V0000372  	S000081 	5	7	477553.00	7976000.00
V000055   	S0000247	7	3	266902.00	2253000.00
V0000188  	S0000121	6	4	425952.00	4583000.00
V0000133  	S000074 	2	5	859771.00	5315000.00
V000076   	S0000136	6	6	304282.00	7257000.00
V0000252  	S0000180	4	1	495727.00	9552000.00
V0000451  	S000056 	1	4	793166.00	2481000.00
V000037   	S0000175	6	6	115761.00	672000.00
V0000457  	S0000136	2	1	304282.00	7472000.00
V0000360  	S000082 	7	4	735757.00	548000.00
V000048   	S000049 	1	4	232876.00	8320000.00
V000099   	S0000207	3	4	843223.00	1216000.00
V0000377  	S0000135	3	7	826060.00	1971000.00
V000090   	S0000149	1	3	114740.00	3815000.00
V000087   	S0000238	9	1	749502.00	1323000.00
V000044   	S0000225	10	2	235421.00	2965000.00
V0000100  	S000048 	6	7	544664.00	6292000.00
V0000335  	S0000205	4	8	844098.00	1284000.00
V000021   	S0000103	8	7	550870.00	7805000.00
V0000205  	S0000112	3	2	506803.00	1613000.00
V0000270  	S00003  	10	6	940943.00	265000.00
V000013   	S0000200	10	1	438617.00	8715000.00
V0000137  	S0000206	10	2	386772.00	857000.00
V0000309  	S000026 	1	7	625885.00	112000.00
V0000226  	S00003  	10	8	940943.00	4303000.00
V000091   	S000080 	3	5	167442.00	2236000.00
V000088   	S0000223	2	8	912544.00	4649000.00
V0000231  	S000097 	9	6	761494.00	3632000.00
V0000215  	S000023 	7	8	630680.00	6093000.00
V0000256  	S0000149	1	10	114740.00	8990000.00
V0000477  	S0000147	5	9	877351.00	7462000.00
V0000388  	S00006  	3	10	807568.00	7800000.00
V000092   	S0000205	10	9	844098.00	643000.00
V0000479  	S0000119	10	6	600809.00	7273000.00
V000039   	S0000157	6	4	527739.00	3885000.00
V0000191  	S00003  	8	10	940943.00	8324000.00
V0000433  	S000045 	7	6	447138.00	5042000.00
V000050   	S000047 	7	4	711867.00	5769000.00
V0000242  	S0000142	3	5	289898.00	3057000.00
V0000197  	S0000118	3	4	583138.00	1030000.00
V000087   	S0000201	4	1	480700.00	1323000.00
V000091   	S0000189	7	7	462431.00	2236000.00
V0000383  	S0000245	8	4	268609.00	7290000.00
V0000131  	S0000163	6	1	767084.00	5585000.00
V0000377  	S0000227	2	3	947455.00	1971000.00
V000031   	S0000145	3	5	271759.00	3696000.00
V0000219  	S000025 	2	10	317629.00	29000.00
V0000294  	S0000154	8	4	202477.00	3116000.00
V0000481  	S000012 	3	6	284549.00	8302000.00
V000012   	S000061 	9	6	597925.00	6986000.00
V0000118  	S0000114	9	8	882536.00	6054000.00
V0000440  	S000086 	8	3	301903.00	9774000.00
V0000242  	S000087 	4	7	760984.00	3057000.00
V000063   	S000077 	1	2	939216.00	4394000.00
V000081   	S0000127	1	1	205371.00	8752000.00
V00009    	S0000233	5	8	457239.00	5860000.00
V0000223  	S000086 	8	1	301903.00	1509000.00
V000063   	S0000129	2	4	950593.00	4394000.00
V0000388  	S0000171	4	6	875127.00	7800000.00
V000058   	S000088 	9	6	468264.00	4202000.00
V0000347  	S0000133	8	7	252486.00	598000.00
V0000186  	S0000146	8	5	890641.00	5625000.00
V000028   	S0000158	10	1	425769.00	4772000.00
V0000163  	S0000228	8	7	232606.00	5320000.00
V000053   	S0000223	9	8	912544.00	4231000.00
V0000479  	S0000162	1	8	43628.00	7273000.00
V0000126  	S0000246	2	6	791706.00	8623000.00
V0000122  	S0000240	5	9	583093.00	8181000.00
V0000450  	S000099 	9	3	466014.00	1457000.00
V0000148  	S0000112	1	5	506803.00	3323000.00
V0000467  	S0000218	3	8	732825.00	338000.00
V0000180  	S0000144	6	3	90059.00	764000.00
V0000460  	S0000232	10	10	11804.00	6193000.00
V000065   	S0000112	8	4	506803.00	7439000.00
V0000364  	S000056 	6	2	793166.00	4650000.00
V0000319  	S000065 	10	7	592870.00	1551000.00
V0000433  	S0000126	9	7	760092.00	5042000.00
V0000155  	S0000120	8	8	726454.00	788000.00
V0000281  	S0000122	7	5	84465.00	7185000.00
V0000260  	S000088 	10	8	468264.00	4924000.00
V0000392  	S0000233	9	3	457239.00	3152000.00
V0000358  	S0000217	8	3	193002.00	1324000.00
V0000377  	S0000115	3	10	870609.00	1971000.00
V00008    	S000072 	7	2	753044.00	9458000.00
V0000467  	S0000130	7	2	13137.00	338000.00
V0000208  	S000039 	10	8	929519.00	8962000.00
V0000211  	S0000158	8	3	425769.00	7844000.00
V0000233  	S000049 	10	9	232876.00	3689000.00
V0000248  	S0000149	4	2	114740.00	3984000.00
V0000137  	S0000132	8	8	400171.00	857000.00
V0000111  	S0000142	1	9	289898.00	2155000.00
V0000420  	S0000174	9	6	532517.00	3962000.00
V0000108  	S0000241	5	10	782966.00	9398000.00
V0000199  	S0000136	2	9	304282.00	5966000.00
V0000123  	S0000194	2	4	873946.00	4308000.00
V000091   	S000090 	7	4	981861.00	2236000.00
V0000308  	S000061 	9	3	597925.00	4491000.00
V0000431  	S0000232	5	3	11804.00	9824000.00
V0000248  	S0000184	10	8	634948.00	3984000.00
V0000428  	S000030 	3	1	185796.00	672000.00
V000076   	S000019 	3	5	192485.00	7257000.00
V0000295  	S0000181	2	8	734851.00	4845000.00
V0000407  	S0000116	8	8	328460.00	7624000.00
V000011   	S0000162	9	4	43628.00	5901000.00
V000053   	S0000201	3	5	480700.00	4231000.00
V0000260  	S0000190	10	6	942849.00	4924000.00
V0000307  	S0000100	1	4	458240.00	6878000.00
V0000244  	S0000149	4	9	114740.00	3351000.00
V0000201  	S0000235	9	1	509335.00	3270000.00
V0000406  	S0000190	6	4	942849.00	1813000.00
V0000206  	S0000230	6	9	178919.00	293000.00
V0000316  	S0000222	3	5	593023.00	112000.00
V0000100  	S0000185	10	2	918522.00	6292000.00
V0000103  	S000027 	7	1	508865.00	793000.00
V0000499  	S0000188	9	5	920322.00	570000.00
V0000230  	S000067 	3	1	325691.00	2808000.00
V0000117  	S000084 	3	6	772416.00	2761000.00
V0000344  	S0000214	8	1	569845.00	1909000.00
V0000435  	S000084 	6	8	772416.00	7914000.00
V0000366  	S0000216	7	1	122362.00	739000.00
V0000416  	S000045 	1	3	447138.00	1465000.00
V0000407  	S0000107	6	5	688007.00	7624000.00
V0000333  	S0000158	3	6	425769.00	9948000.00
V0000451  	S000088 	6	4	468264.00	2481000.00
V0000291  	S000059 	8	3	224387.00	8414000.00
V0000395  	S0000145	9	3	271759.00	1806000.00
V0000279  	S000081 	8	6	477553.00	5334000.00
V0000495  	S000078 	2	8	292372.00	4247000.00
V0000437  	S0000193	2	10	875495.00	4852000.00
V0000224  	S0000197	1	5	69687.00	8426000.00
V0000209  	S000063 	2	5	554.00	3807000.00
V0000387  	S0000154	6	1	202477.00	4024000.00
V0000215  	S0000158	10	3	425769.00	6093000.00
V0000483  	S000015 	5	3	379100.00	6044000.00
V0000121  	S000095 	8	6	611382.00	7597000.00
V0000343  	S000092 	4	8	294908.00	5397000.00
V0000406  	S0000212	9	1	495617.00	1813000.00
V0000427  	S0000206	1	6	386772.00	9396000.00
V0000331  	S0000187	2	10	57520.00	3154000.00
V0000195  	S0000177	10	4	781962.00	6883000.00
V000048   	S000043 	9	8	917810.00	8320000.00
V00001    	S0000186	4	3	516523.00	4074000.00
V0000436  	S000013 	9	4	766951.00	6545000.00
V000058   	S0000108	3	8	704199.00	4202000.00
V0000298  	S0000183	9	5	243214.00	3447000.00
V0000122  	S000065 	8	8	592870.00	8181000.00
V0000312  	S000031 	10	2	359577.00	4560000.00
V0000249  	S0000123	3	3	117639.00	8988000.00
V0000280  	S0000216	2	6	122362.00	8330000.00
V0000347  	S000063 	9	9	554.00	598000.00
V0000361  	S0000166	7	5	698576.00	7922000.00
V0000409  	S000021 	5	8	457012.00	5899000.00
V0000331  	S0000109	9	10	23674.00	3154000.00
V0000131  	S0000130	9	1	13137.00	5585000.00
V00006    	S0000187	3	9	57520.00	7286000.00
V000067   	S0000238	5	6	749502.00	2753000.00
V0000195  	S000047 	4	6	711867.00	6883000.00
V0000455  	S0000176	10	7	588149.00	3978000.00
V0000344  	S000064 	5	4	73363.00	1909000.00
V0000138  	S0000167	3	7	955885.00	8580000.00
V0000317  	S0000113	7	6	279266.00	1155000.00
V0000316  	S0000212	1	5	495617.00	112000.00
V0000112  	S00002  	4	1	169643.00	1934000.00
V0000262  	S0000200	5	3	438617.00	7397000.00
V0000334  	S0000117	10	2	595375.00	9191000.00
V0000326  	S000068 	7	7	583853.00	8510000.00
V0000111  	S000077 	2	10	939216.00	2155000.00
V0000250  	S0000220	1	5	457589.00	2446000.00
V0000337  	S0000134	8	8	796207.00	228000.00
V0000125  	S0000128	5	2	888318.00	7679000.00
V0000381  	S0000182	9	6	256560.00	9963000.00
V000084   	S0000226	4	1	114249.00	4284000.00
V000039   	S0000184	2	3	634948.00	3885000.00
V000070   	S0000229	6	6	179010.00	3890000.00
V0000156  	S0000194	3	8	873946.00	7120000.00
V0000132  	S00003  	5	3	940943.00	853000.00
V0000192  	S0000129	4	7	950593.00	1848000.00
V000067   	S0000215	4	8	918114.00	2753000.00
V0000202  	S000030 	5	5	185796.00	6930000.00
V0000285  	S0000127	2	10	205371.00	6325000.00
V0000103  	S0000153	3	7	657533.00	793000.00
V0000241  	S000043 	9	10	917810.00	8037000.00
V000078   	S0000249	3	5	908248.00	920000.00
V0000336  	S0000140	1	6	240447.00	4579000.00
V0000175  	S0000180	4	1	495727.00	8391000.00
V0000296  	S000044 	3	6	64538.00	7602000.00
V0000139  	S0000180	8	1	495727.00	1690000.00
V0000175  	S0000176	5	10	588149.00	8391000.00
V0000215  	S0000151	8	9	293586.00	6093000.00
V0000466  	S000075 	8	4	210648.00	8463000.00
V0000184  	S0000207	6	1	843223.00	2337000.00
V0000188  	S0000133	4	5	252486.00	4583000.00
V0000359  	S0000118	3	8	583138.00	5421000.00
V0000459  	S0000134	9	8	796207.00	5019000.00
V0000407  	S0000172	9	5	365621.00	7624000.00
V000047   	S0000195	5	8	28155.00	6980000.00
V0000258  	S0000205	5	10	844098.00	264000.00
V0000474  	S0000147	4	3	877351.00	5268000.00
V0000385  	S0000151	8	10	293586.00	7512000.00
V0000469  	S0000199	10	3	625636.00	5926000.00
V0000392  	S000070 	3	5	285708.00	3152000.00
V0000481  	S000036 	5	9	271392.00	8302000.00
V0000486  	S0000103	3	10	550870.00	2545000.00
V0000475  	S0000151	8	5	293586.00	2167000.00
V0000190  	S0000235	7	10	509335.00	1947000.00
V000022   	S000010 	7	9	523225.00	7622000.00
V0000259  	S000098 	7	6	602906.00	9011000.00
V0000224  	S0000209	9	3	951637.00	8426000.00
V000065   	S000070 	6	4	285708.00	7439000.00
V0000360  	S0000209	6	7	951637.00	548000.00
V0000378  	S0000192	4	7	902721.00	9223000.00
V0000200  	S0000232	1	9	11804.00	4648000.00
V0000329  	S0000118	10	4	583138.00	5404000.00
V0000153  	S0000118	4	4	583138.00	1322000.00
V0000206  	S0000190	5	9	942849.00	293000.00
V0000210  	S0000195	6	7	28155.00	5084000.00
V0000456  	S0000117	1	8	595375.00	757000.00
V000090   	S000049 	9	2	232876.00	3815000.00
V0000370  	S0000169	3	9	659235.00	5083000.00
V000043   	S0000143	10	6	658589.00	6063000.00
V0000352  	S000031 	4	1	359577.00	3410000.00
V0000134  	S0000244	4	4	635633.00	2495000.00
V000053   	S0000105	6	8	194202.00	4231000.00
V0000467  	S0000229	7	7	179010.00	338000.00
V000097   	S0000171	10	9	875127.00	1323000.00
V000025   	S00004  	1	3	470694.00	8930000.00
V000041   	S000081 	4	6	477553.00	8499000.00
V0000389  	S000043 	5	6	917810.00	6051000.00
V0000209  	S0000236	4	6	865708.00	3807000.00
V0000404  	S00001  	5	2	754067.00	7853000.00
V000012   	S000014 	3	5	932664.00	6986000.00
V0000361  	S000026 	2	8	625885.00	7922000.00
V0000391  	S0000174	2	10	532517.00	1532000.00
V0000406  	S0000119	6	2	600809.00	1813000.00
V000073   	S000050 	2	7	611213.00	1011000.00
V0000112  	S0000227	2	8	947455.00	1934000.00
V0000333  	S000026 	8	8	625885.00	9948000.00
V0000197  	S000031 	7	1	359577.00	1030000.00
V0000362  	S000081 	6	8	477553.00	8899000.00
V0000392  	S000046 	3	8	338218.00	3152000.00
V0000103  	S0000176	1	7	588149.00	793000.00
V0000318  	S0000130	7	9	13137.00	1899000.00
V0000286  	S0000145	3	10	271759.00	5411000.00
V0000347  	S000044 	8	6	64538.00	598000.00
V0000274  	S0000113	9	7	279266.00	8077000.00
V0000173  	S000047 	4	9	711867.00	1865000.00
V0000295  	S0000234	1	5	124374.00	4845000.00
V000019   	S000013 	5	10	766951.00	2695000.00
V0000144  	S0000134	1	7	796207.00	1300000.00
V0000211  	S0000105	10	4	194202.00	7844000.00
V0000207  	S00009  	9	10	655428.00	5388000.00
V0000278  	S0000225	1	5	235421.00	8801000.00
V0000145  	S0000185	7	10	918522.00	6151000.00
V00009    	S000042 	10	7	276014.00	5860000.00
V0000178  	S0000222	8	2	593023.00	3261000.00
V0000401  	S0000150	8	7	36613.00	7899000.00
V0000234  	S000019 	1	5	192485.00	4636000.00
V0000112  	S0000116	10	1	328460.00	1934000.00
V000055   	S0000224	8	3	242642.00	2253000.00
V0000470  	S000016 	2	3	218377.00	1481000.00
V0000272  	S0000248	2	6	93555.00	9623000.00
V000026   	S0000141	6	1	247401.00	552000.00
V000037   	S0000226	5	10	114249.00	672000.00
V0000422  	S0000219	8	4	740107.00	3507000.00
V0000124  	S0000250	4	6	744079.00	5336000.00
V0000491  	S000099 	8	2	466014.00	2335000.00
V0000269  	S000041 	1	4	198252.00	9256000.00
V0000446  	S0000171	1	7	875127.00	3200000.00
V0000115  	S0000178	7	9	633218.00	59000.00
V000022   	S0000147	3	1	877351.00	7622000.00
V0000336  	S000013 	6	8	766951.00	4579000.00
V0000297  	S000085 	2	9	966700.00	3446000.00
V0000190  	S000028 	4	8	193935.00	1947000.00
V0000247  	S0000186	10	9	516523.00	8290000.00
V0000167  	S000016 	10	8	218377.00	9234000.00
V000071   	S0000182	5	5	256560.00	2718000.00
V0000112  	S0000242	8	10	474150.00	1934000.00
V00004    	S0000155	6	4	208067.00	3756000.00
V0000260  	S0000129	7	9	950593.00	4924000.00
V0000130  	S0000250	2	1	744079.00	4243000.00
V0000225  	S0000240	5	8	583093.00	4622000.00
V0000314  	S0000227	8	9	947455.00	5433000.00
V0000170  	S000089 	1	8	869651.00	4960000.00
V0000134  	S0000102	3	5	6416.00	2495000.00
V0000478  	S000082 	5	3	735757.00	6226000.00
V000039   	S0000218	8	5	732825.00	3885000.00
V0000134  	S0000106	2	4	835538.00	2495000.00
V0000463  	S0000202	2	10	381269.00	2375000.00
V0000189  	S0000239	7	1	67372.00	3873000.00
V0000184  	S000032 	10	2	92195.00	2337000.00
V0000405  	S0000242	4	6	782966.00	2629000.00
V0000245  	S000020 	9	4	271392.00	4462000.00
V0000110  	S000042 	6	8	470694.00	4462000.00
V0000235  	S0000120	4	3	313830.00	8564000.00
\.


--
-- Data for Name: pelanggan; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY pelanggan (email, is_penjual, nilai_reputasi, poin) FROM stdin;
emilystephens@dayrep.com	f	\N	71370
atitterrell0@pagesperso-orange.fr	f	\N	922
gcopes1@earthlink.net	f	\N	572
bfalshaw2@about.me	f	\N	565
gjanning3@opensource.org	f	\N	87
dhurne4@nydailynews.com	f	\N	831
mgarric5@amazon.de	f	\N	946
amardling6@typepad.com	f	\N	882
cbeaman7@instagram.com	f	\N	249
hborn8@sakura.ne.jp	f	\N	542
oernshaw9@ycombinator.com	f	\N	522
castlesa@paginegialle.it	f	\N	205
ebridgwoodb@fotki.com	f	\N	5
lfendleyc@amazon.co.uk	f	\N	958
sdadsond@qq.com	f	\N	780
dreefe@springer.com	f	\N	812
msapwellf@wikimedia.org	f	\N	597
sgrigollig@weather.com	f	\N	957
vhabbeshawh@ifeng.com	f	\N	561
minksteri@aol.com	f	\N	977
rpitwayj@elegantthemes.com	f	\N	632
twormleightonk@dagondesign.com	f	\N	176
adortonl@nytimes.com	f	\N	265
lbarbrookm@google.co.uk	f	\N	348
gtofanon@ustream.tv	f	\N	804
fboheao@baidu.com	f	\N	823
wfullylovep@aboutads.info	f	\N	745
kaleevyq@msn.com	f	\N	790
ntrevorr@fc2.com	f	\N	266
rosesnanes@nationalgeographic.com	f	\N	900
cbakhrushint@reddit.com	f	\N	57
mepinoyu@51.la	f	\N	174
bambersonv@wp.com	f	\N	577
gpickervancew@va.gov	f	\N	491
ggamesonx@webs.com	f	\N	335
hduffieldy@bloglovin.com	f	\N	779
fexrollz@squarespace.com	f	\N	616
vmolyneaux10@google.com.au	f	\N	444
nrodda11@hibu.com	f	\N	191
vgissing12@google.fr	f	\N	136
djentle13@live.com	f	\N	49
gmorgans14@nba.com	f	\N	545
wgoldingay15@shop-pro.jp	f	\N	939
nleither16@google.it	f	\N	719
rpigott17@vimeo.com	f	\N	27
lgreenig18@loc.gov	f	\N	585
lcrichley19@noaa.gov	f	\N	577
hlinklet1a@answers.com	f	\N	493
lbottom1b@blinklist.com	f	\N	121
rjodrelle1c@latimes.com	f	\N	581
mpattison1d@spotify.com	f	\N	483
ebewfield1e@icio.us	f	\N	952
evinas1f@stanford.edu	f	\N	281
mmasserel1g@epa.gov	f	\N	842
fmasic1h@prweb.com	f	\N	522
mrobert1i@pcworld.com	f	\N	645
hcastanaga1j@fda.gov	f	\N	356
pgrollmann1k@posterous.com	f	\N	398
claraway1l@parallels.com	f	\N	646
pshillington1m@usda.gov	f	\N	711
klind1n@diigo.com	f	\N	447
bstukings1o@elpais.com	f	\N	496
ccheale1p@bbc.co.uk	f	\N	158
rmullin1q@google.co.uk	f	\N	241
cleet1r@infoseek.co.jp	f	\N	818
mtooley1s@storify.com	f	\N	885
hjonathon1t@google.ca	f	\N	765
mradsdale1u@imdb.com	f	\N	396
mthebeau1v@ed.gov	f	\N	560
owoolliams1w@unc.edu	f	\N	347
sbwy1x@xing.com	f	\N	428
rreeson1y@cnet.com	f	\N	511
hbeloe1z@freewebs.com	f	\N	282
jsedgeman20@sourceforge.net	f	\N	736
mkleen21@tumblr.com	f	\N	592
glarmett22@reuters.com	f	\N	496
sokeenan23@csmonitor.com	f	\N	12
kviles24@1688.com	f	\N	604
ehegley25@seattletimes.com	f	\N	827
rexley26@barnesandnoble.com	f	\N	862
elamcken27@hud.gov	f	\N	77
hgisborne28@slashdot.org	f	\N	903
zheaton29@va.gov	f	\N	805
pbroadbear2a@indiatimes.com	f	\N	348
fburkman2b@twitpic.com	f	\N	57
cseamans2c@indiatimes.com	f	\N	997
rhallick2d@shutterfly.com	f	\N	731
nwemm2e@meetup.com	f	\N	931
boxtoby2f@zdnet.com	f	\N	876
mborlease2g@com.com	f	\N	624
snavein2h@yolasite.com	f	\N	702
lfalkner2i@cpanel.net	f	\N	321
csiegertsz2j@columbia.edu	f	\N	63
reckh2k@123-reg.co.uk	f	\N	503
jradage2l@blogtalkradio.com	f	\N	878
ktilbey2m@freewebs.com	f	\N	408
vkippie2n@google.ru	f	\N	72
mmobley2o@mac.com	f	\N	457
lbambrick2p@sfgate.com	f	\N	267
dcaulfield2q@dmoz.org	f	\N	199
fportinari2r@cdc.gov	f	\N	307
mpowney2s@over-blog.com	f	\N	101
wzanini2t@yahoo.co.jp	f	\N	614
istreeton2u@yellowbook.com	f	\N	355
bwollers2v@usnews.com	f	\N	132
blemasney2w@yelp.com	f	\N	107
rdametti2x@narod.ru	f	\N	965
jdinesen2y@vimeo.com	f	\N	155
aodevey2z@prlog.org	f	\N	958
lradnage30@canalblog.com	f	\N	882
kjuorio31@t.co	f	\N	19
ldoore32@loc.gov	f	\N	151
smeachen33@chronoengine.com	f	\N	501
eduddle34@redcross.org	f	\N	692
tjohnsson35@gizmodo.com	f	\N	496
rbuckland36@last.fm	f	\N	342
lshillingford37@godaddy.com	f	\N	647
hstapleton38@geocities.com	f	\N	518
kbreukelman39@dot.gov	f	\N	490
odredge3a@sogou.com	f	\N	62
sde3b@trellian.com	f	\N	536
md3c@about.com	f	\N	993
rhouldey3d@latimes.com	f	\N	59
bmacmanus3e@arstechnica.com	f	\N	189
gbonifazio3f@adobe.com	f	\N	696
kde3g@ebay.co.uk	f	\N	263
apacher3h@etsy.com	f	\N	887
mvedikhov3i@linkedin.com	f	\N	245
hlodford3j@slate.com	f	\N	522
ireadhead3k@is.gd	f	\N	589
jalenshev3l@sciencedaily.com	f	\N	400
mhallagan3m@psu.edu	f	\N	319
pworsfold3n@chron.com	f	\N	551
paskem3o@yale.edu	f	\N	822
mvern3p@godaddy.com	f	\N	855
kkilmister3q@indiatimes.com	f	\N	653
plorenz3r@fotki.com	f	\N	685
awestphalen3s@desdev.cn	f	\N	275
bcradick3t@squidoo.com	f	\N	831
adwelly3u@pen.io	f	\N	284
ahaverson3v@columbia.edu	f	\N	483
dedgell3w@ebay.co.uk	f	\N	832
apetrasek3x@cocolog-nifty.com	f	\N	990
sphidgin3y@newyorker.com	f	\N	20
sbellward3z@google.com	f	\N	860
vmessruther40@fc2.com	f	\N	151
rhaselhurst41@netvibes.com	f	\N	120
egiles42@sitemeter.com	f	\N	492
uguiducci43@istockphoto.com	f	\N	476
cchastenet44@jiathis.com	f	\N	411
ghurleston45@netlog.com	f	\N	747
mcollyns46@1und1.de	f	\N	714
cvigars47@irs.gov	f	\N	75
ldoram48@xrea.com	f	\N	995
agatrell49@slate.com	f	\N	147
cbrumen4a@skype.com	f	\N	853
cabby4b@cyberchimps.com	f	\N	827
tadame4c@alexa.com	f	\N	174
lcolicot4d@behance.net	f	\N	941
owoollam4e@amazonaws.com	f	\N	587
bweaver4f@ebay.com	f	\N	459
cmcwhin4g@gizmodo.com	f	\N	176
stither4h@google.ru	f	\N	879
fkynston4i@fda.gov	f	\N	523
rmooney4j@theatlantic.com	f	\N	102
sklimentov4k@creativecommons.org	f	\N	316
rmouland4l@psu.edu	f	\N	644
bbisseker4m@g.co	f	\N	649
dbasire4n@nasa.gov	f	\N	981
gzapata4o@slideshare.net	f	\N	745
kstieger4p@imgur.com	f	\N	565
nrentoll4q@nytimes.com	f	\N	974
pnursey4r@myspace.com	f	\N	940
aslides4s@fotki.com	f	\N	170
vburchill4t@sohu.com	f	\N	492
ao4u@posterous.com	f	\N	341
yseago4v@geocities.com	f	\N	690
gberthouloume4w@delicious.com	f	\N	907
vcarlton4x@jimdo.com	f	\N	712
lmaunders4y@google.ca	f	\N	13
cdrysdale4z@dell.com	f	\N	386
scoppo50@facebook.com	f	\N	225
mquittonden51@acquirethisname.com	f	\N	408
bgenders52@noaa.gov	f	\N	774
rdidball53@webs.com	f	\N	861
rharcarse54@buzzfeed.com	f	\N	39
lehrat55@spiegel.de	f	\N	643
bbryant56@bbc.co.uk	f	\N	828
sdufer57@yellowbook.com	f	\N	686
mcrichmer58@mac.com	f	\N	681
rstump59@thetimes.co.uk	f	\N	532
ptesh5a@salon.com	f	\N	691
kantoniat5b@hc360.com	f	\N	442
hluney5c@bloglovin.com	f	\N	134
dbeagin5d@barnesandnoble.com	f	\N	428
jjeffcoat5e@npr.org	f	\N	323
cshrimptone5f@gov.uk	f	\N	633
umordacai5g@last.fm	f	\N	965
ffarncombe5h@theguardian.com	f	\N	859
amilstead5i@umich.edu	f	\N	982
atrowler5j@apple.com	f	\N	357
drojel5k@merriam-webster.com	f	\N	881
nverlinde5l@globo.com	f	\N	518
gwhitsun5m@china.com.cn	f	\N	295
epotte5n@redcross.org	f	\N	484
rbuxey5o@scientificamerican.com	f	\N	91
tskittreal5p@360.cn	f	\N	857
kdibdale5q@bandcamp.com	f	\N	353
jwillard5r@51.la	f	\N	786
agrimestone5s@jimdo.com	f	\N	164
gtaggett5t@over-blog.com	f	\N	377
lkobpac5u@nih.gov	f	\N	620
awinchurst5v@cloudflare.com	f	\N	218
istoate5w@wix.com	f	\N	312
mmcfadden5x@live.com	f	\N	922
mpietasch5y@nsw.gov.au	f	\N	705
mdraysay5z@weibo.com	f	\N	333
scantu60@icio.us	f	\N	388
tblackway61@51.la	f	\N	599
ryedall62@arizona.edu	f	\N	977
gkristoffersen63@businesswire.com	f	\N	499
cnewling64@hc360.com	f	\N	821
medgell65@arizona.edu	f	\N	996
erihanek66@surveymonkey.com	f	\N	192
carchambault67@cam.ac.uk	f	\N	4
gtackell68@rambler.ru	f	\N	968
msaltsberger69@hud.gov	f	\N	461
csaladine6a@businesswire.com	f	\N	183
amcsparran6b@springer.com	f	\N	281
fsothern6c@dailymail.co.uk	f	\N	390
mmcgarvey6d@yellowbook.com	f	\N	603
kmiddlemiss6e@umn.edu	f	\N	633
jguice6f@cyberchimps.com	f	\N	47
astandell6g@washington.edu	f	\N	453
mkeays6h@posterous.com	f	\N	723
fdarrington6i@unblog.fr	f	\N	695
svezey6j@va.gov	f	\N	451
servine6k@macromedia.com	f	\N	566
kchastelain6l@ucsd.edu	f	\N	94
forudden6m@webeden.co.uk	f	\N	223
jhaggerstone6n@cisco.com	f	\N	530
abinnes6o@pcworld.com	f	\N	216
leason6p@wufoo.com	f	\N	188
msteggals6q@ox.ac.uk	f	\N	358
pmccague6r@a8.net	f	\N	53
sricardin6s@furl.net	f	\N	814
ntye6t@dyndns.org	f	\N	477
jwheelwright6u@i2i.jp	f	\N	862
wnotman6v@istockphoto.com	f	\N	76
zbaybutt6w@cafepress.com	f	\N	244
olindeboom6x@adobe.com	f	\N	16
fpavie0@irs.gov	t	4.5	\N
fcrone1@addtoany.com	t	4.6	\N
mbompas2@netvibes.com	t	2.9	\N
droyce3@vinaora.com	t	1.0	\N
krubberts4@jiathis.com	t	3.7	\N
dshowering5@elegantthemes.com	t	1.4	\N
ltootin6@livejournal.com	t	2.3	\N
ssinnatt7@narod.ru	t	2.8	\N
smaiden8@forbes.com	t	4.5	\N
vback9@tamu.edu	t	1.4	\N
droistonea@archive.org	t	0.3	\N
habrahamovitzb@ameblo.jp	t	0.9	\N
bgrubbec@biblegateway.com	t	2.1	\N
bghidolid@feedburner.com	t	3.9	\N
kpeachmente@exblog.jp	t	3.3	\N
rwhitemanf@microsoft.com	t	3.5	\N
mmcvickerg@bluehost.com	t	5.0	\N
jspenleyh@cisco.com	t	0.3	\N
mheildsi@yahoo.co.jp	t	0.7	\N
biannelloj@chron.com	t	4.5	\N
rarunowiczk@shinystat.com	t	3.3	\N
ggeroldl@imgur.com	t	2.1	\N
rjohniganm@ifeng.com	t	3.9	\N
tselbyn@hhs.gov	t	4.2	\N
lchristoforo@house.gov	t	1.0	\N
dajsikp@yale.edu	t	2.9	\N
cfarringtonq@bbb.org	t	0.3	\N
shartlandr@issuu.com	t	3.6	\N
akyrkemans@sohu.com	t	3.2	\N
rinesont@wikipedia.org	t	2.1	\N
rsatcheru@jalbum.net	t	3.5	\N
haysikv@miitbeian.gov.cn	t	4.4	\N
rdiw@bigcartel.com	t	2.7	\N
wambrogiox@friendfeed.com	t	0.8	\N
obartoszinskiy@jalbum.net	t	0.4	\N
bmcknockiterz@adobe.com	t	3.9	\N
gelderbrant10@woothemes.com	t	0.4	\N
dsilverton11@mysql.com	t	4.1	\N
bdionis12@scribd.com	t	3.3	\N
zbroomhall13@mac.com	t	3.3	\N
gallsup14@fema.gov	t	4.6	\N
hclavey15@engadget.com	t	0.8	\N
ahinkley16@quantcast.com	t	3.4	\N
oben17@mozilla.com	t	3.6	\N
aranyard18@springer.com	t	2.8	\N
elerwell19@ucoz.com	t	0.3	\N
aparkman1a@blogtalkradio.com	t	3.1	\N
tgingold1b@histats.com	t	2.8	\N
lbambra1c@a8.net	t	1.6	\N
vkoomar1d@fema.gov	t	4.3	\N
spabelik1e@ibm.com	t	3.4	\N
rdelacourt1f@smh.com.au	t	3.6	\N
iniche1g@technorati.com	t	0.8	\N
teykelhof1h@com.com	t	4.3	\N
hwillden1i@fastcompany.com	t	1.2	\N
jhadaway1j@icq.com	t	3.7	\N
dsparrowhawk1k@odnoklassniki.ru	t	1.0	\N
lkyston1l@unblog.fr	t	0.4	\N
jisworth1m@sourceforge.net	t	1.6	\N
tmeader1n@fotki.com	t	0.4	\N
ashillington1o@ycombinator.com	t	0.2	\N
wleavesley1p@reddit.com	t	0.7	\N
skleisle1q@mayoclinic.com	t	4.1	\N
vpowder1r@ucoz.ru	t	0.1	\N
jvennard1s@unc.edu	t	0.6	\N
kdawdary1t@springer.com	t	3.3	\N
mbayford1u@slideshare.net	t	3.5	\N
mmuggach1v@army.mil	t	0.4	\N
cdufore1w@ucoz.ru	t	4.3	\N
sferrao1x@sciencedirect.com	t	4.6	\N
pthackwray1y@altervista.org	t	3.2	\N
cpavek1z@sciencedirect.com	t	4.1	\N
sebbles20@ovh.net	t	2.1	\N
sbartolomeotti21@samsung.com	t	2.4	\N
jpaschke22@java.com	t	3.0	\N
sblevin23@webnode.com	t	4.4	\N
mworwood24@1688.com	t	3.6	\N
sosborn25@fastcompany.com	t	0.5	\N
acallum26@jiathis.com	t	3.1	\N
cbrickhill27@skyrock.com	t	3.8	\N
adanbrook28@java.com	t	0.3	\N
bridges29@miibeian.gov.cn	t	2.0	\N
dguyonneau2a@disqus.com	t	0.7	\N
hsealey2b@dagondesign.com	t	4.4	\N
rtrevain2c@posterous.com	t	2.9	\N
fkingsworth2d@ox.ac.uk	t	3.0	\N
cduncanson2e@mayoclinic.com	t	1.4	\N
vcarnier2f@virginia.edu	t	4.8	\N
cmiddler2g@flickr.com	t	4.8	\N
pwelham2h@pen.io	t	2.8	\N
djessope2i@yellowpages.com	t	2.7	\N
sjobern2j@mozilla.org	t	4.3	\N
jeakley2k@yolasite.com	t	3.6	\N
jadamsky2l@constantcontact.com	t	0.7	\N
acheetam2m@is.gd	t	4.9	\N
dbeddoes2n@alibaba.com	t	4.3	\N
dswansborough2o@harvard.edu	t	3.1	\N
hfoley2p@istockphoto.com	t	3.0	\N
rboffey2q@ebay.co.uk	t	2.6	\N
mskaife2r@ca.gov	t	2.9	\N
\.


--
-- Data for Name: pengguna; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY pengguna (email, password, nama, jenis_kelamin, tgl_lahir, no_telp, alamat) FROM stdin;
fpavie0@irs.gov	So4tBqn0t7kc	Flossy Pavie	P	1983-08-01	85887517620	Jl. Hansons no. 10, San Salvador
fcrone1@addtoany.com	7AnDJTV	Foster Crone	L	1964-05-14	89429355210	Jl. Nevada no. 748, Warudoyong
mbompas2@netvibes.com	JjhOWmrlbOz3	Meredith Bompas	L	1950-09-13	80559691121	Jl. Maple no. 247, Pasrur 51480
droyce3@vinaora.com	hhC6JbWUzUW	Dalis Royce	L	1991-04-30	85164747642	Jl. Division no. 203, Batakte
krubberts4@jiathis.com	x8vXhECJ8	Katti Rubberts	L	1972-10-14	85729359848	Jl. Chive no. 529, Artesian¢n
dshowering5@elegantthemes.com	uKnbJIijDYlK	Donavon Showering	L	1949-11-15	84691319130	Jl. Weeping Birch no. 769, Wadi
ltootin6@livejournal.com	1ix3qJ	Lauri Tootin	P	1961-07-09	87987437465	Jl. Northland no. 978, Tochio-honcho 955-0156
ssinnatt7@narod.ru	QQlA98	Sile Sinnatt	P	1994-02-01	86303357588	Jl. Heffernan no. 146, Monze
smaiden8@forbes.com	SnZIiu	Saul Maiden	P	1965-09-26	89413003584	Jl. Spaight no. 188, Lazaro Cardenas 27944
vback9@tamu.edu	w7J13ochPI	Verine Back	L	1963-05-24	85457266989	Jl. 7th no. 692, Satun 23120
droistonea@archive.org	eq1hbYB	Dorie Roistone	P	1979-03-10	85477770243	Jl. Heffernan no. 640, ™rbyhus 748 94
habrahamovitzb@ameblo.jp	aBxiUMEPreqb	Hill Abrahamovitz	P	1946-09-14	82623794146	Jl. Westend no. 636, Vouani
bgrubbec@biblegateway.com	Hzy3E8n0ji	Brod Grubbe	L	1983-12-29	84931898629	Jl. Bobwhite no. 543, Yorii 838-0813
bghidolid@feedburner.com	1jkZpFoC1	Bertrando Ghidoli	P	1987-02-25	81091389281	Jl. Londonderry no. 15, Chipaque 251808
kpeachmente@exblog.jp	LfbwxN	Kathye Peachment	L	1940-02-11	83180014478	Jl. 4th no. 764, Huoxian
rwhitemanf@microsoft.com	t3fOjq1fsNCC	Rees Whiteman	P	1954-05-12	83627133740	Jl. Express no. 316, Pacatuba 49970-000
mmcvickerg@bluehost.com	D8Eeb5	Marc McVicker	P	1975-06-29	88879161256	Jl. Marcy no. 119, Sifangxi
jspenleyh@cisco.com	UiO8MXIH91x	Josi Spenley	P	1996-02-03	86893630837	Jl. Grover no. 991, Nongoma 3950
mheildsi@yahoo.co.jp	S9TxAfbKk	Mollee Heilds	L	1988-03-28	88424721325	Jl. Oakridge no. 990, Laojieji
biannelloj@chron.com	yImXiaiu1	Barret Iannello	L	1956-01-31	81544573937	Jl. Pine View no. 629, Ronggo
rarunowiczk@shinystat.com	R0eaP7m	Roanna Arunowicz	L	1991-10-15	85564746467	Jl. Ohio no. 972, Xiangquan
ggeroldl@imgur.com	WFkwHFVdt	Guillemette Gerold	L	1999-11-10	84837759072	Jl. Lindbergh no. 754, Miribanteng
rjohniganm@ifeng.com	KRgxKPaL0lzN	Reynold Johnigan	L	1986-11-03	83909246250	Jl. Helena no. 517, Wujiabao
tselbyn@hhs.gov	ns5BcQIFMY	Travers Selby	P	1957-01-03	82425122089	Jl. Linden no. 320, Sassandra
lchristoforo@house.gov	d2jP6ADp1HYg	Lacie Christofor	P	1932-07-21	84092396280	Jl. Eliot no. 877, Frantiskovy L zne 351 01
dajsikp@yale.edu	4BOPZ0Rh	Darryl Ajsik	P	2000-10-31	80396730659	Jl. Parkside no. 857, Songnan
cfarringtonq@bbb.org	TY5Odshv	Chelsie Farrington	P	1948-03-14	88653316089	Jl. Michigan no. 864, Hobart 7808
shartlandr@issuu.com	QHgxhIJ4vJF	Saunderson Hartland	L	1957-04-09	81525068758	Jl. South no. 959, Gasto£ni
akyrkemans@sohu.com	3WP2hvHo	Antoine Kyrkeman	P	1992-03-19	87855769035	Jl. Mesta no. 491, Marks 413093
rinesont@wikipedia.org	fM7jXoK	Rosabel Ineson	P	1975-10-03	86063968995	Jl. Fulton no. 280, Myhove
rsatcheru@jalbum.net	nnKChGR4a	Renie Satcher	P	1999-09-24	88122309491	Jl. Stuart no. 32, Toronto M7A
haysikv@miitbeian.gov.cn	xvoSMof	Hedvige Aysik	L	1965-07-23	84956246584	Jl. Anniversary no. 876, Fuji 969-7208
rdiw@bigcartel.com	rvMMEzOTMz4	Randee Di Biaggi	P	1989-07-10	85993095006	Jl. Tony no. 497, Toukh
wambrogiox@friendfeed.com	2WtaNNCq	Waneta Ambrogio	L	1940-11-11	87228386071	Jl. Gulseth no. 412, Kagadi
obartoszinskiy@jalbum.net	VrdDT4EILv	Orsa Bartoszinski	L	1939-03-13	88685831809	Jl. Knutson no. 789, Guishan
bmcknockiterz@adobe.com	SbrWPjTAZ3f	Ben McKnockiter	P	1998-08-24	88025834794	Jl. Farragut no. 270, Pretana
gelderbrant10@woothemes.com	xtBi7lOAX	Gilli Elderbrant	P	1988-06-28	86869809374	Jl. Talmadge no. 780, Kalyves Polygyrou
dsilverton11@mysql.com	OjAJPHvJY	Dal Silverton	P	1938-06-13	80783634277	Jl. Eliot no. 897, Las Vegas 89166
bdionis12@scribd.com	HAUpsRDzNMN	Brandon Dionis	P	1994-06-29	84910015405	Jl. Loeprich no. 579, Nanton L5M
zbroomhall13@mac.com	QHp00JVq	Zoe Broomhall	P	1939-09-11	88024344977	Jl. Rockefeller no. 822, Petrivka
gallsup14@fema.gov	whNLd0	Grenville Allsup	L	1967-04-30	87899664125	Jl. Arrowood no. 977, Marvdasht
hclavey15@engadget.com	9Jn9owX5g7YE	Huntington Clavey	P	1941-08-16	81544795875	Jl. Lerdahl no. 732, Verkhoshizhemye 613310
ahinkley16@quantcast.com	Dazaxr11i	Adrienne Hinkley	L	1944-10-28	89754570726	Jl. La Follette no. 190, Novais 3660-410
oben17@mozilla.com	oATcNWUyE	Obie Ben	P	1959-11-29	84922432965	Jl. Cherokee no. 46, Berlin 10823
aranyard18@springer.com	tpBaOvX	Ade Ranyard	L	1953-05-24	81386892132	Jl. Hoffman no. 11, Matsubara 999-0606
elerwell19@ucoz.com	B4YHbl4HgooF	Ernest Lerwell	L	1972-02-19	89155113248	Jl. West no. 755, Jurangjero
aparkman1a@blogtalkradio.com	imO2QS2YVcG	Anatole Parkman	L	1946-10-05	85564513212	Jl. Oriole no. 801, Miyako 969-6522
tgingold1b@histats.com	Ig0t9KQlTXBQ	Tedman Gingold	L	1956-06-30	81781655657	Jl. Sommers no. 147, Sandouping
lbambra1c@a8.net	sdERNS1pdWN	Lorens Bambra	L	1930-04-17	84981729238	Jl. Grayhawk no. 184, Tshikapa
vkoomar1d@fema.gov	KwECKhrBzL	Vivianne Koomar	P	1935-05-07	89931698288	Jl. Glacier Hill no. 867, Avato
spabelik1e@ibm.com	XMjKrAiEj72	Sanderson Pabelik	P	1959-02-11	82368016039	Jl. Arkansas no. 737, Ketanen
rdelacourt1f@smh.com.au	4EkFS3RDcA	Rosalinda Delacourt	L	1987-04-19	86124708712	Jl. Kropf no. 975, Buliran Segundo 3109
iniche1g@technorati.com	xpQbSouX	Ives Niche	L	1954-08-11	88257603671	Jl. Farmco no. 220, Xiushan
teykelhof1h@com.com	K1CWcT	Toni Eykelhof	L	1989-07-01	80849082296	Jl. Jay no. 580, Trollh„ttan 461 63
hwillden1i@fastcompany.com	zJPnL2Ud9gW	Homer Willden	P	1983-02-05	80772757461	Jl. Thierer no. 696, Farkhah
jhadaway1j@icq.com	q8mcgjyhK	Jimmie Hadaway	P	1955-02-15	89369904932	Jl. Armistice no. 40, `Alaqahdari Gelan
dsparrowhawk1k@odnoklassniki.ru	jhHT1Qb	Derron Sparrowhawk	L	1973-10-21	85011516817	Jl. Pleasure no. 100, Carolina 65980-000
lkyston1l@unblog.fr	78BemEbrGBN	Lincoln Kyston	P	1948-11-09	84775170686	Jl. Logan no. 0, Xai-Xai
jisworth1m@sourceforge.net	g4k4Qa	Joel Isworth	P	2001-01-10	87077658799	Jl. Hollow Ridge no. 516, Trzciana 36-071
tmeader1n@fotki.com	UzO0DBGn8Cf	Temple Meader	P	1940-12-31	89459356177	Jl. Coleman no. 970, Mubende
ashillington1o@ycombinator.com	i7BL944NdSc	Aggi Shillington	P	1940-05-25	86703532079	Jl. Bellgrove no. 574, Buenavista 8601
wleavesley1p@reddit.com	HG2me69hLI	Wes Leavesley	L	1953-11-29	81591634990	Jl. Ruskin no. 375, Leninogorsk 452141
skleisle1q@mayoclinic.com	edi8wiWAc	Sutherlan Kleisle	L	1990-06-05	83553622290	Jl. Warner no. 706, Madoi
vpowder1r@ucoz.ru	WzIpkhT8D	Vania Powder	L	1968-12-09	83133071240	Jl. Summer Ridge no. 161, Novouzensk 413362
jvennard1s@unc.edu	TuEddzEb	Jeff Vennard	L	1945-05-05	83315800922	Jl. Twin Pines no. 424, Cengang
kdawdary1t@springer.com	IKN08FlG9	Ketti Dawdary	P	1982-03-14	88746833189	Jl. Sunbrook no. 801, Yunchi
mbayford1u@slideshare.net	mTO0oCr6qb	Melesa Bayford	P	1970-12-09	83015548254	Jl. Kennedy no. 744, Peixing
mmuggach1v@army.mil	7ki8Yu5zEpXW	Miriam Muggach	L	2001-02-05	86163326253	Jl. Mccormick no. 671, Araguari 38440-000
cdufore1w@ucoz.ru	Qm2rGnDTPc4	Clemens Dufore	P	1987-11-08	85732539553	Jl. Annamark no. 992, Hulu
sferrao1x@sciencedirect.com	pkEw4sH	Sindee Ferrao	L	1996-06-30	82280529626	Jl. Farmco no. 414, Ponta do Sol
pthackwray1y@altervista.org	MhnSYBI7s	Pia Thackwray	P	1962-11-12	86670002425	Jl. Dapin no. 58, Xihe
cpavek1z@sciencedirect.com	v4fVFw4	Constantino Pavek	L	1940-11-13	85479249349	Jl. Bobwhite no. 558, Concepci¢n
sebbles20@ovh.net	TPzx0QVuSxnp	Sascha Ebbles	L	1969-10-01	82469249738	Jl. Nobel no. 396, Francisco Villa 26030
sbartolomeotti21@samsung.com	BApCLLrbSiTN	Sidoney Bartolomeotti	L	1957-04-09	88727523153	Jl. Arrowood no. 615, Kabala
jpaschke22@java.com	cLb4lwjE5	Jilleen Paschke	L	1978-12-26	84624021385	Jl. Declaration no. 470, Borovan 3078
sblevin23@webnode.com	buK9bG	Seth Blevin	L	1941-07-25	84745025704	Jl. Elmside no. 571, Feni 8700
mworwood24@1688.com	ybvQNzctJ	Michaeline Worwood	P	1976-03-14	88219795645	Jl. Utah no. 247, Bijie
sosborn25@fastcompany.com	CAgjc1	Sharity Osborn	L	1944-07-01	81560120275	Jl. Johnson no. 471, Radymno 37-550
acallum26@jiathis.com	MDE649F8ET7l	Alonzo Callum	P	1950-07-06	85765994314	Jl. Miller no. 726, Vellinge 235 36
cbrickhill27@skyrock.com	vOEZSoI0fT2c	Collen Brickhill	P	1997-04-01	89551106795	Jl. Swallow no. 652, Gayamdesa
adanbrook28@java.com	SgDjyA4MH3r	Aurie Danbrook	L	1930-01-29	80301929524	Jl. Briar Crest no. 234, Yanwo
bridges29@miibeian.gov.cn	0833RT	Bab Ridges	P	1935-01-22	89751303586	Jl. Sachtjen no. 921, Owando
dguyonneau2a@disqus.com	XxOiFN94	Dagmar Guyonneau	P	1935-07-03	89057470274	Jl. Jay no. 750, Iwade 949-3376
hsealey2b@dagondesign.com	NEEH1sjGGOV	Hatti Sealey	L	1931-11-05	80106492314	Jl. Raven no. 281, Velk‚ Svatonovice 542 35
rtrevain2c@posterous.com	Wlcnu1aI7	Rossie Trevain	P	1977-08-26	89559067428	Jl. Redwing no. 286, Abut 2720
fkingsworth2d@ox.ac.uk	e9WRIo	Farr Kingsworth	L	1980-03-14	85403022960	Jl. Forest no. 917, Oslo 0376
cduncanson2e@mayoclinic.com	dTH1fV2Q	Cordelia Duncanson	P	1968-01-31	83127696699	Jl. Daystar no. 644, Montes 2460-825
vcarnier2f@virginia.edu	YEGb6z	Vitoria Carnier	P	1967-12-31	84566828565	Jl. Glendale no. 754, Semampir
cmiddler2g@flickr.com	M0n8JfonVkgg	Carley Middler	P	1936-04-02	82630134725	Jl. Homewood no. 827, Hali
pwelham2h@pen.io	Ek3V3I9HS7y	Peri Welham	L	1980-01-01	89443502314	Jl. Sunbrook no. 88, Sukadana
djessope2i@yellowpages.com	QPfPYKlqP8	Dmitri Jessope	P	1991-05-23	82808193254	Jl. Dapin no. 304, Khao Yoi 76140
sjobern2j@mozilla.org	OQcZtjXP5Op	Sibel Jobern	L	2000-09-05	85700434470	Jl. Bonner no. 955, Xiyang
jeakley2k@yolasite.com	fGkdnhHv9S	Jacquelyn Eakley	P	1933-10-09	88497935748	Jl. Alpine no. 118, Aliaga 3111
jadamsky2l@constantcontact.com	QuFPFXFrQ	Jephthah Adamsky	L	1973-12-19	82629618464	Jl. Oakridge no. 165, Al Qitena
acheetam2m@is.gd	D2zW9X1mn5u	Abey Cheetam	L	1973-04-05	84347200924	Jl. Mallory no. 241, Las Palmas
dbeddoes2n@alibaba.com	eNAdlia12Hf	Dorie Beddoes	L	1946-06-18	88751465035	Jl. Shopko no. 923, Mu? ?asan
dswansborough2o@harvard.edu	m7XoSaVGxeZ	Daisie Swansborough	L	1957-12-02	87864002537	Jl. Bluestem no. 989, Rukaj
hfoley2p@istockphoto.com	K5fDPpB8	Hermia Foley	P	1937-02-26	81772665270	Jl. Green Ridge no. 109, Wenwusha
rboffey2q@ebay.co.uk	nzoEZj	Ramona Boffey	P	1933-03-19	83275458753	Jl. Brentwood no. 7, Th…nh Ph? Nam D?nh
mskaife2r@ca.gov	cTxjaSPN	Minnaminnie Skaife d'Ingerthorpe	L	1947-03-26	86262266663	Jl. Parkside no. 153, Sipeng
atitterrell0@pagesperso-orange.fr	xyt326O	Augustin Titterrell	L	1931-06-08	86475150798	Jl. Rockefeller no. 742, Godo 503-2429
gcopes1@earthlink.net	ZefdgHygVyz	Gail Copes	P	1983-11-17	87891654439	Jl. Menomonie no. 715, Liwonde
bfalshaw2@about.me	CYChsL	Brod Falshaw	P	1946-08-12	89250859186	Jl. Ohio no. 567, Auray 56404 CEDEX
gjanning3@opensource.org	l9fxqcN8	Gussi Janning	L	1957-02-06	80295257279	Jl. Westport no. 876, Miaotang
dhurne4@nydailynews.com	3OAOVW4	Danica Hurne	P	1961-09-11	81852887905	Jl. Declaration no. 351, Daojiang
mgarric5@amazon.de	JhT6RBxteLI	Marley Garric	P	2003-02-25	85833193950	Jl. Mallory no. 550, V„ster†s 721 27
amardling6@typepad.com	27z6FIQ8gJl8	Aaren Mardling	P	1993-12-03	86572794970	Jl. Springview no. 548, Xindeng
cbeaman7@instagram.com	5FlBtKYf	Corella Beaman	L	1958-10-22	83888037237	Jl. Calypso no. 638, Shchigry 399505
hborn8@sakura.ne.jp	fcI9faSQ	Humfrey Born	L	1959-08-05	88495578938	Jl. Doe Crossing no. 50, Montreuil 93187 CEDEX
oernshaw9@ycombinator.com	DClh7FXmR	Opalina Ernshaw	L	1932-02-07	84994136174	Jl. Quincy no. 145, Ume† 901 81
castlesa@paginegialle.it	MUT9jVsf	Carly Astles	L	1971-08-01	86601207900	Jl. Lien no. 103, Tomice 34-105
ebridgwoodb@fotki.com	eL1EkAh	Elvyn Bridgwood	P	2002-01-27	84914571715	Jl. Logan no. 887, Karangboyo
lfendleyc@amazon.co.uk	N3Rvz2qp9	Linnea Fendley	P	1963-07-10	86030943634	Jl. Bartillon no. 618, Nakhchivan
sdadsond@qq.com	SUCtZX	Sigfrid Dadson	P	1998-06-09	89405080543	Jl. Northwestern no. 780, Mircze 22-530
dreefe@springer.com	83gdUbpl2	Darda Reef	L	1950-11-04	88639326822	Jl. Valley Edge no. 272, Huangtan
msapwellf@wikimedia.org	Ar5QOGaGJ	Minta Sapwell	P	1977-09-29	85734329715	Jl. Linden no. 358, Cinunjang
sgrigollig@weather.com	5pQh4zv	Scot Grigolli	P	2000-08-18	82047655814	Jl. Crownhardt no. 604, Longfeng
vhabbeshawh@ifeng.com	08LqVAF	Vida Habbeshaw	P	2001-06-12	85010568675	Jl. 2nd no. 71, Krasnokumskoye 357834
minksteri@aol.com	W2L2oewkA	Myrtice Inkster	L	1947-10-11	89822940015	Jl. Oakridge no. 103, Zuobude
rpitwayj@elegantthemes.com	XPBWSIUvT	Ranee Pitway	P	1968-09-17	89953982487	Jl. Golf no. 465, Bordeaux 33036 CEDEX
twormleightonk@dagondesign.com	Acv2JnX0	Tiphanie Wormleighton	P	1939-06-08	89803625389	Jl. Mesta no. 940, Xinxu
adortonl@nytimes.com	Exac7MNIY	Adler Dorton	P	1999-08-02	89629864550	Jl. Straubel no. 565, Helmsange L-7270
lbarbrookm@google.co.uk	SUy1sF	Lolita Barbrook	L	1968-01-04	89877161121	Jl. Melvin no. 414, Kakanj
gtofanon@ustream.tv	cewr72AGBvR	Gordon Tofano	P	1946-05-10	81614595122	Jl. New Castle no. 861, Yaroslavl 353827
fboheao@baidu.com	BWUOkv9	Foss Bohea	P	1960-08-24	83024276671	Jl. Northridge no. 727, Akhtarin
wfullylovep@aboutads.info	pP13cX	Wandie Fullylove	L	1973-09-02	85353879685	Jl. Rieder no. 138, Nzeto
kaleevyq@msn.com	OwmYoAc	Kinna Aleevy	L	1977-07-02	82615861181	Jl. Bluejay no. 54, Opuwo
ntrevorr@fc2.com	wcS729wn0nf	Nettle Trevor	L	1977-11-28	83143078177	Jl. Merchant no. 182, Shuikou
rosesnanes@nationalgeographic.com	BNUwZfE3EJB	Raul O'Sesnane	P	1988-11-02	87738354516	Jl. Ilene no. 907, Kertosari
cbakhrushint@reddit.com	rrVYvfcE	Clari Bakhrushin	P	1961-05-02	86370364042	Jl. Florence no. 674, Zhamao
mepinoyu@51.la	UYdD5fvUpAW	Melodie Epinoy	L	1970-03-09	82993669800	Jl. Kedzie no. 809, Xuetian
bambersonv@wp.com	88VuuAIguwo	Bradley Amberson	L	2000-03-03	81561652227	Jl. Judy no. 930, Wattala 11104
gpickervancew@va.gov	6kvEKr	Gloriana Pickervance	L	1993-01-08	89495105576	Jl. School no. 143, Kashmor 33001
ggamesonx@webs.com	qxGlaIK	Gus Gameson	P	2003-01-03	89864490452	Jl. Lotheville no. 934, Rego de Agua 2860-278
hduffieldy@bloglovin.com	AjKm4U7B	Hendrika Duffield	L	1932-01-25	87798981982	Jl. Corben no. 34, Dapuchaihe
fexrollz@squarespace.com	uUZllw1p9uI	Fernando Exroll	L	1966-05-21	89204058945	Jl. Barnett no. 100, Birnin Kebbi
vmolyneaux10@google.com.au	FkVlCwHI8m9I	Valery Molyneaux	L	1994-09-12	88523069382	Jl. Truax no. 660, Kalp ki
nrodda11@hibu.com	Ca4kAvezmcVi	Nollie Rodda	P	2000-05-27	81252302661	Jl. Cottonwood no. 573, Newton NG34
vgissing12@google.fr	mUq9YL	Vergil Gissing	L	1987-06-19	81227712578	Jl. Kim no. 339, Bulakbanjar
djentle13@live.com	WUsOrPS	Denis Jentle	P	1953-10-14	88328345551	Jl. Arkansas no. 685, Jinotega
gmorgans14@nba.com	ieRleMGJY	Greer Morgans	L	1983-09-11	89947720529	Jl. Sage no. 387, Bajo Pichanaqui
wgoldingay15@shop-pro.jp	HZdVCI	Wyatt Goldingay	P	1989-01-08	85749363541	Jl. Forster no. 203, Tampakan 9507
nleither16@google.it	tZqcGm2RAM6	Noami Leither	P	1943-05-27	81287534952	Jl. Old Gate no. 325, Yinjiang
rpigott17@vimeo.com	2KXB7eBifQ0e	Rene Pigott	L	1941-10-07	83838217143	Jl. Armistice no. 361, Tam Binh
lgreenig18@loc.gov	ir91aXRH	Lindsy Greenig	P	1940-09-27	85465927388	Jl. Rigney no. 574, Huambalpa
lcrichley19@noaa.gov	QEbw3vYpDVt	Linette Crichley	P	1956-08-04	84464299383	Jl. Loeprich no. 138, Pindi Bhattian 52181
hlinklet1a@answers.com	6yOQHbEK	Hugo Linklet	L	1981-11-04	83809332578	Jl. Longview no. 669, Mayanhe
lbottom1b@blinklist.com	ihPlO9DhG	Lucian Bottom	L	1936-01-19	84235158040	Jl. Drewry no. 788, Aligudarz
rjodrelle1c@latimes.com	C5uh7ph3z8lo	Raymond Jodrelle	P	1986-05-22	85817344632	Jl. Sherman no. 673, Ban Muang 47140
mpattison1d@spotify.com	tJpfkxcxfKS	Merrielle Pattison	P	1979-05-18	80446590793	Jl. Anzinger no. 260, Karlsruhe 76199
ebewfield1e@icio.us	aEJxxk7f49B	Even Bewfield	P	1946-04-20	89368096947	Jl. Carey no. 355, Wanquan
evinas1f@stanford.edu	4j3aNYbiPb0b	Ema Vinas	L	1940-07-23	83507186620	Jl. Gerald no. 82, Gorbatov 606125
mmasserel1g@epa.gov	jZeMWQ	Mignon Masserel	L	1997-05-23	88184601779	Jl. Pennsylvania no. 365, Sandovo 171750
fmasic1h@prweb.com	5sBzCH	Forster Masic	L	1979-11-25	87680100452	Jl. Lerdahl no. 263, Momp¢s 473008
mrobert1i@pcworld.com	TsLPm7sdCYa	Marcelia Robert	L	1977-02-25	85869266262	Jl. Katie no. 733, Jinping
hcastanaga1j@fda.gov	Gmtf8Hx	Haze Castanaga	P	1941-10-27	87520960388	Jl. Ludington no. 82, Skelleftehamn 932 33
pgrollmann1k@posterous.com	zQCCbNs9nz26	Pauly Grollmann	P	1972-02-08	81306220495	Jl. Ruskin no. 247, Nashta Rud
claraway1l@parallels.com	oYmULjpuwk	Curry Laraway	P	1960-04-23	85029220527	Jl. Russell no. 84, Coxim 79400-000
pshillington1m@usda.gov	JDDLqUABwMH	Pierette Shillington	L	1945-11-23	86810560738	Jl. Thackeray no. 112, Haishan
klind1n@diigo.com	WG3VRX04Pus	Karoly Lind	L	1981-08-25	81938323903	Jl. Sheridan no. 409, La Salud
bstukings1o@elpais.com	J9tE1Ds9uTu	Brandy Stukings	L	1944-09-26	85429551531	Jl. Caliangt no. 150, Pruzhany
ccheale1p@bbc.co.uk	YHbX3Xn1F	Candice Cheale	L	1984-05-22	86362735784	Jl. Drewry no. 730, Krajan Gajahmati
rmullin1q@google.co.uk	w4TyaBr	Ronald Mullin	L	1933-02-23	85680083575	Jl. Saint Paul no. 428, H‚nin-Beaumont 62259 CEDEX
cleet1r@infoseek.co.jp	uapVt2gAtH	Chrissie Leet	L	1986-09-29	88278772478	Jl. Mallory no. 272, Huolongmen
mtooley1s@storify.com	KyjWxQ	Milo Tooley	P	1973-05-27	83854483381	Jl. Jenifer no. 868, Bayanbaraat
hjonathon1t@google.ca	AuzL5y6t	Hillary Jonathon	L	1961-02-18	80590818388	Jl. Miller no. 625, Yangsha
mradsdale1u@imdb.com	Ckez3nvhm	Marwin Radsdale	P	1978-06-24	83925735059	Jl. Arrowood no. 48, Krasnogorskoye 659500
mthebeau1v@ed.gov	WE7nvl	Malina Thebeau	P	1973-07-08	82171202428	Jl. Acker no. 809, Helong
owoolliams1w@unc.edu	WfdeTCZ	Odele Woolliams	L	1978-09-20	80245678981	Jl. Oak no. 422, Tanzhesi
sbwy1x@xing.com	Sl4OTKtF	Saxe Bwy	L	1950-11-24	83794238715	Jl. Shelley no. 757, Brinje 53260
rreeson1y@cnet.com	E5YBmh	Ravid Reeson	L	1938-12-03	80474700107	Jl. Cascade no. 438, Nizhniy Lomov 442153
hbeloe1z@freewebs.com	xX9cORsnT	Hillel Beloe	P	1992-06-16	84537215061	Jl. Bashford no. 64, Daduchuan
jsedgeman20@sourceforge.net	lHsB4s	Josias Sedgeman	L	1959-01-07	89119013144	Jl. Iowa no. 527, Belalcazar 177007
mkleen21@tumblr.com	1OELWy	Marv Kleen	L	1940-06-06	85032027714	Jl. Barby no. 336, Zhigong
glarmett22@reuters.com	jw0tQhVY	Germana Larmett	P	1938-12-21	80647660331	Jl. Continental no. 223, Langsa
sokeenan23@csmonitor.com	0d7wtvk5R	Sidonnie O'Keenan	P	1961-05-06	83907368770	Jl. Utah no. 835, Kuala Lumpur 50913
kviles24@1688.com	yOwBYZGsO	Kelcy Viles	L	1994-08-09	84860494017	Jl. Sage no. 798, Albufeira 8200-005
ehegley25@seattletimes.com	aFrZJYqjBIty	Eula Hegley	P	1951-05-10	82575144612	Jl. Scoville no. 155, Carleton Place K7C
rexley26@barnesandnoble.com	mXNT18kDx	Rowan Exley	L	1956-01-17	85504321184	Jl. Straubel no. 234, Zhujiang
elamcken27@hud.gov	wuEBnwvGyiO	Edee Lamcken	L	1944-06-07	80081938955	Jl. Maywood no. 616, Bibirevo 301262
hgisborne28@slashdot.org	JIFIGiB	Harmon Gisborne	P	1962-02-24	88627968524	Jl. Nova no. 408, San Agustin 8305
zheaton29@va.gov	X5wg8yotV	Zelda Heaton	P	1977-01-03	84560686482	Jl. Debs no. 295, Pi¤as
pbroadbear2a@indiatimes.com	HRcqVQri	Paul Broadbear	L	1944-07-30	80983160868	Jl. Eliot no. 516, Stoczek Lukowski 21-450
fburkman2b@twitpic.com	qCqp50	Frank Burkman	P	1968-09-23	88060310279	Jl. Cottonwood no. 789, Pangian 4204
cseamans2c@indiatimes.com	0GPjcqLSR	Chrystel Seamans	L	1935-10-03	89112010278	Jl. Miller no. 748, Dayanggezhuang
rhallick2d@shutterfly.com	aydec8yVcF4	Rosaline Hallick	L	1988-10-23	84520550800	Jl. Sutteridge no. 775, Sredniy 141060
nwemm2e@meetup.com	ZqHMdSNzJh	Niles Wemm	P	1983-02-27	83747569638	Jl. Randy no. 792, Sokolovyy 410501
boxtoby2f@zdnet.com	s3eCl8u	Bryan Oxtoby	L	1964-02-26	87762180611	Jl. Forest Run no. 399, Geshan
mborlease2g@com.com	b3TpJQKm	Mechelle Borlease	P	1930-11-28	87909689738	Jl. Cottonwood no. 694, Itatuba 58378-000
snavein2h@yolasite.com	K1m5Z6Q	Sonny Navein	P	1951-07-13	83304827407	Jl. Dayton no. 767, Fontenay-sous-Bois 94726 CEDEX
lfalkner2i@cpanel.net	mcNfoGJ	Louise Falkner	P	1933-05-12	80575460432	Jl. Mendota no. 740, Zitong
csiegertsz2j@columbia.edu	TmTkSy7CrJ	Claude Siegertsz	L	1944-09-21	82387894828	Jl. Twin Pines no. 643, Nakhon Luang 13260
reckh2k@123-reg.co.uk	tEfrm6A9IDHe	Ruben Eckh	L	1938-07-25	87183048439	Jl. Buhler no. 406, Sundbyberg 172 23
jradage2l@blogtalkradio.com	RdU2h8KTAiau	Janean Radage	L	1993-08-03	83776072823	Jl. Sycamore no. 286, Aral
ktilbey2m@freewebs.com	WG9awBHgL	Kenton Tilbey	P	1962-05-15	83924851628	Jl. Saint Paul no. 289, Ciawi
vkippie2n@google.ru	PkKM7S	Virgil Kippie	P	1960-04-30	85350853366	Jl. Melby no. 264, Vit¢ria de Santo Antao 55600-000
mmobley2o@mac.com	8XUDZe	Mellisent Mobley	P	1990-06-18	87872548490	Jl. Pond no. 179, Gjinkar
lbambrick2p@sfgate.com	yDZQ4LLF	Lana Bambrick	L	1975-12-12	85947800537	Jl. Evergreen no. 177, Cesson 77246 CEDEX
dcaulfield2q@dmoz.org	YAw0JqDhsKJ	Danya Caulfield	L	1948-05-13	81060631865	Jl. 2nd no. 335, Yukuhashi 824-0233
fportinari2r@cdc.gov	OTSpn9X0	Frank Portinari	L	1967-03-12	82745997636	Jl. Pleasure no. 458, Huangtan
mpowney2s@over-blog.com	sFXkT7Zn9	Mitchell Powney	P	1957-08-30	84894394013	Jl. Hooker no. 561, Changcun
wzanini2t@yahoo.co.jp	b1xELuG	Waite Zanini	L	2002-10-19	83613145333	Jl. Kensington no. 285, Sionogan 1104
istreeton2u@yellowbook.com	hnumVdkRv	Illa Streeton	L	1982-02-19	80656377820	Jl. Lake View no. 318, Pyay
bwollers2v@usnews.com	7yNJR2	Bryan Wollers	L	1945-07-18	82504673276	Jl. Karstens no. 966, Hankazi
blemasney2w@yelp.com	YJdRhxdU	Batsheva Lemasney	L	1994-03-28	80480085783	Jl. Erie no. 329, Kalan Deh
rdametti2x@narod.ru	SGchZmC	Rupert Dametti	P	1970-12-21	83663483463	Jl. Hoepker no. 519, Las Varas 5941
jdinesen2y@vimeo.com	3DTb1Yoe	Josephine Dinesen	P	1999-08-02	83915236091	Jl. Upham no. 995, Nginjen
aodevey2z@prlog.org	vpBxvGByQa	Ave O'Devey	L	1995-03-30	88146432693	Jl. Florence no. 163, Chengbei
lradnage30@canalblog.com	0I6eOmdSwo5	Loree Radnage	P	1935-04-13	82305706756	Jl. Eastlawn no. 948, Gaotang
kjuorio31@t.co	6RrD9dUT	Ky Juorio	L	2000-03-29	87715602216	Jl. Sachtjen no. 544, Chƒtillon 92324 CEDEX
ldoore32@loc.gov	exY4mTSgdO	Leo Doore	L	1938-04-27	84838437697	Jl. Monument no. 267, Lubu
smeachen33@chronoengine.com	XaBQpR6IM	Sybyl Meachen	P	1995-06-29	87992464342	Jl. Lindbergh no. 681, Foluo
eduddle34@redcross.org	Url6kMnY	Elaine Duddle	L	1935-05-07	86901219773	Jl. Buell no. 260, Stare Miasto 62-571
tjohnsson35@gizmodo.com	MjsQySY2PJp9	Thatcher Johnsson	P	1942-03-27	82503556797	Jl. Bartillon no. 266, Tenno 492-8204
rbuckland36@last.fm	aeFeF4j	Renato Buckland	L	2002-06-18	83267252458	Jl. Schiller no. 724, Traves¡a
lshillingford37@godaddy.com	PDCKe4zKJGHx	Linus Shillingford	L	1943-03-21	84580644402	Jl. Lyons no. 882, Dongfeng
hstapleton38@geocities.com	jrYZOahUu	Harrietta Stapleton	P	1960-09-04	87348158563	Jl. Marquette no. 107, Lubomierz 59-623
kbreukelman39@dot.gov	ShJmmbg	Kellina Breukelman	L	1945-08-20	88560595824	Jl. Mockingbird no. 181, Anxiang
odredge3a@sogou.com	ln1A2a2yl	Ottilie Dredge	L	1980-10-11	80559847594	Jl. Bartillon no. 218, Lad rio 4635-133
sde3b@trellian.com	VY8blgkQI	Sam De Dantesie	L	1952-09-12	80046759658	Jl. Ramsey no. 751, M¡thymna
md3c@about.com	Gtt9Rp	Merry d' Elboux	P	1995-01-14	80139828915	Jl. Hayes no. 753, Zarichne
rhouldey3d@latimes.com	AT897w	Romain Houldey	P	1949-06-25	83681512921	Jl. 5th no. 107, Z¢lkiewka 22-335
bmacmanus3e@arstechnica.com	onIm84SB1	Bellanca MacManus	P	1980-12-27	82391770624	Jl. Melrose no. 639, Osielsko 86-031
gbonifazio3f@adobe.com	8gQIbmFB1ec0	Giraud Bonifazio	L	1954-12-14	88742477621	Jl. Alpine no. 766, San Jose 8427
kde3g@ebay.co.uk	atAmnsIWi	Kort De Carteret	L	1942-09-30	86375130638	Jl. Magdeline no. 151, Lampa
apacher3h@etsy.com	MFbtrwjRFJ7	Alexandr Pacher	L	1989-01-22	82319153350	Jl. Crescent Oaks no. 355, Krokea¡
mvedikhov3i@linkedin.com	2upWctaudZy	Min Vedikhov	P	1932-01-17	88825829443	Jl. Aberg no. 264, Yinkeng
hlodford3j@slate.com	9RS5FBao	Hildagarde Lodford	L	1941-06-20	87679307098	Jl. Fieldstone no. 452, Jiulonggang
ireadhead3k@is.gd	c4AqDd3X7k	Ingeberg Readhead	L	1971-12-17	89268549631	Jl. Namekagon no. 553, Bologoye 171076
jalenshev3l@sciencedaily.com	SW6Mzw	Juliann Alenshev	L	2003-12-05	84367350311	Jl. Pine View no. 417, Besuk Selatan
mhallagan3m@psu.edu	fbvY9ay3o	Maisie Hallagan	L	1961-07-01	81741232359	Jl. Trailsway no. 428, Oslo 0968
pworsfold3n@chron.com	e7GqfIIALR	Phylis Worsfold	L	1986-12-26	82400644516	Jl. Fremont no. 970, Wenlin
paskem3o@yale.edu	BCXwTuPITQfv	Pippy Askem	L	1952-12-23	87276472964	Jl. Iowa no. 207, Marechal Cƒndido Rondon 85960-000
mvern3p@godaddy.com	V0VhDON35RY	Maxim Vern	P	1995-11-23	87541311996	Jl. Mayer no. 244, Bungkulan
kkilmister3q@indiatimes.com	UKIEQ6i	Kalli Kilmister	P	1972-09-24	85918952542	Jl. Arrowood no. 703, Neoch¢rion
plorenz3r@fotki.com	Ef1iJvi	Pattie Lorenz	L	1941-05-20	82546334851	Jl. Carioca no. 387, Nantes 44945 CEDEX 9
awestphalen3s@desdev.cn	NgVi14UmqT	Archy Westphalen	P	1996-10-24	83362913749	Jl. Menomonie no. 429, Iwierzyce 39-124
bcradick3t@squidoo.com	sU78I32	Brit Cradick	P	1994-12-22	80814514094	Jl. Sutteridge no. 612, Feikeng
adwelly3u@pen.io	CtjbAGw9MdK	Anna-diana Dwelly	P	1996-01-30	89480370270	Jl. Kings no. 318, Laxiong
ahaverson3v@columbia.edu	qINiXAvMK	Aleen Haverson	L	1936-04-08	82552305939	Jl. North no. 37, Petong
dedgell3w@ebay.co.uk	Tp4YALw	Delly Edgell	P	1995-05-28	87645187516	Jl. Emmet no. 829, Lafiagi
apetrasek3x@cocolog-nifty.com	yvOhFAZYz	Alden Petrasek	L	1957-08-12	83751068436	Jl. Onsgard no. 808, Hengdian
sphidgin3y@newyorker.com	uSTw7l3	Stefa Phidgin	P	1935-07-19	88865981234	Jl. Jana no. 3, Staraya Kulatka 433940
sbellward3z@google.com	oeyeTx	Sarge Bellward	P	1932-06-11	87323309025	Jl. Declaration no. 204, Lumbayan 7000
vmessruther40@fc2.com	S81pNpKUj	Vivi Messruther	L	1979-08-06	83764441781	Jl. Warrior no. 790, Changxing
rhaselhurst41@netvibes.com	brHOQz	Robinet Haselhurst	L	1940-05-16	85060224263	Jl. Evergreen no. 468, Kocevje 1330
egiles42@sitemeter.com	GNeuKPwkgG	Ermin Giles	L	1931-11-05	86087726649	Jl. Arizona no. 618, Lambayong 2624
uguiducci43@istockphoto.com	rmcrQhyi02	Urbain Guiducci	L	2002-10-06	84184962206	Jl. Summer Ridge no. 688, Culasian 6530
cchastenet44@jiathis.com	sAosDlx	Cheri Chastenet	P	1975-08-01	81734887156	Jl. Steensland no. 439, Bir ?at
ghurleston45@netlog.com	eoknUYHdZwV	Gaylor Hurleston	P	1988-01-09	82154487163	Jl. Lawn no. 539, Banqiaodian
mcollyns46@1und1.de	onnDlPtAuSlK	Mitchel Collyns	P	1985-03-14	85078664484	Jl. Nova no. 273, Rathnew R35
cvigars47@irs.gov	zhf0JF54yGDS	Clarice Vigars	L	1998-01-07	88291429923	Jl. Springs no. 675, Ymittos
ldoram48@xrea.com	Opjc6vo	Lane Doram	P	1978-06-10	88849409298	Jl. Lien no. 585, Karang Daye
agatrell49@slate.com	1RWOVzt	Arlee Gatrell	L	1974-06-23	82135809166	Jl. Prairieview no. 628, Calaoagan 1107
cbrumen4a@skype.com	hwcdOuei	Coleman Brumen	L	1999-07-08	87202747523	Jl. Briar Crest no. 876, Vila de Sal Rei
cabby4b@cyberchimps.com	y4IJutqam	Colin Abby	P	1968-08-29	88272662800	Jl. Iowa no. 259, Dadapan
tadame4c@alexa.com	4eRPbgqHI4V	Tawsha Adame	L	1938-10-22	83954809255	Jl. Chinook no. 590, Barra do Bugres 78390-000
lcolicot4d@behance.net	qV4paxe	Lamar Colicot	L	1968-02-21	88995677800	Jl. Elka no. 498, Okahandja
owoollam4e@amazonaws.com	Vy8NivlL	Olenka Woollam	L	1957-03-26	83036699761	Jl. Blackbird no. 717, Mae Wang 50360
bweaver4f@ebay.com	689w5Oo	Bastian Weaver	L	2003-08-02	83831936485	Jl. Michigan no. 808, Sarykemer
cmcwhin4g@gizmodo.com	ax7A3kO8nQT	Cherish McWhin	P	1988-03-10	82640302573	Jl. Cottonwood no. 811, Jinkou
stither4h@google.ru	b0pCsCewwff	Sam Tither	L	1968-08-03	87640579752	Jl. Mockingbird no. 226, Bukal Sur 4323
fkynston4i@fda.gov	fS03ppA4	Florry Kynston	L	1964-06-18	83108559522	Jl. Melby no. 764, Panyingkiran
rmooney4j@theatlantic.com	guzWA3KXR4	Ruby Mooney	P	1939-10-08	84285996068	Jl. Del Mar no. 766, Mayuan
sklimentov4k@creativecommons.org	R8svGh5Q26	Somerset Klimentov	L	1970-03-16	80810117810	Jl. Barnett no. 278, Hurghada
rmouland4l@psu.edu	CkgR5C4W	Robina Mouland	L	1992-06-02	84128317328	Jl. Sloan no. 867, Kratovo 142452
bbisseker4m@g.co	W3EZrEA09e	Bing Bisseker	P	1975-02-14	87594884290	Jl. Thackeray no. 484, Tullinge 146 40
dbasire4n@nasa.gov	zvogZ0Yy	Durward Basire	L	1931-11-13	86999471286	Jl. Farwell no. 393, Cergy-Pontoise 95061 CEDEX 1
gzapata4o@slideshare.net	JqCN41BihteW	Goraud Zapata	P	1946-06-27	83613907873	Jl. Westend no. 706, Kauran 1106
kstieger4p@imgur.com	zXApuoy3	Karylin Stieger	L	1959-03-21	84058667623	Jl. Bultman no. 517, Sebba
nrentoll4q@nytimes.com	rZkW5E4VzW	Nico Rentoll	P	1979-03-26	89382029723	Jl. Sloan no. 482, Sencur 4208
pnursey4r@myspace.com	DYWdyr	Peggie Nursey	P	1937-11-23	81451543579	Jl. Melvin no. 285, N„ssj” 571 36
aslides4s@fotki.com	5yedsAUfS	Adelle Slides	P	1967-09-02	85398775284	Jl. Sunnyside no. 801, Momignies 6594
vburchill4t@sohu.com	Gu6aC8aq1	Virginia Burchill	P	1992-09-03	87546697030	Jl. Shoshone no. 662, Shijia
ao4u@posterous.com	4QhONPaRMGr	Ardyce O' Concannon	L	1954-12-10	86837747059	Jl. Kenwood no. 109, Kadugannawa 20300
yseago4v@geocities.com	n27tWAK4	Yance Seago	L	1980-01-31	85584668453	Jl. 1st no. 917, Matumadua
gberthouloume4w@delicious.com	BoyMr4	Gardie Berthouloume	L	1943-12-28	88995977500	Jl. Pearson no. 990, Porto Feliz 18540-000
vcarlton4x@jimdo.com	5eJSDQ	Vite Carlton	L	1968-03-23	88221014231	Jl. Clove no. 607, Arevashogh
lmaunders4y@google.ca	xIEQldww	Lonnie Maunders	P	1977-11-17	89181257664	Jl. Lakewood Gardens no. 520, Gaopeng
cdrysdale4z@dell.com	fTOBf3cu	Clemmy Drysdale	P	1999-06-07	83852348392	Jl. Lunder no. 895, La Argentina 415088
scoppo50@facebook.com	W89QF9z7x	Sibelle Coppo	L	1953-02-12	80483717929	Jl. Eastlawn no. 136, Przemet 64-234
mquittonden51@acquirethisname.com	ldwHuZy	Melisande Quittonden	L	1975-12-31	86972171639	Jl. Mallard no. 828, Polo 1444
bgenders52@noaa.gov	80ruYp3s66T	Bank Genders	L	1952-10-17	87905642654	Jl. Stephen no. 273, La Sebala du Mornag
rdidball53@webs.com	fTM6mYEJ	Rhianna Didball	L	2004-11-28	80705469249	Jl. Fordem no. 207, Th? Tr?n Yˆn Ninh
rharcarse54@buzzfeed.com	KbVNKO	Robinia Harcarse	P	1944-05-06	85363513496	Jl. Lukken no. 871, Balud 5412
lehrat55@spiegel.de	2hWh1tVO	Leanna Ehrat	P	1938-09-13	83601865364	Jl. Lukken no. 221, Druya
bbryant56@bbc.co.uk	qim15xKpAs	Brena Bryant	L	1965-12-14	88886565255	Jl. International no. 681, Sinchao
sdufer57@yellowbook.com	0qNYup0rzVTF	Scott Dufer	P	1963-08-13	82160710840	Jl. Oak Valley no. 822, Ventersdorp 2712
mcrichmer58@mac.com	GQDXTi	Monica Crichmer	P	1984-03-01	84632469306	Jl. Oxford no. 263, Kawayan 6545
rstump59@thetimes.co.uk	nL5Oa9A5cM	Rollie Stump	L	1997-01-19	83937227183	Jl. Stephen no. 138, Priekule
ptesh5a@salon.com	ml5oIJcl	Prentice Tesh	P	1984-08-20	88863667126	Jl. Pankratz no. 741, Nanqiao
kantoniat5b@hc360.com	CQ1dp0Fw	Kingsly Antoniat	L	1959-10-05	80488355075	Jl. Butterfield no. 980, San Jorge 5117
hluney5c@bloglovin.com	A2H3Kt	Halimeda Luney	L	1932-04-27	85261212980	Jl. 4th no. 62, Vakhsh
dbeagin5d@barnesandnoble.com	DgynKGB92	Dominik Beagin	P	1960-09-15	82407112188	Jl. Packers no. 314, Ordynskoye 633260
jjeffcoat5e@npr.org	AkKnWM	Janie Jeffcoat	P	1941-03-27	87068389940	Jl. Mandrake no. 876, Brcko
cshrimptone5f@gov.uk	c2aKak	Cristin Shrimptone	L	1960-08-27	88274693340	Jl. Northport no. 263, Banjar Laing
umordacai5g@last.fm	tqgeEzsyhK	Ursa Mordacai	P	1994-07-16	82364007007	Jl. Fordem no. 503, Hamburg 20249
ffarncombe5h@theguardian.com	jrblXz8C	Friederike Farncombe	P	1990-12-07	88300445379	Jl. Surrey no. 740, Pontinha 1675-007
amilstead5i@umich.edu	I7kEXEULaV	Adorne Milstead	L	1995-08-16	84605543375	Jl. Southridge no. 416, Ronda 6034
atrowler5j@apple.com	hqgQITR	Adamo Trowler	L	1987-11-25	84814125457	Jl. Cottonwood no. 432, Piln¡kov 542 42
drojel5k@merriam-webster.com	wT8VMpG	Desiri Rojel	L	1942-01-28	83819654832	Jl. Hooker no. 475, G”teborg 418 03
nverlinde5l@globo.com	HlmPhz4Vx	Natividad Verlinde	P	1954-04-17	81444357145	Jl. Karstens no. 878, Sarpsborg 1725
gwhitsun5m@china.com.cn	YJGo9AmEvL	Glyn Whitsun	L	1983-09-17	85077794280	Jl. Golden Leaf no. 232, Yola
epotte5n@redcross.org	UxYvx0wUC	Ewen Potte	P	1981-01-19	87954524225	Jl. Bartelt no. 732, Dali
rbuxey5o@scientificamerican.com	NT1gWwnj	Rees Buxey	P	1986-02-16	89036678774	Jl. Swallow no. 861, Witzenhausen 37217
tskittreal5p@360.cn	DMuad2WQ7S	Tyne Skittreal	P	2002-10-22	82140943787	Jl. Colorado no. 820, Pantanal 88000-000
kdibdale5q@bandcamp.com	2bb56VjMwO2	Kris Dibdale	L	1970-02-05	83881473500	Jl. Milwaukee no. 211, Roches Noire
jwillard5r@51.la	8w0CRf6fZjO	Joycelin Willard	L	1937-11-18	82050374984	Jl. Mitchell no. 704, Ivanovo-Alekseyevka
agrimestone5s@jimdo.com	8Z8ZKbjwE	Angelo Grimestone	P	1957-12-15	84943331218	Jl. Myrtle no. 940, Koumra
gtaggett5t@over-blog.com	ADj6442PWhub	Giordano Taggett	P	1988-11-17	88620140001	Jl. Autumn Leaf no. 365, Uchimaru 407-0002
lkobpac5u@nih.gov	3qdOz7	Lorinda Kobpac	L	2004-09-08	82736262829	Jl. Crowley no. 70, Makoko
awinchurst5v@cloudflare.com	xT2VKtkJ	Amy Winchurst	P	1932-06-01	80762142879	Jl. Orin no. 62, Pankovka 173526
istoate5w@wix.com	HlurNeprZ	Immanuel Stoate	L	1962-08-27	86011139268	Jl. Mallory no. 997, Almaguer 194089
mmcfadden5x@live.com	lbFIT0	Maire McFadden	L	1930-04-06	87507423479	Jl. Gerald no. 703, Sydney 1130
mpietasch5y@nsw.gov.au	CIBijv5	Maudie Pietasch	P	1973-03-21	82903944658	Jl. Cordelia no. 217, Cumadcad 6014
mdraysay5z@weibo.com	4wpzJqxDO3C	Matilde Draysay	P	1952-06-01	87966446221	Jl. Corben no. 370, Dayou
scantu60@icio.us	MrlUJHSZeV	Starla Cantu	P	1967-01-11	89688331346	Jl. Katie no. 871, Krajandadapmulyo
tblackway61@51.la	VGZxh88Ldloq	Teressa Blackway	P	1981-10-13	89041936071	Jl. Towne no. 720, Boquira 46530-000
ryedall62@arizona.edu	0wN9o2d	Rad Yedall	P	1975-09-22	84184083560	Jl. Scofield no. 253, Pasanauri
gkristoffersen63@businesswire.com	gtCpL8083uY	Garey Kristoffersen	P	1972-05-09	89465850478	Jl. Portage no. 66, Sufang
cnewling64@hc360.com	BIzHo1	Clayson Newling	P	1959-11-24	89159608191	Jl. Starling no. 679, Amaury
medgell65@arizona.edu	u7BV78H	Micaela Edgell	P	1997-04-04	85523555260	Jl. Red Cloud no. 85, Dolinsk 102745
erihanek66@surveymonkey.com	tbbihtns	Evelyn Rihanek	P	1967-08-05	81089491133	Jl. Little Fleur no. 288, Zhuangbu
carchambault67@cam.ac.uk	bW9AcFA	Cleon Archambault	P	1957-12-10	86168846864	Jl. Transport no. 96, Dayangqi
gtackell68@rambler.ru	Vsw54XIh	Gaye Tackell	L	1974-10-11	88065222290	Jl. Lawn no. 120, Hujiaying
msaltsberger69@hud.gov	NN9TUj	Mariellen Saltsberger	L	1988-07-13	86693577153	Jl. Hansons no. 912, Bouillon 6834
csaladine6a@businesswire.com	1GL9mvvT	Celestina Saladine	L	1930-08-22	87630360279	Jl. Talisman no. 611, Nanterre 92019 CEDEX
amcsparran6b@springer.com	DInzZkCuhG	Anne-marie McSparran	L	1973-07-23	89401587927	Jl. Homewood no. 887, Kalabo
fsothern6c@dailymail.co.uk	nWqxLVK	Fred Sothern	P	1932-12-18	82889919431	Jl. Pennsylvania no. 953, Gornyak 658424
mmcgarvey6d@yellowbook.com	07RY2jFbX	Maurine McGarvey	L	1940-11-23	85543170838	Jl. Johnson no. 87, Klakeh
kmiddlemiss6e@umn.edu	riCwpK4vQjP	Katrinka Middlemiss	L	1973-07-11	84351860045	Jl. Mallard no. 570, Vuzenica 2367
jguice6f@cyberchimps.com	4hZJQyR	Jacinthe Guice	P	1987-06-06	88825342280	Jl. Michigan no. 434, Jajaway
astandell6g@washington.edu	enS7FNm7wgh1	Ashbey Standell	L	1967-10-03	88204822346	Jl. Spohn no. 123, Heping
mkeays6h@posterous.com	fEj8rXp1MNZ	Marita Keays	L	1956-12-30	83800668752	Jl. Anderson no. 999, Lian
fdarrington6i@unblog.fr	xy1D1cOZ	Frederica Darrington	L	1963-09-08	80190617622	Jl. Service no. 479, Changchi
svezey6j@va.gov	i6u7FLKGk	Susana Vezey	L	1986-01-31	81232581509	Jl. Emmet no. 298, Cololaca
servine6k@macromedia.com	taljsx5umTjz	Shanon Ervine	L	1954-11-16	86400482295	Jl. Melody no. 920, Alangilanan 2420
kchastelain6l@ucsd.edu	zaxKKH	Kara Chastelain	L	2004-09-30	81144636223	Jl. Sullivan no. 37, Xinming
forudden6m@webeden.co.uk	2WdYz3	Frazer O'Rudden	P	1997-02-15	80931190037	Jl. Surrey no. 860, Arraga 4206
jhaggerstone6n@cisco.com	kqDSc0x1itD	Janis Haggerstone	L	1986-02-21	86702997346	Jl. Butternut no. 865, Fangtang
abinnes6o@pcworld.com	oPuB4wm	Aura Binnes	P	1934-03-17	84313290763	Jl. Lakewood no. 42, Avarua
leason6p@wufoo.com	WGGmjBz6	Lowell Eason	P	1976-10-22	86042741789	Jl. Nelson no. 708, Rumelange L-3755
msteggals6q@ox.ac.uk	9Vn14dLw4la	Meade Steggals	P	1991-06-24	80200637897	Jl. Crowley no. 687, Suicheng
pmccague6r@a8.net	gT9MSyrPD	Pauline McCague	L	1976-09-01	88066108729	Jl. Carioca no. 623, Kraljevo
sricardin6s@furl.net	ShrIpe	Shari Ricardin	P	1977-11-28	85794978063	Jl. Gerald no. 883, Nanyo 2508
ntye6t@dyndns.org	lX7mheL7X	Neysa Tye	P	1958-12-15	88567457252	Jl. Helena no. 718, Cadiz 11010
jwheelwright6u@i2i.jp	lb2mS0geD	Jeanine Wheelwright	L	1966-10-17	82488436035	Jl. Oakridge no. 691, Dasoguz
wnotman6v@istockphoto.com	Q8JpwrO63	Waylen Notman	P	2004-11-04	89798087339	Jl. Anniversary no. 664, Kasiyan
zbaybutt6w@cafepress.com	dvPY7bZ	Zandra Baybutt	L	1974-05-23	88056138111	Jl. Mariners Cove no. 934, Balkanabat
olindeboom6x@adobe.com	AUnlErmBI	Olivette Lindeboom	P	1982-11-24	87901515196	Jl. Cottonwood no. 974, Irbit 623850
owhittington0@si.edu	Uz9WHeB	Octavia Whittington	P	1978-03-09	81972076578	Jl. Forest no. 223, Tawau 91010
rtarbert1@posterous.com	YDdW7mGuMV1	Robinetta Tarbert	L	2004-09-12	82915347409	Jl. Wayridge no. 482, Zuitou
rbrandenburg2@apple.com	QyDSasnQj	Ranee Brandenburg	P	1953-12-31	81148042572	Jl. Lakeland no. 507, Korczyna 38-420
rdeere3@deviantart.com	bHlOeDl35n	Ringo Deere	L	1947-02-07	86530039085	Jl. Warbler no. 773, Suraabad
mmaraga4@timesonline.co.uk	XqriRmiFm08	Mariele Maraga	L	1950-10-18	82388377984	Jl. Algoma no. 306, ™rnsk”ldsvik 891 30
emilystephens@dayrep.com	test1234	Emily Stephens	P	1997-06-08	86472637243	Jl. Anggrek no. 666, Jakarta 16241
\.


--
-- Data for Name: produk; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY produk (kode_produk, nama, harga, deskripsi) FROM stdin;
P00001  	Pulsa Simpati kuota 3 GB malam	7000.00	Pulsa Simpati kuota 3 GB malam
P00002  	Pulsa Bolt kuota 3 GB	12000.00	Pulsa Bolt kuota 3 GB
P00003  	Pulsa Bolt	27000.00	Pulsa Bolt
P00004  	Pulsa Three	52000.00	Pulsa Three
P00005  	Pulsa Three	102000.00	Pulsa Three  bonus kuota 3 GB
P00006  	Pulsa Telkomsel	152000.00	Pulsa Telkomsel
P00007  	Pulsa Axis	202000.00	Pulsa Axis
P00008  	Pulsa Telkomsel paket WiFi	7000.00	Pulsa Telkomsel paket WiFi
P00009  	Pulsa Axis paket SMS sesama	12000.00	Pulsa Axis paket SMS sesama
P000010 	Pulsa Simpati	27000.00	Pulsa Simpati
P000011 	Pulsa Telkomsel kuota 5 GB	52000.00	Pulsa Telkomsel kuota 5 GB
P000012 	Pulsa Simpati	102000.00	Pulsa Simpati  bonus kuota 4 GB malam
P000013 	Pulsa Smart Fren kuota 5 GB	152000.00	Pulsa Smart Fren kuota 5 GB
P000014 	Pulsa Simpati paket nelpon sesama	202000.00	Pulsa Simpati paket nelpon sesama
P000015 	Pulsa Bolt paket nelpon puas	7000.00	Pulsa Bolt paket nelpon puas
P000016 	Pulsa Bolt	12000.00	Pulsa Bolt
P000017 	Pulsa Telkomsel	27000.00	Pulsa Telkomsel
P000018 	Pulsa Telkomsel	52000.00	Pulsa Telkomsel
P000019 	Pulsa Smart Fren paket nelpon puas	102000.00	Pulsa Smart Fren paket nelpon puas
P000020 	Pulsa Three	152000.00	Pulsa Three
P000021 	Pulsa Smart Fren	202000.00	Pulsa Smart Fren
P000022 	Pulsa Telkomsel	7000.00	Pulsa Telkomsel
P000023 	Pulsa Mentari	12000.00	Pulsa Mentari
P000024 	Pulsa Telkomsel	27000.00	Pulsa Telkomsel  bonus nelpon 200 menit
P000025 	Pulsa IM3 paket nelpon puas	52000.00	Pulsa IM3 paket nelpon puas bonus nelpon 200 menit
P000026 	Pulsa Three kuota 1 GB	102000.00	Pulsa Three kuota 1 GB
P000027 	Pulsa Telkomsel	152000.00	Pulsa Telkomsel
P000028 	Pulsa Simpati	202000.00	Pulsa Simpati
P000029 	Pulsa IM3	7000.00	Pulsa IM3
P000030 	Pulsa IM3 kuota 5 GB	12000.00	Pulsa IM3 kuota 5 GB bonus nelpon 200 menit
P000031 	Pulsa Telkomsel	27000.00	Pulsa Telkomsel
P000032 	Pulsa Bolt kuota 1 GB	52000.00	Pulsa Bolt kuota 1 GB
P000033 	Pulsa Smart Fren	102000.00	Pulsa Smart Fren
P000034 	Pulsa Telkomsel kuota 1 GB	152000.00	Pulsa Telkomsel kuota 1 GB
P000035 	Pulsa Three	202000.00	Pulsa Three
P000036 	Pulsa IM3 paket SMS puas	7000.00	Pulsa IM3 paket SMS puas
P000037 	Pulsa Mentari	12000.00	Pulsa Mentari
P000038 	Pulsa Three paket WiFi	27000.00	Pulsa Three paket WiFi
P000039 	Pulsa Three	52000.00	Pulsa Three
P000040 	Pulsa Telkomsel	102000.00	Pulsa Telkomsel
P000041 	Pulsa Bolt	152000.00	Pulsa Bolt
P000042 	Pulsa Three paket SMS puas	202000.00	Pulsa Three paket SMS puas
P000043 	Pulsa Bolt	7000.00	Pulsa Bolt
P000044 	Pulsa Mentari	12000.00	Pulsa Mentari
P000045 	Pulsa IM3 kuota 3 GB	27000.00	Pulsa IM3 kuota 3 GB
P000046 	Pulsa Mentari kuota 1 GB malam	52000.00	Pulsa Mentari kuota 1 GB malam
P000047 	Pulsa Three	102000.00	Pulsa Three  bonus kuota 4 GB malam
P000048 	Pulsa Axis	152000.00	Pulsa Axis
P000049 	Pulsa Mentari	202000.00	Pulsa Mentari
P000050 	Pulsa Axis paket SMS sesama	7000.00	Pulsa Axis paket SMS sesama bonus kuota 4 GB malam
P000051 	Pulsa Simpati	12000.00	Pulsa Simpati  bonus nelpon 200 menit
P000052 	Pulsa Three	27000.00	Pulsa Three
P000053 	Pulsa Three	52000.00	Pulsa Three  bonus kuota 2 GB 24 jam
P000054 	Pulsa Telkomsel	102000.00	Pulsa Telkomsel
P000055 	Pulsa Three paket nelpon puas	152000.00	Pulsa Three paket nelpon puas
P000056 	Pulsa Smart Fren kuota 1 GB	202000.00	Pulsa Smart Fren kuota 1 GB bonus nelpon 200 menit
P000057 	Pulsa Three kuota 5 GB	7000.00	Pulsa Three kuota 5 GB
P000058 	Pulsa Three kuota unlimited	12000.00	Pulsa Three kuota unlimited
P000059 	Pulsa Smart Fren	27000.00	Pulsa Smart Fren
P000060 	Pulsa IM3	52000.00	Pulsa IM3
P000061 	Pulsa Smart Fren	102000.00	Pulsa Smart Fren
P000062 	Pulsa Simpati	152000.00	Pulsa Simpati
P000063 	Pulsa Mentari	202000.00	Pulsa Mentari
P000064 	Pulsa Smart Fren	7000.00	Pulsa Smart Fren
P000065 	Pulsa Bolt paket WiFi	12000.00	Pulsa Bolt paket WiFi
P000066 	Pulsa Simpati	27000.00	Pulsa Simpati
P000067 	Pulsa Axis paket SMS puas	52000.00	Pulsa Axis paket SMS puas
P000068 	Pulsa Three paket SMS sesama	102000.00	Pulsa Three paket SMS sesama
P000069 	Pulsa Axis kuota 3 GB	152000.00	Pulsa Axis kuota 3 GB
P000070 	Pulsa Telkomsel kuota unlimited	202000.00	Pulsa Telkomsel kuota unlimited
P000071 	Pulsa IM3	7000.00	Pulsa IM3  bonus kuota 2 GB 24 jam
P000072 	Pulsa Simpati	12000.00	Pulsa Simpati
P000073 	Pulsa Mentari	27000.00	Pulsa Mentari
P000074 	Pulsa Smart Fren kuota 2 GB	52000.00	Pulsa Smart Fren kuota 2 GB
P000075 	Pulsa Telkomsel kuota 3 GB malam	102000.00	Pulsa Telkomsel kuota 3 GB malam
P000076 	Pulsa Simpati	152000.00	Pulsa Simpati  bonus kuota 3 GB
P000077 	Pulsa Mentari	202000.00	Pulsa Mentari
P000078 	Pulsa Mentari paket nelpon sesama	7000.00	Pulsa Mentari paket nelpon sesama bonus kuota 3 GB
P000079 	Pulsa Bolt	12000.00	Pulsa Bolt
P000080 	Pulsa Three	27000.00	Pulsa Three
P000081 	Pulsa Smart Fren	52000.00	Pulsa Smart Fren
P000082 	Pulsa Three	102000.00	Pulsa Three
P000083 	Pulsa Telkomsel kuota 1 GB	152000.00	Pulsa Telkomsel kuota 1 GB
P000084 	Pulsa Telkomsel paket WiFi	202000.00	Pulsa Telkomsel paket WiFi
P000085 	Pulsa Axis	7000.00	Pulsa Axis
P000086 	Pulsa Simpati	12000.00	Pulsa Simpati
P000087 	Pulsa Axis	27000.00	Pulsa Axis
P000088 	Pulsa Mentari	52000.00	Pulsa Mentari
P000089 	Pulsa IM3 kuota 1 GB malam	102000.00	Pulsa IM3 kuota 1 GB malam
P000090 	Pulsa Mentari paket nelpon puas	152000.00	Pulsa Mentari paket nelpon puas
P000091 	Pulsa Bolt	202000.00	Pulsa Bolt
P000092 	Pulsa Simpati	7000.00	Pulsa Simpati
P000093 	Pulsa Bolt	12000.00	Pulsa Bolt
P000094 	Pulsa Telkomsel	27000.00	Pulsa Telkomsel  bonus kuota 2 GB 24 jam
P000095 	Pulsa Simpati kuota 1 GB malam	52000.00	Pulsa Simpati kuota 1 GB malam
P000096 	Pulsa Axis kuota 3 GB	102000.00	Pulsa Axis kuota 3 GB
P000097 	Pulsa Simpati	152000.00	Pulsa Simpati  bonus kuota 3 GB
P000098 	Pulsa Three kuota 3 GB malam	202000.00	Pulsa Three kuota 3 GB malam
P000099 	Pulsa Simpati	7000.00	Pulsa Simpati
P0000100	Pulsa Smart Fren kuota 3 GB malam	12000.00	Pulsa Smart Fren kuota 3 GB malam
P0000101	Pulsa Smart Fren	27000.00	Pulsa Smart Fren
P0000102	Pulsa Axis kuota 1 GB malam	52000.00	Pulsa Axis kuota 1 GB malam
P0000103	Pulsa Mentari	102000.00	Pulsa Mentari
P0000104	Pulsa Three	152000.00	Pulsa Three
P0000105	Pulsa Smart Fren	202000.00	Pulsa Smart Fren  bonus kuota 2 GB 24 jam
P0000106	Pulsa Axis kuota 2 GB	7000.00	Pulsa Axis kuota 2 GB
P0000107	Pulsa Telkomsel paket nelpon puas	12000.00	Pulsa Telkomsel paket nelpon puas
P0000108	Pulsa Simpati kuota 5 GB	27000.00	Pulsa Simpati kuota 5 GB
P0000109	Pulsa Bolt paket nelpon puas	52000.00	Pulsa Bolt paket nelpon puas
P0000110	Pulsa Bolt paket SMS sesama	102000.00	Pulsa Bolt paket SMS sesama bonus kuota 2 GB 24 jam
P0000111	Pulsa Axis	152000.00	Pulsa Axis  bonus kuota 4 GB malam
P0000112	Pulsa Three paket nelpon puas	202000.00	Pulsa Three paket nelpon puas
P0000113	Pulsa Smart Fren	7000.00	Pulsa Smart Fren
P0000114	Pulsa IM3	12000.00	Pulsa IM3
P0000115	Pulsa Mentari	27000.00	Pulsa Mentari
P0000116	Pulsa IM3	52000.00	Pulsa IM3
P0000117	Pulsa Telkomsel	102000.00	Pulsa Telkomsel
P0000118	Pulsa IM3	152000.00	Pulsa IM3
P0000119	Pulsa Telkomsel kuota 2 GB	202000.00	Pulsa Telkomsel kuota 2 GB
P0000120	Pulsa Telkomsel	7000.00	Pulsa Telkomsel
P0000121	Pulsa Bolt	12000.00	Pulsa Bolt  bonus kuota 3 GB
P0000122	Pulsa Telkomsel paket WiFi	27000.00	Pulsa Telkomsel paket WiFi
P0000123	Pulsa Smart Fren	52000.00	Pulsa Smart Fren
P0000124	Pulsa Telkomsel kuota 2 GB	102000.00	Pulsa Telkomsel kuota 2 GB bonus kuota 4 GB malam
P0000125	Pulsa Smart Fren	152000.00	Pulsa Smart Fren
P0000126	Pulsa Simpati kuota 2 GB	202000.00	Pulsa Simpati kuota 2 GB
P0000127	Pulsa Bolt	7000.00	Pulsa Bolt
P0000128	Pulsa Smart Fren paket SMS puas	12000.00	Pulsa Smart Fren paket SMS puas
P0000129	Pulsa IM3 paket WiFi	27000.00	Pulsa IM3 paket WiFi bonus kuota 4 GB malam
P0000130	Pulsa Mentari	52000.00	Pulsa Mentari  bonus kuota 2 GB 24 jam
P0000131	Pulsa Three kuota 5 GB	102000.00	Pulsa Three kuota 5 GB
P0000132	Pulsa IM3	152000.00	Pulsa IM3
P0000133	Pulsa Mentari	202000.00	Pulsa Mentari  bonus nelpon 200 menit
P0000134	Pulsa Telkomsel kuota 3 GB	7000.00	Pulsa Telkomsel kuota 3 GB
P0000135	Pulsa Three kuota 2 GB	12000.00	Pulsa Three kuota 2 GB
P0000136	Pulsa Axis	27000.00	Pulsa Axis
P0000137	Pulsa Bolt kuota 1 GB	52000.00	Pulsa Bolt kuota 1 GB
P0000138	Pulsa Axis	102000.00	Pulsa Axis
P0000139	Pulsa Bolt	152000.00	Pulsa Bolt
P0000140	Pulsa Three	202000.00	Pulsa Three
P0000141	Pulsa Simpati	7000.00	Pulsa Simpati
P0000142	Pulsa Mentari	12000.00	Pulsa Mentari
P0000143	Pulsa Smart Fren	27000.00	Pulsa Smart Fren
P0000144	Pulsa IM3	52000.00	Pulsa IM3
P0000145	Pulsa Axis	102000.00	Pulsa Axis
P0000146	Pulsa Axis	152000.00	Pulsa Axis
P0000147	Pulsa Mentari	202000.00	Pulsa Mentari
P0000148	Pulsa Bolt paket SMS puas	7000.00	Pulsa Bolt paket SMS puas
P0000149	Pulsa IM3	12000.00	Pulsa IM3
P0000150	Pulsa Axis	27000.00	Pulsa Axis
P0000151	Pulsa Telkomsel paket SMS sesama	52000.00	Pulsa Telkomsel paket SMS sesama
P0000152	Pulsa Telkomsel kuota 5 GB	102000.00	Pulsa Telkomsel kuota 5 GB
P0000153	Pulsa Axis	152000.00	Pulsa Axis
P0000154	Pulsa Mentari paket WiFi	202000.00	Pulsa Mentari paket WiFi bonus nelpon 200 menit
P0000155	Pulsa Three	7000.00	Pulsa Three
P0000156	Pulsa Simpati	12000.00	Pulsa Simpati  bonus kuota 4 GB malam
P0000157	Pulsa Simpati	27000.00	Pulsa Simpati
P0000158	Pulsa Smart Fren	52000.00	Pulsa Smart Fren
P0000159	Pulsa IM3	102000.00	Pulsa IM3  bonus kuota 3 GB
P0000160	Pulsa Simpati	152000.00	Pulsa Simpati
P0000161	Pulsa Three paket nelpon sesama	202000.00	Pulsa Three paket nelpon sesama
P0000162	Pulsa Telkomsel	7000.00	Pulsa Telkomsel  bonus kuota 4 GB malam
P0000163	Pulsa Axis	12000.00	Pulsa Axis
P0000164	Pulsa Bolt paket nelpon puas	27000.00	Pulsa Bolt paket nelpon puas bonus kuota 3 GB
P0000165	Pulsa Axis kuota 3 GB	52000.00	Pulsa Axis kuota 3 GB bonus kuota 2 GB 24 jam
P0000166	Pulsa Bolt paket SMS sesama	102000.00	Pulsa Bolt paket SMS sesama bonus kuota 4 GB malam
P0000167	Pulsa Smart Fren	152000.00	Pulsa Smart Fren
P0000168	Pulsa Axis paket SMS sesama	202000.00	Pulsa Axis paket SMS sesama bonus kuota 2 GB 24 jam
P0000169	Pulsa Telkomsel kuota 1 GB malam	7000.00	Pulsa Telkomsel kuota 1 GB malam
P0000170	Pulsa Mentari	12000.00	Pulsa Mentari
P0000171	Pulsa Simpati kuota 3 GB	27000.00	Pulsa Simpati kuota 3 GB
P0000172	Pulsa Axis	52000.00	Pulsa Axis
P0000173	Pulsa Smart Fren	102000.00	Pulsa Smart Fren  bonus kuota 3 GB
P0000174	Pulsa Telkomsel	152000.00	Pulsa Telkomsel
P0000175	Pulsa Mentari paket nelpon sesama	202000.00	Pulsa Mentari paket nelpon sesama
P0000176	Pulsa Simpati	7000.00	Pulsa Simpati
P0000177	Pulsa Telkomsel paket nelpon sesama	12000.00	Pulsa Telkomsel paket nelpon sesama
P0000178	Pulsa Bolt	27000.00	Pulsa Bolt
P0000179	Pulsa Telkomsel	52000.00	Pulsa Telkomsel
P0000180	Pulsa Telkomsel	102000.00	Pulsa Telkomsel
P0000181	Pulsa Telkomsel paket SMS puas	152000.00	Pulsa Telkomsel paket SMS puas bonus kuota 3 GB
P0000182	Pulsa Telkomsel kuota 12 GB malam	202000.00	Pulsa Telkomsel kuota 12 GB malam
P0000183	Pulsa Simpati paket nelpon puas	7000.00	Pulsa Simpati paket nelpon puas
P0000184	Pulsa Mentari paket nelpon sesama	12000.00	Pulsa Mentari paket nelpon sesama
P0000185	Pulsa Bolt kuota unlimited	27000.00	Pulsa Bolt kuota unlimited
P0000186	Pulsa IM3 paket SMS puas	52000.00	Pulsa IM3 paket SMS puas
P0000187	Pulsa IM3	102000.00	Pulsa IM3
P0000188	Pulsa Mentari kuota 1 GB	152000.00	Pulsa Mentari kuota 1 GB
P0000189	Pulsa Smart Fren kuota unlimited	202000.00	Pulsa Smart Fren kuota unlimited
P0000190	Pulsa IM3	7000.00	Pulsa IM3
P0000191	Pulsa Three kuota 12 GB malam	12000.00	Pulsa Three kuota 12 GB malam
P0000192	Pulsa IM3	27000.00	Pulsa IM3
P0000193	Pulsa Axis	52000.00	Pulsa Axis
P0000194	Pulsa Three kuota 5 GB	102000.00	Pulsa Three kuota 5 GB
P0000195	Pulsa Telkomsel	152000.00	Pulsa Telkomsel
P0000196	Pulsa Axis	202000.00	Pulsa Axis
P0000197	Pulsa Smart Fren paket SMS puas	7000.00	Pulsa Smart Fren paket SMS puas bonus kuota 3 GB
P0000198	Pulsa Mentari	12000.00	Pulsa Mentari  bonus kuota 4 GB malam
P0000199	Pulsa Mentari	27000.00	Pulsa Mentari
P0000200	Pulsa IM3	52000.00	Pulsa IM3
S0000251	Streamlined Pakaian Anak Perempuan Fuscia	821000.00	Streamlined Pakaian Anak Perempuan Fuscia  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.
S00001  	client-driven Obat & Alat Kesehatan Orange	97000.00	client-driven Obat & Alat Kesehatan Orange  Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.
S00002  	Streamlined Pakaian Anak Perempuan Fuschia	350000.00	Streamlined Pakaian Anak Perempuan Fuscia  Sed sagittis. Nunc nisl.
S00003  	Tas Violet	399000.00	radical Tas Violet  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.Donec vitae nisi.
S00004  	Aksesoris Mobil Green	835000.00	mission-critical Aksesoris Mobil Green. Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.  Nulla justo.
S00005  	Set Perawatan Mata Kaki	42000.00	Perawatan Mata Kaki.  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
S00006  	Perlengkapan Ibadah Mauv	408000.00	Centralized Perlengkapan Ibadah Mauv Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.
S00007  	upward-trending Minuman Pink	12000.00	upward-trending Minuman Pink  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
S00008  	stable Makanan Crimson	829000.00	stable Makanan Crimson  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
S00009  	Vision-oriented Kamar Tidur Mauv	2159000.00	Vision-oriented Kamar Tidur Mauv  In congue. Etiam justo. Etiam pretium iaculis justo.
S000010 	Expanded Perawatan Tangan, Kaki dan Kuku Red	501000.00	Expanded Perawatan Tangan, Kaki dan Kuku Red  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
S000011 	workforce Sepatu Anak Perempuan Red	595000.00	workforce Sepatu Anak Perempuan Red  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.
S000012 	framework Basket Yellow	926000.00	framework Basket Yellow  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.
S000013 	orchestration Kamera Pule	164000.00	orchestration Kamera Pule  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
S000014 	Switchable Pakaian Dalam Wanita Red	8782000.00	Switchable Pakaian Dalam Wanita Red  Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.
S000015 	motivating Aksesoris Anak Orange	1365000.00	motivating Aksesoris Anak Orange  In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
S000016 	foreground Aksesoris Jilbab Maroon	519000.00	foreground Aksesoris Jilbab Maroon  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S000017 	tangible Kamar Tidur Blue	307000.00	tangible Kamar Tidur Blue  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000018 	Optimized Aksesoris Jilbab Pule	821000.00	Optimized Aksesoris Jilbab Pule  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.
S000019 	Synergized Sepatu Teal	634000.00	Synergized Sepatu Teal  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
S000020 	exuding Outerwear Khaki	707000.00	exuding Outerwear Khaki  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S000021 	Function-based Kesehatan Gigi & Mulut Orange besar	66000.00	Function-based Kesehatan Gigi & Mulut Orange besar Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S000022 	tangible Atasan Khaki	51000.00	tangible Atasan Khaki  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.
S000023 	Grass-roots Setelan Muslim Turquoise	96000.00	Grass-roots Setelan Muslim Turquoise  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.
S000024 	zero tolerance Setelan Mauv	505000.00	zero tolerance Setelan Mauv  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.
S000025 	non-volatile Outerwear Aquamarine	445000.00	non-volatile Outerwear Aquamarine  Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S000026 	empowering Aksesoris Violet	88000.00	empowering Aksesoris Violet  In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S000027 	Multi-channelled Batik Pria Violet	670000.00	Multi-channelled Batik Pria Violet  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.
S000028 	installation Kesehatan Lainnya Khaki	953000.00	installation Kesehatan Lainnya Khaki  Fusce consequat. Nulla nisl. Nunc nisl.
S000029 	real-time Sepatu Maroon	51300.00	real-time Sepatu Maroon  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.
S000030 	moderator Handphone Turquoise	381000.00	moderator Handphone Turquoise  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
S000031 	Business-focused Celana Pule	247000.00	Business-focused Celana Pule  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S000032 	foreground Perlengkapan Couple Yellow	375000.00	foreground Perlengkapan Couple Yellow  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.
S000033 	monitoring Peralatan Dapur Puce	795000.00	monitoring Peralatan Dapur Puce  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.
S000034 	instruction set Kesehatan Gigi & Mulut Crimson	9149000.00	instruction set Kesehatan Gigi & Mulut Crimson  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S000035 	infrastructure Aksesoris Anak Teal besar	890000.00	infrastructure Aksesoris Anak Teal besar Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.
S000036 	Mandatory Kamar Tidur Maroon	332000.00	Mandatory Kamar Tidur Maroon  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000037 	infrastructure Aksesoris Red	359000.00	infrastructure Aksesoris Red  In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S000038 	holistic Buku Sekolah Indigo	938000.00	holistic Buku Sekolah Indigo  Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.
S000039 	user-facing Aksesoris Rambut Anak Teal	2231000.00	user-facing Aksesoris Rambut Anak Teal  Proin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.
S000040 	Grass-roots Perlengkapan Ibadah Goldenrod	3579000.00	Grass-roots Perlengkapan Ibadah Goldenrod  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.
S000041 	open system Tas Crimson	877000.00	open system Tas Crimson  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S000042 	responsive Baju Tidur Violet	250000.00	responsive Baju Tidur Violet  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.
S000043 	Reverse-engineered Dress Fuscia	360000.00	Reverse-engineered Dress Fuscia  Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.
S000044 	Adaptive Kesehatan Wanita Indigo	933000.00	Adaptive Kesehatan Wanita Indigo  Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S000045 	bandwidth-monitored Pakaian Dalam Pria Pule	3519000.00	bandwidth-monitored Pakaian Dalam Pria Pule  Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.
S000046 	Optional Perlengkapan Couple Violet	352000.00	Optional Perlengkapan Couple Violet  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S000047 	extranet Celana Crimson	215800.00	extranet Celana Crimson  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
S000048 	Persistent Perhiasan Fashion Turquoise	791000.00	Persistent Perhiasan Fashion Turquoise  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S000049 	methodical TV Indigo	296000.00	methodical TV Indigo  Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.
S000050 	matrices Outerwear Khaki	594000.00	matrices Outerwear Khaki  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.
S000051 	modular Mandi & Perawatan Tubuh Yellow	660000.00	modular Mandi & Perawatan Tubuh Yellow  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S000052 	contingency Alat Tulis Red	335000.00	contingency Alat Tulis Red  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S000053 	contextually-based Bawahan Puce	962000.00	contextually-based Bawahan Puce  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
S000054 	software Perlengkapan Ibadah Pule	8377000.00	software Perlengkapan Ibadah Pule  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
S000055 	Synchronised Outerwear Pule	824000.00	Synchronised Outerwear Pule  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S000056 	client-server Grooming Goldenrod	920000.00	client-server Grooming Goldenrod  Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S000057 	Enterise-wide Batik Pria Maroon	359000.00	Enterise-wide Batik Pria Maroon  Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.
S000058 	encryption TV Blue	936000.00	encryption TV Blue  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S000059 	client-driven Perawatan Mata Teal	716000.00	client-driven Perawatan Mata Teal  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.
S0000139	system engine Tas Anak Maroon	372000.00	system engine Tas Anak Maroon  Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.
S000060 	archive Aksesoris Jilbab Turquoise	501000.00	archive Aksesoris Jilbab Turquoise  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S000061 	Customer-focused Kamera Pink	245000.00	Customer-focused Kamera Pink  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000062 	archive Buku Sekolah Yellow	1092000.00	archive Buku Sekolah Yellow  Proin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S000063 	parallelism Makanan Yellow	825000.00	parallelism Makanan Yellow  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S000064 	function Dress Fuscia	666000.00	function Dress Fuscia  Duis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S0000190	artificial intelligence Basket Orange	6864000.00	artificial intelligence Basket Orange  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
S000065 	Vision-oriented Outerwear Blue	4984000.00	Vision-oriented Outerwear Blue  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S000066 	system-worthy Aksesoris Rambut Turquoise	439000.00	system-worthy Aksesoris Rambut Turquoise  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S000067 	national Perawatan Wajah Yellow	7183000.00	national Perawatan Wajah Yellow  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S000068 	composite Setelan Muslim Khaki	420000.00	composite Setelan Muslim Khaki  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.
S000069 	mission-critical Novel Sastra Puce	183000.00	mission-critical Novel Sastra Puce  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.
S000070 	concept Aksesoris Jilbab Turquoise	89000.00	concept Aksesoris Jilbab Turquoise  Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.
S0000191	optimizing Jam Tangan Red	14000.00	optimizing Jam Tangan Red  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.
S0000192	migration Atasan Yellow	611000.00	migration Atasan Yellow  Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
S000071 	foreground Komputer Mauv	701000.00	foreground Komputer Mauv  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S000072 	Object-based Handphone Teal	919000.00	Object-based Handphone Teal  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000073 	orchestration Komputer Yellow	209400.00	orchestration Komputer Yellow  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.
S000074 	transitional Buku Sekolah Crimson	9036000.00	transitional Buku Sekolah Crimson  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S000075 	Business-focused Boneka Mauv	524000.00	Business-focused Boneka Mauv  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S000087 	5th generation Buku Sekolah Green	75000.00	5th generation Buku Sekolah Green  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.
S000076 	emulation Bawahan Goldenrod	54000.00	emulation Bawahan Goldenrod  Duis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S000077 	Virtual Dress Goldenrod	1265000.00	Virtual Dress Goldenrod  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S000078 	encoding Musik Indigo	255000.00	encoding Musik Indigo  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.
S000079 	Robust Perhiasan Fashion Orange	210000.00	Robust Perhiasan Fashion Orange  Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S000080 	value-added Pakaian Anak Perempuan Maroon	112000.00	value-added Pakaian Anak Perempuan Maroon  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S000081 	website Perhiasan Fashion Mauv kecil	83000.00	website Perhiasan Fashion Mauv kecil Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000193	Progressive Scarf Fuscia	56000.00	Progressive Scarf Fuscia  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.
S000082 	Virtual Atasan Green	398000.00	Virtual Atasan Green  Duis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.
S000083 	array Perlengkapan Couple Violet	310000.00	array Perlengkapan Couple Violet  Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S000084 	Profound Kamar Tidur Red	42000.00	Profound Kamar Tidur Red  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S000085 	Reactive Baju Tidur Green	818000.00	Reactive Baju Tidur Green  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000086 	motivating Aksesoris Mobil Yellow	119000.00	motivating Aksesoris Mobil Yellow  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S000088 	data-warehouse Pakaian Dalam Wanita Turquoise	12000.00	data-warehouse Pakaian Dalam Wanita Turquoise  Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S000089 	implementation Atasan Pink	52535.00	implementation Atasan Pink  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\n\nVestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.
S000090 	executive Basket Fuscia	399000.00	executive Basket Fuscia  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S000091 	interface Kesehatan Lainnya Green	815000.00	interface Kesehatan Lainnya Green  Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S000092 	functionalities Tas Anak Fuscia	264000.00	functionalities Tas Anak Fuscia  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000137	modular Aksesoris Mauv	7462000.00	modular Aksesoris Mauv  Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S000093 	methodical Kesehatan Gigi & Mulut Yellow	1110000.00	methodical Kesehatan Gigi & Mulut Yellow  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S000094 	Inverse Setelan Muslim Crimson	743000.00	Inverse Setelan Muslim Crimson  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.
S000095 	analyzer Mandi & Perawatan Tubuh Pink	747000.00	analyzer Mandi & Perawatan Tubuh Pink  Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
S000096 	database Obat & Alat Kesehatan Khaki kecil	409000.00	database Obat & Alat Kesehatan Khaki kecil Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S000097 	software Kamar Tidur Indigo	8243000.00	software Kamar Tidur Indigo  In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000194	dynamic Outerwear Green	480000.00	dynamic Outerwear Green  Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S0000195	analyzing Mandi & Perawatan Tubuh Orange	451000.00	analyzing Mandi & Perawatan Tubuh Orange  In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
S0000196	bandwidth-monitored Celana Orange	4031000.00	bandwidth-monitored Celana Orange  Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
S000098 	incremental Styling Rambut Indigo	515000.00	incremental Styling Rambut Indigo  Proin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S000099 	implementation Perlengkapan Jahit Khaki	933000.00	implementation Perlengkapan Jahit Khaki  Duis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000100	systematic Scarf Crimson	8437000.00	systematic Scarf Crimson  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000101	Diverse Pakaian Dalam Pria Orange	82000.00	Diverse Pakaian Dalam Pria Orange  Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.
S0000102	forecast Aksesoris Jilbab Orange	5000.00	forecast Aksesoris Jilbab Orange  Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000109	executive Celana Aquamarine	227000.00	executive Celana Aquamarine  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.
S0000103	explicit Outerwear Crimson	42000.00	explicit Outerwear Crimson  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.
S0000104	systematic Basket Fuscia	913000.00	systematic Basket Fuscia  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S0000105	Devolved Baju Muslim Anak Teal	131000.00	Devolved Baju Muslim Anak Teal  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000106	time-frame Perlengkapan Medis Green	411000.00	time-frame Perlengkapan Medis Green  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000107	ability Perlengkapan Medis Maroon	2000.00	ability Perlengkapan Medis Maroon  Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S0000108	Secured Kamera Red	3769000.00	Secured Kamera Red  Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
S0000197	monitoring Scarf Indigo	2307000.00	monitoring Scarf Indigo  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S0000198	next generation Tas Anak Crimson	381000.00	next generation Tas Anak Crimson  In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000110	Fully-configurable Perawatan Rambut Aquamarine	989000.00	Fully-configurable Perawatan Rambut Aquamarine  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.
S0000111	Versatile Perlengkapan Jahit Pule	365000.00	Versatile Perlengkapan Jahit Pule  Proin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000112	4th generation Sepatu Goldenrod	32000.00	4th generation Sepatu Goldenrod  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S0000113	coherent Perhiasan Fashion Green	503000.00	coherent Perhiasan Fashion Green  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
S0000114	toolset Dress Aquamarine	6634000.00	toolset Dress Aquamarine  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
S0000199	composite Baju Tidur Pule	419000.00	composite Baju Tidur Pule  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S0000115	bottom-line Telinga Puce	551000.00	bottom-line Telinga Puce  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000116	infrastructure Aksesoris Jilbab Indigo	707000.00	infrastructure Aksesoris Jilbab Indigo  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000117	interactive Kamar Tidur Pule	403000.00	interactive Kamar Tidur Pule  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000118	optimizing Setelan Aquamarine	8927000.00	optimizing Setelan Aquamarine  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000119	Stand-alone Sepatu Red	1132000.00	Stand-alone Sepatu Red  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S0000120	portal Sepatu Yellow	129000.00	portal Sepatu Yellow  Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S0000121	object-oriented Aksesoris Anak Orange	899000.00	object-oriented Aksesoris Anak Orange  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.
S0000122	Stand-alone Jam Tangan Violet	156000.00	Stand-alone Jam Tangan Violet  In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.
S0000123	Open-source Laptop Aquamarine	388000.00	Open-source Laptop Aquamarine  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.
S0000124	Public-key Alat Tulis Indigo	147000.00	Public-key Alat Tulis Indigo  Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
S0000125	Graphic Interface Obat & Alat Kesehatan Maroon	3519000.00	Graphic Interface Obat & Alat Kesehatan Maroon  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S0000126	infrastructure Perawatan Tangan, Kaki dan Kuku Pule	816000.00	infrastructure Perawatan Tangan, Kaki dan Kuku Pule  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.
S0000127	intranet Perhiasan Fashion Crimson	6647000.00	intranet Perhiasan Fashion Crimson  Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
S0000128	Visionary Aksesoris Jilbab Puce	772000.00	Visionary Aksesoris Jilbab Puce  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S0000129	approach Perawatan Tangan, Kaki dan Kuku Red	8712000.00	approach Perawatan Tangan, Kaki dan Kuku Red  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.
S0000130	Front-line Figure Puce	658000.00	Front-line Figure Puce  Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
S0000131	archive Sepatu Red	675000.00	archive Sepatu Red  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000138	well-modulated Peralatan Dapur Indigo	3148000.00	well-modulated Peralatan Dapur Indigo  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000132	synergy Pakaian Anak Perempuan Pink	733000.00	synergy Pakaian Anak Perempuan Pink  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\n\nVestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
S0000133	Diverse Aksesoris Blue	656000.00	Diverse Aksesoris Blue  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
S0000134	approach Jam Tangan Teal	375000.00	approach Jam Tangan Teal  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000135	Automated Kesehatan Mata Yellow	334000.00	Automated Kesehatan Mata Yellow  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
S0000136	object-oriented Perhiasan Fashion Orange	298400.00	object-oriented Perhiasan Fashion Orange  Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000140	projection Musik Mauv	182000.00	projection Musik Mauv  Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n
S0000141	Vision-oriented Figure Puce	1490000.00	Vision-oriented Figure Puce  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000142	Cloned Pakaian Dalam Wanita Goldenrod	404000.00	Cloned Pakaian Dalam Wanita Goldenrod  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.
S0000143	uniform Sepatu Puce	6280000.00	uniform Sepatu Puce  Duis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000144	groupware Atasan Crimson	3815000.00	groupware Atasan Crimson  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S0000145	Ameliorated Telinga Green	8019000.00	Ameliorated Telinga Green  Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S0000146	systemic Jam Tangan Khaki	1646000.00	systemic Jam Tangan Khaki  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S0000217	Vision-oriented Pakaian Anak Perempuan Fuscia	7562000.00	Vision-oriented Pakaian Anak Perempuan Fuscia  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
S0000218	multimedia Bawahan Yellow	3209000.00	multimedia Bawahan Yellow  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.
S0000147	multimedia Kamera Goldenrod	785000.00	multimedia Kamera Goldenrod  Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S0000148	stable Musik Pink	8647000.00	stable Musik Pink  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000149	solution-oriented Outerwear Mauv	9458000.00	solution-oriented Outerwear Mauv  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000150	well-modulated Dress Crimson	930000.00	well-modulated Dress Crimson  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.
S0000151	instruction set Diet & Vitamin Crimson	564000.00	instruction set Diet & Vitamin Crimson  Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000152	archive Outerwear Puce	7377000.00	archive Outerwear Puce  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S0000153	Distributed Aksesoris Mobil Pink	8106000.00	Distributed Aksesoris Mobil Pink  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.
S0000219	product Perawatan Rambut Violet besar	9725000.00	product Perawatan Rambut Violet besar Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000154	Adaptive Dress Indigo	8174000.00	Adaptive Dress Indigo  Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000155	paradigm Musik Fuscia	13000.00	paradigm Musik Fuscia  Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000156	open system Outerwear Puce	66000.00	open system Outerwear Puce  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S0000157	secondary Musik Red	737000.00	secondary Musik Red  Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.
S0000158	moratorium Sepatu Pink	4905000.00	moratorium Sepatu Pink  Proin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.
S0000159	emulation Perhiasan Anak Indigo	8928000.00	emulation Perhiasan Anak Indigo  Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000160	bottom-line Sepatu Crimson	703000.00	bottom-line Sepatu Crimson  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S0000161	encryption Grooming Khaki	39400.00	encryption Grooming Khaki  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.
S0000162	intranet Perlengkapan Couple Red	9786000.00	intranet Perlengkapan Couple Red  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.
S0000163	Enterise-wide Tas Red	152000.00	Enterise-wide Tas Red  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n
S0000164	executive Tas Aquamarine	628000.00	executive Tas Aquamarine.
S0000165	Assimilated Batik Pria Blue	6259000.00	Assimilated Batik Pria Blue  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
S0000166	open architecture Setelan Muslim Mauv	904000.00	open architecture Setelan Muslim Mauv  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.
S0000167	archive Boneka Violet	2200000.00	archive Boneka Violet  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.
S0000168	solution Sepatu Anak Laki-laki Crimson	7045000.00	solution Sepatu Anak Laki-laki Crimson.
S0000169	firmware Perawatan Mata Aquamarine	758000.00	firmware Perawatan Mata Aquamarine  Duis aliquam convallis nunc. Proin at tuis a pede posuere nonummy
S0000170	Self-enabling Perawatan Rambut Maroon	7388000.00	Self-enabling Perawatan Rambut Maroon  In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S0000171	cohesive Atasan Green	216000.00	cohesive Atasan Green  Aenean lectus. Pellentesque eget nunc. Donec quis orci.
S0000172	user-facing Perhiasan Fashion Aquamarine	9275000.00	user-facing Perhiasan Fashion Aquamarine  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.
S0000173	Reduced Dress Mauv	245000.00	Reduced Dress Mauv  Aenean lectus. Pellentesque eget nunc..
S0000174	transitional Atasan Puce	598100.00	transitional Atasan Puce  Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nis.
S0000175	Front-line Perlengkapan Jahit Green	835000.00	Front-line Perlengkapan Jahit Green  In quis justo.
S0000176	logistical Diet & Vitamin Orange	72000.00	logistical Diet & Vitamin Orange  Phasellus sit amet erat.
S0000177	ability Obat & Alat Kesehatan Fuscia	715000.00	ability Obat & Alat Kesehatan Fuscia  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S0000178	incremental Aksesoris Rambut Anak Blue	130000.00	incremental Aksesoris Rambut Anak Blue  Etiam vel augue. Vestibulum rutrum rutrum neque.
S0000179	disintermediate Baju Muslim Anak Indigo	748000.00	disintermediate Baju Muslim Anak Indigo  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.
S0000180	Cloned Musik Green	1608000.00	Cloned Musik Green  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
S0000181	open system Mandi & Perawatan Tubuh Goldenrod	714000.00	open system Mandi & Perawatan Tubuh Goldenrod  Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000182	uniform Batik Wanita Goldenrod	695000.00	uniform Batik Wanita Goldenrod  Duis bibendum.
S0000183	pricing structure Health Products Indigo	456000.00	pricing structure Health Products Indigo  Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.
S0000184	Enhanced Aksesoris Anak Pink	584000.00	Enhanced Aksesoris Anak Pink  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.
S0000185	local Komputer Orange	5311000.00	local Komputer Orange  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.
S0000186	policy Celana Blue	101500.00	policy Celana Blue  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis.
S0000187	process improvement Baju Muslim Anak Orange	561000.00	process improvement Baju Muslim Anak Orange  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
S0000188	hybrid Perawatan Rambut Red	401000.00	hybrid Perawatan Rambut Red  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.
S0000189	Switchable Perhiasan Anak Indigo kecil	2765000.00	Switchable Perhiasan Anak Indigo kecil In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
S0000200	interface Diet & Vitamin Indigo	364000.00	interface Diet & Vitamin Indigo  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S0000201	Streamlined Boneka Aquamarine	879000.00	Streamlined Boneka Aquamarine  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
S0000202	system engine Pakaian Dalam Pria Teal	4656000.00	system engine Pakaian Dalam Pria Teal  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S0000203	Quality-focused Pakaian Dalam Pria Teal	895000.00	Quality-focused Pakaian Dalam Pria Teal  Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S0000204	local Setelan Teal	108000.00	local Setelan Teal  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000205	24/7 Makanan Puce	599000.00	24/7 Makanan Puce  Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S0000206	Customer-focused Peralatan Dapur Violet	73000.00	Customer-focused Peralatan Dapur Violet  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.
S0000207	benchmark Pakaian Anak Perempuan Maroon	854000.00	benchmark Pakaian Anak Perempuan Maroon  Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
S0000208	Organized Atasan Pule	670000.00	Organized Atasan Pule  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.
S0000246	Distributed Laptop Yellow	873000.00	Distributed Laptop Yellow  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
S0000209	Graphical User Interface Outerwear Fuscia	37000.00	Graphical User Interface Outerwear Fuscia  Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
S0000210	Ameliorated Aksesoris Rambut Anak Pink	4285000.00	Ameliorated Aksesoris Rambut Anak Pink  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.
S0000211	bifurcated Aksesoris Rambut Mauv	2521000.00	bifurcated Aksesoris Rambut Mauv  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S0000212	Diverse Perawatan Tangan, Kaki dan Kuku Maroon	827000.00	Diverse Perawatan Tangan, Kaki dan Kuku Maroon  Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000213	firmware Baju Tidur Maroon	541000.00	firmware Baju Tidur Maroon  Nullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.
S0000214	internet solution Perlengkapan Ibadah Blue	981000.00	internet solution Perlengkapan Ibadah Blue  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.Duis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.
S0000215	grid-enabled TV Teal	689000.00	grid-enabled TV Teal  Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.
S0000216	impactful Tas Anak Teal	1969000.00	impactful Tas Anak Teal  Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.
S0000220	frame Perhiasan Violet	43000.00	frame Perhiasan Violet  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
S0000221	Down-sized Kamar Tidur Green	900000.00	Down-sized Kamar Tidur Green  Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.
S0000222	internet solution Scarf Goldenrod	9580000.00	internet solution Scarf Goldenrod  Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S0000223	zero administration Perhiasan Anak Yellow besar	71000.00	zero administration Perhiasan Anak Yellow besar Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\n\nVestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
S0000224	strategy Aksesoris Mobil Red	908000.00	strategy Aksesoris Mobil Red  Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S0000225	Grass-roots Perhiasan Fashion Pule	297000.00	Grass-roots Perhiasan Fashion Pule  Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcoer augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcoer purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
S0000226	adapter Buku Sekolah Turquoise	4172000.00	adapter Buku Sekolah Turquoise  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.
S0000227	User-friendly Aksesoris Bayi Green	1376000.00	User-friendly Aksesoris Bayi Green  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
S0000228	Integrated Aksesoris Jilbab Orange	60000.00	Integrated Aksesoris Jilbab Orange  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S0000229	model Kamar Tidur Pink	207000.00	model Kamar Tidur Pink  Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.
S0000230	Business-focused Atasan Aquamarine	136000.00	Business-focused Atasan Aquamarine  Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S0000231	Fully-configurable Atasan Crimson	705000.00	Fully-configurable Atasan Crimson  Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
S0000232	Cross-platform Setelan Muslim Goldenrod	684000.00	Cross-platform Setelan Muslim Goldenrod  Duis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000233	parallelism Setelan Muslim Indigo	35000.00	parallelism Setelan Muslim Indigo  Nullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S0000234	multi-tasking Perhiasan Aquamarine	4799000.00	multi-tasking Perhiasan Aquamarine  Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.
S0000235	fault-tolerant Outerwear Turquoise	42000.00	fault-tolerant Outerwear Turquoise  Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
S0000236	Function-based Perlengkapan Jahit Crimson	877000.00	Function-based Perlengkapan Jahit Crimson  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.
S0000237	next generation Jam Tangan Violet	81000.00	next generation Jam Tangan Violet  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.
S0000238	methodology Atasan Violet	334000.00	methodology Atasan Violet  Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.
S0000239	throughput Perlengkapan Medis Blue	853000.00	throughput Perlengkapan Medis Blue  In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.
S0000240	info-mediaries Basket Indigo	170000.00	info-mediaries Basket Indigo  Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.
S0000241	directional Pakaian Dalam Pria Orange	7971000.00	directional Pakaian Dalam Pria Orange  Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.
S0000242	core Buku Sekolah Green	667000.00	core Buku Sekolah Green  Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, tuis nec euismod scelerisque, quam tuis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at tuis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.
S0000243	real-time Jam Tangan Khaki	799000.00	real-time Jam Tangan Khaki  Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.
S0000244	capacity Perlengkapan Couple Violet	654000.00	capacity Perlengkapan Couple Violet  Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
S0000245	Graphical User Interface Pakaian Anak Laki-Laki Fuscia	667000.00	Graphical User Interface Pakaian Anak Laki-Laki Fuscia  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.
S0000247	Universal Outerwear Teal	269000.00	Universal Outerwear Teal  Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.
S0000248	parallelism Outerwear Turquoise	2327000.00	parallelism Outerwear Turquoise  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\n\nVestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, tuis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet tuis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at tuis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.
S0000249	Public-key Diet & Vitamin Turquoise	551000.00	Public-key Diet & Vitamin Turquoise  Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.
S0000250	Optimized Minuman Violet	117000.00	Optimized Minuman Violet  Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, tuis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis tuis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis tuis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.
\.


--
-- Data for Name: produk_pulsa; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY produk_pulsa (kode_produk, nominal) FROM stdin;
P00001  	5
P00002  	10
P00003  	25
P00004  	50
P00005  	100
P00006  	150
P00007  	200
P00008  	5
P00009  	10
P000010 	25
P000011 	50
P000012 	100
P000013 	150
P000014 	200
P000015 	5
P000016 	10
P000017 	25
P000018 	50
P000019 	100
P000020 	150
P000021 	200
P000022 	5
P000023 	10
P000024 	25
P000025 	50
P000026 	100
P000027 	150
P000028 	200
P000029 	5
P000030 	10
P000031 	25
P000032 	50
P000033 	100
P000034 	150
P000035 	200
P000036 	5
P000037 	10
P000038 	25
P000039 	50
P000040 	100
P000041 	150
P000042 	200
P000043 	5
P000044 	10
P000045 	25
P000046 	50
P000047 	100
P000048 	150
P000049 	200
P000050 	5
P000051 	10
P000052 	25
P000053 	50
P000054 	100
P000055 	150
P000056 	200
P000057 	5
P000058 	10
P000059 	25
P000060 	50
P000061 	100
P000062 	150
P000063 	200
P000064 	5
P000065 	10
P000066 	25
P000067 	50
P000068 	100
P000069 	150
P000070 	200
P000071 	5
P000072 	10
P000073 	25
P000074 	50
P000075 	100
P000076 	150
P000077 	200
P000078 	5
P000079 	10
P000080 	25
P000081 	50
P000082 	100
P000083 	150
P000084 	200
P000085 	5
P000086 	10
P000087 	25
P000088 	50
P000089 	100
P000090 	150
P000091 	200
P000092 	5
P000093 	10
P000094 	25
P000095 	50
P000096 	100
P000097 	150
P000098 	200
P000099 	5
P0000100	10
P0000101	25
P0000102	50
P0000103	100
P0000104	150
P0000105	200
P0000106	5
P0000107	10
P0000108	25
P0000109	50
P0000110	100
P0000111	150
P0000112	200
P0000113	5
P0000114	10
P0000115	25
P0000116	50
P0000117	100
P0000118	150
P0000119	200
P0000120	5
P0000121	10
P0000122	25
P0000123	50
P0000124	100
P0000125	150
P0000126	200
P0000127	5
P0000128	10
P0000129	25
P0000130	50
P0000131	100
P0000132	150
P0000133	200
P0000134	5
P0000135	10
P0000136	25
P0000137	50
P0000138	100
P0000139	150
P0000140	200
P0000141	5
P0000142	10
P0000143	25
P0000144	50
P0000145	100
P0000146	150
P0000147	200
P0000148	5
P0000149	10
P0000150	25
P0000151	50
P0000152	100
P0000153	150
P0000154	200
P0000155	5
P0000156	10
P0000157	25
P0000158	50
P0000159	100
P0000160	150
P0000161	200
P0000162	5
P0000163	10
P0000164	25
P0000165	50
P0000166	100
P0000167	150
P0000168	200
P0000169	5
P0000170	10
P0000171	25
P0000172	50
P0000173	100
P0000174	150
P0000175	200
P0000176	5
P0000177	10
P0000178	25
P0000179	50
P0000180	100
P0000181	150
P0000182	200
P0000183	5
P0000184	10
P0000185	25
P0000186	50
P0000187	100
P0000188	150
P0000189	200
P0000190	5
P0000191	10
P0000192	25
P0000193	50
P0000194	100
P0000195	150
P0000196	200
P0000197	5
P0000198	10
P0000199	25
P0000200	50
\.


--
-- Data for Name: promo; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY promo (id, deskripsi, periode_awal, periode_akhir, kode) FROM stdin;
R00001	Donec posuere metus vitae ipsum. Aliquam non mauris.	2016-06-12	2016-06-16	Veribet
R00002	Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.	2016-11-19	2016-12-09	Trippledex
R00003	In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.	2016-09-03	2016-11-05	Tresom
R00004	In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.	2017-07-02	2017-08-07	Aerified
R00005	Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.	2017-10-30	2017-12-15	Fintone
\.


--
-- Data for Name: promo_produk; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY promo_produk (id_promo, kode_produk) FROM stdin;
R00002	P00007  
R00002	S000093 
R00004	S000039 
R00004	P0000158
R00003	S0000222
R00001	P000018 
R00001	S0000178
R00004	S0000159
R00001	S0000179
R00005	S0000175
R00003	P000083 
R00002	P0000150
R00003	S000082 
R00004	S000080 
R00005	P000076 
R00002	S0000225
R00003	S000095 
R00004	P0000166
R00002	P0000111
R00003	S000045 
R00004	S000011 
R00002	S000055 
R00005	P000031 
R00005	S000063 
R00004	S0000155
R00003	S0000101
R00004	P0000114
R00002	P0000126
R00003	P0000146
R00002	S000031 
R00001	S000073 
R00003	S000096 
R00002	S000083 
R00005	P0000183
R00003	S000068 
R00003	S000067 
R00002	P0000123
R00005	P000077 
R00005	P000044 
R00004	P0000148
R00004	S0000250
R00004	S0000246
R00004	P000041 
R00001	P000015 
R00001	S00002  
R00003	S0000193
R00004	S0000216
R00001	P000045 
R00003	P0000112
R00003	S0000249
R00002	S0000207
R00005	P0000104
R00002	P0000110
R00001	S0000137
R00002	P000018 
R00002	S0000208
R00004	S000073 
R00002	S000017 
R00003	P00001  
R00004	S0000244
R00002	S0000191
R00004	P000094 
R00001	P0000121
R00003	S0000114
R00004	P0000161
R00005	P0000100
R00002	S0000222
R00003	S00009  
R00003	P000087 
R00003	P0000190
R00005	S000018 
R00002	P0000132
R00003	S0000221
R00001	S0000138
R00002	S0000190
\.


--
-- Data for Name: shipped_produk; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY shipped_produk (kode_produk, kategori, nama_toko, is_asuransi, stok, is_baru, min_order, min_grosir, max_grosir, harga_grosir, foto) FROM stdin;
S00001  	SK056	explicit Clothing	f	342	t	5	48	65	889230.00	Sapien.png
S00002  	SK040	analyzer Computer	t	521	t	3	24	98	369089.00	NecSemDuis.png
S00003  	SK050	asynchronous Industrial	t	406	t	10	41	96	421035.00	EtUltrices.gif
S00004  	SK068	Robust Garden	t	943	t	15	38	84	791828.00	NonMattis.gif
S00005  	SK022	Organic Electronics	t	864	t	6	21	67	499721.00	UtNullaSed.tiff
S00006  	SK040	Future-proofed Toys	f	517	f	20	23	52	959614.00	InEst.tiff
S00007  	SK017	empowering Books	f	666	f	9	21	82	833877.00	Vel.tiff
S00008  	SK059	tertiary Home	t	195	t	7	43	97	701899.00	FaucibusOrci.gif
S00009  	SK073	empowering Electronics	f	102	t	9	24	74	619377.00	AccumsanOdio.png
S000010 	SK062	frame Computers	f	366	f	17	26	93	781012.00	PurusPhasellus.png
S000011 	SK047	Future-proofed Toys	f	453	f	15	31	66	981651.00	InImperdiet.jpeg
S000012 	SK003	knowledge base Games	t	883	f	10	50	51	552024.00	IpsumPrimis.gif
S000013 	SK052	real-time Automotive	f	391	f	8	39	51	818722.00	Nunc.tiff
S000014 	SK073	Advanced Baby	f	353	f	9	32	74	268002.00	MagnisDis.gif
S000015 	SK035	conglomeration Jewelery	t	688	f	16	29	82	929177.00	SapienQuis.tiff
S000016 	SK053	Re-contextualized Automotive	t	244	f	2	37	73	664863.00	Eget.tiff
S000017 	SK072	system engine Computers	t	50	f	20	34	93	391484.00	Nulla.gif
S000018 	SK021	Robust Garden	t	964	f	1	31	83	405937.00	NullaNislNunc.tiff
S000019 	SK048	client-driven Garden	f	687	t	8	39	80	892725.00	LigulaSit.jpeg
S000020 	SK032	asymmetric Baby	t	501	t	4	32	70	93264.00	RhoncusSed.gif
S000021 	SK044	Stand-alone Outdoors	t	121	t	9	46	58	981965.00	PorttitorPede.gif
S000022 	SK017	customer loyalty Movies	f	6	t	16	47	80	442744.00	MorbiNon.jpeg
S000023 	SK008	task-force Garden	t	686	f	12	29	99	939925.00	OrciNullam.tiff
S000024 	SK045	reciprocal Health	f	905	t	12	48	84	137899.00	FaucibusOrciLuctus.jpeg
S000025 	SK037	conglomeration Jewelery	t	349	f	20	50	65	647108.00	Interdum.jpeg
S000026 	SK053	alliance Toys	f	122	f	10	40	91	884018.00	OdioJustoSollicitudin.jpeg
S000027 	SK060	frame Computers	f	661	t	20	43	88	148305.00	PretiumIaculis.tiff
S000028 	SK013	grid-enabled Music	t	692	t	14	41	54	901110.00	Aliquam.tiff
S000029 	SK056	Up-sized Movies	f	208	t	7	46	76	913373.00	ElementumLigula.jpeg
S000030 	SK032	frame Computers	f	663	f	6	47	89	224413.00	MagnaAt.jpeg
S000031 	SK007	Multi-tiered Health	t	450	t	8	32	93	884079.00	Magna.png
S000032 	SK026	Implemented Games	f	42	t	2	25	61	572875.00	Sem.gif
S000033 	SK055	software Books	t	931	t	4	38	98	756446.00	Sit.png
S000034 	SK068	software Books	f	922	f	11	38	100	759070.00	InPorttitorPede.tiff
S000035 	SK029	system engine Computers	f	405	t	20	38	78	923145.00	FaucibusOrciLuctus.tiff
S000036 	SK049	Compatible Outdoors	f	566	f	6	42	98	984990.00	PorttitorLacusAt.tiff
S000037 	SK033	functionalities Home	t	901	f	9	49	73	498724.00	Volutpat.tiff
S000038 	SK052	monitoring Books	t	787	t	8	30	59	980944.00	Sapien.png
S000039 	SK049	knowledge base Games	t	558	t	6	21	84	225274.00	AugueVestibulum.gif
S000040 	SK030	software Garden	f	577	t	16	20	59	954150.00	SemperPorta.gif
S000041 	SK038	methodical Automotive	f	104	t	3	42	53	308642.00	IpsumInteger.tiff
S000042 	SK077	task-force Garden	f	205	t	19	30	97	688774.00	Massa.tiff
S000043 	SK050	software Music	f	314	t	20	37	50	151381.00	QuamTurpis.jpeg
S000044 	SK024	instruction set Beauty	f	175	f	17	39	98	567431.00	Ut.gif
S000045 	SK062	explicit Clothing	t	506	t	8	42	78	179069.00	ErosElementum.gif
S000046 	SK046	global Tools	f	886	f	13	29	71	619277.00	VulputateElementumNullam.gif
S000047 	SK034	Stand-alone Music	f	424	t	16	28	66	755395.00	Congue.tiff
S000048 	SK038	tertiary Home	t	573	f	4	29	90	216097.00	ElitProin.jpeg
S000049 	SK034	empowering Books	f	455	f	4	42	59	221018.00	Sit.png
S000050 	SK041	empowering Beauty	f	649	f	9	33	82	894877.00	MaecenasUt.tiff
S000051 	SK011	analyzing Computers	f	750	f	17	33	80	657162.00	Cubilia.jpeg
S000052 	SK012	software Books	t	639	t	9	20	82	372515.00	EgetElitSodales.gif
S000053 	SK076	Implemented Grocery	t	66	f	16	33	56	988733.00	Duis.png
S000054 	SK037	standardization Automotive	f	244	t	9	43	91	342024.00	SapienCum.jpeg
S000055 	SK015	national Outdoors	t	216	f	16	21	90	334583.00	QuisqueUtErat.tiff
S000056 	SK006	projection Jewelery	f	93	f	13	29	66	319403.00	Suscipit.gif
S000057 	SK067	bottom-line Computers	t	601	t	2	25	98	630641.00	UtDolor.gif
S000058 	SK045	Decentralized Grocery	t	863	t	5	35	90	317767.00	EratTortor.gif
S000059 	SK002	Persevering Outdoors	t	305	f	4	30	97	192982.00	SitAmet.tiff
S000060 	SK017	mission-critical Electronics	t	101	t	3	36	55	465336.00	BlanditNam.jpeg
S000061 	SK010	task-force Movies	f	858	t	15	45	79	132579.00	Turpis.tiff
S000062 	SK020	Secured Baby	f	480	t	13	26	62	273085.00	ViverraEget.tiff
S000063 	SK004	eco-centric Industrial	t	966	f	10	44	75	674312.00	CondimentumNeque.png
S000064 	SK065	Ameliorated Movies	f	834	f	4	25	92	582215.00	PrimisIn.tiff
S000065 	SK019	grid-enabled Music	t	624	t	6	49	61	598203.00	CongueDiamId.tiff
S000066 	SK037	concept Industrial	t	588	t	10	20	72	799932.00	At.tiff
S000067 	SK078	approach Tools	t	234	f	12	37	86	939669.00	FelisSedLacus.jpeg
S000068 	SK053	solution-oriented Electronics	f	482	t	12	32	56	398594.00	Consequat.png
S000069 	SK067	bottom-line Computers	t	451	t	4	20	92	346602.00	InMagnaBibendum.tiff
S000070 	SK054	system engine Computers	f	589	f	18	24	66	209745.00	UtDolor.jpeg
S000071 	SK006	flexibility Toys	f	104	f	4	28	81	873411.00	LiberoNam.png
S000072 	SK044	holistic Shoes	t	727	t	16	35	81	548941.00	NuncDonec.tiff
S000073 	SK049	mission-critical Baby	t	319	t	11	33	59	261010.00	Lacinia.gif
S000074 	SK071	eco-centric Outdoors	t	437	t	15	30	96	912641.00	VestibulumSed.tiff
S000075 	SK024	Robust Garden	f	380	t	17	38	72	469757.00	VestibulumSagittisSapien.tiff
S000076 	SK071	functionalities Toys	t	113	t	3	29	58	670009.00	Pede.tiff
S000077 	SK033	non-volatile Games	f	962	t	3	30	95	420350.00	Aenean.png
S000078 	SK024	groupware Books	f	578	t	3	44	65	529922.00	AliquamNonMauris.jpeg
S000079 	SK037	emulation Sports	t	963	t	18	40	100	692284.00	EgetOrciVehicula.png
S000080 	SK004	Re-contextualized Automotive	t	34	t	2	34	59	681896.00	Eros.tiff
S000081 	SK064	service-desk Tools	f	673	t	6	44	97	84286.00	MorbiUt.jpeg
S000082 	SK044	holistic Shoes	f	534	f	5	48	94	704023.00	ProinRisus.jpeg
S000083 	SK078	service-desk Tools	t	548	f	3	30	79	476827.00	CondimentumNequeSapien.tiff
S000084 	SK049	empowering Beauty	f	902	t	13	30	60	689198.00	ViverraDiam.tiff
S000085 	SK062	client-driven Garden	t	388	f	3	37	84	136380.00	ImperdietEt.tiff
S000086 	SK031	Secured Baby	t	674	t	1	21	96	84371.00	LaoreetUt.gif
S000087 	SK014	frame Beauty	f	450	t	19	27	99	226558.00	Et.jpeg
S000088 	SK071	functionality Home	f	64	t	5	22	100	147818.00	PrimisInFaucibus.gif
S000089 	SK048	Decentralized Grocery	t	19	t	8	20	76	29596.00	UltricesPosuereCubilia.jpeg
S000090 	SK051	real-time Automotive	t	427	t	13	37	80	163657.00	VitaeNisi.tiff
S000091 	SK010	groupware Books	t	832	t	2	24	75	776276.00	DictumstMorbiVestibulum.gif
S000092 	SK065	uniform Shoes	f	743	t	1	36	82	417743.00	IntegerAc.jpeg
S000093 	SK008	emulation Electronics	f	329	t	9	29	57	729715.00	LacusAt.gif
S000094 	SK058	holistic Shoes	t	762	t	2	38	83	769134.00	TristiqueEstEt.tiff
S000095 	SK021	conglomeration Jewelery	t	458	f	19	35	63	957598.00	Dui.jpeg
S000096 	SK032	Cross-group Health	f	203	t	3	41	93	369672.00	Ante.jpeg
S000097 	SK042	functionality Home	t	862	t	10	47	80	84660.00	TempusVelPede.png
S000098 	SK018	alliance Toys	f	895	t	13	37	93	320063.00	Sit.png
S000099 	SK005	functionality Home	f	255	t	13	40	95	306749.00	Vestibulum.png
S0000100	SK059	Multi-tiered Health	f	669	f	5	24	96	688260.00	Amet.tiff
S0000101	SK017	empowering Beauty	t	666	t	18	47	56	119214.00	DonecQuis.gif
S0000102	SK052	Ameliorated Movies	t	325	t	10	26	59	290172.00	DuisAliquamConvallis.png
S0000103	SK006	task-force Garden	f	54	t	9	21	95	438674.00	AOdioIn.tiff
S0000104	SK034	functionalities Home	t	345	f	17	40	53	67287.00	EgetMassaTempor.png
S0000105	SK063	algorithm Music	f	721	f	15	45	89	960041.00	Nunc.gif
S0000106	SK075	algorithm Music	t	24	t	19	44	58	766156.00	PosuereCubiliaCurae.tiff
S0000107	SK070	empowering Beauty	f	510	t	8	41	81	632799.00	SapienIaculisCongue.png
S0000108	SK035	Cross-platform Health	t	561	t	11	20	81	692372.00	FelisSed.jpeg
S0000109	SK046	Implemented Games	t	845	f	3	35	79	819492.00	DolorSit.jpeg
S0000110	SK009	radical Movies	t	312	t	12	41	87	876161.00	AugueVestibulum.tiff
S0000111	SK044	empowering Books	f	222	f	8	47	66	951890.00	Ligula.jpeg
S0000112	SK031	actuating Outdoors	f	271	f	19	50	83	334524.00	MetusArcu.jpeg
S0000113	SK025	Realigned Books	t	902	f	9	25	61	337646.00	TinciduntAnteVel.tiff
S0000114	SK042	approach Tools	f	147	f	8	42	100	520870.00	InHac.tiff
S0000115	SK074	explicit Clothing	t	866	f	14	20	73	822132.00	EratCurabitur.tiff
S0000116	SK069	system engine Computers	f	386	t	9	32	53	235595.00	Aliquam.jpeg
S0000117	SK058	analyzer Computers	f	336	t	17	22	88	338631.00	Sem.jpeg
S0000118	SK028	groupware Books	t	371	t	11	45	76	150077.00	SuspendisseAccumsanTortor.tiff
S0000119	SK077	empowering Books	f	615	t	2	34	89	976015.00	Euismod.tiff
S0000120	SK056	Re-contextualized Automotive	t	526	f	14	29	63	99033.00	TurpisElementumLigula.jpeg
S0000121	SK072	groupware Books	f	764	t	6	29	55	369204.00	FacilisiCrasNon.jpeg
S0000122	SK011	Customizable Shoes	f	396	f	15	44	63	84738.00	SodalesSedTincidunt.gif
S0000123	SK053	solution-oriented Baby	t	212	f	16	49	64	358982.00	MagnisDis.gif
S0000124	SK045	installation Computers	t	403	f	18	43	92	751784.00	Et.jpeg
S0000125	SK017	Robust Garden	t	535	t	18	27	84	866137.00	NecDuiLuctus.jpeg
S0000126	SK054	Implemented Grocery	t	191	f	2	44	75	103770.00	AtNibh.gif
S0000127	SK073	Future-proofed Baby	t	165	t	7	50	91	961191.00	LobortisConvallisTortor.png
S0000128	SK057	analyzing Computers	t	622	t	4	38	77	569686.00	PotentiCrasIn.tiff
S0000129	SK080	flexibility Toys	t	545	f	17	42	72	134157.00	NibhIn.jpeg
S0000130	SK016	empowering Books	t	610	f	6	43	74	621428.00	TempusVivamusIn.tiff
S0000131	SK012	Robust Garden	t	343	f	20	26	74	443611.00	In.gif
S0000132	SK076	Re-contextualized Automotive	t	878	f	11	20	56	344163.00	EtUltricesPosuere.tiff
S0000133	SK076	Quality-focused Music	f	461	t	17	46	76	297777.00	MorbiPorttitorLorem.tiff
S0000134	SK069	conglomeration Jewelery	f	757	t	7	32	66	372167.00	Nam.tiff
S0000135	SK042	Robust Home	f	389	f	20	42	82	920496.00	InLibero.png
S0000136	SK017	holistic Grocery	t	588	t	1	20	55	50730.00	Orci.tiff
S0000137	SK023	empowering Books	f	255	t	12	27	76	419072.00	AmetTurpisElementum.jpeg
S0000138	SK039	frame Beauty	t	955	f	18	31	53	393853.00	IdLuctusNec.png
S0000139	SK062	functionalities Toys	t	132	f	4	34	79	366291.00	EnimSit.jpeg
S0000140	SK058	Robust Garden	f	973	f	19	37	58	626548.00	Turpis.jpeg
S0000141	SK049	Ameliorated Movies	f	516	f	4	22	85	322959.00	Gravida.tiff
S0000142	SK067	asynchronous Industrial	t	764	f	17	36	76	413293.00	GravidaNisiAt.jpeg
S0000143	SK044	projection Jewelery	t	827	t	17	50	88	270766.00	Sapien.jpeg
S0000144	SK043	monitoring Books	f	90	t	14	28	68	889488.00	LectusInEst.jpeg
S0000145	SK022	Cross-platform Health	f	845	f	16	41	74	666612.00	NatoquePenatibus.gif
S0000146	SK026	Re-engineered Jewelery	f	877	f	1	35	96	917501.00	Nisi.gif
S0000147	SK038	Diverse Movies	t	906	t	9	21	80	853452.00	AugueVestibulumAnte.png
S0000148	SK024	Secured Baby	f	946	t	4	49	54	244846.00	CubiliaCurae.jpeg
S0000149	SK033	eco-centric Outdoors	t	407	t	18	40	88	679266.00	Dui.jpeg
S0000150	SK003	instruction set Beauty	t	685	t	17	43	80	154895.00	DapibusDolor.jpeg
S0000151	SK050	analyzing Computers	t	224	f	7	26	73	397522.00	NecCondimentumNeque.png
S0000152	SK061	algorithm Garden	t	717	f	17	41	62	459952.00	UltricesPhasellusId.tiff
S0000153	SK046	non-volatile Games	f	97	t	4	41	65	69162.00	Ante.gif
S0000154	SK064	client-driven Garden	f	785	t	10	30	92	279604.00	Tortor.png
S0000155	SK028	monitoring Books	f	258	f	13	22	61	715856.00	HendreritAt.gif
S0000156	SK070	holistic Grocery	f	974	f	12	36	59	588137.00	Quis.tiff
S0000157	SK049	standardization Automotive	t	362	f	5	28	59	654651.00	Mus.png
S0000158	SK041	groupware Books	f	542	t	2	48	92	463129.00	IdNislVenenatis.jpeg
S0000159	SK038	system engine Computers	t	682	t	11	38	77	764988.00	AmetErat.jpeg
S0000160	SK062	complexity Tools	t	294	t	12	49	78	235356.00	EratCurabitur.tiff
S0000161	SK033	complexity Tools	t	867	t	11	25	57	60223.00	Mauris.jpeg
S0000162	SK055	real-time Automotive	f	36	t	16	24	100	26086.00	PretiumNislUt.gif
S0000163	SK072	Cross-platform Health	t	528	t	11	41	59	386749.00	AccumsanTortor.tiff
S0000164	SK036	Cross-platform Health	f	918	t	12	35	89	188098.00	Consequat.tiff
S0000165	SK047	national Garden	f	668	f	8	24	53	723839.00	Placerat.jpeg
S0000166	SK071	explicit Clothing	t	864	t	16	25	91	14107.00	AmetConsectetuer.jpeg
S0000167	SK054	functionalities Home	f	304	f	8	35	55	521722.00	CumSociisNatoque.png
S0000168	SK061	uniform Shoes	f	804	f	3	29	82	434926.00	LectusInQuam.gif
S0000169	SK042	Quality-focused Music	t	280	t	16	36	90	420064.00	Donec.tiff
S0000170	SK016	alliance Toys	t	143	t	18	23	53	887632.00	NullamMolestie.gif
S0000171	SK005	customer loyalty Movies	t	141	f	3	44	90	271738.00	CurabiturInLibero.jpeg
S0000172	SK026	Stand-alone Outdoors	t	353	f	2	48	70	863981.00	VestibulumAc.gif
S0000173	SK071	asynchronous Industrial	f	709	f	11	30	78	702073.00	UltricesPhasellusId.jpeg
S0000174	SK032	flexibility Toys	t	42	t	16	36	57	124850.00	CurabiturConvallis.png
S0000175	SK063	frame Beauty	t	136	t	4	26	79	704063.00	ConsequatDui.gif
S0000176	SK029	bottom-line Computers	t	273	t	20	35	78	2084.00	SemperEst.jpeg
S0000177	SK046	non-volatile Games	f	24	t	16	48	71	921276.00	Et.gif
S0000178	SK026	Face to face Electronics	f	598	f	16	45	72	110984.00	DictumstMaecenasUt.tiff
S0000179	SK018	task-force Movies	t	496	f	2	35	73	507292.00	Suspendisse.gif
S0000180	SK073	software Garden	t	764	t	9	20	70	321601.00	PharetraMagnaAc.tiff
S0000181	SK052	Up-sized Movies	f	67	t	5	37	93	972699.00	DonecVitae.gif
S0000182	SK055	task-force Garden	f	17	t	4	33	87	314030.00	IpsumDolorSit.gif
S0000183	SK052	Re-contextualized Automotive	f	772	t	7	44	64	987298.00	QuamTurpis.jpeg
S0000184	SK070	methodical Automotive	f	889	f	8	29	67	486819.00	Pede.png
S0000185	SK004	emulation Electronics	f	902	t	18	45	75	945514.00	LuctusEtUltrices.jpeg
S0000186	SK024	analyzing Computers	t	825	t	19	47	65	178087.00	VivamusMetus.jpeg
S0000187	SK040	non-volatile Games	f	200	t	4	50	83	317813.00	VehiculaCondimentum.tiff
S0000188	SK048	knowledge base Games	t	493	t	19	41	78	356797.00	CurabiturConvallis.tiff
S0000189	SK057	analyzing Computers	f	195	t	14	50	51	207774.00	Donec.jpeg
S0000190	SK036	knowledge base Games	f	3	f	18	40	69	587172.00	Est.gif
S0000191	SK021	Up-sized Movies	t	633	t	18	41	77	910639.00	AnteIpsumPrimis.gif
S0000192	SK019	Implemented Games	t	964	f	20	30	97	783450.00	EgetTempusVel.png
S0000193	SK007	knowledge base Games	t	659	f	16	46	99	245070.00	TristiqueEst.jpeg
S0000194	SK044	task-force Garden	f	663	t	15	50	77	448878.00	Cursus.png
S0000195	SK024	software Music	t	233	t	7	23	73	398228.00	EnimSit.tiff
S0000196	SK068	Cross-platform Health	f	517	t	19	21	71	460112.00	Blandit.tiff
S0000197	SK044	service-desk Tools	t	827	f	12	49	85	968802.00	FelisFusce.jpeg
S0000198	SK021	Implemented Games	f	606	t	20	27	96	149065.00	PharetraMagna.tiff
S0000199	SK015	tertiary Home	f	870	f	3	26	65	954565.00	At.png
S0000200	SK070	emulation Sports	f	376	f	12	22	72	851587.00	RhoncusAliquetPulvinar.png
S0000201	SK079	Robust Home	f	181	f	8	46	70	882763.00	ViverraPede.jpeg
S0000202	SK056	Customer-focused Kids	t	402	t	18	47	85	809223.00	Sapien.tiff
S0000203	SK079	empowering Books	t	480	f	4	29	90	455310.00	PraesentBlanditNam.tiff
S0000204	SK054	Customizable Shoes	f	930	t	10	50	94	666169.00	Duis.tiff
S0000205	SK040	emulation Electronics	t	358	t	4	34	96	317962.00	PrimisIn.tiff
S0000206	SK036	radical Movies	t	79	t	20	48	100	451428.00	Ac.jpeg
S0000207	SK004	Customer-focused Kids	t	917	t	4	29	56	648596.00	Libero.gif
S0000208	SK017	Quality-focused Music	t	373	t	16	28	72	950615.00	TurpisElementum.png
S0000209	SK012	Re-contextualized Automotive	t	783	f	6	40	88	353108.00	NibhIn.tiff
S0000210	SK079	task-force Movies	f	535	f	14	32	89	133287.00	Imperdiet.tiff
S0000211	SK080	frame Computers	t	636	t	10	38	87	199967.00	In.tiff
S0000212	SK065	non-volatile Games	f	200	t	3	41	89	114239.00	AtVelit.png
S0000213	SK003	functionalities Home	f	302	t	1	40	90	755031.00	SitAmetConsectetuer.jpeg
S0000214	SK051	capacity Electronics	t	640	f	10	44	84	807698.00	VelNulla.jpeg
S0000215	SK076	standardization Automotive	t	547	t	7	50	97	158745.00	Tristique.jpeg
S0000216	SK031	Implemented Games	f	670	f	18	32	93	413224.00	Viverra.tiff
S0000217	SK006	asymmetric Baby	f	706	t	2	42	67	335181.00	JustoPellentesqueViverra.tiff
S0000218	SK067	radical Movies	t	276	f	1	34	53	351245.00	Eleifend.tiff
S0000219	SK004	Robust Garden	t	196	f	16	23	95	457543.00	Odio.tiff
S0000220	SK070	Re-contextualized Automotive	f	703	f	6	35	57	846652.00	Consequat.png
S0000221	SK050	solution-oriented Baby	f	882	f	12	30	89	937844.00	NuncNislDuis.jpeg
S0000222	SK017	groupware Books	f	62	t	5	40	87	615345.00	SapienNonMi.jpeg
S0000223	SK048	reciprocal Health	f	782	f	10	31	60	157071.00	AcEnimIn.gif
S0000224	SK033	Re-engineered Jewelery	t	883	f	19	49	54	413627.00	MiSitAmet.gif
S0000225	SK033	task-force Movies	f	544	t	10	50	77	414072.00	CommodoPlaceratPraesent.tiff
S0000226	SK063	standardization Automotive	t	903	t	2	39	70	641224.00	Nunc.jpeg
S0000227	SK012	Robust Garden	t	928	t	13	48	71	158087.00	LacusAt.tiff
S0000228	SK053	Implemented Grocery	t	898	t	7	33	71	196732.00	JustoIn.jpeg
S0000229	SK061	radical Movies	f	643	f	11	49	70	115579.00	UtDolorMorbi.png
S0000230	SK035	Graphical User Interface Music	t	289	t	19	50	75	859305.00	NibhFusce.tiff
S0000231	SK038	Stand-alone Music	f	860	f	14	25	53	787626.00	PulvinarSed.png
S0000232	SK073	Robust Garden	f	270	t	20	25	81	887783.00	MolestieHendreritAt.tiff
S0000233	SK077	Quality-focused Music	t	5	t	3	45	89	114611.00	UltricesLiberoNon.tiff
S0000234	SK057	Customer-focused Kids	f	95	f	10	34	79	659869.00	MaurisSit.gif
S0000235	SK035	empowering Beauty	f	745	f	3	50	65	330297.00	NullaEgetEros.png
S0000236	SK055	Re-contextualized Automotive	f	218	f	14	36	100	698903.00	LuctusTinciduntNulla.png
S0000237	SK057	service-desk Tools	t	453	f	17	27	81	120288.00	DuiVel.gif
S0000238	SK074	Organic Electronics	t	661	f	8	47	87	64479.00	Et.tiff
S0000239	SK032	solution-oriented Baby	t	264	f	4	26	70	454345.00	PenatibusEt.png
S0000240	SK022	project Tools	f	298	t	15	42	92	32998.00	MassaVolutpatConvallis.jpeg
S0000241	SK044	analyzer Computer	f	635	f	8	22	86	599707.00	Suscipit.jpeg
S0000242	SK060	approach Tools	t	782	t	15	46	56	340815.00	PosuereCubiliaCurae.gif
S0000243	SK004	radical Movies	t	754	f	9	32	52	944615.00	Nascetur.jpeg
S0000244	SK042	national Garden	f	374	f	8	24	81	188148.00	Malesuada.jpeg
S0000245	SK023	Advanced Baby	f	175	t	14	45	68	671059.00	SedLacusMorbi.jpeg
S0000246	SK040	software Books	f	472	t	18	20	81	980685.00	EratVestibulumSed.tiff
S0000247	SK009	Stand-alone Outdoors	f	622	t	4	42	53	527345.00	Vulputate.tiff
S0000248	SK046	Organic Electronics	f	663	f	15	28	53	917828.00	VestibulumEgetVulputate.jpeg
S0000249	SK060	software Garden	t	430	t	9	43	54	564002.00	NonInterdum.jpeg
S0000250	SK012	empowering Beauty	t	186	f	12	48	60	250075.00	UltricesPosuereCubilia.gif
S0000251	SK001	explicit Clothing	f	10000	t	1	12	500	3500000.00	explicitClothing.png
\.


--
-- Data for Name: sub_kategori; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY sub_kategori (kode, kode_kategori, nama) FROM stdin;
SK001	K01	Atasan
SK002	K01	Celana
SK003	K01	Dress
SK004	K01	Outerwear
SK005	K01	Setelan
SK006	K01	Batik Wanita
SK007	K01	Pakaian Dalam Wanita
SK008	K01	Tas
SK009	K01	Sepatu
SK010	K01	Jam Tangan
SK011	K01	Perhiasan
SK012	K01	Aksesoris
SK013	K01	Aksesoris Rambut
SK014	K01	Perlengkapan Couple
SK015	K01	Baju Tidur
SK016	K01	Perlengkapan Jahit
SK017	K02	Jam Tangan
SK018	K02	Baju Tidur
SK019	K02	Pakaian Dalam Pria
SK020	K02	Outerwear
SK021	K02	Sepatu
SK022	K02	Tas
SK023	K02	Perhiasan Fashion
SK024	K02	Aksesoris
SK025	K02	Celana
SK026	K02	Batik Pria
SK027	K02	Atasan
SK028	K03	Outerwear
SK029	K03	Setelan Muslim
SK030	K03	Dress
SK031	K03	Scarf
SK032	K03	Baju Muslim Anak
SK033	K03	Atasan
SK034	K03	Aksesoris Jilbab
SK035	K03	Bawahan
SK036	K03	Perlengkapan Ibadah
SK037	K04	Perhiasan Anak
SK038	K04	Sepatu Anak Perempuan
SK039	K04	Aksesoris Rambut Anak
SK040	K04	Aksesoris Anak
SK041	K04	Tas Anak
SK042	K04	Sepatu Anak Laki-laki
SK043	K04	Pakaian Anak Perempuan
SK044	K04	Pakaian Anak Laki-Laki
SK045	K05	Kosmetik
SK046	K05	Perawatan Wajah
SK047	K05	Perawatan Tangan, Kaki dan Kuku
SK048	K05	Perawatan Rambut
SK049	K05	Perawatan Mata
SK050	K05	Styling Rambut
SK051	K05	Peralatan Make Up
SK052	K05	Grooming
SK053	K05	Mandi & Perawatan Tubuh
SK054	K06	Telinga
SK055	K06	Kesehatan Wanita
SK056	K06	Obat & Alat Kesehatan
SK057	K06	Health Products
SK058	K06	Kesehatan Gigi & Mulut
SK059	K06	Diet & Vitamin
SK060	K06	Kesehatan Mata
SK061	K06	Perlengkapan Medis
SK062	K06	Kesehatan Lainnya
SK063	K07	Aksesoris Bayi
SK064	K08	Kamar Tidur
SK065	K09	Handphone
SK066	K10	Laptop
SK067	K11	Komputer
SK068	K12	TV
SK069	K13	Kamera
SK070	K14	Aksesoris Mobil
SK071	K15	Basket
SK072	K16	Musik
SK073	K17	Peralatan Dapur
SK074	K18	Alat Tulis
SK075	K19	Boneka
SK076	K20	Figure
SK077	K21	Makanan
SK078	K21	Minuman
SK079	K22	Buku Sekolah
SK080	K22	Novel Sastra
\.


--
-- Data for Name: toko; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY toko (nama, deskripsi, slogan, email_penjual, lokasi) FROM stdin;
Customer-focused Kids	Phased systemic capability	engage wireless partnerships	dswansborough2o@harvard.edu	Jl. Parkside no. 24, Marieville J3M
installation Computers	Enterprise-wide context-sensitive workforce	exploit killer metrics	acallum26@jiathis.com	Jl. South no. 545, Pontevedra 1761
non-volatile Games	Cross-group methodical infrastructure	enhance virtual relationships	fcrone1@addtoany.com	Jl. Steensland no. 685, Cercany 257 22
Customizable Shoes	Secured 3rd generation function	morph distributed methodologies	oben17@mozilla.com	Jl. Oxford no. 464, Maintang
holistic Shoes	Re-engineered bottom-line installation	extend next-generation synergies	droistonea@archive.org	Jl. Marcy no. 653, Rozhniv
bottom-line Computers	Triple-buffered client-server leverage	seize open-source e-business	cdufore1w@ucoz.ru	Jl. Stuart no. 211, Remedios 052828
Re-contextualized Automotive	Optional holistic website	reinvent real-time systems	fkingsworth2d@ox.ac.uk	Jl. Nova no. 613, Canjulao 6309
Future-proofed Toys	Enhanced bifurcated analyzer	enhance leading-edge deliverables	cduncanson2e@mayoclinic.com	Jl. Monument no. 773, Tongxing
instruction set Beauty	Business-focused human-resource solution	strategize virtual solutions	lchristoforo@house.gov	Jl. Stuart no. 525, H”fn 781
reciprocal Health	Realigned systemic throughput	drive seamless bandwidth	tmeader1n@fotki.com	Jl. Dorton no. 987, Manaoag 2430
actuating Outdoors	Self-enabling cohesive paradigm	leverage leading-edge content	cduncanson2e@mayoclinic.com	Jl. Bonner no. 503, Illapel
conglomeration Jewelery	Networked contextually-based array	optimize open-source solutions	oben17@mozilla.com	Jl. Hollow Ridge no. 593, Colima 11305
Realigned Books	De-engineered static task-force	architect user-centric schemas	rarunowiczk@shinystat.com	Jl. Memorial no. 6, Klakeh
frame Computers	Self-enabling encompassing toolset	facilitate proactive bandwidth	mbayford1u@slideshare.net	Jl. Lotheville no. 79, Cikuya
software Books	Multi-channelled incremental moderator	aggregate next-generation ROI	acheetam2m@is.gd	Jl. Banding no. 353, Mianwali 42201
Secured Baby	Team-oriented homogeneous focus group	envisioneer cross-media platforms	lbambra1c@a8.net	Jl. Dakota no. 794, Xiaomenjia
alliance Toys	Pre-emptive 24/7 groupware	target seamless methodologies	ggeroldl@imgur.com	Jl. Bartillon no. 852, Dawu Chengguanzhen
functionalities Home	Distributed hybrid policy	extend cross-media systems	tmeader1n@fotki.com	Jl. Judy no. 92, Daixi
Organic Electronics	Open-source contextually-based application	morph magnetic e-markets	dswansborough2o@harvard.edu	Jl. Sunbrook no. 862, An Chƒu
Implemented Games	Realigned national application	incentivize back-end bandwidth	jspenleyh@cisco.com	Jl. Marcy no. 218, Takari
approach Kids	Digitized zero administration knowledge base	strategize transparent solutions	aparkman1a@blogtalkradio.com	Jl. Dovetail no. 308, Almelo 7609
monitoring Books	Expanded dedicated policy	implement next-generation e-business	spabelik1e@ibm.com	Jl. Mockingbird no. 79, Anolaima 253048
knowledge base Games	Balanced context-sensitive knowledge user	seize impactful partnerships	rsatcheru@jalbum.net	Jl. American no. 759, Yanguan
Future-proofed Baby	Multi-channelled fault-tolerant system engine	cultivate end-to-end portals	mheildsi@yahoo.co.jp	Jl. Waubesa no. 690, Cipadung Timur
software Music	De-engineered local core	e-enable leading-edge paradigms	jisworth1m@sourceforge.net	Jl. Blaine no. 827, Great Neck 11024
Decentralized Grocery	Networked zero defect open system	engineer collaborative paradigms	tselbyn@hhs.gov	Jl. Sauthoff no. 902, Sanban
service-desk Tools	Managed responsive array	visualize interactive solutions	adanbrook28@java.com	Jl. Kedzie no. 305, Visim 622970
asynchronous Industrial	Organic context-sensitive complexity	reinvent back-end infrastructures	acallum26@jiathis.com	Jl. Dayton no. 941, Tupancireta 98170-000
empowering Electronics	Networked human-resource model	architect cutting-edge solutions	cbrickhill27@skyrock.com	Jl. Cambridge no. 124, General Santos 9500
Robust Garden	Visionary exuding utilisation	facilitate open-source methodologies	jeakley2k@yolasite.com	Jl. Glendale no. 269, Cikarang
radical Movies	Advanced uniform service-desk	enable innovative metrics	jeakley2k@yolasite.com	Jl. Sommers no. 247, Jindu
complexity Tools	Digitized impactful project	disintermediate value-added e-commerce	lkyston1l@unblog.fr	Jl. Mockingbird no. 520, Enrekang
functionality Home	Centralized human-resource knowledge base	evolve strategic deliverables	fcrone1@addtoany.com	Jl. Coleman no. 157, Bustonqala
bandwidth-monitored Industrial	Organized uniform structure	cultivate e-business communities	aranyard18@springer.com	Jl. Texas no. 850, Raduzhnyy 601380
Compatible Outdoors	Virtual attitude-oriented system engine	brand clicks-and-mortar vortals	cfarringtonq@bbb.org	Jl. Loomis no. 979, Rennes 35033 CEDEX 9
grid-enabled Music	Visionary encompassing paradigm	recontextualize value-added e-markets	cdufore1w@ucoz.ru	Jl. Prentice no. 979, Lae 96970
Robust Home	Persistent foreground parallelism	cultivate e-business solutions	lchristoforo@house.gov	Jl. Sycamore no. 749, Mogi Gua‡u 13840-000
Ameliorated Movies	Stand-alone tertiary open architecture	seize e-business bandwidth	cduncanson2e@mayoclinic.com	Jl. Di Loreto no. 486, Bila
Business-focused Jewelery	Streamlined encompassing archive	scale one-to-one applications	djessope2i@yellowpages.com	Jl. Vidon no. 987, Santa Mar¡a Chiquimula 08006
Quality-focused Music	Public-key radical projection	strategize interactive synergies	vpowder1r@ucoz.ru	Jl. Annamark no. 590, Mar¡lia 17500-000
analyzing Computers	Multi-tiered context-sensitive migration	facilitate killer users	obartoszinskiy@jalbum.net	Jl. Crest Line no. 878, Keyinhe
algorithm Music	Reactive 24/7 application	synthesize visionary applications	dsparrowhawk1k@odnoklassniki.ru	Jl. Pierstorff no. 418, Verkhniy Kurkuzhin 361515
project Tools	Front-line maximized toolset	exploit interactive action-items	vback9@tamu.edu	Jl. Crest Line no. 223, Penedo 4650-080
task-force Movies	Fundamental bifurcated encryption	whiteboard intuitive paradigms	hwillden1i@fastcompany.com	Jl. Hintze no. 808, Dabrowa 88-306
real-time Automotive	Cloned cohesive website	visualize bleeding-edge ROI	jisworth1m@sourceforge.net	Jl. Bluejay no. 231, Valdemarsvik 615 95
Persevering Outdoors	Exclusive background interface	reintermediate wireless experiences	rdelacourt1f@smh.com.au	Jl. Burrows no. 741, Debrecen 4004
concept Industrial	Multi-lateral value-added throughput	facilitate robust infrastructures	vback9@tamu.edu	Jl. Graceland no. 199, Fujioka 999-7638
explicit Clothing	Inverse zero defect structure	enhance interactive ROI	aparkman1a@blogtalkradio.com	Jl. Clyde Gallagher no. 401, Vogan
empowering Books	Multi-lateral uniform groupware	utilize open-source solutions	skleisle1q@mayoclinic.com	Jl. Stephen no. 161, Maastricht 6204
time-frame Health	Versatile non-volatile initiative	synthesize cutting-edge content	fkingsworth2d@ox.ac.uk	Jl. Stoughton no. 301, Novocherkassk 346408
circuit Automotive	Persistent national monitoring	reinvent dot-com models	cfarringtonq@bbb.org	Jl. Lunder no. 370, Erdaocha
system engine Computers	Optional mobile intranet	iterate holistic systems	rsatcheru@jalbum.net	Jl. Carpenter no. 331, Crespo 3116
Implemented Grocery	Profit-focused dedicated intranet	utilize viral web-readiness	akyrkemans@sohu.com	Jl. Hagan no. 675, Chumphon Buri 71180
analyzer Computers	Inverse client-driven adapter	generate viral web services	rtrevain2c@posterous.com	Jl. International no. 448, Tamianglayang
Multi-tiered Health	Re-engineered human-resource attitude	optimize end-to-end experiences	lbambra1c@a8.net	Jl. Kingsford no. 18, La Mesa 51462
solution-oriented Electronics	Diverse demand-driven interface	transform front-end infomediaries	hsealey2b@dagondesign.com	Jl. Waxwing no. 6, ™rnsk”ldsvik 891 20
eco-centric Outdoors	Object-based responsive focus group	benchmark virtual bandwidth	mbayford1u@slideshare.net	Jl. Knutson no. 214, Gaplek
algorithm Garden	Proactive static archive	optimize transparent e-tailers	fkingsworth2d@ox.ac.uk	Jl. Monument no. 649, Perho 69951
methodical Automotive	Synergized next generation knowledge base	cultivate scalable models	cmiddler2g@flickr.com	Jl. Hauk no. 156, Fosca 251837
tertiary Home	Re-contextualized optimal parallelism	architect plug-and-play solutions	sblevin23@webnode.com	Jl. Schlimgen no. 464, Klemunan
global Tools	Centralized leading edge synergy	streamline value-added paradigms	adanbrook28@java.com	Jl. Laurel no. 714, Turbaco 131008
task-force Garden	Cross-group client-server moderator	generate user-centric solutions	dswansborough2o@harvard.edu	Jl. Dahle no. 858, Tim¢teo 35180-000
mission-critical Electronics	Vision-oriented regional application	iterate dot-com models	hfoley2p@istockphoto.com	Jl. Oakridge no. 385, Detroit 48217
Up-sized Movies	Exclusive stable concept	transition integrated technologies	sblevin23@webnode.com	Jl. Stephen no. 887, Roshchino 456510
standardization Automotive	Function-based logistical toolset	architect seamless web services	sblevin23@webnode.com	Jl. Gale no. 878, Amadora 2610-006
solution-oriented Baby	Customer-focused background utilisation	evolve open-source partnerships	hfoley2p@istockphoto.com	Jl. Forest Run no. 352, Cikujang
Centralized Home	Public-key modular functionalities	grow impactful initiatives	pwelham2h@pen.io	Jl. Fallview no. 502, Banatsko Karadordevo
Diverse Movies	Robust neutral forecast	optimize clicks-and-mortar e-tailers	obartoszinskiy@jalbum.net	Jl. Stone Corner no. 339, Maoping
flexibility Toys	Reverse-engineered mission-critical workforce	cultivate sexy technologies	sjobern2j@mozilla.org	Jl. Browning no. 841, Shalkar
Cross-group Health	Multi-channelled non-volatile task-force	target dot-com content	droistonea@archive.org	Jl. Surrey no. 919, Kuhmo 88901
groupware Books	Profound discrete functionalities	generate world-class e-commerce	ashillington1o@ycombinator.com	Jl. Reinke no. 751, Polyarnyye Zori 184230
projection Jewelery	Managed analyzing budgetary management	benchmark collaborative platforms	ahinkley16@quantcast.com	Jl. Carpenter no. 382, Xinji
Re-engineered Jewelery	Switchable holistic solution	envisioneer mission-critical users	jspenleyh@cisco.com	Jl. Nancy no. 717, Ramat HaSharon
approach Tools	Sharable optimal portal	unleash bricks-and-clicks relationships	acheetam2m@is.gd	Jl. Donald no. 881, Mahalapye
functionalities Toys	Robust maximized artificial intelligence	benchmark web-enabled experiences	cmiddler2g@flickr.com	Jl. Ridge Oak no. 412, Disuq
uniform Shoes	Exclusive 3rd generation function	disintermediate B2C vortals	krubberts4@jiathis.com	Jl. Fuller no. 980, Kamubheka
Graphical User Interface Music	Distributed next generation process improvement	recontextualize visionary models	elerwell19@ucoz.com	Jl. Dexter no. 748, Sibulan 6201
customer loyalty Movies	Future-proofed bandwidth-monitored website	e-enable seamless networks	vcarnier2f@virginia.edu	Jl. Becker no. 367, Bimbo
holistic Grocery	Pre-emptive tertiary info-mediaries	orchestrate dynamic schemas	mskaife2r@ca.gov	Jl. Stone Corner no. 129, Fonta¡nhas 2300-174
Cross-platform Health	Re-contextualized clear-thinking product	implement impactful vortals	rsatcheru@jalbum.net	Jl. Erie no. 776, Lulindi
emulation Electronics	Expanded explicit conglomeration	transition out-of-the-box channels	zbroomhall13@mac.com	Jl. Westridge no. 884, Babice 37-754
Face to face Electronics	Polarised full-range challenge	syndicate best-of-breed e-business	mmuggach1v@army.mil	Jl. Anthes no. 486, Cerro de Pasco
Stand-alone Outdoors	Streamlined well-modulated paradigm	unleash next-generation e-services	aranyard18@springer.com	Jl. Banding no. 929, Doubrava 735 33
algorithm Industrial	Enterprise-wide 24 hour project	extend viral interfaces	bgrubbec@biblegateway.com	Jl. Morrow no. 517, Argalast¡
Advanced Baby	Phased transitional encoding	innovate sexy partnerships	skleisle1q@mayoclinic.com	Jl. Granby no. 777, Jieshui
eco-centric Industrial	Function-based hybrid infrastructure	integrate value-added mindshare	acheetam2m@is.gd	Jl. Miller no. 760, Casais de Vera Cruz 3025-353
empowering Beauty	Versatile needs-based functionalities	grow world-class convergence	iniche1g@technorati.com	Jl. Meadow Valley no. 182, Penebel
client-driven Garden	Function-based background process improvement	envisioneer sticky e-services	teykelhof1h@com.com	Jl. Kinsman no. 367, Belo Horizonte 30000-000
national Garden	Ergonomic uniform monitoring	seize clicks-and-mortar web services	hclavey15@engadget.com	Jl. Prairie Rose no. 262, Itacarambi 39470-000
analyzer Computer	Profit-focused homogeneous support	streamline innovative content	ltootin6@livejournal.com	Jl. Meadow Valley no. 601, Tajan
bottom-line Games	Robust systemic parallelism	iterate integrated e-markets	bridges29@miibeian.gov.cn	Jl. Granby no. 223, Budapest 1147
Stand-alone Music	Fully-configurable mission-critical customer loyalty	revolutionize interactive ROI	lchristoforo@house.gov	Jl. Scott no. 155, Canis
capacity Electronics	Pre-emptive background synergy	target interactive supply-chains	hfoley2p@istockphoto.com	Jl. Arkansas no. 962, Nong Khae 18140
asymmetric Baby	Secured analyzing Graphical User Interface	enhance web-enabled platforms	jpaschke22@java.com	Jl. Hoepker no. 557, Malasila 5507
emulation Sports	Down-sized intermediate emulation	syndicate vertical infomediaries	tmeader1n@fotki.com	Jl. Maple no. 955, Hudson Bay K2J
software Garden	Customizable multimedia collaboration	reintermediate plug-and-play e-tailers	hsealey2b@dagondesign.com	Jl. Shasta no. 531, Vilque
project Computers	Universal value-added complexity	streamline B2B e-tailers	ltootin6@livejournal.com	Jl. Eggendart no. 421, Belyye Berega 241902
national Outdoors	Phased contextually-based middleware	aggregate B2B action-items	cdufore1w@ucoz.ru	Jl. Melody no. 550, Cinangka
mission-critical Baby	Re-engineered object-oriented protocol	whiteboard innovative synergies	skleisle1q@mayoclinic.com	Jl. Oneill no. 893, Savannakht
frame Beauty	Adaptive fresh-thinking standardization	morph sticky e-business	cbrickhill27@skyrock.com	Jl. Hermina no. 612, Aby 616 32
\.


--
-- Data for Name: toko_jasa_kirim; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY toko_jasa_kirim (nama_toko, jasa_kirim) FROM stdin;
solution-oriented Electronics	J&T EXPRESS
analyzing Computers	PAHALA
Future-proofed Toys	WAHANA
installation Computers	PAHALA
project Tools	TIKI REGULER
project Computers	JNE YES
reciprocal Health	TIKI REGULER
Centralized Home	POS PAKET BIASA
monitoring Books	TIKI REGULER
functionalities Toys	POS PAKET KILAT
Decentralized Grocery	WAHANA
installation Computers	TIKI REGULER
time-frame Health	JNE REGULER
asynchronous Industrial	WAHANA
groupware Books	POS PAKET BIASA
non-volatile Games	POS PAKET BIASA
Business-focused Jewelery	PAHALA
conglomeration Jewelery	JNE OKE
alliance Toys	JNE REGULER
circuit Automotive	JNE YES
analyzer Computers	JNE REGULER
mission-critical Electronics	POS PAKET KILAT
Robust Garden	WAHANA
Up-sized Movies	PAHALA
Future-proofed Toys	JNE REGULER
Implemented Grocery	JNE REGULER
knowledge base Games	WAHANA
customer loyalty Movies	POS PAKET BIASA
monitoring Books	JNE REGULER
global Tools	J&T EXPRESS
Ameliorated Movies	POS PAKET KILAT
Compatible Outdoors	WAHANA
Advanced Baby	LION PARCEL
algorithm Garden	POS PAKET BIASA
eco-centric Industrial	POS PAKET KILAT
Implemented Grocery	TIKI REGULER
complexity Tools	WAHANA
Persevering Outdoors	WAHANA
groupware Books	LION PARCEL
solution-oriented Baby	JNE REGULER
Persevering Outdoors	LION PARCEL
Customizable Shoes	WAHANA
Diverse Movies	POS PAKET KILAT
algorithm Music	JNE REGULER
task-force Movies	TIKI REGULER
system engine Computers	JNE REGULER
Implemented Games	J&T EXPRESS
circuit Automotive	POS PAKET KILAT
Stand-alone Outdoors	PAHALA
software Garden	JNE YES
software Garden	PAHALA
Implemented Games	WAHANA
tertiary Home	TIKI REGULER
analyzing Computers	POS PAKET BIASA
software Books	TIKI REGULER
asymmetric Baby	J&T EXPRESS
empowering Beauty	LION PARCEL
analyzing Computers	WAHANA
asynchronous Industrial	J&T EXPRESS
Customer-focused Kids	J&T EXPRESS
Re-engineered Jewelery	PAHALA
Secured Baby	LION PARCEL
Implemented Games	LION PARCEL
Stand-alone Music	PAHALA
mission-critical Electronics	LION PARCEL
Compatible Outdoors	LION PARCEL
asynchronous Industrial	POS PAKET KILAT
analyzing Computers	LION PARCEL
grid-enabled Music	PAHALA
Re-contextualized Automotive	JNE YES
Face to face Electronics	POS PAKET BIASA
holistic Shoes	POS PAKET BIASA
functionalities Toys	TIKI REGULER
knowledge base Games	JNE REGULER
algorithm Industrial	JNE OKE
monitoring Books	J&T EXPRESS
analyzer Computers	POS PAKET BIASA
Compatible Outdoors	JNE REGULER
installation Computers	WAHANA
empowering Beauty	PAHALA
holistic Shoes	J&T EXPRESS
mission-critical Baby	JNE YES
grid-enabled Music	JNE YES
solution-oriented Baby	PAHALA
Re-engineered Jewelery	JNE OKE
groupware Books	PAHALA
Quality-focused Music	JNE REGULER
Face to face Electronics	TIKI REGULER
Stand-alone Music	POS PAKET BIASA
Business-focused Jewelery	JNE OKE
radical Movies	PAHALA
instruction set Beauty	LION PARCEL
installation Computers	J&T EXPRESS
frame Beauty	JNE YES
Organic Electronics	TIKI REGULER
reciprocal Health	J&T EXPRESS
functionalities Home	POS PAKET KILAT
approach Kids	J&T EXPRESS
non-volatile Games	J&T EXPRESS
\.


--
-- Data for Name: transaksi_pulsa; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY transaksi_pulsa (no_invoice, tanggal, waktu_bayar, status, total_bayar, email_pembeli, nominal, nomor, kode_produk) FROM stdin;
V00001    	2017-01-11	2017-01-14 23:04:00	2	7000.00	hgisborne28@slashdot.org	5	88627968524	P00008  
V00002    	2016-05-22	2016-05-24 16:13:00	2	102000.00	rosesnanes@nationalgeographic.com	100	87738354516	P000082 
V00003    	2016-07-03	\N	1	202000.00	hstapleton38@geocities.com	200	87348158563	P000063 
V00004    	2016-10-23	\N	1	152000.00	bweaver4f@ebay.com	150	83831936485	P0000111
V00005    	2016-11-12	\N	1	12000.00	jsedgeman20@sourceforge.net	10	89119013144	P000058 
V00006    	2017-03-23	\N	1	27000.00	rreeson1y@cnet.com	25	80474700107	P000045 
V00007    	2016-11-28	2016-12-02 17:57:00	2	52000.00	lbambrick2p@sfgate.com	50	85947800537	P00004  
V00008    	2016-02-20	2016-02-23 21:28:00	2	12000.00	zheaton29@va.gov	10	84560686482	P0000142
V00009    	2016-07-25	2016-07-27 23:29:00	2	102000.00	hcastanaga1j@fda.gov	100	87520960388	P000033 
V000010   	2016-03-01	2016-03-03 06:04:00	2	52000.00	cabby4b@cyberchimps.com	50	88272662800	P0000200
V000011   	2016-03-18	2016-03-21 00:00:00	2	7000.00	erihanek66@surveymonkey.com	5	81089491133	P0000141
V000012   	2016-07-10	2016-07-12 22:13:00	2	52000.00	istoate5w@wix.com	50	86011139268	P000025 
V000013   	2016-07-10	\N	1	202000.00	rosesnanes@nationalgeographic.com	200	87738354516	P0000189
V000014   	2016-08-05	2016-08-08 00:21:00	2	12000.00	nwemm2e@meetup.com	10	83747569638	P000079 
V000015   	2016-01-19	\N	1	12000.00	mthebeau1v@ed.gov	10	82171202428	P000016 
V000016   	2016-11-28	2016-12-02 06:10:00	2	12000.00	vgissing12@google.fr	10	81227712578	P000023 
V000017   	2016-04-14	\N	1	152000.00	evinas1f@stanford.edu	150	83507186620	P000034 
V000018   	2017-02-12	2017-02-14 03:05:00	2	12000.00	mkeays6h@posterous.com	10	83800668752	P000086 
V000019   	2016-10-16	\N	1	152000.00	jdinesen2y@vimeo.com	150	83915236091	P000062 
V000020   	2016-12-12	\N	1	12000.00	pworsfold3n@chron.com	10	82400644516	P000058 
V000021   	2017-03-18	2017-03-22 09:48:00	2	102000.00	lbottom1b@blinklist.com	100	84235158040	P000082 
V000022   	2016-01-12	2016-01-16 16:41:00	2	52000.00	gbonifazio3f@adobe.com	50	88742477621	P000081 
V000023   	2016-01-12	2016-01-14 09:56:00	2	102000.00	gtackell68@rambler.ru	100	88065222290	P000061 
V000024   	2016-01-26	\N	1	102000.00	lradnage30@canalblog.com	100	82305706756	P000012 
V000025   	2016-11-08	\N	1	52000.00	ebridgwoodb@fotki.com	50	84914571715	P0000123
V000026   	2016-01-02	2016-01-05 13:49:00	2	102000.00	bweaver4f@ebay.com	100	83831936485	P0000131
V000027   	2016-01-01	2016-01-04 20:17:00	2	27000.00	gcopes1@earthlink.net	25	87891654439	P000080 
V000028   	2016-08-08	\N	1	202000.00	rmooney4j@theatlantic.com	200	84285996068	P000070 
V000029   	2017-01-18	\N	1	27000.00	hcastanaga1j@fda.gov	25	87520960388	P000059 
V000030   	2016-01-14	\N	1	27000.00	stither4h@google.ru	25	87640579752	P0000171
V000031   	2016-06-21	\N	1	12000.00	ccheale1p@bbc.co.uk	10	86362735784	P0000184
V000032   	2016-06-14	\N	1	202000.00	jjeffcoat5e@npr.org	200	87068389940	P0000154
V000033   	2016-01-16	2016-01-19 13:31:00	2	152000.00	atrowler5j@apple.com	150	84814125457	P0000181
V000034   	2016-12-21	2016-12-24 04:48:00	2	152000.00	kviles24@1688.com	150	84860494017	P0000139
V000035   	2016-06-27	\N	1	12000.00	hlinklet1a@answers.com	10	83809332578	P0000114
V000036   	2017-03-07	2017-03-10 10:37:00	2	7000.00	mcrichmer58@mac.com	5	84632469306	P0000134
V000037   	2016-12-03	\N	1	102000.00	bcradick3t@squidoo.com	100	80814514094	P0000159
V000038   	2016-08-07	2016-08-10 10:39:00	2	102000.00	zbaybutt6w@cafepress.com	100	88056138111	P000033 
V000039   	2016-10-25	\N	1	152000.00	owoollam4e@amazonaws.com	150	83036699761	P0000132
V000040   	2016-02-15	\N	1	52000.00	rhaselhurst41@netvibes.com	50	85060224263	P000025 
V000041   	2016-11-15	\N	1	152000.00	oernshaw9@ycombinator.com	150	84994136174	P000027 
V000042   	2017-02-17	2017-02-19 06:53:00	2	152000.00	kbreukelman39@dot.gov	150	88560595824	P000034 
V000043   	2016-05-20	2016-05-24 14:29:00	2	12000.00	klind1n@diigo.com	10	81938323903	P000079 
V000044   	2017-01-18	\N	1	52000.00	vmessruther40@fc2.com	50	83764441781	P0000200
V000045   	2016-03-14	2016-03-18 17:22:00	2	27000.00	claraway1l@parallels.com	25	85029220527	P000038 
V000046   	2016-05-29	\N	1	7000.00	mgarric5@amazon.de	5	85833193950	P000099 
V000047   	2017-02-06	2017-02-10 00:36:00	2	202000.00	msteggals6q@ox.ac.uk	200	80200637897	P000077 
V000048   	2016-09-04	\N	1	202000.00	lfendleyc@amazon.co.uk	200	86030943634	P0000140
V000049   	2016-01-17	2016-01-19 22:26:00	2	7000.00	dhurne4@nydailynews.com	5	81852887905	P000099 
V000050   	2016-12-22	2016-12-26 09:10:00	2	52000.00	ktilbey2m@freewebs.com	50	83924851628	P0000193
V000051   	2016-11-29	\N	1	202000.00	bgenders52@noaa.gov	200	87905642654	P000035 
V000052   	2016-08-31	2016-09-03 00:56:00	2	102000.00	rhaselhurst41@netvibes.com	100	85060224263	P000033 
V000053   	2016-08-20	2016-08-24 11:38:00	2	152000.00	pworsfold3n@chron.com	150	82400644516	P000034 
V000054   	2016-09-07	\N	1	102000.00	hluney5c@bloglovin.com	100	85261212980	P000012 
V000055   	2017-04-07	2017-04-11 20:19:00	2	12000.00	fkynston4i@fda.gov	10	83108559522	P0000128
V000056   	2016-10-25	\N	1	52000.00	sbellward3z@google.com	50	87323309025	P0000102
V000057   	2016-06-22	2016-06-26 06:09:00	2	7000.00	mpowney2s@over-blog.com	5	84894394013	P000092 
V000058   	2016-03-07	2016-03-09 14:10:00	2	152000.00	gmorgans14@nba.com	150	89947720529	P0000174
V000059   	2016-06-06	\N	1	152000.00	mthebeau1v@ed.gov	150	82171202428	P000097 
V000060   	2017-03-02	2017-03-04 14:13:00	2	152000.00	minksteri@aol.com	150	89822940015	P0000132
V000061   	2016-09-07	2016-09-09 18:35:00	2	12000.00	sricardin6s@furl.net	10	85794978063	P000023 
V000062   	2016-11-06	2016-11-08 04:16:00	2	7000.00	jguice6f@cyberchimps.com	5	88825342280	P000057 
V000063   	2016-04-21	2016-04-25 02:29:00	2	7000.00	rbuckland36@last.fm	5	83267252458	P0000169
V000064   	2016-03-04	\N	1	52000.00	vgissing12@google.fr	50	81227712578	P000046 
V000065   	2016-05-20	2016-05-23 21:52:00	2	102000.00	hbeloe1z@freewebs.com	100	84537215061	P000061 
V000066   	2016-10-25	2016-10-28 13:19:00	2	152000.00	ntrevorr@fc2.com	150	83143078177	P000097 
V000067   	2017-01-31	2017-02-02 10:11:00	2	27000.00	mpattison1d@spotify.com	25	80446590793	P0000115
V000068   	2016-09-28	2016-10-01 09:54:00	2	27000.00	ldoore32@loc.gov	25	84838437697	P0000199
V000069   	2016-12-10	\N	1	7000.00	hluney5c@bloglovin.com	5	85261212980	P00001  
V000070   	2016-03-13	\N	1	52000.00	mpowney2s@over-blog.com	50	84894394013	P000025 
V000071   	2017-03-04	2017-03-06 10:34:00	2	52000.00	aslides4s@fotki.com	50	85398775284	P000039 
V000072   	2016-01-05	\N	1	27000.00	bbisseker4m@g.co	25	87594884290	P0000108
V000073   	2017-03-09	\N	1	52000.00	jradage2l@blogtalkradio.com	50	83776072823	P000039 
V000074   	2016-07-18	2016-07-22 05:22:00	2	152000.00	rbuckland36@last.fm	150	83267252458	P000027 
V000075   	2016-05-01	\N	1	102000.00	pworsfold3n@chron.com	100	82400644516	P0000124
V000076   	2016-01-10	2016-01-12 01:44:00	2	102000.00	lcrichley19@noaa.gov	100	84464299383	P0000138
V000077   	2016-09-02	2016-09-04 13:32:00	2	102000.00	ccheale1p@bbc.co.uk	100	86362735784	P000068 
V000078   	2016-01-02	2016-01-04 02:45:00	2	27000.00	csiegertsz2j@columbia.edu	25	82387894828	P000038 
V000079   	2016-12-16	\N	1	152000.00	gberthouloume4w@delicious.com	150	88995977500	P000069 
V000080   	2016-02-26	\N	1	7000.00	lcrichley19@noaa.gov	5	84464299383	P000064 
V000081   	2016-11-23	\N	1	52000.00	mquittonden51@acquirethisname.com	50	86972171639	P0000130
V000082   	2016-04-30	\N	1	52000.00	boxtoby2f@zdnet.com	50	87762180611	P0000137
V000083   	2016-01-13	2016-01-17 16:45:00	2	27000.00	fdarrington6i@unblog.fr	25	80190617622	P0000199
V000084   	2016-02-08	2016-02-11 01:07:00	2	12000.00	cleet1r@infoseek.co.jp	10	88278772478	P0000121
V000085   	2016-01-18	\N	1	12000.00	vkippie2n@google.ru	10	85350853366	P0000107
V000086   	2016-09-07	2016-09-09 14:48:00	2	7000.00	pmccague6r@a8.net	5	88066108729	P0000162
V000087   	2016-11-03	\N	1	7000.00	mpowney2s@over-blog.com	5	84894394013	P000050 
V000088   	2016-09-19	2016-09-21 01:54:00	2	12000.00	csiegertsz2j@columbia.edu	10	82387894828	P0000114
V000089   	2017-03-28	\N	1	102000.00	cshrimptone5f@gov.uk	100	88274693340	P00005  
V000090   	2016-08-18	\N	1	52000.00	egiles42@sitemeter.com	50	86087726649	P0000186
V000091   	2017-01-10	\N	1	27000.00	sbellward3z@google.com	25	87323309025	P0000199
V000092   	2016-01-30	2016-02-01 22:28:00	2	7000.00	nwemm2e@meetup.com	5	83747569638	P000050 
V000093   	2017-04-26	2017-04-29 10:30:00	2	152000.00	lehrat55@spiegel.de	150	83601865364	P0000104
V000094   	2016-09-09	2016-09-11 00:35:00	2	52000.00	erihanek66@surveymonkey.com	50	81089491133	P000039 
V000095   	2016-09-14	2016-09-18 06:03:00	2	202000.00	apacher3h@etsy.com	200	82319153350	P000063 
V000096   	2016-05-06	2016-05-08 21:37:00	2	27000.00	mmcgarvey6d@yellowbook.com	25	85543170838	P000066 
V000097   	2016-04-01	2016-04-03 11:50:00	2	7000.00	kmiddlemiss6e@umn.edu	5	84351860045	P0000148
V000098   	2016-11-21	2016-11-23 02:44:00	2	202000.00	boxtoby2f@zdnet.com	200	87762180611	P0000196
V000099   	2016-08-02	2016-08-04 20:13:00	2	102000.00	amilstead5i@umich.edu	100	84605543375	P000019 
V0000100  	2016-05-27	2016-05-29 19:54:00	2	7000.00	hduffieldy@bloglovin.com	5	87798981982	P0000141
V0000101  	2016-05-04	2016-05-06 19:41:00	2	7000.00	aslides4s@fotki.com	5	85398775284	P000064 
V0000102  	2016-01-18	2016-01-21 20:27:00	2	52000.00	gcopes1@earthlink.net	50	87891654439	P0000193
V0000103  	2017-03-28	\N	1	102000.00	aodevey2z@prlog.org	100	88146432693	P0000124
V0000104  	2016-12-11	\N	1	152000.00	erihanek66@surveymonkey.com	150	81089491133	P0000181
V0000105  	2017-03-18	2017-03-22 22:22:00	2	152000.00	rpitwayj@elegantthemes.com	150	89953982487	P0000188
V0000106  	2016-07-13	\N	1	102000.00	owoolliams1w@unc.edu	100	80245678981	P000047 
V0000107  	2016-08-02	2016-08-04 09:23:00	2	27000.00	hborn8@sakura.ne.jp	25	88495578938	P000038 
V0000108  	2016-08-31	2016-09-04 21:57:00	2	102000.00	mpietasch5y@nsw.gov.au	100	82903944658	P0000138
V0000109  	2016-11-28	2016-11-30 23:23:00	2	27000.00	jguice6f@cyberchimps.com	25	88825342280	P000052 
V0000110  	2016-03-29	\N	1	52000.00	hduffieldy@bloglovin.com	50	87798981982	P0000116
V0000111  	2016-10-23	\N	1	152000.00	ghurleston45@netlog.com	150	82154487163	P000048 
V0000112  	2016-11-16	2016-11-19 08:38:00	2	7000.00	mepinoyu@51.la	5	82993669800	P000043 
V0000113  	2016-11-26	2016-11-29 18:37:00	2	12000.00	mradsdale1u@imdb.com	10	83925735059	P0000170
V0000114  	2016-03-03	2016-03-06 23:24:00	2	152000.00	hcastanaga1j@fda.gov	150	87520960388	P000048 
V0000115  	2016-04-21	2016-04-25 03:13:00	2	152000.00	tblackway61@51.la	150	89041936071	P000090 
V0000116  	2016-07-28	2016-08-01 21:12:00	2	52000.00	nwemm2e@meetup.com	50	83747569638	P000095 
V0000117  	2016-02-14	2016-02-17 11:26:00	2	202000.00	bbryant56@bbc.co.uk	200	88886565255	P000021 
V0000118  	2016-02-26	2016-02-29 06:20:00	2	12000.00	jwillard5r@51.la	10	82050374984	P0000191
V0000119  	2016-10-06	\N	1	102000.00	owoolliams1w@unc.edu	100	80245678981	P0000194
V0000120  	2016-03-06	2016-03-09 01:43:00	2	52000.00	lcolicot4d@behance.net	50	88995677800	P0000165
V0000121  	2017-01-31	2017-02-02 02:26:00	2	7000.00	mradsdale1u@imdb.com	5	83925735059	P0000190
V0000122  	2016-03-26	\N	1	12000.00	nverlinde5l@globo.com	10	81444357145	P0000114
V0000123  	2017-03-16	2017-03-20 03:18:00	2	52000.00	sdufer57@yellowbook.com	50	82160710840	P000081 
V0000124  	2016-09-23	2016-09-25 19:23:00	2	52000.00	castlesa@paginegialle.it	50	86601207900	P0000116
V0000125  	2017-02-01	2017-02-05 22:24:00	2	152000.00	vcarlton4x@jimdo.com	150	88221014231	P0000153
V0000126  	2016-05-26	2016-05-29 21:30:00	2	7000.00	vcarlton4x@jimdo.com	5	88221014231	P0000155
V0000127  	2016-06-11	\N	1	202000.00	snavein2h@yolasite.com	200	83304827407	P000028 
V0000128  	2016-02-15	\N	1	12000.00	gberthouloume4w@delicious.com	10	88995977500	P000023 
V0000129  	2016-09-21	2016-09-25 20:30:00	2	7000.00	mtooley1s@storify.com	5	83854483381	P000085 
V0000130  	2016-01-08	\N	1	7000.00	kkilmister3q@indiatimes.com	5	85918952542	P000015 
V0000131  	2017-01-19	2017-01-23 14:56:00	2	202000.00	istoate5w@wix.com	200	86011139268	P000049 
V0000132  	2016-05-13	\N	1	27000.00	nwemm2e@meetup.com	25	83747569638	P0000164
V0000133  	2017-01-14	2017-01-18 11:30:00	2	12000.00	cvigars47@irs.gov	10	88291429923	P000016 
V0000134  	2017-03-15	\N	1	102000.00	amardling6@typepad.com	100	86572794970	P000054 
V0000135  	2016-07-29	2016-08-01 07:31:00	2	152000.00	mquittonden51@acquirethisname.com	150	86972171639	P0000153
V0000136  	2016-10-14	\N	1	12000.00	blemasney2w@yelp.com	10	80480085783	P0000177
V0000137  	2016-05-02	2016-05-04 22:38:00	2	12000.00	gbonifazio3f@adobe.com	10	88742477621	P000093 
V0000138  	2016-07-28	2016-08-01 09:37:00	2	202000.00	bbisseker4m@g.co	200	87594884290	P000070 
V0000139  	2016-05-30	2016-06-03 23:02:00	2	27000.00	mmcfadden5x@live.com	25	87507423479	P0000136
V0000140  	2016-01-30	2016-02-01 09:18:00	2	12000.00	csaladine6a@businesswire.com	10	87630360279	P000093 
V0000141  	2016-11-07	2016-11-10 19:18:00	2	7000.00	vburchill4t@sohu.com	5	87546697030	P000092 
V0000142  	2016-08-17	2016-08-21 10:43:00	2	27000.00	kantoniat5b@hc360.com	25	80488355075	P0000171
V0000143  	2017-01-21	\N	1	7000.00	mmobley2o@mac.com	5	87872548490	P0000162
V0000144  	2016-01-06	2016-01-09 21:31:00	2	102000.00	msteggals6q@ox.ac.uk	100	80200637897	P000075 
V0000145  	2016-03-28	2016-03-31 09:52:00	2	102000.00	klind1n@diigo.com	100	81938323903	P0000138
V0000146  	2016-10-31	\N	1	202000.00	bmacmanus3e@arstechnica.com	200	82391770624	P000035 
V0000147  	2016-05-14	\N	1	152000.00	medgell65@arizona.edu	150	85523555260	P000069 
V0000148  	2016-11-21	2016-11-24 02:08:00	2	27000.00	zheaton29@va.gov	25	84560686482	P0000115
V0000149  	2017-01-26	2017-01-29 10:52:00	2	152000.00	hbeloe1z@freewebs.com	150	84537215061	P0000153
V0000150  	2016-05-29	2016-06-01 11:19:00	2	27000.00	pshillington1m@usda.gov	25	86810560738	P000045 
V0000151  	2016-09-24	2016-09-26 23:37:00	2	12000.00	servine6k@macromedia.com	10	86400482295	P0000156
V0000152  	2016-03-18	\N	1	102000.00	fsothern6c@dailymail.co.uk	100	82889919431	P0000124
V0000153  	2016-01-13	2016-01-15 12:30:00	2	102000.00	ntye6t@dyndns.org	100	88567457252	P000068 
V0000154  	2016-05-13	\N	1	152000.00	astandell6g@washington.edu	150	88204822346	P000041 
V0000155  	2016-10-13	2016-10-15 03:33:00	2	102000.00	pmccague6r@a8.net	100	88066108729	P000026 
V0000156  	2017-02-04	\N	1	52000.00	lkobpac5u@nih.gov	50	82736262829	P000060 
V0000157  	2016-09-10	2016-09-14 00:24:00	2	102000.00	mcollyns46@1und1.de	100	85078664484	P000012 
V0000158  	2016-01-22	\N	1	52000.00	istreeton2u@yellowbook.com	50	80656377820	P0000158
V0000159  	2016-11-16	\N	1	152000.00	drojel5k@merriam-webster.com	150	83819654832	P0000118
V0000160  	2016-11-03	2016-11-05 15:21:00	2	152000.00	hbeloe1z@freewebs.com	150	84537215061	P0000139
V0000161  	2016-03-13	2016-03-17 18:48:00	2	7000.00	scantu60@icio.us	5	89688331346	P0000176
V0000162  	2016-02-15	2016-02-17 18:29:00	2	202000.00	adwelly3u@pen.io	200	89480370270	P0000126
V0000163  	2017-02-02	\N	1	27000.00	dedgell3w@ebay.co.uk	25	87645187516	P000087 
V0000164  	2017-02-03	2017-02-06 23:09:00	2	202000.00	twormleightonk@dagondesign.com	200	89803625389	P000056 
V0000165  	2017-02-06	\N	1	102000.00	tjohnsson35@gizmodo.com	100	82503556797	P0000173
V0000166  	2016-09-09	2016-09-11 21:09:00	2	52000.00	aslides4s@fotki.com	50	85398775284	P0000193
V0000167  	2017-03-27	\N	1	202000.00	jjeffcoat5e@npr.org	200	87068389940	P000063 
V0000168  	2017-02-23	2017-02-25 16:10:00	2	102000.00	jguice6f@cyberchimps.com	100	88825342280	P000012 
V0000169  	2016-12-23	\N	1	27000.00	gberthouloume4w@delicious.com	25	88995977500	P000017 
V0000170  	2017-03-01	2017-03-05 07:15:00	2	152000.00	dcaulfield2q@dmoz.org	150	81060631865	P000020 
V0000171  	2016-08-14	2016-08-16 05:05:00	2	152000.00	ggamesonx@webs.com	150	89864490452	P0000111
V0000172  	2016-02-06	\N	1	152000.00	atrowler5j@apple.com	150	84814125457	P0000181
V0000173  	2017-02-22	2017-02-26 06:00:00	2	12000.00	hcastanaga1j@fda.gov	10	87520960388	P0000170
V0000174  	2016-01-31	2016-02-03 05:53:00	2	202000.00	zbaybutt6w@cafepress.com	200	88056138111	P000042 
V0000175  	2016-11-01	2016-11-04 03:34:00	2	12000.00	fdarrington6i@unblog.fr	10	80190617622	P0000100
V0000176  	2016-08-26	\N	1	7000.00	bfalshaw2@about.me	5	89250859186	P000085 
V0000177  	2016-02-06	2016-02-08 13:05:00	2	52000.00	cvigars47@irs.gov	50	88291429923	P0000137
V0000178  	2016-04-27	2016-05-01 07:34:00	2	7000.00	kdibdale5q@bandcamp.com	5	83881473500	P000078 
V0000179  	2016-04-27	2016-04-29 13:03:00	2	102000.00	rexley26@barnesandnoble.com	100	85504321184	P000012 
V0000180  	2016-03-13	2016-03-16 17:37:00	2	102000.00	rhallick2d@shutterfly.com	100	84520550800	P0000103
V0000181  	2016-11-29	2016-12-02 15:32:00	2	12000.00	kjuorio31@t.co	10	87715602216	P000086 
V0000182  	2016-12-02	2016-12-05 08:18:00	2	27000.00	gtofanon@ustream.tv	25	81614595122	P0000143
V0000183  	2016-04-06	2016-04-10 21:30:00	2	27000.00	minksteri@aol.com	25	89822940015	P0000178
V0000184  	2016-09-19	\N	1	52000.00	mmasserel1g@epa.gov	50	88184601779	P0000200
V0000185  	2016-12-27	2016-12-30 20:51:00	2	102000.00	astandell6g@washington.edu	100	88204822346	P000089 
V0000186  	2016-11-20	2016-11-22 09:16:00	2	102000.00	pshillington1m@usda.gov	100	86810560738	P0000124
V0000187  	2016-08-11	2016-08-14 15:34:00	2	7000.00	rmooney4j@theatlantic.com	5	84285996068	P000092 
V0000188  	2017-03-14	\N	1	102000.00	cbakhrushint@reddit.com	100	86370364042	P0000180
V0000189  	2016-12-10	2016-12-13 00:39:00	2	27000.00	kde3g@ebay.co.uk	25	86375130638	P0000150
V0000190  	2016-03-23	2016-03-26 17:54:00	2	202000.00	cbakhrushint@reddit.com	200	86370364042	P000070 
V0000191  	2016-05-27	2016-05-30 06:19:00	2	202000.00	nverlinde5l@globo.com	200	81444357145	P000084 
V0000192  	2017-01-07	2017-01-10 23:29:00	2	7000.00	cbrumen4a@skype.com	5	87202747523	P0000183
V0000193  	2016-03-22	\N	1	102000.00	bbryant56@bbc.co.uk	100	88886565255	P000012 
V0000194  	2016-03-22	2016-03-25 20:14:00	2	12000.00	cmcwhin4g@gizmodo.com	10	82640302573	P0000184
V0000195  	2016-07-24	2016-07-27 04:24:00	2	152000.00	gtofanon@ustream.tv	150	81614595122	P000076 
V0000196  	2016-11-07	2016-11-09 06:09:00	2	102000.00	dcaulfield2q@dmoz.org	100	81060631865	P0000103
V0000197  	2016-03-03	2016-03-05 11:09:00	2	7000.00	umordacai5g@last.fm	5	82364007007	P00001  
V0000198  	2016-05-25	2016-05-28 10:27:00	2	202000.00	amardling6@typepad.com	200	86572794970	P0000119
V0000199  	2016-04-06	2016-04-08 04:41:00	2	202000.00	kchastelain6l@ucsd.edu	200	81144636223	P000098 
V0000200  	2017-04-04	\N	1	12000.00	cshrimptone5f@gov.uk	10	88274693340	P0000135
V0000201  	2016-09-16	2016-09-18 01:54:00	2	7000.00	nrodda11@hibu.com	5	81252302661	P0000120
V0000202  	2016-07-19	\N	1	12000.00	atrowler5j@apple.com	10	84814125457	P000086 
V0000203  	2017-02-10	2017-02-13 02:23:00	2	202000.00	cbrumen4a@skype.com	200	87202747523	P0000175
V0000204  	2016-11-21	2016-11-25 03:07:00	2	152000.00	gmorgans14@nba.com	150	89947720529	P000027 
V0000205  	2016-10-03	\N	1	202000.00	lradnage30@canalblog.com	200	82305706756	P0000126
V0000206  	2016-10-31	\N	1	202000.00	rreeson1y@cnet.com	200	80474700107	P00007  
V0000207  	2017-01-12	\N	1	202000.00	dbeagin5d@barnesandnoble.com	200	82407112188	P0000140
V0000208  	2016-06-10	\N	1	12000.00	csiegertsz2j@columbia.edu	10	82387894828	P00009  
V0000209  	2017-01-27	2017-01-30 05:29:00	2	12000.00	hlodford3j@slate.com	10	87679307098	P0000170
V0000210  	2016-05-04	\N	1	202000.00	gberthouloume4w@delicious.com	200	88995977500	P0000175
V0000211  	2017-02-18	2017-02-20 14:16:00	2	7000.00	rbuxey5o@scientificamerican.com	5	89036678774	P0000183
V0000212  	2017-01-17	2017-01-21 01:20:00	2	12000.00	owoollam4e@amazonaws.com	10	83036699761	P00002  
V0000213  	2016-02-03	2016-02-05 11:49:00	2	12000.00	ntye6t@dyndns.org	10	88567457252	P0000163
V0000214  	2016-08-04	2016-08-06 12:56:00	2	202000.00	atrowler5j@apple.com	200	84814125457	P000070 
V0000215  	2017-03-06	\N	1	102000.00	csiegertsz2j@columbia.edu	100	82387894828	P000082 
V0000216  	2016-11-24	\N	1	12000.00	rdidball53@webs.com	10	80705469249	P0000163
V0000217  	2016-05-21	\N	1	152000.00	stither4h@google.ru	150	87640579752	P0000139
V0000218  	2016-06-14	2016-06-18 00:41:00	2	52000.00	mkeays6h@posterous.com	50	83800668752	P000067 
V0000219  	2016-07-25	2016-07-29 15:06:00	2	12000.00	mmcgarvey6d@yellowbook.com	10	85543170838	P0000191
V0000220  	2017-02-19	2017-02-23 07:38:00	2	27000.00	rdametti2x@narod.ru	25	83663483463	P000017 
V0000221  	2016-11-18	\N	1	7000.00	kjuorio31@t.co	5	87715602216	P0000120
V0000222  	2016-04-09	2016-04-11 23:18:00	2	152000.00	hstapleton38@geocities.com	150	87348158563	P000083 
V0000223  	2016-07-14	2016-07-17 01:48:00	2	7000.00	kantoniat5b@hc360.com	5	80488355075	P0000113
V0000224  	2016-10-11	2016-10-15 10:24:00	2	27000.00	mquittonden51@acquirethisname.com	25	86972171639	P000017 
V0000225  	2016-12-21	2016-12-25 08:14:00	2	52000.00	nrodda11@hibu.com	50	81252302661	P000025 
V0000226  	2016-11-16	2016-11-20 09:25:00	2	7000.00	aodevey2z@prlog.org	5	88146432693	P0000106
V0000227  	2016-12-26	\N	1	202000.00	hstapleton38@geocities.com	200	87348158563	P000056 
V0000228  	2016-09-04	2016-09-07 17:28:00	2	202000.00	rdidball53@webs.com	200	80705469249	P0000154
V0000229  	2016-10-06	2016-10-09 16:02:00	2	12000.00	jwillard5r@51.la	10	82050374984	P000051 
V0000230  	2016-01-24	\N	1	52000.00	fdarrington6i@unblog.fr	50	80190617622	P0000137
V0000231  	2016-11-28	2016-11-30 00:58:00	2	12000.00	fburkman2b@twitpic.com	10	88060310279	P000079 
V0000232  	2017-04-16	\N	1	12000.00	cnewling64@hc360.com	10	89159608191	P0000156
V0000233  	2016-09-10	\N	1	7000.00	castlesa@paginegialle.it	5	86601207900	P000050 
V0000234  	2016-01-28	2016-01-30 19:38:00	2	152000.00	minksteri@aol.com	150	89822940015	P000041 
V0000235  	2016-05-09	\N	1	52000.00	sokeenan23@csmonitor.com	50	83907368770	P00004  
V0000236  	2016-09-29	2016-10-01 14:37:00	2	52000.00	kmiddlemiss6e@umn.edu	50	84351860045	P0000123
V0000237  	2016-03-05	\N	1	152000.00	servine6k@macromedia.com	150	86400482295	P000083 
V0000238  	2016-05-06	2016-05-10 17:26:00	2	12000.00	ptesh5a@salon.com	10	88863667126	P0000177
V0000239  	2016-10-30	2016-11-01 21:28:00	2	27000.00	tadame4c@alexa.com	25	83954809255	P0000185
V0000240  	2017-03-30	\N	1	102000.00	mcollyns46@1und1.de	100	85078664484	P0000180
V0000241  	2016-08-08	\N	1	152000.00	mhallagan3m@psu.edu	150	81741232359	P0000195
V0000242  	2016-06-09	2016-06-12 07:48:00	2	202000.00	carchambault67@cam.ac.uk	200	86168846864	P000021 
V0000243  	2016-02-16	\N	1	12000.00	pbroadbear2a@indiatimes.com	10	80983160868	P000016 
V0000244  	2017-03-20	2017-03-23 19:11:00	2	27000.00	kdibdale5q@bandcamp.com	25	83881473500	P0000171
V0000245  	2016-03-04	2016-03-06 07:15:00	2	52000.00	bmacmanus3e@arstechnica.com	50	82391770624	P000018 
V0000246  	2016-09-09	2016-09-13 01:11:00	2	52000.00	tblackway61@51.la	50	89041936071	P000025 
V0000247  	2016-12-12	2016-12-15 14:28:00	2	7000.00	gbonifazio3f@adobe.com	5	88742477621	P0000148
V0000248  	2017-03-08	2017-03-10 03:25:00	2	7000.00	tblackway61@51.la	5	89041936071	P0000113
V0000249  	2016-05-13	2016-05-16 05:49:00	2	27000.00	kkilmister3q@indiatimes.com	25	85918952542	P0000122
V0000250  	2016-04-06	\N	1	152000.00	lradnage30@canalblog.com	150	82305706756	P000083 
V0000251  	2016-01-09	2016-01-11 11:49:00	2	102000.00	jsedgeman20@sourceforge.net	100	89119013144	P0000124
V0000252  	2016-04-27	\N	1	102000.00	kantoniat5b@hc360.com	100	80488355075	P000019 
V0000253  	2016-08-15	2016-08-17 07:46:00	2	7000.00	aslides4s@fotki.com	5	85398775284	P0000106
V0000254  	2016-11-09	2016-11-13 00:55:00	2	102000.00	kviles24@1688.com	100	84860494017	P00005  
V0000255  	2017-04-01	2017-04-03 02:41:00	2	102000.00	lbarbrookm@google.co.uk	100	89877161121	P0000117
V0000256  	2017-02-20	\N	1	27000.00	wnotman6v@istockphoto.com	25	89798087339	P0000129
V0000257  	2017-04-12	2017-04-16 08:28:00	2	7000.00	agrimestone5s@jimdo.com	5	84943331218	P000043 
V0000258  	2016-04-13	2016-04-16 02:23:00	2	12000.00	gzapata4o@slideshare.net	10	83613907873	P000065 
V0000259  	2017-03-26	\N	1	27000.00	sdufer57@yellowbook.com	25	82160710840	P0000178
V0000260  	2016-07-04	2016-07-08 00:45:00	2	52000.00	hjonathon1t@google.ca	50	80590818388	P000074 
V0000261  	2016-02-16	2016-02-19 12:28:00	2	52000.00	rmouland4l@psu.edu	50	84128317328	P0000193
V0000262  	2016-01-24	\N	1	102000.00	amardling6@typepad.com	100	86572794970	P00005  
V0000263  	2016-10-04	2016-10-07 19:59:00	2	12000.00	fkynston4i@fda.gov	10	83108559522	P000065 
V0000264  	2017-03-14	\N	1	52000.00	rharcarse54@buzzfeed.com	50	85363513496	P000032 
V0000265  	2016-03-10	2016-03-14 23:58:00	2	52000.00	abinnes6o@pcworld.com	50	84313290763	P000032 
V0000266  	2016-08-17	\N	1	27000.00	wnotman6v@istockphoto.com	25	89798087339	P000087 
V0000267  	2016-01-11	\N	1	102000.00	ldoore32@loc.gov	100	84838437697	P000012 
V0000268  	2017-03-17	2017-03-20 23:09:00	2	12000.00	gkristoffersen63@businesswire.com	10	89465850478	P000072 
V0000269  	2017-01-29	2017-02-01 23:06:00	2	152000.00	mrobert1i@pcworld.com	150	85869266262	P0000146
V0000270  	2016-06-26	2016-06-30 10:07:00	2	202000.00	vgissing12@google.fr	200	81227712578	P0000161
V0000271  	2016-05-31	2016-06-04 10:33:00	2	7000.00	blemasney2w@yelp.com	5	80480085783	P000099 
V0000272  	2016-03-14	\N	1	27000.00	aodevey2z@prlog.org	25	88146432693	P0000150
V0000273  	2016-12-13	\N	1	102000.00	scantu60@icio.us	100	89688331346	P0000180
V0000274  	2016-06-22	\N	1	7000.00	csaladine6a@businesswire.com	5	87630360279	P00001  
V0000275  	2016-01-14	2016-01-18 01:24:00	2	202000.00	pgrollmann1k@posterous.com	200	81306220495	P000077 
V0000276  	2016-04-28	\N	1	7000.00	vmessruther40@fc2.com	5	83764441781	P000029 
V0000277  	2017-03-07	\N	1	202000.00	svezey6j@va.gov	200	81232581509	P000056 
V0000278  	2016-10-08	2016-10-12 11:24:00	2	152000.00	hstapleton38@geocities.com	150	87348158563	P000076 
V0000279  	2017-02-26	\N	1	102000.00	fportinari2r@cdc.gov	100	82745997636	P0000110
V0000280  	2017-03-15	2017-03-19 05:33:00	2	7000.00	wzanini2t@yahoo.co.jp	5	83613145333	P0000155
V0000281  	2016-04-30	2016-05-04 04:42:00	2	202000.00	fdarrington6i@unblog.fr	200	80190617622	P0000154
V0000282  	2016-08-27	\N	1	12000.00	leason6p@wufoo.com	10	86042741789	P0000191
V0000283  	2016-02-08	\N	1	12000.00	rbuxey5o@scientificamerican.com	10	89036678774	P000072 
V0000284  	2016-08-03	2016-08-07 07:10:00	2	52000.00	cdrysdale4z@dell.com	50	83852348392	P0000200
V0000285  	2016-09-09	2016-09-12 18:06:00	2	102000.00	sricardin6s@furl.net	100	85794978063	P0000117
V0000286  	2016-10-17	2016-10-21 05:12:00	2	52000.00	gmorgans14@nba.com	50	89947720529	P000032 
V0000287  	2016-08-29	2016-08-31 01:52:00	2	27000.00	scantu60@icio.us	25	89688331346	P0000115
V0000288  	2016-02-21	2016-02-25 18:52:00	2	202000.00	sbwy1x@xing.com	200	83794238715	P0000154
V0000289  	2016-04-08	\N	1	7000.00	dhurne4@nydailynews.com	5	81852887905	P0000120
V0000290  	2016-12-21	2016-12-25 01:37:00	2	202000.00	glarmett22@reuters.com	200	80647660331	P0000140
V0000291  	2016-10-02	\N	1	7000.00	rbuxey5o@scientificamerican.com	5	89036678774	P000057 
V0000292  	2016-08-01	\N	1	27000.00	kantoniat5b@hc360.com	25	80488355075	P0000108
V0000293  	2016-09-23	2016-09-26 05:11:00	2	102000.00	tblackway61@51.la	100	89041936071	P000033 
V0000294  	2016-06-03	2016-06-06 04:03:00	2	27000.00	dhurne4@nydailynews.com	25	81852887905	P0000185
V0000295  	2016-09-11	2016-09-15 10:57:00	2	27000.00	nleither16@google.it	25	81287534952	P0000122
V0000296  	2016-04-20	\N	1	152000.00	cleet1r@infoseek.co.jp	150	88278772478	P000055 
V0000297  	2016-09-22	2016-09-25 02:39:00	2	102000.00	jhaggerstone6n@cisco.com	100	86702997346	P000082 
V0000298  	2016-06-26	\N	1	202000.00	medgell65@arizona.edu	200	85523555260	P000021 
V0000299  	2016-06-10	\N	1	152000.00	ghurleston45@netlog.com	150	82154487163	P0000167
V0000300  	2017-04-22	2017-04-24 15:23:00	2	102000.00	vcarlton4x@jimdo.com	100	88221014231	P000082 
V0000301  	2016-09-05	2016-09-09 14:07:00	2	12000.00	istoate5w@wix.com	10	86011139268	P00002  
V0000302  	2016-09-25	2016-09-28 00:18:00	2	152000.00	sgrigollig@weather.com	150	82047655814	P0000174
V0000303  	2017-04-04	2017-04-06 09:05:00	2	202000.00	eduddle34@redcross.org	200	86901219773	P0000161
V0000304  	2016-01-19	2016-01-22 21:14:00	2	27000.00	kchastelain6l@ucsd.edu	25	81144636223	P0000136
V0000305  	2016-09-25	\N	1	7000.00	cbeaman7@instagram.com	5	83888037237	P000092 
V0000306  	2016-02-15	2016-02-19 15:48:00	2	52000.00	lmaunders4y@google.ca	50	89181257664	P000060 
V0000307  	2017-02-23	2017-02-26 06:54:00	2	12000.00	kviles24@1688.com	10	84860494017	P000016 
V0000308  	2016-11-02	2016-11-06 16:25:00	2	202000.00	pgrollmann1k@posterous.com	200	81306220495	P000063 
V0000309  	2016-06-06	2016-06-09 07:21:00	2	152000.00	mkleen21@tumblr.com	150	85032027714	P000090 
V0000310  	2016-09-10	\N	1	7000.00	odredge3a@sogou.com	5	80559847594	P000050 
V0000311  	2017-02-14	\N	1	152000.00	cabby4b@cyberchimps.com	150	88272662800	P0000146
V0000312  	2016-08-05	\N	1	27000.00	rbuxey5o@scientificamerican.com	25	89036678774	P000045 
V0000313  	2016-07-28	\N	1	12000.00	egiles42@sitemeter.com	10	86087726649	P0000128
V0000314  	2016-11-03	\N	1	202000.00	erihanek66@surveymonkey.com	200	81089491133	P000056 
V0000315  	2016-07-08	2016-07-11 03:07:00	2	202000.00	amcsparran6b@springer.com	200	89401587927	P0000105
V0000316  	2017-01-18	\N	1	152000.00	apetrasek3x@cocolog-nifty.com	150	83751068436	P00006  
V0000317  	2017-04-16	\N	1	7000.00	md3c@about.com	5	80139828915	P000036 
V0000318  	2017-02-18	\N	1	152000.00	cleet1r@infoseek.co.jp	150	88278772478	P0000139
V0000319  	2016-01-16	2016-01-20 14:12:00	2	102000.00	nrodda11@hibu.com	100	81252302661	P000047 
V0000320  	2016-01-04	\N	1	7000.00	vmolyneaux10@google.com.au	5	88523069382	P000092 
V0000321  	2016-02-28	\N	1	152000.00	gtofanon@ustream.tv	150	81614595122	P000027 
V0000322  	2016-02-26	2016-03-01 16:35:00	2	152000.00	pgrollmann1k@posterous.com	150	81306220495	P0000111
V0000323  	2017-01-17	2017-01-19 08:41:00	2	7000.00	jalenshev3l@sciencedaily.com	5	84367350311	P0000190
V0000324  	2016-06-08	2016-06-12 18:38:00	2	12000.00	vmolyneaux10@google.com.au	10	88523069382	P000037 
V0000325  	2016-07-29	2016-08-01 01:01:00	2	12000.00	kde3g@ebay.co.uk	10	86375130638	P000072 
V0000326  	2017-03-23	2017-03-27 15:01:00	2	12000.00	ldoram48@xrea.com	10	88849409298	P000023 
V0000327  	2017-02-12	2017-02-15 02:18:00	2	12000.00	mgarric5@amazon.de	10	85833193950	P0000191
V0000328  	2016-08-12	2016-08-15 18:35:00	2	202000.00	md3c@about.com	200	80139828915	P000028 
V0000329  	2016-11-27	2016-11-29 01:30:00	2	52000.00	cbrumen4a@skype.com	50	87202747523	P0000193
V0000330  	2016-07-22	2016-07-24 04:47:00	2	7000.00	cdrysdale4z@dell.com	5	83852348392	P0000127
V0000331  	2016-01-29	2016-02-02 10:01:00	2	202000.00	cbakhrushint@reddit.com	200	86370364042	P000063 
V0000332  	2016-08-07	2016-08-11 13:56:00	2	12000.00	istreeton2u@yellowbook.com	10	80656377820	P0000191
V0000333  	2016-05-10	\N	1	52000.00	jhaggerstone6n@cisco.com	50	86702997346	P0000193
V0000334  	2016-12-10	2016-12-12 23:19:00	2	202000.00	sklimentov4k@creativecommons.org	200	80810117810	P0000147
V0000335  	2016-11-14	2016-11-16 13:14:00	2	102000.00	blemasney2w@yelp.com	100	80480085783	P0000138
V0000336  	2016-02-03	2016-02-07 16:12:00	2	52000.00	sphidgin3y@newyorker.com	50	88865981234	P0000130
V0000337  	2017-01-09	2017-01-11 01:14:00	2	102000.00	gzapata4o@slideshare.net	100	83613907873	P0000180
V0000338  	2016-06-24	2016-06-28 14:34:00	2	12000.00	amcsparran6b@springer.com	10	89401587927	P000037 
V0000339  	2016-01-01	\N	1	12000.00	tblackway61@51.la	10	89041936071	P0000128
V0000340  	2016-10-07	\N	1	27000.00	msapwellf@wikimedia.org	25	85734329715	P0000122
V0000341  	2016-10-08	2016-10-10 20:42:00	2	152000.00	cbeaman7@instagram.com	150	83888037237	P0000111
V0000342  	2016-11-23	2016-11-25 03:16:00	2	202000.00	reckh2k@123-reg.co.uk	200	87183048439	P000070 
V0000343  	2017-03-16	2017-03-19 03:39:00	2	152000.00	mdraysay5z@weibo.com	150	87966446221	P000041 
V0000344  	2016-01-16	2016-01-19 18:33:00	2	7000.00	ehegley25@seattletimes.com	5	82575144612	P00008  
V0000345  	2017-01-25	2017-01-28 02:58:00	2	27000.00	pshillington1m@usda.gov	25	86810560738	P0000129
V0000346  	2016-12-15	\N	1	102000.00	sdufer57@yellowbook.com	100	82160710840	P000075 
V0000347  	2016-04-27	2016-04-30 23:04:00	2	7000.00	ptesh5a@salon.com	5	88863667126	P000071 
V0000348  	2017-03-01	\N	1	102000.00	ffarncombe5h@theguardian.com	100	88300445379	P000082 
V0000349  	2016-07-30	2016-08-01 19:16:00	2	152000.00	egiles42@sitemeter.com	150	86087726649	P000013 
V0000350  	2016-09-12	2016-09-14 07:19:00	2	7000.00	kviles24@1688.com	5	84860494017	P0000155
V0000351  	2016-03-18	\N	1	7000.00	kde3g@ebay.co.uk	5	86375130638	P000099 
V0000352  	2016-01-06	2016-01-08 20:56:00	2	102000.00	atrowler5j@apple.com	100	84814125457	P000061 
V0000353  	2016-12-30	2017-01-01 14:50:00	2	12000.00	cbeaman7@instagram.com	10	83888037237	P0000163
V0000354  	2016-04-26	\N	1	152000.00	fexrollz@squarespace.com	150	89204058945	P000097 
V0000355  	2016-01-28	2016-01-31 14:39:00	2	27000.00	rdametti2x@narod.ru	25	83663483463	P0000157
V0000356  	2016-11-25	2016-11-27 13:06:00	2	27000.00	fboheao@baidu.com	25	83024276671	P000052 
V0000357  	2016-10-27	2016-10-31 20:13:00	2	152000.00	bfalshaw2@about.me	150	89250859186	P0000160
V0000358  	2017-03-04	2017-03-08 18:22:00	2	202000.00	eduddle34@redcross.org	200	86901219773	P0000196
V0000359  	2016-03-07	2016-03-09 08:37:00	2	12000.00	hborn8@sakura.ne.jp	10	88495578938	P0000128
V0000360  	2016-02-05	2016-02-09 23:07:00	2	27000.00	bwollers2v@usnews.com	25	82504673276	P000045 
V0000361  	2016-11-19	2016-11-21 18:23:00	2	102000.00	hlinklet1a@answers.com	100	83809332578	P00005  
V0000362  	2016-11-06	\N	1	202000.00	jguice6f@cyberchimps.com	200	88825342280	P0000126
V0000363  	2017-03-08	\N	1	102000.00	jdinesen2y@vimeo.com	100	83915236091	P000019 
V0000364  	2017-02-09	2017-02-13 10:04:00	2	52000.00	awinchurst5v@cloudflare.com	50	80762142879	P000081 
V0000365  	2016-08-02	\N	1	27000.00	tskittreal5p@360.cn	25	82140943787	P0000157
V0000366  	2016-03-22	2016-03-26 07:14:00	2	27000.00	jhaggerstone6n@cisco.com	25	86702997346	P0000101
V0000367  	2016-12-12	\N	1	12000.00	jdinesen2y@vimeo.com	10	83915236091	P000016 
V0000368  	2016-06-10	2016-06-13 19:33:00	2	152000.00	mquittonden51@acquirethisname.com	150	86972171639	P0000146
V0000369  	2016-08-31	\N	1	12000.00	kbreukelman39@dot.gov	10	88560595824	P000030 
V0000370  	2017-03-10	2017-03-12 23:35:00	2	27000.00	ldoram48@xrea.com	25	88849409298	P0000157
V0000371  	2016-11-07	2016-11-10 10:46:00	2	152000.00	odredge3a@sogou.com	150	80559847594	P000048 
V0000372  	2016-07-03	2016-07-07 09:08:00	2	152000.00	pmccague6r@a8.net	150	88066108729	P00006  
V0000373  	2016-12-19	2016-12-21 17:08:00	2	52000.00	bcradick3t@squidoo.com	50	80814514094	P000081 
V0000374  	2016-05-18	2016-05-20 21:41:00	2	12000.00	vmolyneaux10@google.com.au	10	88523069382	P0000191
V0000375  	2017-01-25	\N	1	202000.00	sokeenan23@csmonitor.com	200	83907368770	P0000196
V0000376  	2016-08-14	\N	1	102000.00	mquittonden51@acquirethisname.com	100	86972171639	P0000187
V0000377  	2017-03-29	2017-04-02 05:02:00	2	7000.00	vhabbeshawh@ifeng.com	5	85010568675	P0000134
V0000378  	2017-02-17	2017-02-19 03:19:00	2	27000.00	gtaggett5t@over-blog.com	25	88620140001	P00003  
V0000379  	2017-03-28	\N	1	7000.00	gtofanon@ustream.tv	5	81614595122	P0000120
V0000380  	2017-01-02	\N	1	27000.00	olindeboom6x@adobe.com	25	87901515196	P0000122
V0000381  	2016-03-01	2016-03-05 12:04:00	2	202000.00	jguice6f@cyberchimps.com	200	88825342280	P000049 
V0000382  	2017-02-07	\N	1	52000.00	umordacai5g@last.fm	50	82364007007	P000025 
V0000383  	2016-11-22	2016-11-24 15:31:00	2	27000.00	eduddle34@redcross.org	25	86901219773	P000094 
V0000384  	2017-04-15	\N	1	27000.00	bcradick3t@squidoo.com	25	80814514094	P0000157
V0000385  	2016-03-10	\N	1	152000.00	cnewling64@hc360.com	150	89159608191	P0000118
V0000386  	2016-05-14	2016-05-16 15:07:00	2	152000.00	owoolliams1w@unc.edu	150	80245678981	P000069 
V0000387  	2016-06-01	2016-06-03 05:15:00	2	202000.00	ebridgwoodb@fotki.com	200	84914571715	P00007  
V0000388  	2017-03-14	2017-03-17 08:56:00	2	7000.00	amilstead5i@umich.edu	5	84605543375	P000043 
V0000389  	2016-11-11	\N	1	27000.00	md3c@about.com	25	80139828915	P0000171
V0000390  	2016-08-28	\N	1	27000.00	nrodda11@hibu.com	25	81252302661	P0000136
V0000391  	2016-11-06	\N	1	12000.00	jjeffcoat5e@npr.org	10	87068389940	P0000163
V0000392  	2016-10-19	\N	1	202000.00	mpowney2s@over-blog.com	200	84894394013	P000091 
V0000393  	2017-02-12	2017-02-16 09:26:00	2	27000.00	gkristoffersen63@businesswire.com	25	89465850478	P000073 
V0000394  	2016-01-29	\N	1	52000.00	vmessruther40@fc2.com	50	83764441781	P00004  
V0000395  	2016-12-26	\N	1	52000.00	mpattison1d@spotify.com	50	80446590793	P000053 
V0000396  	2017-04-04	\N	1	12000.00	rreeson1y@cnet.com	10	80474700107	P000023 
V0000397  	2016-07-24	\N	1	7000.00	ireadhead3k@is.gd	5	89268549631	P0000141
V0000398  	2016-08-21	2016-08-25 00:00:00	2	12000.00	pshillington1m@usda.gov	10	86810560738	P000030 
V0000399  	2016-07-02	\N	1	7000.00	sklimentov4k@creativecommons.org	5	80810117810	P000022 
V0000400  	2016-07-24	\N	1	27000.00	fmasic1h@prweb.com	25	87680100452	P0000157
V0000401  	2016-09-09	\N	1	202000.00	sokeenan23@csmonitor.com	200	83907368770	P0000182
V0000402  	2017-01-09	\N	1	102000.00	epotte5n@redcross.org	100	87954524225	P0000152
V0000403  	2016-01-26	2016-01-30 08:52:00	2	152000.00	hgisborne28@slashdot.org	150	88627968524	P0000160
V0000404  	2017-01-26	2017-01-28 15:20:00	2	7000.00	sbwy1x@xing.com	5	83794238715	P000029 
V0000405  	2016-07-10	2016-07-13 23:35:00	2	102000.00	mmobley2o@mac.com	100	87872548490	P00005  
V0000406  	2016-08-08	2016-08-12 01:52:00	2	52000.00	jdinesen2y@vimeo.com	50	83915236091	P000039 
V0000407  	2017-04-15	\N	1	27000.00	jwillard5r@51.la	25	82050374984	P0000150
V0000408  	2016-12-31	\N	1	102000.00	gkristoffersen63@businesswire.com	100	89465850478	P0000145
V0000409  	2016-06-29	\N	1	52000.00	lcolicot4d@behance.net	50	88995677800	P0000137
V0000410  	2016-04-01	2016-04-04 05:56:00	2	27000.00	awestphalen3s@desdev.cn	25	83362913749	P000045 
V0000411  	2017-04-23	2017-04-25 02:07:00	2	12000.00	apetrasek3x@cocolog-nifty.com	10	83751068436	P000016 
V0000412  	2016-03-13	2016-03-16 03:06:00	2	12000.00	jsedgeman20@sourceforge.net	10	89119013144	P0000156
V0000413  	2016-11-06	\N	1	152000.00	ebewfield1e@icio.us	150	89368096947	P0000174
V0000414  	2016-05-26	\N	1	52000.00	cbeaman7@instagram.com	50	83888037237	P000060 
V0000415  	2016-07-11	2016-07-14 20:25:00	2	7000.00	cbrumen4a@skype.com	5	87202747523	P0000134
V0000416  	2016-09-17	2016-09-21 12:29:00	2	202000.00	owoolliams1w@unc.edu	200	80245678981	P0000133
V0000417  	2016-02-21	2016-02-25 10:09:00	2	102000.00	cshrimptone5f@gov.uk	100	88274693340	P000054 
V0000418  	2016-10-05	\N	1	27000.00	blemasney2w@yelp.com	25	80480085783	P0000164
V0000419  	2017-01-27	2017-01-29 14:10:00	2	102000.00	glarmett22@reuters.com	100	80647660331	P000075 
V0000420  	2016-10-02	2016-10-05 00:21:00	2	7000.00	bambersonv@wp.com	5	81561652227	P000022 
V0000421  	2016-04-01	2016-04-05 21:49:00	2	152000.00	elamcken27@hud.gov	150	80081938955	P0000125
V0000422  	2016-02-21	\N	1	52000.00	ggamesonx@webs.com	50	89864490452	P00004  
V0000423  	2016-07-04	\N	1	52000.00	pbroadbear2a@indiatimes.com	50	80983160868	P0000158
V0000424  	2016-09-26	2016-09-30 08:42:00	2	152000.00	nleither16@google.it	150	81287534952	P0000160
V0000425  	2016-03-28	2016-04-01 12:53:00	2	202000.00	minksteri@aol.com	200	89822940015	P0000112
V0000426  	2016-06-16	\N	1	202000.00	ehegley25@seattletimes.com	200	82575144612	P0000182
V0000427  	2016-06-13	\N	1	152000.00	kchastelain6l@ucsd.edu	150	81144636223	P0000104
V0000428  	2016-08-13	\N	1	152000.00	tskittreal5p@360.cn	150	82140943787	P0000125
V0000429  	2016-10-24	2016-10-28 20:53:00	2	202000.00	aodevey2z@prlog.org	200	88146432693	P00007  
V0000430  	2016-11-03	2016-11-05 23:38:00	2	12000.00	cabby4b@cyberchimps.com	10	88272662800	P0000198
V0000431  	2017-01-10	\N	1	202000.00	kchastelain6l@ucsd.edu	200	81144636223	P0000168
V0000432  	2016-08-14	2016-08-17 03:06:00	2	12000.00	rstump59@thetimes.co.uk	10	83937227183	P000093 
V0000433  	2016-12-07	\N	1	52000.00	scantu60@icio.us	50	89688331346	P0000116
V0000434  	2016-10-22	2016-10-24 16:01:00	2	102000.00	zbaybutt6w@cafepress.com	100	88056138111	P0000145
V0000435  	2016-09-28	2016-10-01 12:36:00	2	12000.00	mcrichmer58@mac.com	10	84632469306	P000051 
V0000436  	2016-09-17	\N	1	7000.00	bmacmanus3e@arstechnica.com	5	82391770624	P0000183
V0000437  	2016-03-07	2016-03-11 23:27:00	2	27000.00	kde3g@ebay.co.uk	25	86375130638	P0000199
V0000438  	2016-05-12	2016-05-15 16:23:00	2	12000.00	kbreukelman39@dot.gov	10	88560595824	P000058 
V0000439  	2016-03-14	2016-03-17 20:07:00	2	152000.00	rmooney4j@theatlantic.com	150	84285996068	P0000125
V0000440  	2016-10-27	2016-10-31 11:15:00	2	12000.00	jalenshev3l@sciencedaily.com	10	84367350311	P0000149
V0000441  	2016-05-09	\N	1	52000.00	bbisseker4m@g.co	50	87594884290	P0000179
V0000442  	2016-09-01	2016-09-03 12:12:00	2	27000.00	rdametti2x@narod.ru	25	83663483463	P000045 
V0000443  	2016-09-28	2016-10-01 08:27:00	2	152000.00	sbwy1x@xing.com	150	83794238715	P0000160
V0000444  	2017-04-05	2017-04-08 09:52:00	2	152000.00	nverlinde5l@globo.com	150	81444357145	P0000167
V0000445  	2016-01-28	\N	1	27000.00	klind1n@diigo.com	25	81938323903	P000052 
V0000446  	2016-03-16	2016-03-20 20:15:00	2	7000.00	hjonathon1t@google.ca	5	80590818388	P000092 
V0000447  	2016-08-15	2016-08-19 05:59:00	2	52000.00	ccheale1p@bbc.co.uk	50	86362735784	P0000130
V0000448  	2016-09-06	2016-09-10 15:38:00	2	52000.00	mtooley1s@storify.com	50	83854483381	P000074 
V0000449  	2016-03-13	2016-03-15 18:21:00	2	12000.00	evinas1f@stanford.edu	10	83507186620	P0000121
V0000450  	2016-03-27	\N	1	52000.00	servine6k@macromedia.com	50	86400482295	P0000179
V0000451  	2016-11-13	2016-11-15 18:03:00	2	7000.00	lehrat55@spiegel.de	5	83601865364	P0000141
V0000452  	2017-01-27	2017-01-30 06:37:00	2	152000.00	sbwy1x@xing.com	150	83794238715	P0000174
V0000453  	2016-01-25	2016-01-27 22:39:00	2	102000.00	lbambrick2p@sfgate.com	100	85947800537	P000040 
V0000454  	2016-04-24	2016-04-28 06:11:00	2	7000.00	mcrichmer58@mac.com	5	84632469306	P0000190
V0000455  	2016-01-29	2016-02-02 03:08:00	2	12000.00	cbeaman7@instagram.com	10	83888037237	P0000191
V0000456  	2016-05-14	\N	1	7000.00	vcarlton4x@jimdo.com	5	88221014231	P000071 
V0000457  	2017-01-11	\N	1	12000.00	kaleevyq@msn.com	10	82615861181	P0000128
V0000458  	2016-11-05	\N	1	7000.00	pbroadbear2a@indiatimes.com	5	80983160868	P0000127
V0000459  	2016-02-27	2016-03-01 06:47:00	2	52000.00	ehegley25@seattletimes.com	50	82575144612	P000074 
V0000460  	2016-07-30	\N	1	52000.00	dcaulfield2q@dmoz.org	50	81060631865	P0000137
V0000461  	2017-02-28	2017-03-02 08:17:00	2	27000.00	hcastanaga1j@fda.gov	25	87520960388	P0000192
V0000462  	2016-08-13	2016-08-16 09:10:00	2	152000.00	dreefe@springer.com	150	88639326822	P0000125
V0000463  	2016-01-14	\N	1	12000.00	vgissing12@google.fr	10	81227712578	P0000163
V0000464  	2016-08-31	2016-09-02 00:52:00	2	152000.00	sricardin6s@furl.net	150	85794978063	P000076 
V0000465  	2016-04-03	2016-04-06 20:31:00	2	52000.00	apacher3h@etsy.com	50	82319153350	P0000123
V0000466  	2016-10-30	2016-11-03 16:53:00	2	202000.00	paskem3o@yale.edu	200	87276472964	P0000182
V0000467  	2016-07-31	\N	1	12000.00	sbellward3z@google.com	10	87323309025	P000044 
V0000468  	2016-07-04	\N	1	52000.00	tblackway61@51.la	50	89041936071	P0000130
V0000469  	2017-02-08	2017-02-12 09:01:00	2	102000.00	rexley26@barnesandnoble.com	100	85504321184	P0000194
V0000470  	2016-06-24	2016-06-28 16:42:00	2	27000.00	jhaggerstone6n@cisco.com	25	86702997346	P000059 
V0000471  	2016-11-20	2016-11-23 02:58:00	2	7000.00	rhouldey3d@latimes.com	5	83681512921	P0000134
V0000472  	2016-03-20	2016-03-24 14:56:00	2	12000.00	mmcfadden5x@live.com	10	87507423479	P0000114
V0000473  	2016-11-09	\N	1	27000.00	cleet1r@infoseek.co.jp	25	88278772478	P0000136
V0000474  	2017-03-12	\N	1	12000.00	kmiddlemiss6e@umn.edu	10	84351860045	P0000121
V0000475  	2016-07-06	\N	1	12000.00	erihanek66@surveymonkey.com	10	81089491133	P000079 
V0000476  	2017-01-31	\N	1	202000.00	vcarlton4x@jimdo.com	200	88221014231	P000077 
V0000477  	2016-02-02	2016-02-06 07:26:00	2	27000.00	mpowney2s@over-blog.com	25	84894394013	P0000122
V0000478  	2016-09-10	\N	1	52000.00	zbaybutt6w@cafepress.com	50	88056138111	P000053 
V0000479  	2016-02-24	\N	1	102000.00	forudden6m@webeden.co.uk	100	80931190037	P000096 
V0000480  	2016-09-27	\N	1	102000.00	svezey6j@va.gov	100	81232581509	P0000138
V0000481  	2017-03-11	2017-03-13 06:32:00	2	102000.00	gtofanon@ustream.tv	100	81614595122	P0000110
V0000482  	2017-03-07	2017-03-10 01:32:00	2	7000.00	cvigars47@irs.gov	5	88291429923	P0000134
V0000483  	2016-08-30	\N	1	27000.00	yseago4v@geocities.com	25	85584668453	P0000101
V0000484  	2016-04-11	\N	1	102000.00	sokeenan23@csmonitor.com	100	83907368770	P0000110
V0000485  	2016-04-10	\N	1	102000.00	nwemm2e@meetup.com	100	83747569638	P0000117
V0000486  	2016-07-21	2016-07-25 09:40:00	2	52000.00	mradsdale1u@imdb.com	50	83925735059	P0000172
V0000487  	2016-08-08	2016-08-12 19:43:00	2	202000.00	mquittonden51@acquirethisname.com	200	86972171639	P0000119
V0000488  	2016-05-21	2016-05-23 06:11:00	2	27000.00	smeachen33@chronoengine.com	25	87992464342	P0000178
V0000489  	2017-04-18	2017-04-22 01:03:00	2	202000.00	cvigars47@irs.gov	200	88291429923	P0000168
V0000490  	2016-08-01	\N	1	27000.00	lkobpac5u@nih.gov	25	82736262829	P0000157
V0000491  	2016-04-13	\N	1	152000.00	dbeagin5d@barnesandnoble.com	150	82407112188	P0000139
V0000492  	2016-11-14	\N	1	52000.00	erihanek66@surveymonkey.com	50	81089491133	P0000172
V0000493  	2016-06-30	\N	1	52000.00	hjonathon1t@google.ca	50	80590818388	P000025 
V0000494  	2016-01-28	\N	1	12000.00	ghurleston45@netlog.com	10	82154487163	P0000107
V0000495  	2016-04-24	2016-04-28 03:58:00	2	202000.00	stither4h@google.ru	200	87640579752	P000056 
V0000496  	2016-04-12	\N	1	202000.00	evinas1f@stanford.edu	200	83507186620	P0000147
V0000497  	2017-02-27	2017-03-03 09:58:00	2	7000.00	bstukings1o@elpais.com	5	85429551531	P000036 
V0000498  	2016-01-20	\N	1	12000.00	tjohnsson35@gizmodo.com	10	82503556797	P000079 
V0000499  	2016-08-02	2016-08-05 22:30:00	2	52000.00	bbryant56@bbc.co.uk	50	88886565255	P0000123
V0000500  	2016-10-29	\N	1	52000.00	csiegertsz2j@columbia.edu	50	82387894828	P000088 
V0000501  	2017-01-16	\N	1	7000.00	awinchurst5v@cloudflare.com	5	80762142879	P0000148
V0000502  	2016-11-17	\N	1	52000.00	rreeson1y@cnet.com	50	80474700107	P0000151
V0000503  	2016-11-16	\N	1	152000.00	agrimestone5s@jimdo.com	150	84943331218	P0000139
V0000504  	2016-06-14	\N	1	52000.00	vcarlton4x@jimdo.com	50	88221014231	P0000193
V0000505  	2016-07-03	2016-07-06 18:06:00	2	7000.00	msteggals6q@ox.ac.uk	5	80200637897	P000043 
V0000506  	2017-02-11	2017-02-13 23:04:00	2	7000.00	cdrysdale4z@dell.com	5	83852348392	P0000162
V0000507  	2016-11-21	2016-11-25 09:55:00	2	102000.00	nrentoll4q@nytimes.com	100	89382029723	P0000159
V0000508  	2016-12-02	2016-12-05 15:51:00	2	52000.00	pgrollmann1k@posterous.com	50	81306220495	P0000144
V0000509  	2016-05-25	\N	1	12000.00	mquittonden51@acquirethisname.com	10	86972171639	P0000198
V0000510  	2016-11-25	\N	1	52000.00	fportinari2r@cdc.gov	50	82745997636	P0000165
V0000511  	2016-10-09	2016-10-11 01:16:00	2	12000.00	epotte5n@redcross.org	10	87954524225	P0000128
V0000512  	2016-12-13	2016-12-16 19:33:00	2	202000.00	wfullylovep@aboutads.info	200	85353879685	P0000161
V0000513  	2016-04-09	2016-04-13 03:10:00	2	152000.00	bcradick3t@squidoo.com	150	80814514094	P000062 
V0000514  	2016-02-06	\N	1	52000.00	zbaybutt6w@cafepress.com	50	88056138111	P0000179
V0000515  	2017-04-20	\N	1	202000.00	rosesnanes@nationalgeographic.com	200	87738354516	P0000189
V0000516  	2016-02-19	2016-02-21 08:13:00	2	202000.00	amardling6@typepad.com	200	86572794970	P0000161
V0000517  	2016-08-17	2016-08-20 00:43:00	2	102000.00	uguiducci43@istockphoto.com	100	84184962206	P000040 
V0000518  	2017-01-26	2017-01-29 11:43:00	2	27000.00	ldoore32@loc.gov	25	84838437697	P0000150
V0000519  	2016-10-03	\N	1	7000.00	lehrat55@spiegel.de	5	83601865364	P0000127
V0000520  	2017-02-19	2017-02-22 13:39:00	2	52000.00	vgissing12@google.fr	50	81227712578	P000095 
V0000521  	2017-04-13	\N	1	202000.00	mpietasch5y@nsw.gov.au	200	82903944658	P00007  
V0000522  	2017-02-13	2017-02-17 13:23:00	2	152000.00	lbarbrookm@google.co.uk	150	89877161121	P0000174
V0000523  	2016-09-13	2016-09-15 23:22:00	2	202000.00	castlesa@paginegialle.it	200	86601207900	P0000182
V0000524  	2017-04-02	2017-04-04 17:26:00	2	152000.00	lmaunders4y@google.ca	150	89181257664	P0000125
V0000525  	2016-05-21	2016-05-23 05:49:00	2	12000.00	sbwy1x@xing.com	10	83794238715	P000079 
V0000526  	2016-12-11	2016-12-15 11:05:00	2	102000.00	kdibdale5q@bandcamp.com	100	83881473500	P00005  
V0000527  	2016-05-22	2016-05-25 22:25:00	2	152000.00	mmobley2o@mac.com	150	87872548490	P000041 
V0000528  	2016-12-25	\N	1	12000.00	tjohnsson35@gizmodo.com	10	82503556797	P0000156
V0000529  	2016-10-30	2016-11-02 21:00:00	2	202000.00	sokeenan23@csmonitor.com	200	83907368770	P000014 
V0000530  	2017-04-13	\N	1	12000.00	mgarric5@amazon.de	10	85833193950	P0000100
V0000531  	2016-06-28	2016-06-30 19:07:00	2	52000.00	cchastenet44@jiathis.com	50	81734887156	P000088 
V0000532  	2017-04-04	2017-04-07 13:38:00	2	102000.00	vhabbeshawh@ifeng.com	100	85010568675	P0000159
V0000533  	2017-03-28	2017-03-31 03:15:00	2	27000.00	lkobpac5u@nih.gov	25	82736262829	P000017 
V0000534  	2016-12-18	2016-12-20 19:11:00	2	52000.00	jdinesen2y@vimeo.com	50	83915236091	P000046 
V0000535  	2016-02-09	2016-02-13 23:47:00	2	202000.00	gtofanon@ustream.tv	200	81614595122	P0000133
V0000536  	2016-08-22	2016-08-24 10:31:00	2	52000.00	vcarlton4x@jimdo.com	50	88221014231	P0000123
V0000537  	2016-01-07	2016-01-09 02:50:00	2	12000.00	fdarrington6i@unblog.fr	10	80190617622	P000079 
V0000538  	2016-08-29	2016-09-02 19:33:00	2	12000.00	rhouldey3d@latimes.com	10	83681512921	P000065 
V0000539  	2016-08-06	2016-08-10 17:31:00	2	202000.00	ldoram48@xrea.com	200	88849409298	P0000147
V0000540  	2016-04-18	\N	1	7000.00	kjuorio31@t.co	5	87715602216	P000071 
V0000541  	2016-04-07	2016-04-11 05:07:00	2	102000.00	md3c@about.com	100	80139828915	P000089 
V0000542  	2016-05-18	2016-05-22 12:09:00	2	102000.00	istreeton2u@yellowbook.com	100	80656377820	P0000124
V0000543  	2017-04-01	2017-04-04 02:58:00	2	152000.00	ireadhead3k@is.gd	150	89268549631	P000027 
V0000544  	2016-04-17	\N	1	52000.00	sricardin6s@furl.net	50	85794978063	P000088 
V0000545  	2016-08-24	\N	1	52000.00	hbeloe1z@freewebs.com	50	84537215061	P000011 
V0000546  	2017-01-06	\N	1	52000.00	claraway1l@parallels.com	50	85029220527	P000046 
V0000547  	2016-08-14	\N	1	202000.00	fburkman2b@twitpic.com	200	88060310279	P0000147
V0000548  	2016-07-03	2016-07-05 02:29:00	2	202000.00	lfendleyc@amazon.co.uk	200	86030943634	P000063 
V0000549  	2016-11-25	\N	1	27000.00	ffarncombe5h@theguardian.com	25	88300445379	P000017 
V0000550  	2016-05-31	2016-06-02 10:19:00	2	52000.00	rdametti2x@narod.ru	50	83663483463	P0000130
V0000551  	2016-11-09	2016-11-13 10:33:00	2	202000.00	ccheale1p@bbc.co.uk	200	86362735784	P000042 
V0000552  	2016-04-28	2016-04-30 06:24:00	2	7000.00	jalenshev3l@sciencedaily.com	5	84367350311	P000029 
V0000553  	2017-03-24	2017-03-27 06:46:00	2	12000.00	ebridgwoodb@fotki.com	10	84914571715	P000072 
V0000554  	2016-07-24	\N	1	102000.00	ryedall62@arizona.edu	100	84184083560	P0000138
V0000555  	2016-02-19	2016-02-23 12:32:00	2	202000.00	astandell6g@washington.edu	200	88204822346	P000070 
V0000556  	2016-08-26	2016-08-29 04:52:00	2	102000.00	adwelly3u@pen.io	100	89480370270	P000019 
V0000557  	2016-01-20	2016-01-22 10:59:00	2	52000.00	rharcarse54@buzzfeed.com	50	85363513496	P0000102
V0000558  	2016-05-26	2016-05-28 19:46:00	2	7000.00	rosesnanes@nationalgeographic.com	5	87738354516	P0000141
V0000559  	2017-04-01	2017-04-04 20:56:00	2	12000.00	gtaggett5t@over-blog.com	10	88620140001	P000016 
V0000560  	2016-07-27	\N	1	12000.00	ghurleston45@netlog.com	10	82154487163	P000093 
V0000561  	2016-02-14	2016-02-18 12:35:00	2	12000.00	twormleightonk@dagondesign.com	10	89803625389	P0000191
V0000562  	2017-03-08	\N	1	202000.00	gtaggett5t@over-blog.com	200	88620140001	P000056 
V0000563  	2017-02-17	\N	1	102000.00	mmcgarvey6d@yellowbook.com	100	85543170838	P000096 
V0000564  	2016-05-17	2016-05-21 03:02:00	2	7000.00	hborn8@sakura.ne.jp	5	88495578938	P00001  
V0000565  	2016-11-18	\N	1	152000.00	gpickervancew@va.gov	150	89495105576	P000062 
V0000566  	2016-08-08	2016-08-10 04:54:00	2	12000.00	cbrumen4a@skype.com	10	87202747523	P000086 
V0000567  	2016-06-23	\N	1	102000.00	jjeffcoat5e@npr.org	100	87068389940	P000026 
V0000568  	2016-04-23	2016-04-25 20:09:00	2	52000.00	wzanini2t@yahoo.co.jp	50	83613145333	P0000172
V0000569  	2017-03-05	2017-03-08 00:56:00	2	12000.00	abinnes6o@pcworld.com	10	84313290763	P0000121
V0000570  	2016-05-17	\N	1	202000.00	ccheale1p@bbc.co.uk	200	86362735784	P000042 
V0000571  	2016-04-26	\N	1	202000.00	ao4u@posterous.com	200	86837747059	P000021 
V0000572  	2016-02-27	2016-02-29 03:18:00	2	27000.00	csaladine6a@businesswire.com	25	87630360279	P000073 
V0000573  	2017-03-14	2017-03-16 09:44:00	2	52000.00	pmccague6r@a8.net	50	88066108729	P0000123
V0000574  	2016-08-10	2016-08-13 21:42:00	2	52000.00	paskem3o@yale.edu	50	87276472964	P000074 
V0000575  	2016-03-01	2016-03-04 23:37:00	2	27000.00	ireadhead3k@is.gd	25	89268549631	P0000171
V0000576  	2017-04-07	\N	1	152000.00	mcollyns46@1und1.de	150	85078664484	P0000111
V0000577  	2016-04-14	2016-04-17 18:17:00	2	102000.00	lcrichley19@noaa.gov	100	84464299383	P0000180
V0000578  	2016-10-22	2016-10-26 07:46:00	2	12000.00	bcradick3t@squidoo.com	10	80814514094	P000065 
V0000579  	2017-03-01	\N	1	202000.00	lcrichley19@noaa.gov	200	84464299383	P0000133
V0000580  	2016-09-08	2016-09-10 18:05:00	2	12000.00	drojel5k@merriam-webster.com	10	83819654832	P0000128
V0000581  	2016-08-20	2016-08-23 15:54:00	2	202000.00	mkeays6h@posterous.com	200	83800668752	P000042 
V0000582  	2016-01-23	\N	1	102000.00	dcaulfield2q@dmoz.org	100	81060631865	P000096 
V0000583  	2016-04-29	\N	1	27000.00	cchastenet44@jiathis.com	25	81734887156	P000094 
V0000584  	2016-03-23	\N	1	27000.00	rpigott17@vimeo.com	25	83838217143	P0000136
V0000585  	2016-03-12	\N	1	102000.00	ebridgwoodb@fotki.com	100	84914571715	P000096 
V0000586  	2017-03-02	2017-03-06 22:48:00	2	12000.00	wnotman6v@istockphoto.com	10	89798087339	P000093 
V0000587  	2016-04-26	2016-04-30 10:32:00	2	7000.00	kkilmister3q@indiatimes.com	5	85918952542	P0000162
V0000588  	2016-05-30	2016-06-02 14:33:00	2	27000.00	dbasire4n@nasa.gov	25	86999471286	P0000157
V0000589  	2016-01-22	2016-01-26 01:10:00	2	152000.00	epotte5n@redcross.org	150	87954524225	P000027 
V0000590  	2016-11-03	\N	1	152000.00	hluney5c@bloglovin.com	150	85261212980	P000076 
V0000591  	2016-11-30	2016-12-03 05:47:00	2	12000.00	mkeays6h@posterous.com	10	83800668752	P000093 
V0000592  	2017-01-27	2017-01-30 22:20:00	2	102000.00	vcarlton4x@jimdo.com	100	88221014231	P000089 
V0000593  	2017-02-23	\N	1	52000.00	lgreenig18@loc.gov	50	85465927388	P0000102
V0000594  	2016-07-30	2016-08-01 00:13:00	2	52000.00	sokeenan23@csmonitor.com	50	83907368770	P00004  
V0000595  	2016-10-28	2016-11-01 05:36:00	2	27000.00	bambersonv@wp.com	25	81561652227	P0000178
V0000596  	2016-10-30	2016-11-02 21:30:00	2	12000.00	lcrichley19@noaa.gov	10	84464299383	P0000135
V0000597  	2016-10-31	2016-11-04 18:01:00	2	27000.00	nwemm2e@meetup.com	25	83747569638	P0000150
V0000598  	2016-07-19	\N	1	202000.00	evinas1f@stanford.edu	200	83507186620	P0000126
V0000599  	2016-11-25	2016-11-29 16:58:00	2	152000.00	mquittonden51@acquirethisname.com	150	86972171639	P0000132
V0000600  	2017-04-18	\N	1	52000.00	rpitwayj@elegantthemes.com	50	89953982487	P000067 
V0000601  	2016-05-04	\N	1	52000.00	tblackway61@51.la	50	89041936071	P000032 
V0000602  	2016-01-21	2016-01-23 20:55:00	2	12000.00	wzanini2t@yahoo.co.jp	10	83613145333	P00009  
V0000603  	2016-12-20	2016-12-23 01:07:00	2	102000.00	tadame4c@alexa.com	100	83954809255	P0000187
V0000604  	2016-10-13	2016-10-16 17:47:00	2	202000.00	dcaulfield2q@dmoz.org	200	81060631865	P0000126
V0000605  	2016-03-22	2016-03-25 00:38:00	2	202000.00	gjanning3@opensource.org	200	80295257279	P0000147
V0000606  	2016-12-30	2017-01-01 00:23:00	2	7000.00	sde3b@trellian.com	5	80046759658	P00008  
V0000607  	2016-10-07	2016-10-09 05:17:00	2	12000.00	tblackway61@51.la	10	89041936071	P0000114
V0000608  	2017-03-31	2017-04-03 06:40:00	2	52000.00	egiles42@sitemeter.com	50	86087726649	P0000123
V0000609  	2017-02-04	2017-02-07 03:09:00	2	52000.00	kantoniat5b@hc360.com	50	80488355075	P000067 
V0000610  	2016-01-27	\N	1	52000.00	ffarncombe5h@theguardian.com	50	88300445379	P0000109
V0000611  	2017-04-17	2017-04-19 11:07:00	2	12000.00	jsedgeman20@sourceforge.net	10	89119013144	P000093 
V0000612  	2016-06-05	\N	1	12000.00	lbottom1b@blinklist.com	10	84235158040	P0000107
V0000613  	2016-11-30	2016-12-03 03:14:00	2	102000.00	bstukings1o@elpais.com	100	85429551531	P0000173
V0000614  	2016-01-07	\N	1	102000.00	hduffieldy@bloglovin.com	100	87798981982	P0000187
V0000615  	2017-02-05	\N	1	27000.00	owoolliams1w@unc.edu	25	80245678981	P000010 
V0000616  	2016-01-20	2016-01-24 09:45:00	2	202000.00	ehegley25@seattletimes.com	200	82575144612	P000049 
V0000617  	2017-01-24	2017-01-27 15:35:00	2	7000.00	nrentoll4q@nytimes.com	5	89382029723	P000036 
V0000618  	2016-02-05	2016-02-08 06:18:00	2	202000.00	cabby4b@cyberchimps.com	200	88272662800	P000021 
V0000619  	2016-11-22	2016-11-26 23:39:00	2	12000.00	bweaver4f@ebay.com	10	83831936485	P0000198
V0000620  	2016-05-18	2016-05-21 14:22:00	2	152000.00	lfalkner2i@cpanel.net	150	80575460432	P0000118
V0000621  	2016-08-25	2016-08-27 08:14:00	2	52000.00	twormleightonk@dagondesign.com	50	89803625389	P000074 
V0000622  	2016-07-18	\N	1	7000.00	pshillington1m@usda.gov	5	86810560738	P0000176
V0000623  	2016-06-29	2016-07-01 18:24:00	2	27000.00	gkristoffersen63@businesswire.com	25	89465850478	P000038 
V0000624  	2016-09-03	2016-09-07 06:24:00	2	102000.00	ahaverson3v@columbia.edu	100	82552305939	P0000117
V0000625  	2017-02-05	2017-02-09 17:35:00	2	202000.00	rbuxey5o@scientificamerican.com	200	89036678774	P000021 
V0000626  	2016-07-08	\N	1	52000.00	msaltsberger69@hud.gov	50	86693577153	P000053 
V0000627  	2016-09-12	2016-09-15 17:18:00	2	7000.00	mkeays6h@posterous.com	5	83800668752	P0000134
V0000628  	2016-04-09	2016-04-12 23:00:00	2	102000.00	tadame4c@alexa.com	100	83954809255	P000075 
V0000629  	2016-03-03	\N	1	12000.00	lehrat55@spiegel.de	10	83601865364	P000058 
V0000630  	2017-01-23	2017-01-27 16:29:00	2	27000.00	hlinklet1a@answers.com	25	83809332578	P000031 
V0000631  	2016-09-10	2016-09-12 02:57:00	2	52000.00	ehegley25@seattletimes.com	50	82575144612	P000067 
V0000632  	2016-12-22	\N	1	202000.00	mcrichmer58@mac.com	200	84632469306	P0000133
V0000633  	2017-01-06	2017-01-08 04:50:00	2	27000.00	jradage2l@blogtalkradio.com	25	83776072823	P0000178
V0000634  	2016-08-14	\N	1	12000.00	fmasic1h@prweb.com	10	87680100452	P0000107
V0000635  	2016-09-16	2016-09-20 10:03:00	2	27000.00	cseamans2c@indiatimes.com	25	89112010278	P0000143
V0000636  	2016-07-02	\N	1	27000.00	lbarbrookm@google.co.uk	25	89877161121	P0000143
V0000637  	2016-07-28	2016-08-01 22:39:00	2	152000.00	wfullylovep@aboutads.info	150	85353879685	P000048 
V0000638  	2017-03-20	2017-03-24 02:19:00	2	52000.00	pshillington1m@usda.gov	50	86810560738	P000032 
V0000639  	2017-04-22	2017-04-24 11:05:00	2	102000.00	kviles24@1688.com	100	84860494017	P000047 
V0000640  	2016-01-07	2016-01-09 16:15:00	2	27000.00	kde3g@ebay.co.uk	25	86375130638	P000066 
V0000641  	2017-04-02	\N	1	27000.00	bweaver4f@ebay.com	25	83831936485	P00003  
V0000642  	2016-09-11	2016-09-13 11:00:00	2	12000.00	yseago4v@geocities.com	10	85584668453	P000086 
V0000643  	2016-12-04	\N	1	102000.00	lbambrick2p@sfgate.com	100	85947800537	P000089 
V0000644  	2016-02-13	\N	1	202000.00	cabby4b@cyberchimps.com	200	88272662800	P000021 
V0000645  	2016-03-21	2016-03-23 18:30:00	2	12000.00	pshillington1m@usda.gov	10	86810560738	P000023 
V0000646  	2016-02-22	2016-02-24 19:44:00	2	102000.00	zbaybutt6w@cafepress.com	100	88056138111	P0000131
V0000647  	2016-05-02	2016-05-04 06:53:00	2	12000.00	hbeloe1z@freewebs.com	10	84537215061	P0000163
V0000648  	2016-01-19	\N	1	27000.00	sbellward3z@google.com	25	87323309025	P0000185
V0000649  	2016-04-01	2016-04-05 04:35:00	2	7000.00	bfalshaw2@about.me	5	89250859186	P0000141
V0000650  	2017-03-07	2017-03-11 14:42:00	2	152000.00	owoolliams1w@unc.edu	150	80245678981	P000034 
V0000651  	2016-09-21	2016-09-23 08:11:00	2	7000.00	dhurne4@nydailynews.com	5	81852887905	P000078 
V0000652  	2016-02-25	2016-02-28 20:24:00	2	7000.00	nrodda11@hibu.com	5	81252302661	P0000134
V0000653  	2016-09-16	\N	1	27000.00	lgreenig18@loc.gov	25	85465927388	P000066 
V0000654  	2016-09-20	2016-09-24 02:22:00	2	52000.00	nverlinde5l@globo.com	50	81444357145	P0000158
V0000655  	2016-08-08	\N	1	12000.00	bambersonv@wp.com	10	81561652227	P0000198
V0000656  	2017-01-04	2017-01-07 23:20:00	2	202000.00	smeachen33@chronoengine.com	200	87992464342	P000056 
V0000657  	2016-10-20	2016-10-23 03:44:00	2	12000.00	zheaton29@va.gov	10	84560686482	P000093 
V0000658  	2017-04-08	2017-04-10 20:04:00	2	152000.00	fdarrington6i@unblog.fr	150	80190617622	P0000104
V0000659  	2016-06-10	2016-06-13 08:11:00	2	202000.00	erihanek66@surveymonkey.com	200	81089491133	P000084 
V0000660  	2016-07-25	\N	1	102000.00	cseamans2c@indiatimes.com	100	89112010278	P000033 
V0000661  	2016-08-20	2016-08-22 01:36:00	2	202000.00	sdufer57@yellowbook.com	200	82160710840	P000021 
V0000662  	2016-03-11	2016-03-13 08:06:00	2	102000.00	dcaulfield2q@dmoz.org	100	81060631865	P000019 
V0000663  	2016-12-06	\N	1	202000.00	mmcfadden5x@live.com	200	87507423479	P0000154
V0000664  	2016-01-13	\N	1	152000.00	wnotman6v@istockphoto.com	150	89798087339	P0000167
V0000665  	2016-11-18	\N	1	27000.00	rdidball53@webs.com	25	80705469249	P000066 
V0000666  	2016-12-01	\N	1	52000.00	ebewfield1e@icio.us	50	89368096947	P0000151
V0000667  	2017-01-11	2017-01-15 22:36:00	2	52000.00	stither4h@google.ru	50	87640579752	P000088 
V0000668  	2016-04-01	2016-04-03 17:00:00	2	52000.00	olindeboom6x@adobe.com	50	87901515196	P000046 
V0000669  	2016-11-29	\N	1	52000.00	lkobpac5u@nih.gov	50	82736262829	P000088 
V0000670  	2016-12-01	2016-12-05 02:44:00	2	152000.00	ptesh5a@salon.com	150	88863667126	P000090 
V0000671  	2016-10-15	2016-10-18 14:17:00	2	12000.00	dreefe@springer.com	10	88639326822	P000044 
V0000672  	2016-02-26	2016-02-28 01:10:00	2	102000.00	dbasire4n@nasa.gov	100	86999471286	P0000110
V0000673  	2016-03-11	2016-03-14 05:24:00	2	152000.00	fburkman2b@twitpic.com	150	88060310279	P0000132
V0000674  	2016-06-19	2016-06-21 08:16:00	2	202000.00	lehrat55@spiegel.de	200	83601865364	P000035 
V0000675  	2016-10-13	2016-10-15 00:09:00	2	12000.00	snavein2h@yolasite.com	10	83304827407	P0000142
V0000676  	2016-05-13	\N	1	52000.00	jguice6f@cyberchimps.com	50	88825342280	P000053 
V0000677  	2016-02-14	2016-02-16 08:12:00	2	52000.00	pnursey4r@myspace.com	50	81451543579	P000011 
V0000678  	2016-03-04	2016-03-08 14:31:00	2	52000.00	jsedgeman20@sourceforge.net	50	89119013144	P000067 
V0000679  	2016-07-05	2016-07-07 23:59:00	2	102000.00	fburkman2b@twitpic.com	100	88060310279	P000026 
V0000680  	2016-06-12	2016-06-16 04:28:00	2	152000.00	hduffieldy@bloglovin.com	150	87798981982	P0000153
V0000681  	2017-03-10	2017-03-14 02:28:00	2	152000.00	kviles24@1688.com	150	84860494017	P000062 
V0000682  	2016-12-16	\N	1	7000.00	elamcken27@hud.gov	5	80081938955	P0000162
V0000683  	2016-10-02	2016-10-06 07:13:00	2	27000.00	agatrell49@slate.com	25	82135809166	P0000199
V0000684  	2016-04-24	2016-04-26 20:42:00	2	152000.00	lgreenig18@loc.gov	150	85465927388	P000034 
V0000685  	2016-02-08	2016-02-11 23:55:00	2	102000.00	smeachen33@chronoengine.com	100	87992464342	P0000110
V0000686  	2017-01-17	\N	1	7000.00	adortonl@nytimes.com	5	89629864550	P000043 
V0000687  	2016-01-11	\N	1	202000.00	nleither16@google.it	200	81287534952	P000070 
V0000688  	2016-04-30	\N	1	12000.00	egiles42@sitemeter.com	10	86087726649	P0000198
V0000689  	2016-01-31	\N	1	27000.00	apacher3h@etsy.com	25	82319153350	P000017 
V0000690  	2017-04-08	2017-04-10 15:11:00	2	27000.00	mmcgarvey6d@yellowbook.com	25	85543170838	P000080 
V0000691  	2016-02-23	2016-02-26 23:15:00	2	52000.00	cnewling64@hc360.com	50	89159608191	P000060 
V0000692  	2016-05-25	2016-05-29 12:56:00	2	102000.00	gberthouloume4w@delicious.com	100	88995977500	P0000187
V0000693  	2016-09-22	2016-09-26 11:52:00	2	27000.00	claraway1l@parallels.com	25	85029220527	P0000199
V0000694  	2017-01-03	\N	1	27000.00	kbreukelman39@dot.gov	25	88560595824	P0000171
V0000695  	2016-03-15	2016-03-17 21:51:00	2	52000.00	dbasire4n@nasa.gov	50	86999471286	P0000130
V0000696  	2016-02-19	2016-02-23 10:23:00	2	7000.00	sgrigollig@weather.com	5	82047655814	P0000106
V0000697  	2017-02-27	\N	1	52000.00	tblackway61@51.la	50	89041936071	P0000102
V0000698  	2016-07-11	2016-07-15 18:34:00	2	102000.00	cbakhrushint@reddit.com	100	86370364042	P000047 
V0000699  	2016-04-23	\N	1	102000.00	mepinoyu@51.la	100	82993669800	P0000187
V0000700  	2017-03-16	2017-03-19 09:10:00	2	12000.00	rexley26@barnesandnoble.com	10	85504321184	P0000198
V0000701  	2016-04-26	2016-04-30 22:32:00	2	202000.00	mmobley2o@mac.com	200	87872548490	P000091 
V0000702  	2016-06-15	2016-06-18 22:33:00	2	12000.00	mmasserel1g@epa.gov	10	88184601779	P000058 
V0000703  	2016-02-23	2016-02-27 02:51:00	2	202000.00	sricardin6s@furl.net	200	85794978063	P000084 
V0000704  	2016-08-24	\N	1	27000.00	jhaggerstone6n@cisco.com	25	86702997346	P000024 
V0000705  	2016-09-12	2016-09-15 23:51:00	2	102000.00	lcrichley19@noaa.gov	100	84464299383	P0000194
V0000706  	2016-03-07	\N	1	102000.00	jwheelwright6u@i2i.jp	100	82488436035	P000075 
V0000707  	2016-02-27	2016-02-29 16:03:00	2	102000.00	fburkman2b@twitpic.com	100	88060310279	P000047 
V0000708  	2017-04-04	2017-04-07 05:09:00	2	7000.00	rosesnanes@nationalgeographic.com	5	87738354516	P000078 
V0000709  	2016-03-11	2016-03-13 07:44:00	2	7000.00	cvigars47@irs.gov	5	88291429923	P0000134
V0000710  	2016-11-18	\N	1	12000.00	lmaunders4y@google.ca	10	89181257664	P0000135
V0000711  	2016-05-28	2016-06-01 07:41:00	2	52000.00	ldoram48@xrea.com	50	88849409298	P0000200
V0000712  	2016-02-26	2016-03-01 22:51:00	2	12000.00	scoppo50@facebook.com	10	80483717929	P000065 
V0000713  	2016-02-27	\N	1	7000.00	bbryant56@bbc.co.uk	5	88886565255	P0000141
V0000714  	2016-07-10	\N	1	102000.00	gjanning3@opensource.org	100	80295257279	P000096 
V0000715  	2016-01-01	2016-01-05 05:47:00	2	152000.00	sde3b@trellian.com	150	80046759658	P000048 
V0000716  	2016-12-08	2016-12-10 16:44:00	2	152000.00	amardling6@typepad.com	150	86572794970	P000041 
V0000717  	2016-03-14	\N	1	52000.00	hcastanaga1j@fda.gov	50	87520960388	P0000109
V0000718  	2017-03-30	\N	1	27000.00	djentle13@live.com	25	88328345551	P0000178
V0000719  	2016-09-21	2016-09-25 02:42:00	2	52000.00	medgell65@arizona.edu	50	85523555260	P000053 
V0000720  	2016-04-24	\N	1	27000.00	erihanek66@surveymonkey.com	25	81089491133	P000094 
V0000721  	2016-03-19	2016-03-22 11:55:00	2	7000.00	rosesnanes@nationalgeographic.com	5	87738354516	P0000162
V0000722  	2016-02-29	\N	1	7000.00	claraway1l@parallels.com	5	85029220527	P000022 
V0000723  	2016-09-19	\N	1	27000.00	rharcarse54@buzzfeed.com	25	85363513496	P000059 
V0000724  	2017-02-10	\N	1	27000.00	msteggals6q@ox.ac.uk	25	80200637897	P0000164
V0000725  	2017-02-13	\N	1	152000.00	klind1n@diigo.com	150	81938323903	P000013 
V0000726  	2017-04-21	\N	1	27000.00	ldoore32@loc.gov	25	84838437697	P000080 
V0000727  	2016-06-21	\N	1	102000.00	mquittonden51@acquirethisname.com	100	86972171639	P000019 
V0000728  	2016-05-28	2016-06-01 03:39:00	2	27000.00	leason6p@wufoo.com	25	86042741789	P0000143
V0000729  	2016-08-27	\N	1	152000.00	mpattison1d@spotify.com	150	80446590793	P00006  
V0000730  	2016-07-22	2016-07-26 19:10:00	2	152000.00	lcrichley19@noaa.gov	150	84464299383	P000055 
V0000731  	2016-03-10	2016-03-14 09:19:00	2	102000.00	erihanek66@surveymonkey.com	100	81089491133	P0000117
V0000732  	2016-07-10	2016-07-12 13:29:00	2	7000.00	jalenshev3l@sciencedaily.com	5	84367350311	P000057 
V0000733  	2016-08-18	2016-08-22 12:28:00	2	152000.00	ntye6t@dyndns.org	150	88567457252	P0000132
V0000734  	2017-01-06	2017-01-08 06:42:00	2	202000.00	astandell6g@washington.edu	200	88204822346	P000028 
V0000735  	2017-04-02	2017-04-05 06:21:00	2	152000.00	svezey6j@va.gov	150	81232581509	P0000188
V0000736  	2016-02-11	2016-02-15 03:50:00	2	152000.00	cnewling64@hc360.com	150	89159608191	P000055 
V0000737  	2017-01-03	2017-01-05 21:04:00	2	202000.00	ebridgwoodb@fotki.com	200	84914571715	P000049 
V0000738  	2017-04-17	2017-04-19 05:24:00	2	7000.00	hduffieldy@bloglovin.com	5	87798981982	P0000183
V0000739  	2017-02-10	2017-02-12 04:47:00	2	202000.00	drojel5k@merriam-webster.com	200	83819654832	P0000119
V0000740  	2017-01-30	\N	1	12000.00	cleet1r@infoseek.co.jp	10	88278772478	P0000163
V0000741  	2017-01-03	2017-01-05 23:16:00	2	202000.00	pmccague6r@a8.net	200	88066108729	P00007  
V0000742  	2017-01-01	2017-01-04 08:48:00	2	7000.00	fdarrington6i@unblog.fr	5	80190617622	P000036 
V0000743  	2016-01-11	\N	1	52000.00	mkleen21@tumblr.com	50	85032027714	P000060 
V0000744  	2017-03-02	\N	1	52000.00	pmccague6r@a8.net	50	88066108729	P000081 
V0000745  	2017-01-10	\N	1	12000.00	adwelly3u@pen.io	10	89480370270	P0000156
V0000746  	2016-06-06	2016-06-08 00:46:00	2	152000.00	rreeson1y@cnet.com	150	80474700107	P000083 
V0000747  	2017-04-01	\N	1	52000.00	hborn8@sakura.ne.jp	50	88495578938	P000032 
V0000748  	2016-08-25	2016-08-27 04:17:00	2	52000.00	zbaybutt6w@cafepress.com	50	88056138111	P000074 
V0000749  	2016-12-24	\N	1	152000.00	snavein2h@yolasite.com	150	83304827407	P000041 
V0000750  	2016-09-21	2016-09-23 11:54:00	2	52000.00	glarmett22@reuters.com	50	80647660331	P000032 
V0000751  	2017-04-25	2017-04-27 12:49:00	2	52000.00	castlesa@paginegialle.it	50	86601207900	P000074 
V0000752  	2016-11-01	2016-11-03 04:04:00	2	7000.00	sokeenan23@csmonitor.com	5	83907368770	P0000134
V0000753  	2016-07-22	\N	1	52000.00	mvern3p@godaddy.com	50	87541311996	P0000200
V0000754  	2017-03-27	2017-03-31 16:41:00	2	202000.00	csiegertsz2j@columbia.edu	200	82387894828	P000014 
V0000755  	2016-12-18	2016-12-22 10:14:00	2	152000.00	klind1n@diigo.com	150	81938323903	P00006  
V0000756  	2016-01-11	2016-01-13 08:17:00	2	12000.00	gjanning3@opensource.org	10	80295257279	P000058 
V0000757  	2016-11-19	2016-11-23 06:20:00	2	202000.00	ebridgwoodb@fotki.com	200	84914571715	P000084 
V0000758  	2017-01-21	2017-01-25 21:39:00	2	102000.00	gtackell68@rambler.ru	100	88065222290	P0000138
V0000759  	2016-06-08	2016-06-12 00:26:00	2	102000.00	paskem3o@yale.edu	100	87276472964	P000075 
V0000760  	2016-11-26	2016-11-30 13:47:00	2	152000.00	kbreukelman39@dot.gov	150	88560595824	P000055 
V0000761  	2017-01-06	2017-01-10 09:19:00	2	12000.00	kkilmister3q@indiatimes.com	10	85918952542	P0000142
V0000762  	2016-05-08	2016-05-11 06:41:00	2	12000.00	jjeffcoat5e@npr.org	10	87068389940	P0000142
V0000763  	2016-01-02	\N	1	152000.00	rdidball53@webs.com	150	80705469249	P000076 
V0000764  	2016-03-26	2016-03-29 06:58:00	2	102000.00	lkobpac5u@nih.gov	100	82736262829	P0000131
V0000765  	2016-01-09	\N	1	7000.00	zheaton29@va.gov	5	84560686482	P0000113
V0000766  	2016-10-31	2016-11-02 12:24:00	2	152000.00	jradage2l@blogtalkradio.com	150	83776072823	P0000118
V0000767  	2016-12-26	2016-12-30 11:20:00	2	12000.00	bweaver4f@ebay.com	10	83831936485	P0000191
V0000768  	2016-11-01	\N	1	102000.00	klind1n@diigo.com	100	81938323903	P0000110
V0000769  	2016-10-10	2016-10-14 03:17:00	2	52000.00	mdraysay5z@weibo.com	50	87966446221	P000025 
V0000770  	2017-01-11	\N	1	202000.00	md3c@about.com	200	80139828915	P0000133
V0000771  	2016-02-08	2016-02-12 00:34:00	2	7000.00	rhallick2d@shutterfly.com	5	84520550800	P00001  
V0000772  	2016-03-19	\N	1	102000.00	zbaybutt6w@cafepress.com	100	88056138111	P000019 
V0000773  	2016-06-21	2016-06-24 16:44:00	2	12000.00	ebewfield1e@icio.us	10	89368096947	P0000135
V0000774  	2016-09-12	\N	1	27000.00	kde3g@ebay.co.uk	25	86375130638	P0000129
V0000775  	2016-03-01	2016-03-05 05:26:00	2	12000.00	rpitwayj@elegantthemes.com	10	89953982487	P0000128
V0000776  	2016-08-11	2016-08-15 03:31:00	2	27000.00	cchastenet44@jiathis.com	25	81734887156	P0000199
V0000777  	2016-01-20	\N	1	12000.00	gzapata4o@slideshare.net	10	83613907873	P0000184
V0000778  	2017-04-25	2017-04-29 05:24:00	2	12000.00	sokeenan23@csmonitor.com	10	83907368770	P000086 
V0000779  	2016-01-13	\N	1	27000.00	jwillard5r@51.la	25	82050374984	P0000192
V0000780  	2016-07-19	\N	1	27000.00	lcrichley19@noaa.gov	25	84464299383	P0000192
V0000781  	2016-07-21	2016-07-23 10:59:00	2	27000.00	lehrat55@spiegel.de	25	83601865364	P0000171
V0000782  	2016-04-16	2016-04-18 02:34:00	2	7000.00	pworsfold3n@chron.com	5	82400644516	P0000120
V0000783  	2017-03-29	2017-03-31 14:36:00	2	152000.00	abinnes6o@pcworld.com	150	84313290763	P0000104
V0000784  	2016-02-07	2016-02-09 14:41:00	2	52000.00	lshillingford37@godaddy.com	50	84580644402	P000046 
V0000785  	2016-03-24	2016-03-26 10:28:00	2	12000.00	rdametti2x@narod.ru	10	83663483463	P000058 
V0000786  	2016-03-14	\N	1	152000.00	mkleen21@tumblr.com	150	85032027714	P0000125
V0000787  	2017-02-15	2017-02-18 06:47:00	2	12000.00	gkristoffersen63@businesswire.com	10	89465850478	P0000184
V0000788  	2016-06-14	\N	1	52000.00	klind1n@diigo.com	50	81938323903	P000060 
V0000789  	2016-10-26	\N	1	27000.00	ghurleston45@netlog.com	25	82154487163	P0000164
V0000790  	2017-04-08	\N	1	52000.00	jsedgeman20@sourceforge.net	50	89119013144	P0000186
V0000791  	2016-05-18	2016-05-20 09:47:00	2	102000.00	yseago4v@geocities.com	100	85584668453	P0000124
V0000792  	2017-03-03	2017-03-05 17:04:00	2	27000.00	forudden6m@webeden.co.uk	25	80931190037	P000017 
V0000793  	2017-04-21	\N	1	52000.00	uguiducci43@istockphoto.com	50	84184962206	P0000193
V0000794  	2016-01-31	\N	1	27000.00	cshrimptone5f@gov.uk	25	88274693340	P000038 
V0000795  	2017-01-14	\N	1	12000.00	kmiddlemiss6e@umn.edu	10	84351860045	P0000184
V0000796  	2016-05-18	2016-05-22 06:02:00	2	202000.00	mthebeau1v@ed.gov	200	82171202428	P0000112
V0000797  	2016-10-07	\N	1	102000.00	cseamans2c@indiatimes.com	100	89112010278	P0000187
V0000798  	2016-12-17	2016-12-21 21:03:00	2	152000.00	wzanini2t@yahoo.co.jp	150	83613145333	P0000160
V0000799  	2016-10-02	\N	1	7000.00	mrobert1i@pcworld.com	5	85869266262	P000071 
V0000800  	2017-03-22	2017-03-26 14:35:00	2	152000.00	wfullylovep@aboutads.info	150	85353879685	P000041 
V0000801  	2016-02-01	2016-02-03 13:23:00	2	202000.00	kviles24@1688.com	200	84860494017	P000077 
V0000802  	2016-08-03	2016-08-05 03:32:00	2	7000.00	ryedall62@arizona.edu	5	84184083560	P000022 
V0000803  	2016-06-09	2016-06-12 08:35:00	2	12000.00	gtofanon@ustream.tv	10	81614595122	P0000128
V0000804  	2016-11-16	2016-11-19 19:22:00	2	202000.00	gberthouloume4w@delicious.com	200	88995977500	P0000154
V0000805  	2016-10-21	\N	1	152000.00	paskem3o@yale.edu	150	87276472964	P0000181
V0000806  	2016-01-20	\N	1	27000.00	sdufer57@yellowbook.com	25	82160710840	P0000136
V0000807  	2016-01-11	2016-01-15 11:13:00	2	102000.00	rharcarse54@buzzfeed.com	100	85363513496	P000068 
V0000808  	2016-09-22	2016-09-25 14:03:00	2	52000.00	kaleevyq@msn.com	50	82615861181	P00004  
V0000809  	2016-05-31	\N	1	7000.00	kaleevyq@msn.com	5	82615861181	P0000134
V0000810  	2016-11-14	2016-11-16 13:50:00	2	152000.00	adortonl@nytimes.com	150	89629864550	P0000153
V0000811  	2016-09-23	\N	1	152000.00	cleet1r@infoseek.co.jp	150	88278772478	P0000111
V0000812  	2016-11-24	\N	1	52000.00	nverlinde5l@globo.com	50	81444357145	P0000172
V0000813  	2016-11-28	2016-12-01 04:36:00	2	27000.00	lshillingford37@godaddy.com	25	84580644402	P000073 
V0000814  	2016-10-09	\N	1	152000.00	tskittreal5p@360.cn	150	82140943787	P000013 
V0000815  	2016-11-18	\N	1	52000.00	bwollers2v@usnews.com	50	82504673276	P0000109
V0000816  	2016-08-03	2016-08-05 23:23:00	2	202000.00	svezey6j@va.gov	200	81232581509	P000028 
V0000817  	2016-12-10	2016-12-14 07:40:00	2	202000.00	rhallick2d@shutterfly.com	200	84520550800	P000056 
V0000818  	2016-09-19	2016-09-23 18:48:00	2	12000.00	hjonathon1t@google.ca	10	80590818388	P0000107
V0000819  	2016-01-11	2016-01-13 13:31:00	2	12000.00	stither4h@google.ru	10	87640579752	P000086 
V0000820  	2017-04-02	\N	1	7000.00	rdidball53@webs.com	5	80705469249	P00001  
V0000821  	2016-12-16	2016-12-18 12:55:00	2	102000.00	ebewfield1e@icio.us	100	89368096947	P000068 
V0000822  	2016-09-12	2016-09-14 05:45:00	2	152000.00	mkleen21@tumblr.com	150	85032027714	P0000181
V0000823  	2016-04-03	\N	1	7000.00	mkeays6h@posterous.com	5	83800668752	P0000127
V0000824  	2016-08-27	2016-08-31 04:31:00	2	7000.00	cabby4b@cyberchimps.com	5	88272662800	P0000155
V0000825  	2016-11-09	2016-11-12 10:44:00	2	12000.00	bfalshaw2@about.me	10	89250859186	P000023 
V0000826  	2017-01-08	\N	1	152000.00	bmacmanus3e@arstechnica.com	150	82391770624	P000055 
V0000827  	2016-03-16	2016-03-18 16:35:00	2	202000.00	rjodrelle1c@latimes.com	200	85817344632	P0000189
V0000828  	2016-12-19	2016-12-23 03:53:00	2	7000.00	awinchurst5v@cloudflare.com	5	80762142879	P000050 
V0000829  	2016-02-20	2016-02-24 03:28:00	2	52000.00	bambersonv@wp.com	50	81561652227	P0000200
V0000830  	2016-07-19	\N	1	202000.00	mrobert1i@pcworld.com	200	85869266262	P0000126
V0000831  	2016-07-29	2016-08-01 03:50:00	2	7000.00	mkleen21@tumblr.com	5	85032027714	P000029 
V0000832  	2016-07-31	\N	1	152000.00	bgenders52@noaa.gov	150	87905642654	P000048 
V0000833  	2017-02-03	\N	1	7000.00	lfalkner2i@cpanel.net	5	80575460432	P000015 
V0000834  	2016-07-21	2016-07-23 09:35:00	2	7000.00	dreefe@springer.com	5	88639326822	P0000183
V0000835  	2016-04-15	\N	1	7000.00	rmooney4j@theatlantic.com	5	84285996068	P0000141
V0000836  	2016-02-08	2016-02-10 04:29:00	2	152000.00	jsedgeman20@sourceforge.net	150	89119013144	P0000160
V0000837  	2017-03-07	2017-03-10 08:53:00	2	7000.00	mcollyns46@1und1.de	5	85078664484	P0000148
V0000838  	2016-12-12	2016-12-16 00:37:00	2	52000.00	rmooney4j@theatlantic.com	50	84285996068	P0000193
V0000839  	2016-01-07	2016-01-11 00:19:00	2	52000.00	kbreukelman39@dot.gov	50	88560595824	P000081 
V0000840  	2016-03-07	2016-03-10 07:50:00	2	12000.00	lfalkner2i@cpanel.net	10	80575460432	P0000149
V0000841  	2016-04-12	2016-04-15 08:23:00	2	27000.00	scantu60@icio.us	25	89688331346	P000024 
V0000842  	2016-04-24	2016-04-27 04:23:00	2	202000.00	vmessruther40@fc2.com	200	83764441781	P0000161
V0000843  	2017-02-14	2017-02-16 16:43:00	2	27000.00	plorenz3r@fotki.com	25	82546334851	P000087 
V0000844  	2016-01-07	2016-01-11 07:18:00	2	12000.00	erihanek66@surveymonkey.com	10	81089491133	P00002  
V0000845  	2016-05-12	\N	1	12000.00	ghurleston45@netlog.com	10	82154487163	P0000114
V0000846  	2016-04-30	2016-05-03 20:59:00	2	152000.00	sbwy1x@xing.com	150	83794238715	P0000146
V0000847  	2016-10-20	2016-10-22 13:34:00	2	152000.00	olindeboom6x@adobe.com	150	87901515196	P000027 
V0000848  	2017-03-14	\N	1	27000.00	bwollers2v@usnews.com	25	82504673276	P0000199
V0000849  	2016-04-19	2016-04-21 17:41:00	2	202000.00	nleither16@google.it	200	81287534952	P000084 
V0000850  	2016-08-20	\N	1	202000.00	adwelly3u@pen.io	200	89480370270	P000049 
V0000851  	2016-09-02	\N	1	52000.00	fburkman2b@twitpic.com	50	88060310279	P0000151
V0000852  	2016-06-20	2016-06-22 23:27:00	2	7000.00	svezey6j@va.gov	5	81232581509	P0000162
V0000853  	2016-03-13	2016-03-15 02:45:00	2	12000.00	astandell6g@washington.edu	10	88204822346	P000086 
V0000854  	2016-08-25	\N	1	102000.00	kmiddlemiss6e@umn.edu	100	84351860045	P0000187
V0000855  	2016-04-26	2016-04-30 00:51:00	2	27000.00	odredge3a@sogou.com	25	80559847594	P000066 
V0000856  	2016-04-03	2016-04-05 09:51:00	2	152000.00	servine6k@macromedia.com	150	86400482295	P0000118
V0000857  	2016-09-28	2016-10-02 07:56:00	2	52000.00	mborlease2g@com.com	50	87909689738	P0000102
V0000858  	2016-10-05	2016-10-08 16:33:00	2	202000.00	bambersonv@wp.com	200	81561652227	P0000196
V0000859  	2016-04-06	2016-04-08 15:09:00	2	102000.00	mcollyns46@1und1.de	100	85078664484	P0000110
V0000860  	2016-04-03	2016-04-06 21:53:00	2	52000.00	lshillingford37@godaddy.com	50	84580644402	P000018 
V0000861  	2017-04-01	2017-04-04 07:20:00	2	152000.00	sbellward3z@google.com	150	87323309025	P0000153
V0000862  	2017-03-15	\N	1	202000.00	apetrasek3x@cocolog-nifty.com	200	83751068436	P000063 
V0000863  	2017-03-03	2017-03-06 03:57:00	2	12000.00	hlinklet1a@answers.com	10	83809332578	P000051 
V0000864  	2016-10-10	2016-10-12 19:19:00	2	202000.00	cnewling64@hc360.com	200	89159608191	P0000168
V0000865  	2016-06-17	2016-06-20 05:17:00	2	27000.00	twormleightonk@dagondesign.com	25	89803625389	P000038 
V0000866  	2017-04-03	2017-04-07 06:55:00	2	27000.00	mdraysay5z@weibo.com	25	87966446221	P00003  
V0000867  	2017-03-30	2017-04-02 03:28:00	2	152000.00	bcradick3t@squidoo.com	150	80814514094	P0000188
V0000868  	2016-08-20	2016-08-23 17:48:00	2	102000.00	tjohnsson35@gizmodo.com	100	82503556797	P0000117
V0000869  	2016-04-15	\N	1	102000.00	kkilmister3q@indiatimes.com	100	85918952542	P000026 
V0000870  	2017-01-15	2017-01-19 07:38:00	2	152000.00	amcsparran6b@springer.com	150	89401587927	P000048 
V0000871  	2016-02-21	\N	1	202000.00	rhaselhurst41@netvibes.com	200	85060224263	P000077 
V0000872  	2016-12-09	2016-12-13 00:09:00	2	102000.00	mmcfadden5x@live.com	100	87507423479	P0000166
V0000873  	2016-04-01	\N	1	152000.00	csaladine6a@businesswire.com	150	87630360279	P0000188
V0000874  	2017-02-12	2017-02-15 01:13:00	2	152000.00	pgrollmann1k@posterous.com	150	81306220495	P0000160
V0000875  	2016-01-26	2016-01-29 15:21:00	2	12000.00	hduffieldy@bloglovin.com	10	87798981982	P0000142
V0000876  	2016-03-31	\N	1	7000.00	rpigott17@vimeo.com	5	83838217143	P0000134
V0000877  	2017-04-03	\N	1	7000.00	mvedikhov3i@linkedin.com	5	88825829443	P0000120
V0000878  	2016-10-07	\N	1	152000.00	ffarncombe5h@theguardian.com	150	88300445379	P000048 
V0000879  	2016-09-20	2016-09-24 18:19:00	2	27000.00	lradnage30@canalblog.com	25	82305706756	P0000115
V0000880  	2017-04-10	2017-04-12 04:27:00	2	52000.00	amardling6@typepad.com	50	86572794970	P0000144
V0000881  	2016-09-05	2016-09-08 02:33:00	2	52000.00	elamcken27@hud.gov	50	80081938955	P0000109
V0000882  	2016-01-30	2016-02-03 13:44:00	2	12000.00	istreeton2u@yellowbook.com	10	80656377820	P000065 
V0000883  	2016-01-22	\N	1	12000.00	evinas1f@stanford.edu	10	83507186620	P000051 
V0000884  	2016-12-23	2016-12-26 08:36:00	2	102000.00	cmcwhin4g@gizmodo.com	100	82640302573	P0000152
V0000885  	2017-02-19	2017-02-22 07:06:00	2	7000.00	rdametti2x@narod.ru	5	83663483463	P0000134
V0000886  	2016-01-16	2016-01-18 13:43:00	2	152000.00	odredge3a@sogou.com	150	80559847594	P000048 
V0000887  	2016-05-23	2016-05-25 02:29:00	2	27000.00	mmcfadden5x@live.com	25	87507423479	P0000115
V0000888  	2016-11-04	\N	1	202000.00	gberthouloume4w@delicious.com	200	88995977500	P0000119
V0000889  	2016-05-27	2016-05-30 23:35:00	2	202000.00	atrowler5j@apple.com	200	84814125457	P000042 
V0000890  	2016-01-23	\N	1	12000.00	oernshaw9@ycombinator.com	10	84994136174	P0000149
V0000891  	2016-02-05	2016-02-08 20:27:00	2	202000.00	dhurne4@nydailynews.com	200	81852887905	P000091 
V0000892  	2016-07-29	\N	1	152000.00	boxtoby2f@zdnet.com	150	87762180611	P0000167
V0000893  	2017-02-28	2017-03-03 22:00:00	2	202000.00	mtooley1s@storify.com	200	83854483381	P000035 
V0000894  	2016-08-10	\N	1	52000.00	rharcarse54@buzzfeed.com	50	85363513496	P000095 
V0000895  	2017-02-05	2017-02-08 00:42:00	2	52000.00	plorenz3r@fotki.com	50	82546334851	P0000137
V0000896  	2016-03-13	\N	1	27000.00	epotte5n@redcross.org	25	87954524225	P000066 
V0000897  	2016-05-10	2016-05-14 10:06:00	2	12000.00	mpattison1d@spotify.com	10	80446590793	P000023 
V0000898  	2016-12-02	2016-12-04 13:37:00	2	202000.00	aodevey2z@prlog.org	200	88146432693	P0000119
V0000899  	2016-12-27	2016-12-29 13:26:00	2	12000.00	djentle13@live.com	10	88328345551	P0000191
V0000900  	2016-03-29	2016-04-01 10:37:00	2	12000.00	pgrollmann1k@posterous.com	10	81306220495	P000086 
V0000901  	2016-05-06	2016-05-08 08:12:00	2	152000.00	nleither16@google.it	150	81287534952	P0000118
V0000902  	2016-01-22	2016-01-26 01:48:00	2	102000.00	hjonathon1t@google.ca	100	80590818388	P000047 
V0000903  	2016-11-25	\N	1	12000.00	ntye6t@dyndns.org	10	88567457252	P0000184
V0000904  	2016-04-28	\N	1	152000.00	sbwy1x@xing.com	150	83794238715	P000041 
V0000905  	2016-10-07	2016-10-10 20:44:00	2	202000.00	wzanini2t@yahoo.co.jp	200	83613145333	P0000105
V0000906  	2016-09-29	2016-10-01 00:04:00	2	152000.00	mmcfadden5x@live.com	150	87507423479	P0000181
V0000907  	2017-04-11	2017-04-15 01:59:00	2	27000.00	rexley26@barnesandnoble.com	25	85504321184	P000045 
V0000908  	2017-02-05	2017-02-08 22:09:00	2	7000.00	bmacmanus3e@arstechnica.com	5	82391770624	P000099 
V0000909  	2017-04-07	2017-04-11 02:52:00	2	12000.00	kmiddlemiss6e@umn.edu	10	84351860045	P0000100
V0000910  	2016-06-02	2016-06-04 16:50:00	2	12000.00	apacher3h@etsy.com	10	82319153350	P000093 
V0000911  	2017-03-11	2017-03-15 16:30:00	2	102000.00	kchastelain6l@ucsd.edu	100	81144636223	P00005  
V0000912  	2016-05-21	2016-05-25 00:30:00	2	102000.00	rstump59@thetimes.co.uk	100	83937227183	P00005  
V0000913  	2016-08-28	2016-09-01 04:14:00	2	7000.00	jjeffcoat5e@npr.org	5	87068389940	P0000120
V0000914  	2016-09-22	\N	1	202000.00	rhouldey3d@latimes.com	200	83681512921	P0000105
V0000915  	2016-05-07	\N	1	152000.00	awinchurst5v@cloudflare.com	150	80762142879	P000097 
V0000916  	2016-12-29	2017-01-01 06:02:00	2	102000.00	rjodrelle1c@latimes.com	100	85817344632	P0000124
V0000917  	2017-02-09	2017-02-11 06:36:00	2	102000.00	mradsdale1u@imdb.com	100	83925735059	P000012 
V0000918  	2016-06-28	2016-06-30 12:08:00	2	52000.00	gjanning3@opensource.org	50	80295257279	P0000186
V0000919  	2017-03-09	2017-03-11 08:48:00	2	27000.00	bgenders52@noaa.gov	25	87905642654	P0000108
V0000920  	2016-09-10	2016-09-14 12:37:00	2	102000.00	lbottom1b@blinklist.com	100	84235158040	P0000145
V0000921  	2016-10-31	\N	1	202000.00	mradsdale1u@imdb.com	200	83925735059	P000014 
V0000922  	2016-06-26	2016-06-30 16:47:00	2	12000.00	agrimestone5s@jimdo.com	10	84943331218	P0000177
V0000923  	2016-04-18	2016-04-20 03:19:00	2	202000.00	csiegertsz2j@columbia.edu	200	82387894828	P0000140
V0000924  	2016-07-27	\N	1	52000.00	ffarncombe5h@theguardian.com	50	88300445379	P0000137
V0000925  	2017-02-06	2017-02-10 09:54:00	2	152000.00	dreefe@springer.com	150	88639326822	P000020 
V0000926  	2016-02-21	\N	1	7000.00	tblackway61@51.la	5	89041936071	P0000113
V0000927  	2016-12-16	2016-12-20 09:37:00	2	52000.00	fdarrington6i@unblog.fr	50	80190617622	P0000158
V0000928  	2016-07-06	\N	1	152000.00	gtackell68@rambler.ru	150	88065222290	P0000153
V0000929  	2017-02-24	2017-02-28 14:27:00	2	152000.00	msaltsberger69@hud.gov	150	86693577153	P000090 
V0000930  	2016-02-10	\N	1	202000.00	ptesh5a@salon.com	200	88863667126	P0000161
V0000931  	2016-07-02	2016-07-05 10:59:00	2	27000.00	sricardin6s@furl.net	25	85794978063	P000010 
V0000932  	2017-04-22	2017-04-24 18:54:00	2	102000.00	bwollers2v@usnews.com	100	82504673276	P000089 
V0000933  	2016-09-11	\N	1	52000.00	rbuckland36@last.fm	50	83267252458	P0000102
V0000934  	2016-12-13	\N	1	52000.00	elamcken27@hud.gov	50	80081938955	P0000200
V0000935  	2016-11-25	\N	1	12000.00	mrobert1i@pcworld.com	10	85869266262	P000037 
V0000936  	2016-07-08	2016-07-11 05:47:00	2	7000.00	ccheale1p@bbc.co.uk	5	86362735784	P000050 
V0000937  	2016-12-23	2016-12-27 09:25:00	2	7000.00	rhallick2d@shutterfly.com	5	84520550800	P000043 
V0000938  	2016-02-25	2016-02-29 21:36:00	2	152000.00	elamcken27@hud.gov	150	80081938955	P000013 
V0000939  	2016-07-03	2016-07-07 13:35:00	2	12000.00	mmasserel1g@epa.gov	10	88184601779	P0000156
V0000940  	2016-04-21	\N	1	202000.00	lcolicot4d@behance.net	200	88995677800	P0000119
V0000941  	2016-05-04	2016-05-07 07:22:00	2	52000.00	snavein2h@yolasite.com	50	83304827407	P0000109
V0000942  	2016-04-29	2016-05-03 01:00:00	2	152000.00	paskem3o@yale.edu	150	87276472964	P0000195
V0000943  	2017-02-12	\N	1	102000.00	minksteri@aol.com	100	89822940015	P000061 
V0000944  	2016-06-07	2016-06-09 13:42:00	2	102000.00	cbeaman7@instagram.com	100	83888037237	P0000117
V0000945  	2016-06-23	2016-06-26 15:37:00	2	27000.00	erihanek66@surveymonkey.com	25	81089491133	P0000185
V0000946  	2017-01-14	2017-01-16 22:56:00	2	7000.00	bgenders52@noaa.gov	5	87905642654	P000043 
V0000947  	2016-09-30	\N	1	152000.00	gmorgans14@nba.com	150	89947720529	P000097 
V0000948  	2017-01-09	2017-01-11 03:52:00	2	152000.00	tadame4c@alexa.com	150	83954809255	P000034 
V0000949  	2016-09-20	2016-09-24 06:30:00	2	202000.00	adwelly3u@pen.io	200	89480370270	P000042 
V0000950  	2016-11-30	\N	1	27000.00	elamcken27@hud.gov	25	80081938955	P0000171
V0000951  	2016-02-23	2016-02-27 23:43:00	2	102000.00	atrowler5j@apple.com	100	84814125457	P0000173
V0000952  	2017-04-14	2017-04-16 17:52:00	2	27000.00	cbeaman7@instagram.com	25	83888037237	P0000171
V0000953  	2016-07-25	2016-07-27 21:55:00	2	52000.00	sphidgin3y@newyorker.com	50	88865981234	P000046 
V0000954  	2016-07-13	2016-07-15 19:24:00	2	52000.00	hgisborne28@slashdot.org	50	88627968524	P0000165
V0000955  	2017-04-21	2017-04-23 18:24:00	2	27000.00	vgissing12@google.fr	25	81227712578	P0000185
V0000956  	2016-03-30	2016-04-02 19:19:00	2	27000.00	ghurleston45@netlog.com	25	82154487163	P000010 
V0000957  	2016-12-29	\N	1	202000.00	rhallick2d@shutterfly.com	200	84520550800	P0000133
V0000958  	2016-01-26	\N	1	12000.00	mmobley2o@mac.com	10	87872548490	P0000107
V0000959  	2017-02-07	\N	1	27000.00	gtaggett5t@over-blog.com	25	88620140001	P0000115
V0000960  	2016-05-18	\N	1	202000.00	forudden6m@webeden.co.uk	200	80931190037	P0000133
V0000961  	2016-06-18	\N	1	12000.00	fsothern6c@dailymail.co.uk	10	82889919431	P000051 
V0000962  	2016-09-28	2016-09-30 23:33:00	2	202000.00	mmobley2o@mac.com	200	87872548490	P0000126
V0000963  	2016-09-25	2016-09-27 10:29:00	2	52000.00	jhaggerstone6n@cisco.com	50	86702997346	P0000200
V0000964  	2016-04-11	\N	1	12000.00	egiles42@sitemeter.com	10	86087726649	P000016 
V0000965  	2016-11-07	\N	1	27000.00	bgenders52@noaa.gov	25	87905642654	P0000185
V0000966  	2016-06-07	2016-06-09 13:45:00	2	202000.00	leason6p@wufoo.com	200	86042741789	P000070 
V0000967  	2016-05-18	\N	1	52000.00	mhallagan3m@psu.edu	50	81741232359	P000039 
V0000968  	2016-09-28	\N	1	152000.00	dhurne4@nydailynews.com	150	81852887905	P0000132
V0000969  	2016-10-02	2016-10-05 15:27:00	2	52000.00	ntye6t@dyndns.org	50	88567457252	P0000193
V0000970  	2017-04-20	\N	1	27000.00	hcastanaga1j@fda.gov	25	87520960388	P000066 
V0000971  	2016-05-25	2016-05-27 15:52:00	2	102000.00	lbarbrookm@google.co.uk	100	89877161121	P000040 
V0000972  	2016-05-13	2016-05-15 05:06:00	2	12000.00	fdarrington6i@unblog.fr	10	80190617622	P0000107
V0000973  	2016-03-10	2016-03-13 21:45:00	2	27000.00	vmessruther40@fc2.com	25	83764441781	P000031 
V0000974  	2016-04-03	2016-04-07 20:07:00	2	152000.00	csaladine6a@businesswire.com	150	87630360279	P000076 
V0000975  	2016-03-16	\N	1	27000.00	kde3g@ebay.co.uk	25	86375130638	P0000143
V0000976  	2017-04-14	\N	1	12000.00	cmcwhin4g@gizmodo.com	10	82640302573	P0000128
V0000977  	2016-08-08	\N	1	152000.00	scoppo50@facebook.com	150	80483717929	P000062 
V0000978  	2017-01-25	\N	1	102000.00	paskem3o@yale.edu	100	87276472964	P0000152
V0000979  	2017-03-06	2017-03-10 22:18:00	2	152000.00	claraway1l@parallels.com	150	85029220527	P000097 
V0000980  	2016-10-23	\N	1	12000.00	adortonl@nytimes.com	10	89629864550	P0000156
V0000981  	2016-07-07	2016-07-11 07:40:00	2	102000.00	djentle13@live.com	100	88328345551	P000012 
V0000982  	2017-04-25	\N	1	102000.00	tadame4c@alexa.com	100	83954809255	P0000103
V0000983  	2017-03-20	\N	1	7000.00	kde3g@ebay.co.uk	5	86375130638	P0000141
V0000984  	2016-01-16	2016-01-19 18:47:00	2	102000.00	mtooley1s@storify.com	100	83854483381	P000075 
V0000985  	2016-02-14	2016-02-18 03:37:00	2	7000.00	lfendleyc@amazon.co.uk	5	86030943634	P000071 
V0000986  	2016-11-14	2016-11-16 14:52:00	2	27000.00	glarmett22@reuters.com	25	80647660331	P0000164
V0000987  	2016-12-15	2016-12-18 17:00:00	2	202000.00	rpigott17@vimeo.com	200	83838217143	P0000168
V0000988  	2016-01-13	\N	1	102000.00	cbrumen4a@skype.com	100	87202747523	P0000145
V0000989  	2016-01-16	\N	1	102000.00	sdadsond@qq.com	100	89405080543	P000082 
V0000990  	2016-04-29	\N	1	27000.00	lbambrick2p@sfgate.com	25	85947800537	P0000129
V0000991  	2016-05-20	\N	1	152000.00	vkippie2n@google.ru	150	85350853366	P0000160
V0000992  	2017-01-11	\N	1	52000.00	lshillingford37@godaddy.com	50	84580644402	P000011 
V0000993  	2016-02-12	2016-02-16 00:47:00	2	27000.00	mthebeau1v@ed.gov	25	82171202428	P0000101
V0000994  	2016-11-05	2016-11-08 04:23:00	2	7000.00	zbaybutt6w@cafepress.com	5	88056138111	P000029 
V0000995  	2017-02-23	2017-02-25 23:20:00	2	102000.00	jdinesen2y@vimeo.com	100	83915236091	P000047 
V0000996  	2016-07-12	2016-07-14 16:25:00	2	27000.00	rjodrelle1c@latimes.com	25	85817344632	P0000157
V0000997  	2016-11-25	2016-11-29 15:01:00	2	152000.00	gtofanon@ustream.tv	150	81614595122	P0000174
V0000998  	2016-08-13	2016-08-16 01:29:00	2	102000.00	adwelly3u@pen.io	100	89480370270	P000033 
V0000999  	2016-06-26	2016-06-30 12:17:00	2	7000.00	dbeagin5d@barnesandnoble.com	5	82407112188	P0000176
V00001000 	2016-10-23	\N	1	12000.00	bfalshaw2@about.me	10	89250859186	P0000184
\.


--
-- Data for Name: transaksi_shipped; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY transaksi_shipped (no_invoice, tanggal, waktu_bayar, status, total_bayar, email_pembeli, nama_toko, alamat_kirim, biaya_kirim, no_resi, nama_jasa_kirim) FROM stdin;
V0000334  	2017-02-27	2017-03-03 08:22:00	2	9191000.00	hluney5c@bloglovin.com	Advanced Baby	Jl. Mayfield no. 17, Zurich 8023	68.00	ZRHZH63738188416	LION PARCEL
V00001    	2016-08-14	2016-08-17 03:29:00	4	4074000.00	bbryant56@bbc.co.uk	solution-oriented Electronics	Jl. West no. 25, Kitango 6407	20.00	KTG5535411741553	J&T EXPRESS
V00002    	2016-05-08	2016-05-12 08:08:00	2	6690000.00	mpietasch5y@nsw.gov.au	analyzing Computers	Jl. Oxford no. 828, Huangzhan	40.00	HAZ3394962641339	PAHALA
V00003    	2016-03-22	2016-03-25 10:32:00	2	1123000.00	mcrichmer58@mac.com	Future-proofed Toys	Jl. Reindahl no. 346, Villa Nueva 5903	63.00	VL 8672468541867	WAHANA
V00004    	2016-01-01	2016-01-03 02:57:00	4	3756000.00	bcradick3t@squidoo.com	installation Computers	Jl. Sloan no. 507, Pajak	45.00	PJ43071615414307	PAHALA
V0000501  	2017-02-25	2017-02-22 07:21:00	4	7137000.00	emilystephens@dayrep.com	solution-oriented Electronics	Jl. Anggrek no. 666, Jakarta 16241	43000.00	CGK8236508841823	J&T EXPRESS
V00005    	2016-09-06	2016-09-09 16:06:00	4	6938000.00	mpowney2s@over-blog.com	project Tools	Jl. Dahle no. 585, Shengmi	78.00	SEM3897713741389	TIKI REGULER
V00006    	2017-03-28	2017-03-30 17:23:00	3	7286000.00	mquittonden51@acquirethisname.com	project Computers	Jl. Little Fleur no. 463, Komes	51.00	KM11812709411181	JNE YES
V00007    	2016-08-27	2016-08-31 17:36:00	3	5267000.00	nwemm2e@meetup.com	reciprocal Health	Jl. 5th no. 464, P“sto Fiscal Rolim de Moura 97755-000	51.00	PS 4149132741414	TIKI REGULER
V00008    	2016-04-28	2016-04-30 07:31:00	2	9458000.00	rexley26@barnesandnoble.com	Centralized Home	Jl. Hallows no. 71, Cabcaben 2133	62.00	CBB4968281641496	POS PAKET BIASA
V00009    	2016-04-25	2016-04-29 01:14:00	2	5860000.00	jhaggerstone6n@cisco.com	monitoring Books	Jl. Loftsgordon no. 111, Kandun	11.00	KNN3486451641348	TIKI REGULER
V000010   	2016-06-03	2016-06-05 14:20:00	4	2078000.00	lfendleyc@amazon.co.uk	functionalities Toys	Jl. Village Green no. 474, Donggaocun	10.00	DNA5563694641556	POS PAKET KILAT
V000011   	2016-02-12	2016-02-16 12:58:00	4	5901000.00	wnotman6v@istockphoto.com	Decentralized Grocery	Jl. Russell no. 848, Hujra 56170	77.00	HJ72918255417291	WAHANA
V000012   	2016-06-02	2016-06-06 15:46:00	4	6986000.00	fmasic1h@prweb.com	installation Computers	Jl. Johnson no. 772, Beidao	18.00	BIO3832884641383	TIKI REGULER
V000013   	2017-03-21	2017-03-23 18:35:00	2	8715000.00	jsedgeman20@sourceforge.net	Future-proofed Toys	Jl. Iowa no. 408, Kikuchi 861-1686	86.00	KKH0431210941043	WAHANA
V000014   	2016-04-02	2016-04-05 01:35:00	3	6551000.00	vgissing12@google.fr	time-frame Health	Jl. Kinsman no. 452, Le Blanc-Mesnil 93154 CEDEX	16.00	L AA874906595417	JNE REGULER
V000015   	2016-12-26	2016-12-29 15:23:00	3	5719000.00	sphidgin3y@newyorker.com	asynchronous Industrial	Jl. Annamark no. 736, Jiling	31.00	JLG3285672841328	WAHANA
V000016   	2016-09-25	2016-09-28 05:07:00	2	782000.00	servine6k@macromedia.com	groupware Books	Jl. Green no. 920, Valky	32.00	VL07008747410700	POS PAKET BIASA
V000017   	2016-06-19	2016-06-22 11:53:00	4	8165000.00	wnotman6v@istockphoto.com	non-volatile Games	Jl. Golden Leaf no. 586, Nong Saeng 41340	78.00	NNS0917336641091	POS PAKET BIASA
V000018   	2016-06-23	2016-06-25 00:04:00	2	4674000.00	mthebeau1v@ed.gov	Business-focused Jewelery	Jl. 1st no. 281, Gantang	57.00	GNN8920466641892	PAHALA
V000019   	2016-08-20	\N	1	2695000.00	nleither16@google.it	conglomeration Jewelery	Jl. Schiller no. 689, Priargunsk 674310	16.00	PIG8162271741816	JNE OKE
V000020   	2016-08-17	2016-08-19 00:41:00	4	6743000.00	lehrat55@spiegel.de	alliance Toys	Jl. Lukken no. 906, Derbent 368608	61.00	DRN5054931741505	JNE REGULER
V000021   	2016-01-27	2016-01-30 20:09:00	2	7805000.00	castlesa@paginegialle.it	circuit Automotive	Jl. Park Meadow no. 11, Braunschweig 38106	12.00	BASNI07352935410	JNE YES
V000022   	2016-07-29	2016-08-02 19:29:00	3	7622000.00	bbryant56@bbc.co.uk	analyzer Computers	Jl. Toban no. 754, Tuchengzi	54.00	TCN3450289641345	JNE REGULER
V000023   	2016-08-03	2016-08-06 12:02:00	3	474000.00	wgoldingay15@shop-pro.jp	mission-critical Electronics	Jl. Pine View no. 418, Koutsop¢di	27.00	KUO1375220741137	POS PAKET KILAT
V000024   	2016-01-26	2016-01-28 10:37:00	3	963000.00	mhallagan3m@psu.edu	Robust Garden	Jl. Northridge no. 501, Sao Mateus 9700-555	90.00	SOA4312640835411	WAHANA
V000025   	2016-04-26	2016-04-28 23:23:00	4	8930000.00	dbasire4n@nasa.gov	Up-sized Movies	Jl. Old Shore no. 753, Dalongzhan	69.00	DLG1103171641110	PAHALA
V000026   	2016-03-06	\N	1	552000.00	cdrysdale4z@dell.com	Future-proofed Toys	Jl. Carberry no. 645, Shinkafe	89.00	SIA5660627541566	JNE REGULER
V000027   	2016-01-01	2016-01-04 16:35:00	2	8238000.00	rreeson1y@cnet.com	Implemented Grocery	Jl. Evergreen no. 329, Ankazobe	91.00	AKO9416661541941	JNE REGULER
V000028   	2016-11-17	\N	1	4772000.00	csiegertsz2j@columbia.edu	knowledge base Games	Jl. Thackeray no. 415, Isnos 418049	65.00	IN39606397413960	WAHANA
V000029   	2016-12-29	\N	1	7074000.00	ccheale1p@bbc.co.uk	customer loyalty Movies	Jl. American no. 334, `Anat al Qadimah	71.00	`N 4690003841469	POS PAKET BIASA
V000030   	2016-08-30	\N	1	9254000.00	jguice6f@cyberchimps.com	monitoring Books	Jl. Larry no. 182, Nanshi	55.00	NNI1760352741176	JNE REGULER
V000031   	2016-09-06	2016-09-09 15:24:00	3	3696000.00	carchambault67@cam.ac.uk	global Tools	Jl. Marcy no. 172, Sao Pedro 2710-470	24.00	SOE1199457137419	J&T EXPRESS
V000032   	2017-02-22	2017-02-25 20:53:00	4	9642000.00	rjodrelle1c@latimes.com	Ameliorated Movies	Jl. Lawn no. 49, Santa Barbara 5002	59.00	SN 2186977841218	POS PAKET KILAT
V000033   	2016-09-30	\N	1	173000.00	bbisseker4m@g.co	Compatible Outdoors	Jl. Eagan no. 414, Shixi	68.00	SI52737257415273	WAHANA
V000034   	2016-02-19	2016-02-23 22:25:00	3	1546000.00	lbarbrookm@google.co.uk	Advanced Baby	Jl. Schurz no. 149, Menglie	37.00	MNI9370295541937	LION PARCEL
V000035   	2017-01-01	\N	1	6283000.00	yseago4v@geocities.com	algorithm Garden	Jl. Charing Cross no. 811, Brejos 2860-318	74.00	BES1599230338419	POS PAKET BIASA
V000036   	2017-03-04	2017-03-08 00:39:00	3	6533000.00	apetrasek3x@cocolog-nifty.com	eco-centric Industrial	Jl. Northwestern no. 27, Oz‰rsk 238124	57.00	O‰K2697858841269	POS PAKET KILAT
V000037   	2016-12-19	2016-12-22 14:39:00	3	672000.00	ktilbey2m@freewebs.com	Implemented Grocery	Jl. Packers no. 164, Leijiadian	86.00	LIA9838512841983	TIKI REGULER
V000038   	2016-12-19	2016-12-21 03:42:00	2	4920000.00	sbwy1x@xing.com	complexity Tools	Jl. Eagle Crest no. 163, Fontenay-sous-Bois 94124 CEDEX	86.00	FNNA862981128416	WAHANA
V000039   	2017-02-21	2017-02-24 17:10:00	2	3885000.00	mmcfadden5x@live.com	Persevering Outdoors	Jl. Sundown no. 347, Argel	51.00	AG14079678411407	WAHANA
V000040   	2017-02-13	2017-02-16 06:58:00	3	4922000.00	gtaggett5t@over-blog.com	groupware Books	Jl. Carey no. 492, Luodian	82.00	LOA7809696841780	LION PARCEL
V000041   	2016-09-05	2016-09-07 03:03:00	4	8499000.00	scoppo50@facebook.com	solution-oriented Baby	Jl. Sommers no. 943, Ejido	61.00	EI33644037413364	JNE REGULER
V000042   	2016-02-10	2016-02-12 19:34:00	4	4034000.00	sdadsond@qq.com	Persevering Outdoors	Jl. Grayhawk no. 670, Yulin	3.00	YL65823155416582	LION PARCEL
V000043   	2016-06-07	2016-06-11 08:03:00	3	6063000.00	umordacai5g@last.fm	Customizable Shoes	Jl. Fisk no. 470, Borzech¢w 24-224	88.00	BRC5366825641536	WAHANA
V000044   	2016-01-27	2016-01-31 09:50:00	2	2965000.00	amardling6@typepad.com	Diverse Movies	Jl. Clarendon no. 476, Canto 3840-065	87.00	CN01452888354145	POS PAKET KILAT
V000045   	2016-04-14	2016-04-17 04:02:00	3	1849000.00	mmcgarvey6d@yellowbook.com	algorithm Music	Jl. Mallard no. 309, Sollefte† 881 86	61.00	SLFY265606064126	JNE REGULER
V000046   	2016-02-11	2016-02-13 04:42:00	2	6498000.00	mquittonden51@acquirethisname.com	task-force Movies	Jl. Linden no. 317, Wonopringgo	21.00	WNR7575615541757	TIKI REGULER
V000047   	2016-10-13	2016-10-17 12:48:00	4	6980000.00	cbeaman7@instagram.com	system engine Computers	Jl. Westerfield no. 811, Bor 606448	56.00	BR52926367415292	JNE REGULER
V000048   	2016-11-28	2016-12-02 00:32:00	3	8320000.00	mmasserel1g@epa.gov	Implemented Games	Jl. Memorial no. 488, Huaqiao	54.00	HAA7513920841751	J&T EXPRESS
V000049   	2016-08-21	2016-08-25 05:36:00	3	2617000.00	hbeloe1z@freewebs.com	circuit Automotive	Jl. Hansons no. 993, Tempursari Wetan	34.00	TMR0087571741008	POS PAKET KILAT
V000050   	2017-02-14	2017-02-18 11:01:00	3	5769000.00	hjonathon1t@google.ca	Stand-alone Outdoors	Jl. Northfield no. 661, Lame	14.00	LM31107078413110	PAHALA
V000051   	2016-12-05	2016-12-08 12:25:00	4	1789000.00	dcaulfield2q@dmoz.org	software Garden	Jl. Doe Crossing no. 66, Ch? G?o	47.00	C??0170490841017	JNE YES
V000052   	2016-12-04	\N	1	4322000.00	ahaverson3v@columbia.edu	software Garden	Jl. Mendota no. 551, Gunungjulang	53.00	GNG2149180841214	PAHALA
V000053   	2016-07-16	2016-07-19 06:33:00	3	4231000.00	fsothern6c@dailymail.co.uk	Implemented Games	Jl. American Ash no. 347, Huangjiabu	32.00	HAJ7080568641708	WAHANA
V000054   	2017-04-23	2017-04-25 03:23:00	3	3080000.00	zbaybutt6w@cafepress.com	tertiary Home	Jl. 4th no. 640, Gananoque K7G	89.00	GNOON59771929415	TIKI REGULER
V000055   	2017-04-07	2017-04-11 18:19:00	3	2253000.00	sbwy1x@xing.com	analyzing Computers	Jl. Express no. 997, Bobonan 2437	75.00	BBA2619851941261	POS PAKET BIASA
V000056   	2017-03-31	2017-04-04 04:11:00	2	5242000.00	drojel5k@merriam-webster.com	software Books	Jl. Upham no. 842, Tselinnoye 659430	75.00	TEN6053390941605	TIKI REGULER
V000057   	2016-08-11	2016-08-13 12:18:00	2	2329000.00	dbeagin5d@barnesandnoble.com	asymmetric Baby	Jl. Lakewood no. 141, Xipingle	97.00	XPG8097190741809	J&T EXPRESS
V000058   	2017-02-11	2017-02-14 10:59:00	3	4202000.00	rbuckland36@last.fm	empowering Beauty	Jl. Welch no. 566, Shpola	82.00	SPA2970186841297	LION PARCEL
V000059   	2016-07-28	\N	1	8715000.00	bweaver4f@ebay.com	analyzing Computers	Jl. Paget no. 720, Yanagawa 990-1274	52.00	YNA3765379641376	WAHANA
V000060   	2016-08-16	2016-08-20 01:13:00	4	6258000.00	gberthouloume4w@delicious.com	asynchronous Industrial	Jl. Canary no. 668, Shaxi	98.00	SA59990317415999	J&T EXPRESS
V000061   	2016-10-30	2016-11-02 17:08:00	3	4204000.00	jradage2l@blogtalkradio.com	Customer-focused Kids	Jl. Lien no. 423, `Afak	44.00	`F00374877410037	J&T EXPRESS
V000062   	2016-01-31	2016-02-02 16:37:00	4	2375000.00	rhouldey3d@latimes.com	Re-engineered Jewelery	Jl. Brickson Park no. 691, Agudos 17120-000	39.00	AUS3728524541372	PAHALA
V000063   	2016-09-04	2016-09-08 17:13:00	4	4394000.00	scoppo50@facebook.com	Secured Baby	Jl. Esker no. 314, Chengjiao	78.00	CEJ3029003741302	LION PARCEL
V000064   	2016-08-30	2016-09-02 20:01:00	2	4091000.00	jhaggerstone6n@cisco.com	Implemented Games	Jl. Susan no. 635, Boisbriand J7G	91.00	BIRQC46278527414	LION PARCEL
V000065   	2016-10-21	2016-10-23 19:46:00	3	7439000.00	lfalkner2i@cpanel.net	Stand-alone Music	Jl. Hermina no. 872, Los Lotes	79.00	LSO4029707741402	PAHALA
V000066   	2016-07-13	2016-07-17 00:39:00	3	4086000.00	mtooley1s@storify.com	mission-critical Electronics	Jl. Golf no. 29, Xinfeng	82.00	XNN7630738641763	LION PARCEL
V000067   	2016-03-08	2016-03-10 10:29:00	4	2753000.00	gberthouloume4w@delicious.com	Compatible Outdoors	Jl. South no. 720, Tongzi	29.00	TNI4992347541499	LION PARCEL
V000068   	2017-01-11	2017-01-13 08:32:00	4	6838000.00	cshrimptone5f@gov.uk	asynchronous Industrial	Jl. Quincy no. 478, Rodionovo-Nesvetaiskoye 346580	7.00	RDN8253214841825	POS PAKET KILAT
V000069   	2017-01-17	2017-01-21 20:43:00	4	4804000.00	lbottom1b@blinklist.com	analyzing Computers	Jl. Arkansas no. 402, Amassoma	23.00	AAO1385864841138	LION PARCEL
V000070   	2016-05-26	2016-05-28 02:31:00	4	3890000.00	md3c@about.com	grid-enabled Music	Jl. Stephen no. 320, G”teborg 418 77	49.00	GTOO419922464141	PAHALA
V000071   	2016-02-11	2016-02-14 22:12:00	4	2718000.00	jalenshev3l@sciencedaily.com	Re-contextualized Automotive	Jl. Weeping Birch no. 144, A‡ucena 35150-000	47.00	AUN1678225541167	JNE YES
V000072   	2016-04-06	2016-04-10 18:38:00	4	9377000.00	umordacai5g@last.fm	Face to face Electronics	Jl. Bashford no. 92, Kitchener N2R	98.00	KTEON38876995413	POS PAKET BIASA
V000073   	2016-03-09	2016-03-12 20:05:00	2	1011000.00	aslides4s@fotki.com	holistic Shoes	Jl. Sutherland no. 384, Gaokan	53.00	GON8193557541819	POS PAKET BIASA
V000074   	2017-04-16	2017-04-18 12:47:00	2	5508000.00	mkeays6h@posterous.com	functionalities Toys	Jl. Village Green no. 362, Batulenger Barat	60.00	BTE9486432941948	TIKI REGULER
V000075   	2017-02-04	2017-02-08 11:46:00	2	4782000.00	rdidball53@webs.com	knowledge base Games	Jl. Mcguire no. 655, Chervonopartyzansk	45.00	CEO2088026841208	JNE REGULER
V000076   	2016-12-17	2016-12-21 10:42:00	4	7257000.00	bstukings1o@elpais.com	algorithm Industrial	Jl. Karstens no. 750, Tucupido	42.00	TCI2631791841263	JNE OKE
V000077   	2016-06-07	2016-06-11 11:23:00	2	4289000.00	minksteri@aol.com	monitoring Books	Jl. Boyd no. 393, Sidomulyo	13.00	SDU9268925641926	J&T EXPRESS
V000078   	2016-06-09	2016-06-12 13:32:00	4	920000.00	awinchurst5v@cloudflare.com	analyzer Computers	Jl. Banding no. 457, Polanczyk 38-610	98.00	PLC1319745641131	POS PAKET BIASA
V000079   	2016-10-10	2016-10-14 17:39:00	2	563000.00	reckh2k@123-reg.co.uk	Compatible Outdoors	Jl. Forster no. 230, V„stra Fr”lunda 426 71	37.00	VSAO241121674124	JNE REGULER
V000080   	2017-02-15	2017-02-19 16:17:00	3	8790000.00	rexley26@barnesandnoble.com	installation Computers	Jl. Stoughton no. 809, Rokytne	26.00	RKN9445717841944	WAHANA
V000081   	2016-09-10	2016-09-14 22:05:00	4	8752000.00	snavein2h@yolasite.com	empowering Beauty	Jl. Carberry no. 628, Deqing	96.00	DQG2115453741211	LION PARCEL
V000082   	2016-11-30	2016-12-04 21:14:00	3	9694000.00	bfalshaw2@about.me	holistic Shoes	Jl. Monument no. 425, Kaem	37.00	KE56404508415640	J&T EXPRESS
V000083   	2016-01-22	2016-01-25 21:01:00	4	8546000.00	jwheelwright6u@i2i.jp	mission-critical Baby	Jl. Main no. 943, Xianglan	75.00	XAL4746943541474	JNE YES
V000084   	2017-02-20	2017-02-24 17:18:00	2	4284000.00	cchastenet44@jiathis.com	grid-enabled Music	Jl. Anthes no. 437, Nueva Loja	64.00	NE 8111167841811	JNE YES
V000085   	2016-12-22	2016-12-26 19:40:00	2	7254000.00	sgrigollig@weather.com	solution-oriented Baby	Jl. Milwaukee no. 514, Lubenec 439 83	100.00	LBE6465342841646	PAHALA
V000086   	2016-01-25	2016-01-27 13:56:00	3	8029000.00	hlodford3j@slate.com	Re-engineered Jewelery	Jl. Sullivan no. 479, Praimarada	98.00	PAA6120373541612	JNE OKE
V000087   	2017-03-27	\N	1	1323000.00	scantu60@icio.us	Business-focused Jewelery	Jl. Debra no. 148, Dorotea 917 32	26.00	DREAC41097509414	PAHALA
V000088   	2016-12-26	\N	1	4649000.00	dedgell3w@ebay.co.uk	Quality-focused Music	Jl. Grayhawk no. 3, Dalongdong	95.00	DLG3182172841318	JNE REGULER
V000089   	2017-04-24	2017-04-26 05:44:00	4	9809000.00	evinas1f@stanford.edu	Face to face Electronics	Jl. Ludington no. 871, Rive-de-Gier 42809 CEDEX	35.00	RVDB986621039418	TIKI REGULER
V000090   	2016-11-29	2016-12-03 07:20:00	2	3815000.00	servine6k@macromedia.com	Stand-alone Music	Jl. Park Meadow no. 93, D‰rm‰nas	54.00	DRN5004040841500	POS PAKET BIASA
V000091   	2016-05-30	\N	1	2236000.00	lshillingford37@godaddy.com	groupware Books	Jl. Bonner no. 111, Xinzhuang	3.00	XNU9501564641950	POS PAKET BIASA
V000092   	2016-07-12	2016-07-16 01:32:00	4	643000.00	kviles24@1688.com	radical Movies	Jl. Arkansas no. 545, Makariv	34.00	MKI9217828641921	PAHALA
V000093   	2016-01-03	\N	1	550000.00	ggamesonx@webs.com	instruction set Beauty	Jl. Sycamore no. 84, Rio do Sul 89160-000	18.00	ROO8628381541862	LION PARCEL
V000094   	2016-12-07	2016-12-09 07:05:00	4	1627000.00	medgell65@arizona.edu	installation Computers	Jl. David no. 882, Cheqiao	98.00	CEA4034901841403	J&T EXPRESS
V000095   	2016-11-11	2016-11-15 03:18:00	3	934000.00	epotte5n@redcross.org	frame Beauty	Jl. Portage no. 215, Tymbark 34-650	85.00	TMR0824388741082	JNE YES
V000096   	2017-01-28	\N	1	3201000.00	nleither16@google.it	Organic Electronics	Jl. Dayton no. 865, Guohuan	96.00	GOA7770465841777	TIKI REGULER
V000097   	2017-01-30	\N	1	1323000.00	atitterrell0@pagesperso-orange.fr	reciprocal Health	Jl. Green Ridge no. 414, Prochnookopskaya 352947	82.00	PON1359875841135	J&T EXPRESS
V000098   	2016-12-31	2017-01-04 17:11:00	4	5953000.00	dbeagin5d@barnesandnoble.com	functionalities Home	Jl. Hintze no. 491, Anibare	75.00	AIR8824023841882	POS PAKET KILAT
V000099   	2017-02-12	2017-02-15 12:19:00	2	1216000.00	owoolliams1w@unc.edu	approach Kids	Jl. Eliot no. 929, Cocieri MD-4571	66.00	CCR2491096841249	J&T EXPRESS
V0000100  	2017-04-22	2017-04-25 16:06:00	3	6292000.00	nrentoll4q@nytimes.com	non-volatile Games	Jl. Judy no. 669, Ngroto	10.00	NRO2127782941212	J&T EXPRESS
V0000101  	2016-12-20	2016-12-22 20:51:00	2	3657000.00	mkeays6h@posterous.com	solution-oriented Electronics	Jl. Duke no. 105, Itapag‚ 62600-000	58.00	IAG7907622841790	J&T EXPRESS
V0000102  	2017-02-24	2017-02-26 15:34:00	3	1449000.00	ktilbey2m@freewebs.com	analyzing Computers	Jl. Pierstorff no. 373, Sigli	43.00	SG74405978417440	PAHALA
V0000103  	2016-12-27	2016-12-31 12:11:00	2	793000.00	lbottom1b@blinklist.com	Future-proofed Toys	Jl. Texas no. 506, Xiadahe	65.00	XAH7660482841766	WAHANA
V0000104  	2017-01-01	2017-01-05 19:24:00	3	9783000.00	ebridgwoodb@fotki.com	installation Computers	Jl. Roxbury no. 825, Luga 412292	32.00	LG17689238411768	PAHALA
V0000105  	2017-01-26	2017-01-29 04:35:00	2	3061000.00	awinchurst5v@cloudflare.com	project Tools	Jl. Rusk no. 533, Seredka 188422	16.00	SRK4335045841433	TIKI REGULER
V0000106  	2016-12-23	2016-12-27 21:19:00	3	4509000.00	astandell6g@washington.edu	project Computers	Jl. 3rd no. 718, Chalcos	34.00	CAO3797252841379	JNE YES
V0000107  	2016-05-27	2016-05-29 22:04:00	4	947000.00	nrodda11@hibu.com	reciprocal Health	Jl. Crest Line no. 32, Delgerhaan	15.00	DLR8766834641876	TIKI REGULER
V0000108  	2016-08-27	2016-08-29 00:22:00	2	9398000.00	agrimestone5s@jimdo.com	Centralized Home	Jl. Anhalt no. 187, Osogbo	40.00	OOO5237522741523	POS PAKET BIASA
V0000109  	2016-01-11	2016-01-14 02:13:00	4	181000.00	ldoram48@xrea.com	monitoring Books	Jl. Petterle no. 95, Camias 2307	32.00	CMS6148742541614	TIKI REGULER
V0000110  	2016-07-09	2016-07-13 18:35:00	2	4462000.00	pgrollmann1k@posterous.com	functionalities Toys	Jl. Lukken no. 505, Krajan Baru	42.00	KAN1339808641133	POS PAKET KILAT
V0000111  	2016-02-01	2016-02-04 16:27:00	3	2155000.00	hlodford3j@slate.com	Decentralized Grocery	Jl. Shelley no. 689, Iriga City 4431	93.00	II 9404434541940	WAHANA
V0000112  	2016-07-21	2016-07-23 00:47:00	3	1934000.00	bmacmanus3e@arstechnica.com	installation Computers	Jl. Blue Bill Park no. 808, Mil n 185038	76.00	ML82026096418202	TIKI REGULER
V0000113  	2016-12-08	\N	1	5531000.00	medgell65@arizona.edu	Future-proofed Toys	Jl. Algoma no. 809, Pacasmayo	68.00	PCM4939121841493	WAHANA
V0000114  	2017-03-08	\N	1	6735000.00	rjodrelle1c@latimes.com	time-frame Health	Jl. Hermina no. 908, Wola Jachowa 01-943	19.00	WLJ5448998841544	JNE REGULER
V0000115  	2016-04-04	\N	1	59000.00	csiegertsz2j@columbia.edu	asynchronous Industrial	Jl. Northport no. 440, Gniechowice 55-042	71.00	GIH4118089541411	WAHANA
V0000116  	2016-10-30	2016-11-03 08:22:00	2	7255000.00	owoolliams1w@unc.edu	groupware Books	Jl. Lakewood no. 159, Baclayon 6301	23.00	BCY7275187741727	POS PAKET BIASA
V0000117  	2017-03-12	2017-03-16 04:09:00	4	2761000.00	cnewling64@hc360.com	non-volatile Games	Jl. Bartelt no. 44, Magangu‚ 132527	82.00	MGG0671929841067	POS PAKET BIASA
V0000118  	2017-04-24	2017-04-26 17:11:00	4	6054000.00	gmorgans14@nba.com	Business-focused Jewelery	Jl. Fisk no. 121, Debre Zeyit	44.00	DB 2093503941209	PAHALA
V0000119  	2016-08-18	2016-08-22 18:08:00	4	5057000.00	rbuxey5o@scientificamerican.com	conglomeration Jewelery	Jl. Nevada no. 336, Coruripe 57230-000	25.00	CRI2863451741286	JNE OKE
V0000120  	2016-03-16	2016-03-20 18:43:00	4	6317000.00	gtaggett5t@over-blog.com	alliance Toys	Jl. Orin no. 825, Sao Jos‚ dos Campos 12200-000	66.00	SOO5383518541538	JNE REGULER
V0000121  	2017-01-05	2017-01-07 13:28:00	3	7597000.00	cshrimptone5f@gov.uk	circuit Automotive	Jl. Sloan no. 314, Kudowa-Zdr¢j 75-136	34.00	KDA4982263841498	JNE YES
V0000122  	2016-07-21	2016-07-24 21:38:00	3	8181000.00	cbrumen4a@skype.com	analyzer Computers	Jl. Mitchell no. 504, Vladikavkaz 362049	19.00	VAK3117319641311	JNE REGULER
V0000123  	2016-03-31	2016-04-04 19:28:00	4	4308000.00	rbuckland36@last.fm	mission-critical Electronics	Jl. Scoville no. 219, Lisk¢w 62-850	12.00	LSW4252549541425	POS PAKET KILAT
V0000124  	2016-08-15	2016-08-18 03:39:00	2	5336000.00	ireadhead3k@is.gd	Robust Garden	Jl. Gale no. 475, B‚boto	11.00	BBO8532321741853	WAHANA
V0000125  	2016-07-04	2016-07-08 12:46:00	4	7679000.00	leason6p@wufoo.com	Up-sized Movies	Jl. Corben no. 111, Skomlin 98-346	90.00	SOI1936367641193	PAHALA
V0000126  	2016-05-29	2016-06-01 04:35:00	4	8623000.00	astandell6g@washington.edu	Future-proofed Toys	Jl. Mallory no. 879, L'Union 31244 CEDEX	27.00	LUOB361569446416	JNE REGULER
V0000127  	2017-02-02	2017-02-06 09:43:00	4	3574000.00	hlodford3j@slate.com	Implemented Grocery	Jl. Schurz no. 71, Dakoro	90.00	DKO7958206841795	JNE REGULER
V0000128  	2016-04-04	2016-04-07 15:19:00	2	6354000.00	awinchurst5v@cloudflare.com	knowledge base Games	Jl. Kedzie no. 431, Voskhod	80.00	VSO7613879541761	WAHANA
V0000129  	2017-01-20	\N	1	8048000.00	rosesnanes@nationalgeographic.com	customer loyalty Movies	Jl. Main no. 865, Olpiny 38-247	92.00	OPY3253984841325	POS PAKET BIASA
V0000130  	2016-04-02	2016-04-06 22:28:00	4	4243000.00	dhurne4@nydailynews.com	monitoring Books	Jl. Elmside no. 64, Bonga 5504	29.00	BN09063695410906	JNE REGULER
V0000131  	2016-03-24	2016-03-27 17:55:00	2	5585000.00	ntrevorr@fc2.com	global Tools	Jl. Main no. 261, Vilarinho das Cambas 4760-743	82.00	VLI0303124885410	J&T EXPRESS
V0000132  	2017-02-15	2017-02-17 17:25:00	2	853000.00	mmobley2o@mac.com	Ameliorated Movies	Jl. Westridge no. 911, Kuma	10.00	KM00597178410059	POS PAKET KILAT
V0000133  	2016-10-25	2016-10-29 23:03:00	3	5315000.00	mborlease2g@com.com	Compatible Outdoors	Jl. Lyons no. 518, Ga‹t nion	77.00	G‹N4956347741495	WAHANA
V0000134  	2016-03-06	2016-03-10 20:46:00	3	2495000.00	lgreenig18@loc.gov	Advanced Baby	Jl. 7th no. 407, Th? Tr?n Qu?	84.00	T?R3717927541371	LION PARCEL
V0000135  	2016-05-22	2016-05-25 00:42:00	4	8410000.00	rhaselhurst41@netvibes.com	algorithm Garden	Jl. Fairview no. 643, Santiago de Subrrifana 4560-776	8.00	SNA1385777836418	POS PAKET BIASA
V0000136  	2016-07-11	2016-07-15 21:09:00	3	2711000.00	mquittonden51@acquirethisname.com	eco-centric Industrial	Jl. Becker no. 48, Balzers 9496	12.00	BLR2531728641253	POS PAKET KILAT
V0000137  	2017-04-09	2017-04-13 21:20:00	2	857000.00	gzapata4o@slideshare.net	Implemented Grocery	Jl. Mallory no. 949, Cirahab	91.00	CRA8182771941818	TIKI REGULER
V0000138  	2016-07-17	2016-07-19 20:06:00	2	8580000.00	rmullin1q@google.co.uk	complexity Tools	Jl. Veith no. 228, Zebrzydowice 43-410	96.00	ZBY1795878641179	WAHANA
V0000139  	2016-05-10	2016-05-14 00:45:00	2	1690000.00	ehegley25@seattletimes.com	Persevering Outdoors	Jl. Lakewood Gardens no. 558, Yangzhen	43.00	YNH3411482641341	WAHANA
V0000140  	2016-05-01	2016-05-04 08:08:00	4	6507000.00	rexley26@barnesandnoble.com	groupware Books	Jl. Thompson no. 744, Nicolas Bravo 40030	38.00	NCAGRO8010902641	LION PARCEL
V0000141  	2017-03-20	2017-03-22 05:53:00	4	4806000.00	mtooley1s@storify.com	solution-oriented Baby	Jl. Hallows no. 212, Necocl¡ 057878	56.00	NCL9129899841912	JNE REGULER
V0000142  	2016-09-29	2016-10-02 13:37:00	4	7666000.00	kstieger4p@imgur.com	Persevering Outdoors	Jl. Sutteridge no. 449, La Rochelle 17044 CEDEX 1	48.00	L CB795265157419	LION PARCEL
V0000143  	2016-12-06	2016-12-10 23:51:00	4	5554000.00	hgisborne28@slashdot.org	Customizable Shoes	Jl. Glendale no. 205, Yinghai	41.00	YNA2728601841272	WAHANA
V0000144  	2016-06-16	2016-06-19 10:28:00	3	1300000.00	abinnes6o@pcworld.com	Diverse Movies	Jl. Portage no. 803, Zungeru	77.00	ZNR4882706641488	POS PAKET KILAT
V0000145  	2016-06-04	2016-06-06 10:29:00	3	6151000.00	mcrichmer58@mac.com	algorithm Music	Jl. Lakewood no. 925, Parna¡ba 64200-000	63.00	PR¡4716305641471	JNE REGULER
V0000146  	2016-07-04	\N	1	2642000.00	minksteri@aol.com	task-force Movies	Jl. Calypso no. 182, Zhongjiapu	99.00	ZOJ2366267641236	TIKI REGULER
V0000147  	2016-05-01	2016-05-03 03:05:00	3	5101000.00	rpigott17@vimeo.com	system engine Computers	Jl. Heffernan no. 387, Libu	62.00	LB01917026410191	JNE REGULER
V0000148  	2016-12-14	2016-12-17 02:09:00	2	3323000.00	fmasic1h@prweb.com	Implemented Games	Jl. Oneill no. 44, Trˆs Cora‡oes 37410-000	63.00	TˆC0431861841043	J&T EXPRESS
V0000149  	2016-06-25	2016-06-27 01:06:00	4	2020000.00	sdadsond@qq.com	circuit Automotive	Jl. La Follette no. 991, Kelme 86001	71.00	KL37761866413776	POS PAKET KILAT
V0000150  	2016-05-09	2016-05-11 20:50:00	4	5179000.00	jjeffcoat5e@npr.org	Stand-alone Outdoors	Jl. Sherman no. 688, Ca¤uelas 1814	61.00	C¤L0207282641020	PAHALA
V0000151  	2016-06-27	2016-06-29 05:29:00	3	6519000.00	vburchill4t@sohu.com	software Garden	Jl. Melody no. 441, Tungelsta 137 57	76.00	TNLAB09350076410	JNE YES
V0000152  	2017-02-11	2017-02-14 15:49:00	2	9223000.00	hjonathon1t@google.ca	software Garden	Jl. Erie no. 237, San Miguel de Tucum n 4137	54.00	SNI9818286841981	PAHALA
V0000153  	2016-02-02	2016-02-05 22:19:00	4	1322000.00	lehrat55@spiegel.de	Implemented Games	Jl. Spohn no. 9, Floda 448 92	27.00	FOO2951544541295	WAHANA
V0000154  	2017-02-12	2017-02-15 11:19:00	4	1980000.00	msapwellf@wikimedia.org	tertiary Home	Jl. Sherman no. 187, San Nicol s	28.00	SNI5738986841573	TIKI REGULER
V0000155  	2016-08-20	2016-08-22 11:04:00	2	788000.00	cvigars47@irs.gov	analyzing Computers	Jl. Tony no. 310, Fukui-shi 919-0486	84.00	FK-5501961741550	POS PAKET BIASA
V0000156  	2016-01-20	2016-01-24 06:36:00	4	7120000.00	scoppo50@facebook.com	software Books	Jl. Hintze no. 795, Gusinoozyorsk 671178	1.00	GSO8181723541818	TIKI REGULER
V0000157  	2017-01-01	2017-01-05 22:20:00	2	9839000.00	nverlinde5l@globo.com	asymmetric Baby	Jl. Walton no. 995, Pingshan	53.00	PNH3329033841332	J&T EXPRESS
V0000158  	2017-02-20	2017-02-24 07:54:00	2	6917000.00	jjeffcoat5e@npr.org	empowering Beauty	Jl. Caliangt no. 338, Vitry-sur-Seine 94785 CEDEX	33.00	VT-A896277578419	LION PARCEL
V0000159  	2016-06-18	2016-06-22 11:54:00	2	5693000.00	bmacmanus3e@arstechnica.com	analyzing Computers	Jl. Warbler no. 609, Qiangtou	12.00	QAT6980526641698	WAHANA
V0000160  	2016-09-15	2016-09-17 11:33:00	2	7188000.00	stither4h@google.ru	asynchronous Industrial	Jl. Westerfield no. 185, Cruz Alta 98000-000	55.00	CUA6329393741632	J&T EXPRESS
V0000161  	2016-03-03	2016-03-06 04:43:00	3	1739000.00	jalenshev3l@sciencedaily.com	Customer-focused Kids	Jl. Summer Ridge no. 325, Muleng	78.00	MLG7810896541781	J&T EXPRESS
V0000162  	2016-10-07	2016-10-11 10:19:00	2	6402000.00	fmasic1h@prweb.com	Re-engineered Jewelery	Jl. Straubel no. 204, Hegarmanah	24.00	HGM8755385741875	PAHALA
V0000163  	2016-10-04	2016-10-06 12:40:00	3	5320000.00	gjanning3@opensource.org	Secured Baby	Jl. Derek no. 212, Buka	63.00	BK03848557410384	LION PARCEL
V0000164  	2016-11-27	2016-11-30 12:25:00	2	4096000.00	gmorgans14@nba.com	Implemented Games	Jl. Tomscot no. 871, Jintan	4.00	JNN3259420841325	LION PARCEL
V0000165  	2017-01-14	\N	1	5127000.00	pgrollmann1k@posterous.com	Stand-alone Music	Jl. Kropf no. 241, Macabugos 1283	84.00	MCU6303734841630	PAHALA
V0000166  	2017-02-22	2017-02-26 05:13:00	4	2345000.00	ryedall62@arizona.edu	mission-critical Electronics	Jl. Browning no. 872, Mizi	11.00	MZ63404778416340	LION PARCEL
V0000167  	2016-04-22	2016-04-26 04:24:00	3	9234000.00	cabby4b@cyberchimps.com	Compatible Outdoors	Jl. Veith no. 736, Qiancang	75.00	QAA2709921641270	LION PARCEL
V0000168  	2016-04-26	2016-04-29 12:08:00	3	605000.00	bstukings1o@elpais.com	asynchronous Industrial	Jl. Gerald no. 808, Sande Sao Louren‡o 4805-583	25.00	SN 0382527616418	POS PAKET KILAT
V0000169  	2017-01-24	2017-01-28 11:31:00	2	4660000.00	wgoldingay15@shop-pro.jp	analyzing Computers	Jl. Judy no. 235, Wutongkou	43.00	WTG8157525841815	LION PARCEL
V0000170  	2016-11-03	2016-11-05 08:41:00	4	4960000.00	wnotman6v@istockphoto.com	grid-enabled Music	Jl. Hoffman no. 366, Jurish	41.00	JRH6742618741674	PAHALA
V0000171  	2017-04-03	\N	1	504000.00	mborlease2g@com.com	Re-contextualized Automotive	Jl. Ridgeway no. 453, Domoni	7.00	DMI3045021941304	JNE YES
V0000172  	2016-02-03	\N	1	421000.00	gtofanon@ustream.tv	Face to face Electronics	Jl. Marquette no. 84, Thanh Ba	89.00	TA 0858644541085	POS PAKET BIASA
V0000173  	2016-02-22	2016-02-26 22:23:00	3	1865000.00	cbeaman7@instagram.com	holistic Shoes	Jl. Moland no. 346, General Pinedo 3732	80.00	GNA5879716541587	POS PAKET BIASA
V0000174  	2016-01-31	2016-02-03 04:20:00	2	4131000.00	hlodford3j@slate.com	functionalities Toys	Jl. Cascade no. 549, Wangzuizi	8.00	WNU4304124541430	TIKI REGULER
V0000175  	2016-08-06	2016-08-08 22:30:00	3	8391000.00	cchastenet44@jiathis.com	knowledge base Games	Jl. Mcguire no. 328, Al Maslub	76.00	A s2462250741246	JNE REGULER
V0000176  	2016-03-22	2016-03-25 20:27:00	3	5087000.00	astandell6g@washington.edu	algorithm Industrial	Jl. Ronald Regan no. 466, Medell¡n 051059	12.00	MDL4448768541444	JNE OKE
V0000177  	2016-08-12	2016-08-15 17:41:00	3	1210000.00	dbasire4n@nasa.gov	monitoring Books	Jl. Morning no. 803, Police nad Metuj¡ 549 54	37.00	PLE3863201741386	J&T EXPRESS
V0000178  	2016-07-20	2016-07-24 03:00:00	3	3261000.00	lehrat55@spiegel.de	analyzer Computers	Jl. Mockingbird no. 120, Strazhitsa 5179	96.00	SRH8463898641846	POS PAKET BIASA
V0000179  	2016-11-11	2016-11-14 22:55:00	2	8414000.00	cbeaman7@instagram.com	Compatible Outdoors	Jl. Mccormick no. 689, Chengbei	100.00	CEB3194098741319	JNE REGULER
V0000180  	2017-04-10	\N	1	764000.00	paskem3o@yale.edu	installation Computers	Jl. Briar Crest no. 719, Aguas Corrientes	98.00	AU 6412481941641	WAHANA
V0000181  	2016-11-13	2016-11-15 11:31:00	4	2427000.00	gtaggett5t@over-blog.com	empowering Beauty	Jl. Lyons no. 555, Kasreman Wetan	41.00	KSM8666309741866	LION PARCEL
V0000182  	2016-04-14	2016-04-17 19:20:00	4	4578000.00	rpigott17@vimeo.com	holistic Shoes	Jl. Sunfield no. 661, Garissa	68.00	GRS2561660641256	J&T EXPRESS
V0000183  	2016-09-20	2016-09-24 02:30:00	4	2570000.00	vhabbeshawh@ifeng.com	mission-critical Baby	Jl. Longview no. 861, Toulon 83060 CEDEX	52.00	TUNB863683347416	JNE YES
V0000184  	2016-05-21	2016-05-23 15:35:00	3	2337000.00	cbrumen4a@skype.com	grid-enabled Music	Jl. Manitowish no. 50, East End BH21	92.00	ESEENG4494483641	JNE YES
V0000185  	2016-03-06	2016-03-08 22:17:00	3	170000.00	elamcken27@hud.gov	solution-oriented Baby	Jl. Clemons no. 951, Guashe	65.00	GAE0562037541056	PAHALA
V0000186  	2016-07-06	2016-07-10 12:46:00	3	5625000.00	servine6k@macromedia.com	Re-engineered Jewelery	Jl. Dwight no. 688, Narol 37-610	85.00	NR99190876419919	JNE OKE
V0000187  	2016-08-17	2016-08-21 21:05:00	4	2544000.00	mcrichmer58@mac.com	Business-focused Jewelery	Jl. Twin Pines no. 936, Xueshan	1.00	XEA9197641741919	PAHALA
V0000188  	2017-01-07	2017-01-11 08:51:00	3	4583000.00	astandell6g@washington.edu	Quality-focused Music	Jl. Norway Maple no. 967, Tabuc Pontevedra 5815	68.00	TB 3609773841360	JNE REGULER
V0000189  	2016-06-04	2016-06-07 13:03:00	3	3873000.00	kdibdale5q@bandcamp.com	Face to face Electronics	Jl. Vidon no. 578, Timurjaya	3.00	TMJ8835405641883	TIKI REGULER
V0000190  	2016-02-09	2016-02-11 00:18:00	2	1947000.00	mmcgarvey6d@yellowbook.com	Stand-alone Music	Jl. Cascade no. 686, Bijaepasu	18.00	BJP6807794541680	POS PAKET BIASA
V0000191  	2016-03-31	2016-04-02 10:02:00	3	8324000.00	kchastelain6l@ucsd.edu	groupware Books	Jl. Springs no. 467, Nancheng	24.00	NNE8358149541835	POS PAKET BIASA
V0000192  	2016-12-28	2017-01-01 22:55:00	4	1848000.00	vburchill4t@sohu.com	radical Movies	Jl. Walton no. 443, Tibakisa	47.00	TBI8175692841817	PAHALA
V0000193  	2016-06-07	2016-06-10 22:58:00	4	4648000.00	ireadhead3k@is.gd	instruction set Beauty	Jl. Laurel no. 396, Smirice 503 03	71.00	SIC0030435641003	LION PARCEL
V0000194  	2016-12-07	2016-12-09 08:57:00	4	1404000.00	bstukings1o@elpais.com	installation Computers	Jl. Utah no. 866, Guarar‚	2.00	GAR0401011841040	J&T EXPRESS
V0000195  	2016-01-28	2016-01-30 22:20:00	4	6883000.00	djentle13@live.com	frame Beauty	Jl. Holmberg no. 809, Cerca la Source	38.00	CR 9069104541906	JNE YES
V0000196  	2016-07-12	2016-07-15 06:26:00	3	5100000.00	ireadhead3k@is.gd	Organic Electronics	Jl. Arizona no. 429, Muchkapskiy 394961	13.00	MCA6674038641667	TIKI REGULER
V0000197  	2016-11-24	2016-11-26 13:23:00	2	1030000.00	sklimentov4k@creativecommons.org	reciprocal Health	Jl. Pepper Wood no. 243, Pesisir	76.00	PSI5383999741538	J&T EXPRESS
V0000198  	2016-11-14	2016-11-18 08:02:00	2	8969000.00	hjonathon1t@google.ca	functionalities Home	Jl. Basil no. 433, Jundian	25.00	JNA1350119741135	POS PAKET KILAT
V0000199  	2017-01-22	2017-01-25 21:30:00	4	5966000.00	pshillington1m@usda.gov	approach Kids	Jl. Armistice no. 393, Uddevalla 451 95	24.00	UDAO306021584130	J&T EXPRESS
V0000200  	2016-09-25	2016-09-29 08:35:00	4	4648000.00	istoate5w@wix.com	non-volatile Games	Jl. Talisman no. 633, Dukuhtengah	22.00	DKT9152974741915	J&T EXPRESS
V0000201  	2017-03-09	2017-03-13 10:14:00	3	3270000.00	pnursey4r@myspace.com	solution-oriented Electronics	Jl. Arapahoe no. 134, Jardim do Serid¢ 59343-000	4.00	JRM1544509841154	J&T EXPRESS
V0000202  	2016-04-01	\N	1	6930000.00	gtackell68@rambler.ru	analyzing Computers	Jl. Becker no. 251, Rzepiennik Strzyzewski 33-163	10.00	REE8745359541874	PAHALA
V0000203  	2016-09-21	2016-09-23 07:11:00	3	7135000.00	istreeton2u@yellowbook.com	Future-proofed Toys	Jl. Clemons no. 689, Vale da Serra 2350-259	13.00	VLD1446814447414	WAHANA
V0000204  	2016-03-03	2016-03-07 13:23:00	3	5189000.00	rstump59@thetimes.co.uk	installation Computers	Jl. Ridge Oak no. 574, Bajawa	87.00	BJA7041107541704	PAHALA
V0000205  	2017-02-15	2017-02-17 21:29:00	2	1613000.00	pbroadbear2a@indiatimes.com	project Tools	Jl. Spaight no. 606, Yekimovichi 216533	48.00	YKO8714917841871	TIKI REGULER
V0000206  	2016-01-19	2016-01-22 15:55:00	3	293000.00	rmouland4l@psu.edu	project Computers	Jl. Dayton no. 205, Libertador General San Mart¡n 5771	9.00	LBT9398123541939	JNE YES
V0000207  	2016-06-24	2016-06-28 10:40:00	2	5388000.00	lgreenig18@loc.gov	reciprocal Health	Jl. Weeping Birch no. 325, Bagani	98.00	BGI6184676641618	TIKI REGULER
V0000208  	2016-04-25	2016-04-28 14:29:00	4	8962000.00	erihanek66@surveymonkey.com	Centralized Home	Jl. Carpenter no. 142, Zhuangshi	9.00	ZUG0654951641065	POS PAKET BIASA
V0000209  	2016-04-15	2016-04-18 22:09:00	3	3807000.00	abinnes6o@pcworld.com	monitoring Books	Jl. Reindahl no. 994, Brest 29213 CEDEX 1	95.00	BEA2841857064184	TIKI REGULER
V0000210  	2017-01-05	2017-01-09 09:38:00	2	5084000.00	epotte5n@redcross.org	functionalities Toys	Jl. North no. 257, Lavia 38601	29.00	LV38090638413809	POS PAKET KILAT
V0000211  	2016-05-23	2016-05-25 04:26:00	2	7844000.00	yseago4v@geocities.com	Decentralized Grocery	Jl. Straubel no. 107, Ayagoz	20.00	AAZ5757793641575	WAHANA
V0000212  	2017-03-14	2017-03-18 09:34:00	3	4192000.00	rmouland4l@psu.edu	installation Computers	Jl. Ronald Regan no. 782, Obroshyne	95.00	ORH1804849841180	TIKI REGULER
V0000213  	2016-07-12	2016-07-15 03:11:00	3	7111000.00	gtaggett5t@over-blog.com	Future-proofed Toys	Jl. Russell no. 892, Le Mans 72052 CEDEX 2	33.00	L NB541139286414	WAHANA
V0000214  	2016-11-09	2016-11-13 16:51:00	4	6675000.00	zbaybutt6w@cafepress.com	time-frame Health	Jl. Dexter no. 835, Hujra 56170	67.00	HJ36201787413620	JNE REGULER
V0000215  	2017-03-22	2017-03-24 20:10:00	2	6093000.00	sdadsond@qq.com	asynchronous Industrial	Jl. Messerschmidt no. 144, Nangxian	67.00	NNI0543120941054	WAHANA
V0000216  	2016-02-17	\N	1	7775000.00	hluney5c@bloglovin.com	groupware Books	Jl. Loomis no. 418, Baiyanghe	11.00	BIN7397475541739	POS PAKET BIASA
V0000217  	2016-05-27	2016-05-30 04:25:00	2	7707000.00	nwemm2e@meetup.com	non-volatile Games	Jl. Riverside no. 523, Yushikalasu	73.00	YSK7013234641701	POS PAKET BIASA
V0000218  	2016-10-23	\N	1	3479000.00	msteggals6q@ox.ac.uk	Business-focused Jewelery	Jl. Texas no. 275, Montr‚al-Ouest H5B	48.00	MN‚QC29164277412	PAHALA
V0000219  	2016-06-19	\N	1	29000.00	apacher3h@etsy.com	conglomeration Jewelery	Jl. Anderson no. 634, Tantou	23.00	TNU4957636641495	JNE OKE
V0000220  	2016-07-07	2016-07-11 21:42:00	3	8315000.00	ahaverson3v@columbia.edu	alliance Toys	Jl. Ilene no. 341, Santiago de las Vegas	57.00	SNA1777297641177	JNE REGULER
V0000221  	2016-01-23	2016-01-27 09:19:00	3	460000.00	lcrichley19@noaa.gov	circuit Automotive	Jl. Hazelcrest no. 508, San Antonio	95.00	SNN9870453541987	JNE YES
V0000222  	2017-01-06	2017-01-09 08:28:00	2	5798000.00	rharcarse54@buzzfeed.com	analyzer Computers	Jl. Manitowish no. 567, Kosakowo 81-198	99.00	KSO9331963841933	JNE REGULER
V0000223  	2016-08-13	2016-08-16 08:39:00	3	1509000.00	epotte5n@redcross.org	mission-critical Electronics	Jl. Oak Valley no. 434, Muhur	36.00	MH24577017412457	POS PAKET KILAT
V0000224  	2017-01-18	2017-01-21 18:36:00	2	8426000.00	scoppo50@facebook.com	Robust Garden	Jl. Meadow Vale no. 805, Hofors 813 91	66.00	HFSX716467484171	WAHANA
V0000225  	2017-02-26	2017-03-02 10:50:00	4	4622000.00	msapwellf@wikimedia.org	Up-sized Movies	Jl. Waxwing no. 177, V„xj” 351 88	1.00	VXG8326018841832	PAHALA
V0000226  	2016-07-31	2016-08-04 16:38:00	3	4303000.00	leason6p@wufoo.com	Future-proofed Toys	Jl. Merry no. 737, Sampangan	46.00	SMN4803899641480	JNE REGULER
V0000227  	2016-10-05	\N	1	1725000.00	castlesa@paginegialle.it	Implemented Grocery	Jl. Annamark no. 394, Kudahuvadhoo	65.00	KDU6029665741602	JNE REGULER
V0000228  	2016-12-23	2016-12-26 11:12:00	3	2963000.00	ggamesonx@webs.com	knowledge base Games	Jl. Old Gate no. 659, Yanqi	14.00	YN36519428413651	WAHANA
V0000229  	2016-09-18	2016-09-22 08:53:00	4	2707000.00	forudden6m@webeden.co.uk	customer loyalty Movies	Jl. Vera no. 888, Aguia Branca 29795-000	56.00	AU 4388814741438	POS PAKET BIASA
V0000230  	2017-01-09	2017-01-12 22:24:00	4	2808000.00	gtofanon@ustream.tv	monitoring Books	Jl. Stone Corner no. 42, Camarate 2680-005	28.00	CMA1156600048415	JNE REGULER
V0000231  	2016-02-02	2016-02-06 07:52:00	3	3632000.00	ktilbey2m@freewebs.com	global Tools	Jl. Northland no. 395, Lutut¢w 98-360	8.00	LT¢1759934541175	J&T EXPRESS
V0000232  	2016-02-29	2016-03-03 19:08:00	3	6565000.00	sricardin6s@furl.net	Ameliorated Movies	Jl. Gulseth no. 622, Mapaniqui 3010	82.00	MPI2092776541209	POS PAKET KILAT
V0000233  	2016-12-20	2016-12-23 02:13:00	3	3689000.00	pgrollmann1k@posterous.com	Compatible Outdoors	Jl. Golf no. 894, Asamboka	92.00	AAO2100022841210	WAHANA
V0000234  	2016-08-12	2016-08-14 20:00:00	2	4636000.00	pworsfold3n@chron.com	Advanced Baby	Jl. Kennedy no. 444, Wadeng	58.00	WDG9102301741910	LION PARCEL
V0000235  	2016-07-07	2016-07-10 01:13:00	2	8564000.00	ldoram48@xrea.com	algorithm Garden	Jl. Eastlawn no. 991, Kota Ternate	4.00	KTT1893587641189	POS PAKET BIASA
V0000236  	2016-09-18	\N	1	9335000.00	mvedikhov3i@linkedin.com	eco-centric Industrial	Jl. Corscot no. 635, Pig¡	32.00	PG18124247411812	POS PAKET KILAT
V0000237  	2017-01-11	2017-01-14 23:44:00	4	7002000.00	mcrichmer58@mac.com	Implemented Grocery	Jl. Blackbird no. 742, Ignalina 30001	28.00	INI0428714841042	TIKI REGULER
V0000238  	2016-04-26	2016-04-28 22:38:00	2	7277000.00	amilstead5i@umich.edu	complexity Tools	Jl. Meadow Valley no. 59, Rizal 7104	48.00	RZ99201716419920	WAHANA
V0000239  	2016-11-23	2016-11-25 08:18:00	2	8314000.00	nrentoll4q@nytimes.com	Persevering Outdoors	Jl. Oak no. 39, Nizhniy Bestyakh 678080	8.00	NZI9019889741901	WAHANA
V0000240  	2016-03-23	2016-03-26 16:55:00	3	8952000.00	istoate5w@wix.com	groupware Books	Jl. Maple no. 960, Tor	76.00	TR04125785410412	LION PARCEL
V0000241  	2016-12-15	\N	1	8037000.00	adortonl@nytimes.com	solution-oriented Baby	Jl. Warner no. 207, Jaboticabal 14870-000	6.00	JBI4001081841400	JNE REGULER
V0000242  	2017-02-28	2017-03-02 19:57:00	4	3057000.00	bambersonv@wp.com	Persevering Outdoors	Jl. Shelley no. 214, Suz‰mka 242190	2.00	SZK5281138841528	LION PARCEL
V0000243  	2016-01-04	2016-01-06 03:15:00	3	6147000.00	agatrell49@slate.com	Customizable Shoes	Jl. Mendota no. 527, Anyar	46.00	AY24377815412437	WAHANA
V0000244  	2016-09-16	2016-09-18 12:53:00	2	3351000.00	pmccague6r@a8.net	Diverse Movies	Jl. Upham no. 346, Pervomayske	85.00	PRM0830304741083	POS PAKET KILAT
V0000245  	2017-02-15	2017-02-19 20:02:00	4	4462000.00	kde3g@ebay.co.uk	algorithm Music	Jl. Kropf no. 471, Yanshi	77.00	YNI3698817841369	JNE REGULER
V0000246  	2016-04-27	2016-05-01 15:04:00	2	9209000.00	dbeagin5d@barnesandnoble.com	task-force Movies	Jl. Blaine no. 658, Longlou	27.00	LNO9949671641994	TIKI REGULER
V0000247  	2016-05-05	2016-05-08 10:48:00	3	8290000.00	ffarncombe5h@theguardian.com	system engine Computers	Jl. Onsgard no. 257, Do¤a Remedios Trinidad 3009	5.00	D¤R8035442641803	JNE REGULER
V0000248  	2016-05-13	2016-05-16 08:39:00	4	3984000.00	lbottom1b@blinklist.com	Implemented Games	Jl. Briar Crest no. 782, Pingyang	24.00	PNA1778213641177	J&T EXPRESS
V0000249  	2016-09-23	2016-09-27 08:17:00	3	8988000.00	eduddle34@redcross.org	circuit Automotive	Jl. Transport no. 975, San Fernando 8711	51.00	SNE2468164741246	POS PAKET KILAT
V0000250  	2016-09-22	2016-09-24 23:33:00	4	2446000.00	lcrichley19@noaa.gov	Stand-alone Outdoors	Jl. Hauk no. 724, Kurmuk	49.00	KRK8817854741881	PAHALA
V0000251  	2016-01-15	2016-01-17 00:13:00	4	4695000.00	rdametti2x@narod.ru	software Garden	Jl. Holmberg no. 847, Xiumei	15.00	XUI9186182541918	JNE YES
V0000252  	2016-10-28	\N	1	9552000.00	md3c@about.com	software Garden	Jl. Aberg no. 591, Jega	31.00	JG70298677417029	PAHALA
V0000253  	2017-03-25	2017-03-28 09:48:00	2	8655000.00	rmullin1q@google.co.uk	Implemented Games	Jl. Browning no. 304, Port Elizabeth	1.00	PRE3925340941392	WAHANA
V0000254  	2016-09-24	\N	1	9799000.00	sokeenan23@csmonitor.com	tertiary Home	Jl. Grayhawk no. 507, Lees Summit 64082	99.00	LESMO52482747415	TIKI REGULER
V0000255  	2017-02-14	2017-02-17 08:16:00	2	8396000.00	evinas1f@stanford.edu	analyzing Computers	Jl. Onsgard no. 668, Jilong	88.00	JLG1020607841102	POS PAKET BIASA
V0000256  	2016-05-28	2016-05-31 05:20:00	3	8990000.00	mpietasch5y@nsw.gov.au	software Books	Jl. Independence no. 150, Xinshi	83.00	XNI9582144641958	TIKI REGULER
V0000257  	2016-10-30	2016-11-03 19:38:00	3	9898000.00	nrodda11@hibu.com	asymmetric Baby	Jl. Eliot no. 516, Chilliwack N5L	68.00	CIIBC09265877410	J&T EXPRESS
V0000258  	2016-06-18	2016-06-21 09:32:00	4	264000.00	rmouland4l@psu.edu	empowering Beauty	Jl. Scofield no. 768, Tempaling	45.00	TML7532426641753	LION PARCEL
V0000259  	2017-03-14	2017-03-17 18:24:00	2	9011000.00	hluney5c@bloglovin.com	analyzing Computers	Jl. Elmside no. 601, Yuyangguan	53.00	YYG3785159841378	WAHANA
V0000260  	2016-06-14	2016-06-16 12:32:00	3	4924000.00	gbonifazio3f@adobe.com	asynchronous Industrial	Jl. Pepper Wood no. 107, Shiwan	68.00	SIN1557095641155	J&T EXPRESS
V0000261  	2016-06-12	2016-06-14 01:45:00	2	4391000.00	awinchurst5v@cloudflare.com	Customer-focused Kids	Jl. Logan no. 532, Dabao	11.00	DB60959656416095	J&T EXPRESS
V0000262  	2016-10-20	2016-10-22 02:53:00	3	7397000.00	dhurne4@nydailynews.com	Re-engineered Jewelery	Jl. Kingsford no. 183, Paritaman	84.00	PRA6102396741610	PAHALA
V0000263  	2017-02-19	2017-02-22 03:49:00	2	8326000.00	dcaulfield2q@dmoz.org	Secured Baby	Jl. Memorial no. 541, Borovoy 309135	79.00	BRO7916747841791	LION PARCEL
V0000264  	2016-07-01	2016-07-03 08:00:00	3	911000.00	dedgell3w@ebay.co.uk	Implemented Games	Jl. 2nd no. 260, Aasiaat 3950	50.00	ASA0400637641040	LION PARCEL
V0000265  	2016-09-01	2016-09-03 11:14:00	2	7350000.00	mpowney2s@over-blog.com	Stand-alone Music	Jl. Prentice no. 926, Luoshanchuan	46.00	LOA0848272741084	PAHALA
V0000266  	2016-08-22	2016-08-24 01:21:00	2	8036000.00	lgreenig18@loc.gov	mission-critical Electronics	Jl. Gulseth no. 767, Rantauambacang	12.00	RNU6198281741619	LION PARCEL
V0000267  	2016-07-14	\N	1	6114000.00	gberthouloume4w@delicious.com	Compatible Outdoors	Jl. Armistice no. 263, Itupiranga 68580-000	31.00	IUR3409748641340	LION PARCEL
V0000268  	2017-03-01	2017-03-04 05:36:00	2	2879000.00	cnewling64@hc360.com	asynchronous Industrial	Jl. Fisk no. 310, Alah Say	46.00	AAS5166438841516	POS PAKET KILAT
V0000269  	2016-11-28	2016-11-30 08:30:00	4	9256000.00	lradnage30@canalblog.com	analyzing Computers	Jl. Jay no. 468, Coronda 2240	41.00	CRD1281230841128	LION PARCEL
V0000270  	2016-08-15	2016-08-19 23:00:00	2	265000.00	mmcfadden5x@live.com	grid-enabled Music	Jl. Everett no. 244, Yaqian	70.00	YQN1502031741150	PAHALA
V0000271  	2016-07-20	2016-07-23 23:04:00	3	8721000.00	kmiddlemiss6e@umn.edu	Re-contextualized Automotive	Jl. Lien no. 754, Marathon P6A	46.00	MRHON14855096411	JNE YES
V0000272  	2016-08-29	\N	1	9623000.00	rmouland4l@psu.edu	Face to face Electronics	Jl. Pennsylvania no. 863, Zhangfeng	61.00	ZAF0889842741088	POS PAKET BIASA
V0000273  	2016-12-25	2016-12-28 14:00:00	2	4959000.00	olindeboom6x@adobe.com	holistic Shoes	Jl. Thierer no. 190, Paris 15 75737 CEDEX 15	94.00	PR A801447628410	POS PAKET BIASA
V0000274  	2016-05-17	2016-05-20 04:35:00	4	8077000.00	evinas1f@stanford.edu	functionalities Toys	Jl. Forest Dale no. 130, Brant N3T	50.00	BAON127954364112	TIKI REGULER
V0000275  	2016-07-14	2016-07-17 06:56:00	3	5580000.00	lbambrick2p@sfgate.com	knowledge base Games	Jl. Corry no. 989, F”gl” 22710	99.00	FG90497486419049	JNE REGULER
V0000276  	2017-04-22	2017-04-26 16:44:00	4	9844000.00	mpowney2s@over-blog.com	algorithm Industrial	Jl. Becker no. 761, Arau  49220-000	25.00	AA99497829419949	JNE OKE
V0000277  	2017-04-07	2017-04-09 02:18:00	3	8192000.00	mvedikhov3i@linkedin.com	monitoring Books	Jl. Magdeline no. 56, Indaial 89130-000	53.00	IDA6151351941615	J&T EXPRESS
V0000278  	2016-02-29	2016-03-02 11:27:00	4	8801000.00	apetrasek3x@cocolog-nifty.com	analyzer Computers	Jl. Kenwood no. 675, Ratchaburi 84180	44.00	RTA7225476541722	POS PAKET BIASA
V0000279  	2016-09-24	2016-09-28 23:51:00	4	5334000.00	ntye6t@dyndns.org	Compatible Outdoors	Jl. Sage no. 729, Buliran Segundo 3109	86.00	BLA4601674741460	JNE REGULER
V0000280  	2016-01-17	2016-01-19 16:10:00	3	8330000.00	bambersonv@wp.com	installation Computers	Jl. Coolidge no. 256, G‚fyra	45.00	GFA6307403541630	WAHANA
V0000281  	2016-08-14	2016-08-16 16:56:00	3	7185000.00	mquittonden51@acquirethisname.com	empowering Beauty	Jl. Di Loreto no. 262, Bella Vista 10112	72.00	BL 3183911741318	LION PARCEL
V0000282  	2016-04-26	2016-04-29 14:37:00	4	8184000.00	agrimestone5s@jimdo.com	holistic Shoes	Jl. Morning no. 89, Tulc n	100.00	TLN3541861641354	J&T EXPRESS
V0000283  	2016-08-08	2016-08-10 09:27:00	4	9232000.00	cdrysdale4z@dell.com	mission-critical Baby	Jl. Forster no. 151, Ngrambitan	17.00	NRB3748460741374	JNE YES
V0000284  	2016-04-17	2016-04-20 12:11:00	2	7884000.00	tjohnsson35@gizmodo.com	grid-enabled Music	Jl. Lighthouse Bay no. 155, Krajan Demit	15.00	KAN6115980641611	JNE YES
V0000285  	2016-10-27	2016-10-31 02:55:00	3	6325000.00	jwillard5r@51.la	solution-oriented Baby	Jl. Namekagon no. 653, Poggio di Chiesanuova 47894	15.00	PGO0096357741009	PAHALA
V0000286  	2016-01-31	2016-02-04 02:11:00	2	5411000.00	fdarrington6i@unblog.fr	Re-engineered Jewelery	Jl. Bobwhite no. 425, Banraeaba Village	50.00	BNE7826024541782	JNE OKE
V0000287  	2016-07-04	2016-07-06 15:31:00	3	8238000.00	jwillard5r@51.la	Business-focused Jewelery	Jl. Spohn no. 581, Tambillo	20.00	TML5136467641513	PAHALA
V0000288  	2016-01-01	2016-01-03 08:48:00	4	1211000.00	jguice6f@cyberchimps.com	Quality-focused Music	Jl. Banding no. 992, Tomteboda 173 18	93.00	TMBAB41183615414	JNE REGULER
V0000289  	2017-03-28	2017-04-01 20:56:00	4	6109000.00	hbeloe1z@freewebs.com	Face to face Electronics	Jl. Moulton no. 942, Bilbays	55.00	BLY7954370941795	TIKI REGULER
V0000290  	2017-02-26	2017-03-02 13:39:00	4	4542000.00	wfullylovep@aboutads.info	Stand-alone Music	Jl. Oakridge no. 653, Novyye Gorki 155101	8.00	NVE2436118841243	POS PAKET BIASA
V0000291  	2017-01-01	2017-01-05 10:44:00	4	8414000.00	vmolyneaux10@google.com.au	groupware Books	Jl. Eastwood no. 961, Palcamayo	42.00	PLM9947623841994	POS PAKET BIASA
V0000292  	2016-12-30	2017-01-02 02:06:00	2	725000.00	gcopes1@earthlink.net	radical Movies	Jl. Summer Ridge no. 227, Elat	2.00	EA61636038416163	PAHALA
V0000293  	2016-05-06	2016-05-09 12:24:00	2	7802000.00	bcradick3t@squidoo.com	instruction set Beauty	Jl. Claremont no. 455, Siedleczka 37-230	59.00	SEE7447352641744	LION PARCEL
V0000294  	2016-12-26	2016-12-30 07:34:00	2	3116000.00	aodevey2z@prlog.org	installation Computers	Jl. Nova no. 400, Mirny 678179	93.00	MR74673728417467	J&T EXPRESS
V0000295  	2016-10-09	2016-10-13 09:09:00	3	4845000.00	jsedgeman20@sourceforge.net	frame Beauty	Jl. Sunbrook no. 369, Yangyuan	30.00	YNU5914006741591	JNE YES
V0000296  	2016-10-10	2016-10-13 14:11:00	2	7602000.00	vmessruther40@fc2.com	Organic Electronics	Jl. Mariners Cove no. 85, la Massana AD400	81.00	L S7078016741707	TIKI REGULER
V0000297  	2017-01-17	2017-01-19 12:54:00	4	3446000.00	hgisborne28@slashdot.org	reciprocal Health	Jl. Walton no. 882, Tala	17.00	TL85675648418567	J&T EXPRESS
V0000298  	2016-06-07	2016-06-11 16:03:00	3	3447000.00	mquittonden51@acquirethisname.com	functionalities Home	Jl. Jay no. 963, Reconquista 3560	75.00	RCQ1145135641114	POS PAKET KILAT
V0000299  	2017-01-29	2017-02-01 10:53:00	2	2003000.00	dreefe@springer.com	approach Kids	Jl. Banding no. 279, Lauro de Freitas 42700-000	91.00	LU 0817865841081	J&T EXPRESS
V0000300  	2016-05-14	2016-05-17 02:27:00	2	5517000.00	paskem3o@yale.edu	non-volatile Games	Jl. Prairieview no. 682, Krasnosilka	64.00	KAO0682913641068	J&T EXPRESS
V0000301  	2016-07-30	2016-08-02 12:35:00	2	1522000.00	ffarncombe5h@theguardian.com	solution-oriented Electronics	Jl. Anderson no. 158, Eskilstuna 635 11	43.00	EKSD051288964105	J&T EXPRESS
V0000302  	2016-01-04	2016-01-07 08:18:00	2	677000.00	drojel5k@merriam-webster.com	analyzing Computers	Jl. Tennyson no. 471, Romba	54.00	RM21559815412155	PAHALA
V0000303  	2016-08-04	2016-08-07 01:56:00	3	7442000.00	cbakhrushint@reddit.com	Future-proofed Toys	Jl. Rutledge no. 425, Jablonka 34-480	77.00	JBN9775720741977	WAHANA
V0000304  	2017-03-04	2017-03-08 09:44:00	4	2480000.00	bweaver4f@ebay.com	installation Computers	Jl. Eagan no. 592, Es‚ka	65.00	E‚44602688414460	PAHALA
V0000305  	2016-04-18	2016-04-21 06:13:00	4	3159000.00	cabby4b@cyberchimps.com	project Tools	Jl. Starling no. 577, Takasaki 985-0862	97.00	TKA7999590641799	TIKI REGULER
V0000306  	2016-05-30	2016-06-01 01:36:00	4	653000.00	bambersonv@wp.com	project Computers	Jl. Goodland no. 447, Sanlian	82.00	SNA9812754641981	JNE YES
V0000307  	2017-04-04	2017-04-08 16:16:00	3	6878000.00	jguice6f@cyberchimps.com	reciprocal Health	Jl. Corry no. 275, Liuche	49.00	LUE7162231941716	TIKI REGULER
V0000308  	2016-05-27	\N	1	4491000.00	klind1n@diigo.com	Centralized Home	Jl. Novick no. 283, Arauca 810009	4.00	AAA0357034641035	POS PAKET BIASA
V0000309  	2016-04-08	\N	1	112000.00	ghurleston45@netlog.com	monitoring Books	Jl. Stoughton no. 775, Cordeiro 28540-000	57.00	CRI3806210641380	TIKI REGULER
V0000310  	2016-12-25	2016-12-29 13:45:00	2	6753000.00	vmolyneaux10@google.com.au	functionalities Toys	Jl. Bayside no. 974, Dogbo	45.00	DG41537628414153	POS PAKET KILAT
V0000311  	2016-03-15	2016-03-17 05:27:00	4	6416000.00	nrentoll4q@nytimes.com	Decentralized Grocery	Jl. Riverside no. 631, Hongshunli	25.00	HNH5769108541576	WAHANA
V0000312  	2016-10-13	2016-10-17 10:20:00	2	4560000.00	snavein2h@yolasite.com	installation Computers	Jl. Norway Maple no. 146, Bomadi	47.00	BMI5304536741530	TIKI REGULER
V0000313  	2017-03-01	2017-03-03 08:59:00	3	3688000.00	fexrollz@squarespace.com	Future-proofed Toys	Jl. Mitchell no. 933, Blainville J7J	1.00	BAVQC39785388413	WAHANA
V0000314  	2017-01-12	\N	1	5433000.00	mcrichmer58@mac.com	time-frame Health	Jl. Homewood no. 972, Sh‰nm‰ri	71.00	S‰‰8025524841802	JNE REGULER
V0000315  	2017-02-05	\N	1	5440000.00	smeachen33@chronoengine.com	asynchronous Industrial	Jl. Brentwood no. 637, Gingsir	2.00	GNI3455526841345	WAHANA
V0000316  	2016-04-06	2016-04-09 20:12:00	2	112000.00	gbonifazio3f@adobe.com	groupware Books	Jl. Memorial no. 613, Meiyuan Xincun	81.00	MIA3453799541345	POS PAKET BIASA
V0000317  	2016-12-24	2016-12-26 08:49:00	2	1155000.00	istreeton2u@yellowbook.com	non-volatile Games	Jl. Burning Wood no. 22, Grahamstown 6150	96.00	GAM7439652841743	POS PAKET BIASA
V0000318  	2016-06-26	2016-06-29 22:31:00	2	1899000.00	castlesa@paginegialle.it	Business-focused Jewelery	Jl. Upham no. 510, Nancha	38.00	NNA7030896641703	PAHALA
V0000319  	2017-02-19	2017-02-21 18:25:00	4	1551000.00	hduffieldy@bloglovin.com	conglomeration Jewelery	Jl. 3rd no. 494, Shihudang	88.00	SID8478257841847	JNE OKE
V0000320  	2016-09-13	2016-09-17 05:21:00	3	3254000.00	nwemm2e@meetup.com	alliance Toys	Jl. Montana no. 24, Qutun	4.00	QT47044737414704	JNE REGULER
V0000321  	2017-01-09	2017-01-11 10:45:00	4	743000.00	mpietasch5y@nsw.gov.au	circuit Automotive	Jl. Thackeray no. 276, Salzburg 5071	93.00	SLU0590785938419	JNE YES
V0000322  	2016-10-12	2016-10-15 22:46:00	4	7276000.00	jdinesen2y@vimeo.com	analyzer Computers	Jl. Menomonie no. 296, San Rafael 5039	85.00	SNA0732136741073	JNE REGULER
V0000323  	2016-08-02	2016-08-05 16:43:00	4	3872000.00	hstapleton38@geocities.com	mission-critical Electronics	Jl. Ramsey no. 899, Inashiki 925-0563	67.00	IAI9226510741922	POS PAKET KILAT
V0000324  	2017-04-19	\N	1	6920000.00	lbottom1b@blinklist.com	Robust Garden	Jl. Portage no. 938, Huangcun	30.00	HAC2654952941265	WAHANA
V0000325  	2016-08-15	2016-08-19 07:45:00	2	8922000.00	jdinesen2y@vimeo.com	Up-sized Movies	Jl. Buell no. 860, Fufang	57.00	FFG0517421741051	PAHALA
V0000326  	2016-02-12	2016-02-15 07:14:00	4	8510000.00	ggamesonx@webs.com	Future-proofed Toys	Jl. Pearson no. 864, Bejuco 50906	14.00	BJO5421625541542	JNE REGULER
V0000327  	2016-09-26	2016-09-30 19:01:00	3	5802000.00	leason6p@wufoo.com	Implemented Grocery	Jl. Rutledge no. 86, Budta 1774	77.00	BD60561947416056	JNE REGULER
V0000328  	2017-03-30	2017-04-02 13:00:00	3	945000.00	adwelly3u@pen.io	knowledge base Games	Jl. Grim no. 857, Taizhou	66.00	TIO9488780941948	WAHANA
V0000329  	2016-08-15	2016-08-18 02:21:00	3	5404000.00	lgreenig18@loc.gov	customer loyalty Movies	Jl. Sutherland no. 346, Divjak‰	45.00	DVK5967221741596	POS PAKET BIASA
V0000330  	2016-02-04	2016-02-07 23:58:00	3	8639000.00	awinchurst5v@cloudflare.com	monitoring Books	Jl. Arapahoe no. 120, Zapolyarnyy 184433	97.00	ZPY5920364541592	JNE REGULER
V0000331  	2016-05-18	2016-05-22 08:36:00	3	3154000.00	bwollers2v@usnews.com	global Tools	Jl. Coolidge no. 321, Presidencia Roque S enz Pe¤a 5444	41.00	PED6950653641695	J&T EXPRESS
V0000332  	2016-08-18	2016-08-20 22:34:00	2	708000.00	dhurne4@nydailynews.com	Ameliorated Movies	Jl. Roth no. 59, Chornomorske	98.00	COO7769551741776	POS PAKET KILAT
V0000333  	2016-06-15	2016-06-18 10:52:00	4	9948000.00	claraway1l@parallels.com	Compatible Outdoors	Jl. Riverside no. 794, Swierad¢w-Zdr¢j 59-852	77.00	SIA7497895641749	WAHANA
V0000335  	2016-09-17	\N	1	1284000.00	lmaunders4y@google.ca	algorithm Garden	Jl. Havey no. 697, Vidyayevo 184389	35.00	VDY9490414741949	POS PAKET BIASA
V0000336  	2016-01-24	2016-01-26 14:53:00	3	4579000.00	rdametti2x@narod.ru	eco-centric Industrial	Jl. Coleman no. 61, Rasshevatskaya 356012	96.00	RSE2027463541202	POS PAKET KILAT
V0000337  	2016-01-02	2016-01-05 11:59:00	2	228000.00	rdidball53@webs.com	Implemented Grocery	Jl. Ridgeview no. 285, Oefau	6.00	OF07953715410795	TIKI REGULER
V0000338  	2016-06-10	2016-06-12 16:57:00	3	2823000.00	rhallick2d@shutterfly.com	complexity Tools	Jl. Stoughton no. 633, Netanya	51.00	NTY7387755641738	WAHANA
V0000339  	2016-07-21	\N	1	3549000.00	rdidball53@webs.com	Persevering Outdoors	Jl. Scoville no. 479, Shichuan	3.00	SIU0349019641034	WAHANA
V0000340  	2016-10-13	2016-10-15 22:15:00	4	5019000.00	rpitwayj@elegantthemes.com	groupware Books	Jl. Huxley no. 956, Jiangkou	68.00	JAK9096936741909	LION PARCEL
V0000341  	2017-02-16	\N	1	6357000.00	mrobert1i@pcworld.com	solution-oriented Baby	Jl. 4th no. 53, Pavlohrad	3.00	PVH1711327841171	JNE REGULER
V0000342  	2017-02-23	2017-02-25 15:19:00	4	868000.00	dhurne4@nydailynews.com	Persevering Outdoors	Jl. Rieder no. 344, Oklahoma City 73124	64.00	OLOOK48136878414	LION PARCEL
V0000343  	2016-08-21	2016-08-25 23:46:00	4	5397000.00	sokeenan23@csmonitor.com	Customizable Shoes	Jl. Oriole no. 712, Xinzhan	58.00	XNA0813281741081	WAHANA
V0000344  	2016-04-28	2016-05-02 13:39:00	4	1909000.00	bmacmanus3e@arstechnica.com	Diverse Movies	Jl. Roth no. 358, Ostrogozhsk 397855	31.00	OTG5570581641557	POS PAKET KILAT
V0000345  	2016-07-08	2016-07-10 14:25:00	2	532000.00	gtaggett5t@over-blog.com	algorithm Music	Jl. Service no. 573, Vceln  373 82	90.00	VE 0297897641029	JNE REGULER
V0000346  	2016-12-02	2016-12-06 15:04:00	2	9139000.00	msaltsberger69@hud.gov	task-force Movies	Jl. Wayridge no. 949, Listvyanskiy 633224	77.00	LSY8401960841840	TIKI REGULER
V0000347  	2016-09-14	2016-09-16 13:31:00	2	598000.00	fburkman2b@twitpic.com	system engine Computers	Jl. Ridgeview no. 626, I‡ara 88820-000	27.00	IA46895837414689	JNE REGULER
V0000348  	2016-01-12	2016-01-15 23:30:00	3	6822000.00	mthebeau1v@ed.gov	Implemented Games	Jl. Redwing no. 499, Putat Lor	65.00	PT 5341462541534	J&T EXPRESS
V0000349  	2017-03-05	2017-03-09 20:09:00	2	6118000.00	mtooley1s@storify.com	circuit Automotive	Jl. David no. 331, Xinhua	36.00	XNA2754478841275	POS PAKET KILAT
V0000350  	2017-04-12	2017-04-14 16:18:00	2	7515000.00	kbreukelman39@dot.gov	Stand-alone Outdoors	Jl. Oxford no. 926, Awilega	32.00	AIG7193102941719	PAHALA
V0000351  	2016-05-21	2016-05-24 04:16:00	4	7865000.00	tskittreal5p@360.cn	software Garden	Jl. Comanche no. 277, Pereira 4950-770	95.00	PRR1616140836411	JNE YES
V0000352  	2017-03-08	2017-03-12 16:44:00	4	3410000.00	nverlinde5l@globo.com	software Garden	Jl. Tomscot no. 298, Mizdah	22.00	MZH3941998841394	PAHALA
V0000353  	2016-03-10	2016-03-14 13:20:00	2	5467000.00	dbeagin5d@barnesandnoble.com	Implemented Games	Jl. Badeau no. 373, Akita Shi 501-1235	55.00	AI 4506167541450	WAHANA
V0000354  	2016-04-24	2016-04-26 14:30:00	4	7383000.00	cleet1r@infoseek.co.jp	tertiary Home	Jl. Northridge no. 282, Karvia 39930	53.00	KRA2128051641212	TIKI REGULER
V0000355  	2016-01-17	2016-01-20 10:03:00	4	1167000.00	olindeboom6x@adobe.com	analyzing Computers	Jl. Bartillon no. 629, Neoch¢ri	51.00	NO¢3305203541330	POS PAKET BIASA
V0000356  	2016-03-06	2016-03-09 23:03:00	4	3703000.00	rharcarse54@buzzfeed.com	software Books	Jl. Heath no. 987, Lyon 69245 CEDEX 05	35.00	LOB9204503754120	TIKI REGULER
V0000357  	2016-05-30	\N	1	1816000.00	scantu60@icio.us	asymmetric Baby	Jl. Kensington no. 983, Vƒn T—ng	42.00	VN—6277954641627	J&T EXPRESS
V0000358  	2016-12-29	2016-12-31 18:04:00	3	1324000.00	cbeaman7@instagram.com	empowering Beauty	Jl. Elmside no. 580, Binuangan 9008	83.00	BNN6764303841676	LION PARCEL
V0000359  	2016-06-27	2016-06-30 03:25:00	2	5421000.00	gtackell68@rambler.ru	analyzing Computers	Jl. Shelley no. 570, J„rf„lla 176 76	28.00	JRLAB23979966412	WAHANA
V0000360  	2017-02-10	2017-02-14 02:28:00	3	548000.00	twormleightonk@dagondesign.com	asynchronous Industrial	Jl. Independence no. 896, Ajaccio 20184 CEDEX 1	48.00	AAIA548639668414	J&T EXPRESS
V0000361  	2017-02-24	2017-02-27 13:39:00	2	7922000.00	gberthouloume4w@delicious.com	Customer-focused Kids	Jl. Walton no. 286, Chiclayo	6.00	CIA2753497841275	J&T EXPRESS
V0000362  	2017-02-03	2017-02-06 00:51:00	3	8899000.00	bfalshaw2@about.me	Re-engineered Jewelery	Jl. Kenwood no. 884, Doibang	49.00	DIN6903806841690	PAHALA
V0000363  	2016-06-21	2016-06-24 13:01:00	4	5097000.00	dedgell3w@ebay.co.uk	Secured Baby	Jl. Susan no. 391, Carrasqueira 2420-267	85.00	CRS1076041566417	LION PARCEL
V0000364  	2016-11-23	2016-11-27 12:41:00	2	4650000.00	rbuckland36@last.fm	Implemented Games	Jl. Marquette no. 540, Huangshui	95.00	HAS5684099741568	LION PARCEL
V0000365  	2017-01-03	2017-01-05 01:30:00	4	5498000.00	epotte5n@redcross.org	Stand-alone Music	Jl. Pennsylvania no. 261, Yangdian	70.00	YNI3107043841310	PAHALA
V0000366  	2016-12-18	2016-12-20 05:05:00	3	739000.00	csaladine6a@businesswire.com	mission-critical Electronics	Jl. Mayer no. 160, Pamplona/Iru¤a 31005	54.00	PMONC00573028410	LION PARCEL
V0000367  	2016-03-07	2016-03-09 16:14:00	4	8366000.00	gwhitsun5m@china.com.cn	Compatible Outdoors	Jl. Jana no. 474, Laval H7S	41.00	LVQC552763754155	LION PARCEL
V0000368  	2016-07-17	2016-07-19 04:59:00	2	2742000.00	gtaggett5t@over-blog.com	asynchronous Industrial	Jl. Amoth no. 729, Varge Mondar 2635-483	18.00	VR 1164513786416	POS PAKET KILAT
V0000369  	2016-04-08	2016-04-10 03:29:00	4	1259000.00	mpietasch5y@nsw.gov.au	analyzing Computers	Jl. Nevada no. 717, Arauquita 816019	41.00	AAU5416800641541	LION PARCEL
V0000370  	2016-03-20	2016-03-22 20:27:00	3	5083000.00	mmasserel1g@epa.gov	grid-enabled Music	Jl. Arkansas no. 687, Tietˆ 18530-000	14.00	TE94650585419465	PAHALA
V0000371  	2016-03-02	2016-03-05 07:26:00	4	2108000.00	servine6k@macromedia.com	Re-contextualized Automotive	Jl. Oak no. 478, Iwatsuki 339-0061	56.00	IAU5653096541565	JNE YES
V0000372  	2016-09-20	2016-09-22 21:52:00	3	7976000.00	fkynston4i@fda.gov	Face to face Electronics	Jl. Mockingbird no. 426, Dongcheng	99.00	DNH0338044741033	POS PAKET BIASA
V0000373  	2016-04-24	2016-04-26 16:49:00	2	8898000.00	ggamesonx@webs.com	holistic Shoes	Jl. Mcguire no. 267, Javalera 4114	54.00	JVE9956151641995	POS PAKET BIASA
V0000374  	2017-02-26	\N	1	5024000.00	mradsdale1u@imdb.com	functionalities Toys	Jl. Atwood no. 923, Amiens 80031 CEDEX 1	46.00	AISB676182188417	TIKI REGULER
V0000375  	2016-05-16	2016-05-20 13:21:00	4	8899000.00	ntrevorr@fc2.com	knowledge base Games	Jl. Fairview no. 408, Tambov 392999	33.00	TMV5194043641519	JNE REGULER
V0000376  	2016-10-17	2016-10-20 09:41:00	4	2715000.00	blemasney2w@yelp.com	algorithm Industrial	Jl. Nova no. 738, Swinice Warckie 99-140	44.00	SIC6627966741662	JNE OKE
V0000377  	2016-12-07	2016-12-10 22:29:00	4	1971000.00	cchastenet44@jiathis.com	monitoring Books	Jl. Redwing no. 594, Nova Igua‡u 26000-000	39.00	NVI0979411841097	J&T EXPRESS
V0000378  	2016-11-21	\N	1	9223000.00	lmaunders4y@google.ca	analyzer Computers	Jl. Roth no. 84, Nowe Miasto nad Pilica 60-763	69.00	NWM2757479741275	POS PAKET BIASA
V0000379  	2017-04-19	2017-04-22 09:16:00	3	8881000.00	djentle13@live.com	Compatible Outdoors	Jl. Johnson no. 753, Jianli	51.00	JAI5143952941514	JNE REGULER
V0000380  	2016-08-10	\N	1	6726000.00	jguice6f@cyberchimps.com	installation Computers	Jl. Buell no. 343, Hongwon	86.00	HNo3190080741319	WAHANA
V0000381  	2016-04-09	2016-04-11 18:11:00	2	9963000.00	tskittreal5p@360.cn	empowering Beauty	Jl. Atwood no. 282, Darlowo 76-153	30.00	DRW3645220641364	LION PARCEL
V0000382  	2017-02-13	2017-02-15 14:08:00	4	5484000.00	zbaybutt6w@cafepress.com	holistic Shoes	Jl. Raven no. 179, Andramasina	7.00	ADM5394996841539	J&T EXPRESS
V0000383  	2016-08-03	2016-08-07 21:19:00	3	7290000.00	cbrumen4a@skype.com	mission-critical Baby	Jl. Stang no. 159, Bogandinskiy 625520	78.00	BGD3619520741361	JNE YES
V0000384  	2016-01-07	\N	1	3247000.00	mvedikhov3i@linkedin.com	grid-enabled Music	Jl. South no. 434, Waitakere 0782	58.00	WIK6488312541648	JNE YES
V0000385  	2016-05-26	2016-05-30 07:56:00	4	7512000.00	bmacmanus3e@arstechnica.com	solution-oriented Baby	Jl. Logan no. 952, Uppsala 753 14	48.00	UPLC914942464191	PAHALA
V0000386  	2016-02-07	2016-02-10 20:42:00	2	6513000.00	tskittreal5p@360.cn	Re-engineered Jewelery	Jl. Drewry no. 13, Marcara	16.00	MRR5477784541547	JNE OKE
V0000387  	2017-03-12	\N	1	4024000.00	mmasserel1g@epa.gov	Business-focused Jewelery	Jl. Westerfield no. 280, Jongiyeh	54.00	JNY3899729841389	PAHALA
V0000388  	2016-06-22	2016-06-24 05:31:00	2	7800000.00	mhallagan3m@psu.edu	Quality-focused Music	Jl. Chinook no. 469, Gujba	86.00	GJ10537566411053	JNE REGULER
V0000389  	2016-10-06	2016-10-09 05:32:00	4	6051000.00	msaltsberger69@hud.gov	Face to face Electronics	Jl. Union no. 724, Jajarm	90.00	JJM6591375741659	TIKI REGULER
V0000390  	2017-04-02	\N	1	1711000.00	fportinari2r@cdc.gov	Stand-alone Music	Jl. Evergreen no. 258, Kokembang	97.00	KKB8033011941803	POS PAKET BIASA
V0000391  	2016-09-30	2016-10-04 18:32:00	3	1532000.00	istoate5w@wix.com	groupware Books	Jl. Londonderry no. 494, Hongmiao	34.00	HNI1430625741143	POS PAKET BIASA
V0000392  	2016-03-20	2016-03-22 20:40:00	3	3152000.00	sbwy1x@xing.com	radical Movies	Jl. Forest Dale no. 269, Watubuku	96.00	WTU3446058541344	PAHALA
V0000393  	2016-12-30	2017-01-03 21:37:00	4	1032000.00	sbwy1x@xing.com	instruction set Beauty	Jl. Barby no. 580, Capljina	33.00	CPI2783313841278	LION PARCEL
V0000394  	2016-10-05	2016-10-08 04:21:00	2	1443000.00	hgisborne28@slashdot.org	installation Computers	Jl. Hallows no. 449, Oele	21.00	OL08214657410821	J&T EXPRESS
V0000395  	2016-08-25	\N	1	1806000.00	hluney5c@bloglovin.com	frame Beauty	Jl. Bartillon no. 352, Majennang	68.00	MJN7938112741793	JNE YES
V0000396  	2017-03-28	2017-04-01 02:45:00	2	5229000.00	csiegertsz2j@columbia.edu	Organic Electronics	Jl. Stuart no. 589, Taozhuang	4.00	TOU0319660941031	TIKI REGULER
V0000397  	2017-01-16	2017-01-19 21:34:00	3	6388000.00	oernshaw9@ycombinator.com	reciprocal Health	Jl. Gateway no. 638, Mlaka pri Kranju 4212	61.00	MA 0542064841054	J&T EXPRESS
V0000398  	2016-10-08	2016-10-12 13:35:00	3	6673000.00	ldoram48@xrea.com	functionalities Home	Jl. Granby no. 975, Cajamarca 732508	30.00	CJA4573395741457	POS PAKET KILAT
V0000399  	2016-03-14	2016-03-18 04:59:00	2	7349000.00	minksteri@aol.com	approach Kids	Jl. Bluestem no. 827, Cikalong	48.00	CKO3751397541375	J&T EXPRESS
V0000400  	2016-06-07	2016-06-10 14:39:00	2	7403000.00	klind1n@diigo.com	non-volatile Games	Jl. Riverside no. 393, Tabanan	33.00	TBA8730135641873	J&T EXPRESS
V0000401  	2016-11-09	\N	1	7899000.00	kmiddlemiss6e@umn.edu	solution-oriented Electronics	Jl. Spenser no. 225, Jiujie	55.00	JUE5133278741513	J&T EXPRESS
V0000402  	2017-01-26	\N	1	3067000.00	nleither16@google.it	analyzing Computers	Jl. Kinsman no. 439, Houston 77090	92.00	HUOTX94353458419	PAHALA
V0000403  	2016-02-01	\N	1	5479000.00	gkristoffersen63@businesswire.com	Future-proofed Toys	Jl. Arrowood no. 220, Jiuchenggong	82.00	JUE8404634541840	WAHANA
V0000404  	2016-10-30	2016-11-03 12:09:00	3	7853000.00	rstump59@thetimes.co.uk	installation Computers	Jl. Charing Cross no. 83, Al Qanayat	95.00	A N8639287741863	PAHALA
V0000405  	2017-03-18	2017-03-20 22:11:00	4	2629000.00	cmcwhin4g@gizmodo.com	project Tools	Jl. Elgar no. 303, Vermil 4805-550	72.00	VRL0368057898416	TIKI REGULER
V0000406  	2016-04-18	2016-04-21 06:56:00	2	1813000.00	lbottom1b@blinklist.com	project Computers	Jl. Division no. 906, Tanumshede 457 23	43.00	TNSO275269064127	JNE YES
V0000407  	2016-02-14	2016-02-17 09:02:00	4	7624000.00	fkynston4i@fda.gov	reciprocal Health	Jl. Veith no. 146, Nao	94.00	NO57504455415750	TIKI REGULER
V0000408  	2016-05-01	2016-05-05 16:03:00	2	9543000.00	rmooney4j@theatlantic.com	Centralized Home	Jl. Norway Maple no. 279, Larvik 3255	34.00	LRK0798581126419	POS PAKET BIASA
V0000409  	2016-10-15	2016-10-18 19:13:00	2	5899000.00	kviles24@1688.com	monitoring Books	Jl. Everett no. 980, Saki	56.00	SK69785567416978	TIKI REGULER
V0000410  	2016-02-16	2016-02-19 15:44:00	3	7778000.00	eduddle34@redcross.org	functionalities Toys	Jl. Havey no. 85, Charlotte 28205	32.00	CAONC19473655411	POS PAKET KILAT
V0000411  	2017-01-14	2017-01-17 01:02:00	4	3259000.00	gmorgans14@nba.com	Decentralized Grocery	Jl. Anzinger no. 476, Xinghua	12.00	XNU5775534841577	WAHANA
V0000412  	2016-03-07	\N	1	8556000.00	wzanini2t@yahoo.co.jp	installation Computers	Jl. Golf View no. 418, Taoyuan	55.00	TOA2404337541240	TIKI REGULER
V0000413  	2017-03-30	2017-04-01 08:30:00	3	9746000.00	sokeenan23@csmonitor.com	Future-proofed Toys	Jl. Gerald no. 722, Siemiech¢w 33-181	69.00	SEE4462680941446	WAHANA
V0000414  	2016-04-21	2016-04-25 01:52:00	2	4430000.00	jwillard5r@51.la	time-frame Health	Jl. Warrior no. 465, Vila Franca 4935-621	20.00	VLF1693530216419	JNE REGULER
V0000415  	2016-10-02	2016-10-04 11:25:00	3	109000.00	gpickervancew@va.gov	asynchronous Industrial	Jl. Hudson no. 10, Saint Paul 55108	77.00	SI MN85570457418	WAHANA
V0000416  	2017-04-03	\N	1	1465000.00	hlinklet1a@answers.com	groupware Books	Jl. Lyons no. 314, Chuandao	33.00	CUD4278021941427	POS PAKET BIASA
V0000417  	2017-01-24	2017-01-27 16:11:00	3	9287000.00	ao4u@posterous.com	non-volatile Games	Jl. Prentice no. 354, Bialobrzegi 37-114	49.00	BAB6134725841613	POS PAKET BIASA
V0000418  	2016-07-11	2016-07-13 23:59:00	3	1113000.00	ehegley25@seattletimes.com	Business-focused Jewelery	Jl. Donald no. 152, Nowy Sacz 33-320	38.00	NWS9951828641995	PAHALA
V0000419  	2016-04-24	2016-04-28 06:19:00	2	6062000.00	jdinesen2y@vimeo.com	conglomeration Jewelery	Jl. Dexter no. 433, Mayisad	14.00	MYA6478741641647	JNE OKE
V0000420  	2017-04-16	\N	1	3962000.00	lkobpac5u@nih.gov	alliance Toys	Jl. Badeau no. 107, Kipit 1101	14.00	KP49058329414905	JNE REGULER
V0000421  	2016-04-04	2016-04-08 10:08:00	4	5856000.00	cabby4b@cyberchimps.com	circuit Automotive	Jl. Cardinal no. 512, Tongqian	90.00	TNI4944679541494	JNE YES
V0000422  	2016-05-13	2016-05-16 19:37:00	2	3507000.00	mepinoyu@51.la	analyzer Computers	Jl. Buhler no. 113, Tubigan 9022	21.00	TBA3728613641372	JNE REGULER
V0000423  	2016-10-12	2016-10-16 03:55:00	2	512000.00	fportinari2r@cdc.gov	mission-critical Electronics	Jl. Bay no. 562, Valle de Guanape	53.00	VL 4254426741425	POS PAKET KILAT
V0000424  	2017-03-31	2017-04-02 21:39:00	4	6957000.00	lfendleyc@amazon.co.uk	Robust Garden	Jl. Independence no. 825, Duogongma	59.00	DON8636990941863	WAHANA
V0000425  	2016-07-19	\N	1	368000.00	cshrimptone5f@gov.uk	Up-sized Movies	Jl. Summerview no. 511, Liangshuihe	32.00	LAS7712498641771	PAHALA
V0000426  	2016-07-14	2016-07-16 07:50:00	2	2418000.00	hgisborne28@slashdot.org	Future-proofed Toys	Jl. Schmedeman no. 9, East London 5688	33.00	ESL4062848641406	JNE REGULER
V0000427  	2016-08-07	2016-08-11 00:14:00	3	9396000.00	ao4u@posterous.com	Implemented Grocery	Jl. David no. 339, Kegums	27.00	KGS4588250741458	JNE REGULER
V0000428  	2017-04-12	2017-04-15 07:05:00	4	672000.00	bbryant56@bbc.co.uk	knowledge base Games	Jl. Goodland no. 768, Cileueur	17.00	CLE1470891941147	WAHANA
V0000429  	2016-12-26	2016-12-28 16:37:00	4	8905000.00	md3c@about.com	customer loyalty Movies	Jl. Superior no. 385, Libertad 83450	5.00	LBTSON9320772841	POS PAKET BIASA
V0000430  	2017-02-26	2017-03-01 08:29:00	3	6419000.00	cvigars47@irs.gov	monitoring Books	Jl. Canary no. 733, Chowki Jamali 80401	60.00	COI0777908841077	JNE REGULER
V0000431  	2016-08-15	2016-08-18 04:34:00	4	9824000.00	msteggals6q@ox.ac.uk	global Tools	Jl. Troy no. 259, Church End CB4	89.00	CUHENG4565321741	J&T EXPRESS
V0000432  	2016-10-29	2016-10-31 21:31:00	2	8292000.00	reckh2k@123-reg.co.uk	Ameliorated Movies	Jl. Kropf no. 919, Victoria	32.00	VCR0866777741086	POS PAKET KILAT
V0000433  	2017-01-25	2017-01-28 23:53:00	4	5042000.00	hcastanaga1j@fda.gov	Compatible Outdoors	Jl. Buhler no. 99, Banjar Wates Tengah	70.00	BNR8148835841814	WAHANA
V0000434  	2016-01-31	2016-02-03 02:01:00	2	8070000.00	ebewfield1e@icio.us	Advanced Baby	Jl. Old Shore no. 271, Pampas	63.00	PMS9175024541917	LION PARCEL
V0000435  	2016-02-10	2016-02-12 18:01:00	3	7914000.00	mmcgarvey6d@yellowbook.com	algorithm Garden	Jl. Mandrake no. 295, Hod HaSharon	47.00	HDA6037215541603	POS PAKET BIASA
V0000436  	2016-09-30	2016-10-03 11:15:00	3	6545000.00	kde3g@ebay.co.uk	eco-centric Industrial	Jl. Mendota no. 44, Chuangwang	33.00	CUG4514325741451	POS PAKET KILAT
V0000437  	2016-05-18	2016-05-20 06:47:00	4	4852000.00	gkristoffersen63@businesswire.com	Implemented Grocery	Jl. Thierer no. 17, Walton CV35	42.00	WLNENG7304553641	TIKI REGULER
V0000438  	2016-08-07	2016-08-11 17:38:00	3	9563000.00	astandell6g@washington.edu	complexity Tools	Jl. 4th no. 447, Tecovice 763 02	2.00	TcI6941950741694	WAHANA
V0000439  	2016-01-19	2016-01-21 19:54:00	2	2330000.00	mpietasch5y@nsw.gov.au	Persevering Outdoors	Jl. Chive no. 668, Ximei	12.00	XM68233235416823	WAHANA
V0000440  	2016-10-09	2016-10-12 08:03:00	4	9774000.00	kkilmister3q@indiatimes.com	groupware Books	Jl. Oneill no. 242, Bigaan 6105	38.00	BGN2020006741202	LION PARCEL
V0000441  	2016-03-19	2016-03-21 03:23:00	3	1127000.00	uguiducci43@istockphoto.com	solution-oriented Baby	Jl. Dottie no. 219, Les Sables-d'Olonne 85109 CEDEX	40.00	LSAB571875385417	JNE REGULER
V0000442  	2016-04-12	2016-04-16 08:25:00	4	5605000.00	claraway1l@parallels.com	Persevering Outdoors	Jl. Marquette no. 383, Koson	3.00	KS53594406415359	LION PARCEL
V0000443  	2016-05-11	2016-05-13 13:48:00	3	1811000.00	lbarbrookm@google.co.uk	Customizable Shoes	Jl. Welch no. 497, Kambove	82.00	KMV5944792641594	WAHANA
V0000444  	2017-01-26	\N	1	9728000.00	hduffieldy@bloglovin.com	Diverse Movies	Jl. Harbort no. 143, Szelk¢w 45-559	87.00	SE¢6536145841653	POS PAKET KILAT
V0000445  	2016-11-04	2016-11-06 05:39:00	4	5158000.00	pshillington1m@usda.gov	algorithm Music	Jl. Westend no. 398, Tucuran 7019	46.00	TCA5697328741569	JNE REGULER
V0000446  	2016-12-22	2016-12-24 10:04:00	3	3200000.00	dreefe@springer.com	task-force Movies	Jl. Southridge no. 163, Kobenhavn 1738	47.00	KBH1084680104284	TIKI REGULER
V0000447  	2016-03-05	2016-03-07 13:36:00	4	8094000.00	ao4u@posterous.com	system engine Computers	Jl. Gateway no. 805, Mlanggeng	44.00	MAG3794817541379	JNE REGULER
V0000448  	2016-05-28	\N	1	4689000.00	jwheelwright6u@i2i.jp	Implemented Games	Jl. Hagan no. 193, Zhengchang	76.00	ZEC2918544641291	J&T EXPRESS
V0000449  	2017-04-14	2017-04-17 12:48:00	4	7130000.00	bstukings1o@elpais.com	circuit Automotive	Jl. Mallard no. 115, Chenzui	62.00	CEU0804712941080	POS PAKET KILAT
V0000450  	2016-07-06	2016-07-10 20:28:00	2	1457000.00	gmorgans14@nba.com	Stand-alone Outdoors	Jl. Waubesa no. 651, San Jose 41963	73.00	SNOGRO2986387641	PAHALA
V0000451  	2016-05-13	2016-05-15 01:50:00	2	2481000.00	cleet1r@infoseek.co.jp	software Garden	Jl. Sachtjen no. 635, Siasi 7412	19.00	SA92240136419224	JNE YES
V0000452  	2016-03-25	2016-03-28 18:48:00	3	5520000.00	bcradick3t@squidoo.com	software Garden	Jl. Di Loreto no. 560, Beizi	82.00	BI70713985417071	PAHALA
V0000453  	2017-01-29	2017-02-02 19:50:00	4	2195000.00	mradsdale1u@imdb.com	Implemented Games	Jl. 1st no. 130, Agua de Pau 9560-205	32.00	AUD4201491758410	WAHANA
V0000454  	2016-01-05	2016-01-07 06:26:00	3	9585000.00	mdraysay5z@weibo.com	tertiary Home	Jl. Sunfield no. 27, Xinzheng	34.00	XNE8615791541861	TIKI REGULER
V0000455  	2016-04-27	2016-05-01 18:41:00	3	3978000.00	rhallick2d@shutterfly.com	analyzing Computers	Jl. Stone Corner no. 86, Zeleznice 507 13	99.00	ZLN5742871641574	POS PAKET BIASA
V0000456  	2016-01-15	\N	1	757000.00	vhabbeshawh@ifeng.com	software Books	Jl. Sachtjen no. 305, La Roche-sur-Yon 85021 CEDEX	59.00	L CB517393825411	TIKI REGULER
V0000457  	2016-05-19	2016-05-23 02:55:00	4	7472000.00	vburchill4t@sohu.com	asymmetric Baby	Jl. Hanson no. 694, Luotang	66.00	LON7156263641715	J&T EXPRESS
V0000458  	2017-04-25	2017-04-28 17:49:00	4	5061000.00	servine6k@macromedia.com	empowering Beauty	Jl. Iowa no. 248, Jamaica 11407	90.00	JMCNY45524139414	LION PARCEL
V0000459  	2016-05-14	2016-05-18 09:10:00	3	5019000.00	lfendleyc@amazon.co.uk	analyzing Computers	Jl. Veith no. 660, Zhaoguli	35.00	ZAU8007123641800	WAHANA
V0000460  	2017-03-19	\N	1	6193000.00	fsothern6c@dailymail.co.uk	asynchronous Industrial	Jl. Becker no. 282, Gouveia 6290-311	85.00	GUI0930954998413	J&T EXPRESS
V0000461  	2017-01-05	2017-01-09 18:59:00	4	5288000.00	ghurleston45@netlog.com	Customer-focused Kids	Jl. Garrison no. 611, Sarangmeduro	89.00	SRG0972463841097	J&T EXPRESS
V0000462  	2016-03-31	\N	1	4856000.00	csiegertsz2j@columbia.edu	Re-engineered Jewelery	Jl. Sutherland no. 374, Shemonaikha	57.00	SEN8730149541873	PAHALA
V0000463  	2017-01-01	2017-01-04 05:12:00	3	2375000.00	lehrat55@spiegel.de	Secured Baby	Jl. Bayside no. 707, San Juan Pueblo	75.00	SNU4457423841445	LION PARCEL
V0000464  	2016-02-28	2016-03-01 23:41:00	3	8949000.00	hstapleton38@geocities.com	Implemented Games	Jl. Rutledge no. 844, Baisha	22.00	BIA8982076541898	LION PARCEL
V0000465  	2016-01-01	\N	1	3821000.00	sbwy1x@xing.com	Stand-alone Music	Jl. Talmadge no. 29, Sarilhos Grandes 2870-514	37.00	SRH1519182615411	PAHALA
V0000466  	2016-08-03	2016-08-07 16:24:00	3	8463000.00	cbrumen4a@skype.com	mission-critical Electronics	Jl. Dapin no. 243, Shangxing	23.00	SAX1541420741154	LION PARCEL
V0000467  	2016-03-20	2016-03-24 11:17:00	3	338000.00	bbisseker4m@g.co	Compatible Outdoors	Jl. Randy no. 147, Noebesa	34.00	NES9362748541936	LION PARCEL
V0000468  	2016-01-29	2016-01-31 18:07:00	4	9301000.00	bbisseker4m@g.co	asynchronous Industrial	Jl. Gale no. 582, Sovetskaya 347180	51.00	SVS3780904541378	POS PAKET KILAT
V0000469  	2016-05-05	2016-05-07 10:03:00	2	5926000.00	lcrichley19@noaa.gov	analyzing Computers	Jl. Colorado no. 107, Xichang	37.00	XCN1162442641116	LION PARCEL
V0000470  	2017-02-27	\N	1	1481000.00	mcrichmer58@mac.com	grid-enabled Music	Jl. Dayton no. 302, Tulungagung	21.00	TLG3719518841371	PAHALA
V0000471  	2016-05-23	2016-05-25 20:01:00	3	9726000.00	gtofanon@ustream.tv	Re-contextualized Automotive	Jl. Loeprich no. 1, Guder	62.00	GD99633046419963	JNE YES
V0000472  	2017-04-01	\N	1	8670000.00	abinnes6o@pcworld.com	Face to face Electronics	Jl. Schlimgen no. 224, Svoge 2287	43.00	SO81951019418195	POS PAKET BIASA
V0000473  	2017-02-23	2017-02-26 17:45:00	3	8651000.00	jhaggerstone6n@cisco.com	holistic Shoes	Jl. Stuart no. 366, Aglipay 3403	92.00	ALA2591787841259	POS PAKET BIASA
V0000474  	2016-08-16	2016-08-18 12:47:00	3	5268000.00	wfullylovep@aboutads.info	functionalities Toys	Jl. Northridge no. 783, Sangojar	30.00	SNJ8461531741846	TIKI REGULER
V0000475  	2016-11-06	2016-11-09 16:46:00	4	2167000.00	mpowney2s@over-blog.com	knowledge base Games	Jl. Westerfield no. 721, Amieira 7050-511	63.00	AIR0786705487418	JNE REGULER
V0000476  	2016-04-12	\N	1	7166000.00	jjeffcoat5e@npr.org	algorithm Industrial	Jl. Dixon no. 547, Khamyab	93.00	KAa3511340641351	JNE OKE
V0000477  	2016-11-28	2016-12-01 16:01:00	2	7462000.00	gtofanon@ustream.tv	monitoring Books	Jl. 7th no. 796, Leyuan	15.00	LYN2988430841298	J&T EXPRESS
V0000478  	2016-06-29	2016-07-02 20:06:00	2	6226000.00	pgrollmann1k@posterous.com	analyzer Computers	Jl. Messerschmidt no. 283, Xinming	78.00	XNN6080327641608	POS PAKET BIASA
V0000479  	2016-04-24	2016-04-27 21:59:00	2	7273000.00	md3c@about.com	Compatible Outdoors	Jl. Rowland no. 523, Volgograd 309621	8.00	VLG9515351641951	JNE REGULER
V0000480  	2016-03-22	2016-03-26 19:49:00	2	3835000.00	jguice6f@cyberchimps.com	installation Computers	Jl. Pine View no. 421, Ampelgading	25.00	APG8416768541841	WAHANA
V0000481  	2016-09-01	2016-09-03 14:44:00	2	8302000.00	rbuckland36@last.fm	empowering Beauty	Jl. Forest Run no. 268, Laramate	77.00	LRA8601472741860	LION PARCEL
V0000482  	2016-11-10	2016-11-13 00:51:00	4	7127000.00	cbakhrushint@reddit.com	holistic Shoes	Jl. Fremont no. 610, Moraz n 02015	62.00	MR 5709378741570	J&T EXPRESS
V0000483  	2017-02-10	2017-02-13 12:22:00	4	6044000.00	pgrollmann1k@posterous.com	mission-critical Baby	Jl. Iowa no. 455, Alvaraes 69475-000	32.00	AVa4439276841443	JNE YES
V0000484  	2016-11-02	\N	1	3159000.00	hjonathon1t@google.ca	grid-enabled Music	Jl. Mitchell no. 918, Santana 2970-187	22.00	SNN1561722187416	JNE YES
V0000485  	2016-03-01	2016-03-03 15:05:00	2	8197000.00	gtackell68@rambler.ru	solution-oriented Baby	Jl. Manley no. 151, Pointe-…-Pitre 97019 CEDEX	99.00	PIEGP01744865410	PAHALA
V0000486  	2016-02-26	2016-03-01 03:25:00	4	2545000.00	hjonathon1t@google.ca	Re-engineered Jewelery	Jl. Riverside no. 152, Arcos 35588-000	5.00	AC82175465418217	JNE OKE
V0000487  	2016-02-20	2016-02-22 18:43:00	2	3249000.00	rpigott17@vimeo.com	Business-focused Jewelery	Jl. Dawn no. 208, Soanindrariny	70.00	SAN4383995541438	PAHALA
V0000488  	2016-09-30	2016-10-04 02:17:00	4	2535000.00	vmessruther40@fc2.com	Quality-focused Music	Jl. Linden no. 384, Mundybash 652900	74.00	MNB9481025741948	JNE REGULER
V0000489  	2016-09-07	2016-09-11 23:58:00	3	5097000.00	mhallagan3m@psu.edu	Face to face Electronics	Jl. 5th no. 299, Hidalgo 96980	76.00	HDGVER2172923741	TIKI REGULER
V0000490  	2016-07-25	2016-07-29 07:34:00	2	3437000.00	fexrollz@squarespace.com	Stand-alone Music	Jl. Fisk no. 952, Shangpai	29.00	SAP0702349641070	POS PAKET BIASA
V0000491  	2016-08-23	\N	1	2335000.00	rharcarse54@buzzfeed.com	groupware Books	Jl. 8th no. 793, Milwaukee 53234	62.00	MLUWI34327917413	POS PAKET BIASA
V0000492  	2016-06-02	2016-06-04 05:57:00	3	9215000.00	mcrichmer58@mac.com	radical Movies	Jl. Oak no. 894, Vikbolandet 610 25	82.00	VKLE240748464124	PAHALA
V0000493  	2016-09-17	2016-09-19 01:03:00	3	7903000.00	uguiducci43@istockphoto.com	instruction set Beauty	Jl. Ryan no. 706, Yuanjue	6.00	YAU4024704741402	LION PARCEL
V0000494  	2016-08-28	2016-09-01 04:18:00	2	4106000.00	mvedikhov3i@linkedin.com	installation Computers	Jl. Heffernan no. 353, Alepo£	69.00	AE£4297532741429	J&T EXPRESS
V0000495  	2017-01-13	2017-01-16 04:19:00	2	4247000.00	blemasney2w@yelp.com	frame Beauty	Jl. Fisk no. 965, Magallanes 8604	23.00	MGL3711824841371	JNE YES
V0000496  	2017-03-20	2017-03-23 01:16:00	3	17000.00	ggamesonx@webs.com	Organic Electronics	Jl. Sommers no. 687, Petrolina de Goi s 75480-000	8.00	PTL6952799841695	TIKI REGULER
V0000497  	2016-04-07	2016-04-10 06:23:00	4	2792000.00	fexrollz@squarespace.com	reciprocal Health	Jl. Kennedy no. 744, Ocala 34479	73.00	OAFL712010064171	J&T EXPRESS
V0000498  	2016-06-23	2016-06-25 03:51:00	2	551000.00	ggamesonx@webs.com	functionalities Home	Jl. Becker no. 48, La?ij	5.00	L?96835666419683	POS PAKET KILAT
V0000499  	2016-10-26	2016-10-28 23:18:00	3	570000.00	mquittonden51@acquirethisname.com	approach Kids	Jl. Morning no. 422, Shishan	75.00	SIA1393257741139	J&T EXPRESS
V0000500  	2016-06-09	2016-06-13 12:41:00	4	5351000.00	bbryant56@bbc.co.uk	non-volatile Games	Jl. Roxbury no. 786, Dipayal	28.00	DPA1016745641101	J&T EXPRESS
\.


--
-- Data for Name: ulasan; Type: TABLE DATA; Schema: tokokeren; Owner: d04
--

COPY ulasan (email_pembeli, kode_produk, tanggal, rating, komentar) FROM stdin;
rosesnanes@nationalgeographic.com	S0000199	2016-10-30	1	Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.
vcarlton4x@jimdo.com	S000049 	2016-09-26	2	Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.
csaladine6a@businesswire.com	S000054 	2016-09-18	2	Proin risus. Praesent lectus.
ggamesonx@webs.com	S000075 	2016-07-10	4	Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.
bbryant56@bbc.co.uk	S000083 	2016-06-25	4	Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.
gtofanon@ustream.tv	S0000219	2016-09-19	1	Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
rhallick2d@shutterfly.com	S0000125	2016-01-30	4	Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.
uguiducci43@istockphoto.com	S0000115	2017-02-06	5	Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.
rhouldey3d@latimes.com	S000052 	2016-04-07	4	Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.
bbisseker4m@g.co	S0000171	2016-08-25	4	Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.
mpattison1d@spotify.com	S0000167	2016-11-05	1	Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.
rhouldey3d@latimes.com	S00001  	2017-02-14	5	Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.
ktilbey2m@freewebs.com	S000013 	2016-02-22	5	Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.
rjodrelle1c@latimes.com	S0000221	2017-02-20	4	Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.
tjohnsson35@gizmodo.com	S000036 	2016-04-24	3	Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.
cmcwhin4g@gizmodo.com	S0000147	2016-05-15	1	Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
odredge3a@sogou.com	S0000205	2016-08-29	5	Pellentesque at nulla. Suspendisse potenti.
rdidball53@webs.com	S000099 	2016-07-06	3	Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.
rdidball53@webs.com	S0000177	2017-02-20	4	Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.
kviles24@1688.com	S000094 	2017-03-02	4	Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.
vgissing12@google.fr	S000020 	2016-04-07	4	Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.
cbrumen4a@skype.com	S0000190	2016-11-02	2	In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.
lradnage30@canalblog.com	S0000183	2016-07-09	1	Suspendisse potenti. Cras in purus eu magna vulputate luctus.
bstukings1o@elpais.com	S000082 	2016-04-16	5	Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.
apetrasek3x@cocolog-nifty.com	S0000161	2016-07-19	1	Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.
jwheelwright6u@i2i.jp	S0000100	2016-02-25	4	Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.
wnotman6v@istockphoto.com	S000011 	2017-03-28	1	Donec semper sapien a libero. Nam dui.
kde3g@ebay.co.uk	S0000148	2016-05-05	3	Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.
sokeenan23@csmonitor.com	S0000123	2017-04-05	5	Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
sokeenan23@csmonitor.com	S0000157	2016-03-29	4	Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.
kstieger4p@imgur.com	S000062 	2016-07-18	4	Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.
jalenshev3l@sciencedaily.com	S0000149	2016-11-24	1	Sed accumsan felis. Ut at dolor quis odio consequat varius.
rosesnanes@nationalgeographic.com	S0000114	2016-10-11	5	Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.
aodevey2z@prlog.org	S000055 	2016-05-17	3	Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.
gcopes1@earthlink.net	S0000134	2016-01-29	2	Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.
yseago4v@geocities.com	S0000134	2016-04-05	3	Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.
dhurne4@nydailynews.com	S0000241	2017-01-09	4	Quisque ut erat. Curabitur gravida nisi at nibh.
vgissing12@google.fr	S0000221	2017-01-28	4	Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.
erihanek66@surveymonkey.com	S0000110	2016-08-14	2	In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.
lcolicot4d@behance.net	S0000129	2016-07-25	5	Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
ireadhead3k@is.gd	S0000158	2016-05-14	1	Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
ptesh5a@salon.com	S000090 	2017-03-20	2	Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.
ptesh5a@salon.com	S000031 	2016-06-04	1	Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.
rosesnanes@nationalgeographic.com	S0000174	2016-04-12	5	Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.
dedgell3w@ebay.co.uk	S0000246	2016-01-14	1	Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.
ptesh5a@salon.com	S000091 	2016-03-30	5	Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.
fburkman2b@twitpic.com	S000078 	2016-07-15	2	Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.
rdametti2x@narod.ru	S0000212	2016-09-06	1	Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.
jjeffcoat5e@npr.org	S000097 	2017-03-06	5	Aenean fermentum.
rdidball53@webs.com	S0000235	2016-06-05	3	Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.
apetrasek3x@cocolog-nifty.com	S0000198	2016-08-27	1	In quis justo.
lehrat55@spiegel.de	S0000131	2016-02-07	1	Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.
aodevey2z@prlog.org	S0000169	2017-03-28	4	Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.
rbuxey5o@scientificamerican.com	S0000196	2017-04-19	2	Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.
lbarbrookm@google.co.uk	S0000220	2016-11-05	5	Morbi a ipsum. Integer a nibh.
ktilbey2m@freewebs.com	S000092 	2016-07-16	5	Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.
bbisseker4m@g.co	S0000173	2016-03-08	3	Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.
pshillington1m@usda.gov	S000097 	2017-02-22	1	Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
tadame4c@alexa.com	S0000135	2017-03-08	3	Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.
md3c@about.com	S0000100	2016-04-08	2	Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.
vgissing12@google.fr	S000028 	2016-04-01	3	Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.
ptesh5a@salon.com	S000021 	2016-12-12	5	Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.
pshillington1m@usda.gov	S0000132	2016-04-07	1	Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.
rpigott17@vimeo.com	S0000204	2016-03-29	4	Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.
lbarbrookm@google.co.uk	S000081 	2016-09-10	1	Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.
mmcfadden5x@live.com	S0000238	2017-04-03	4	Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.
jjeffcoat5e@npr.org	S0000148	2016-04-27	3	Phasellus in felis. Donec semper sapien a libero.
tblackway61@51.la	S0000136	2016-02-28	2	Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.
smeachen33@chronoengine.com	S000068 	2016-11-11	4	Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.
mvedikhov3i@linkedin.com	S0000249	2017-02-25	1	Phasellus in felis. Donec semper sapien a libero.
hjonathon1t@google.ca	S000070 	2016-01-06	1	Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.
hstapleton38@geocities.com	S000078 	2016-07-30	2	In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.
gzapata4o@slideshare.net	S000080 	2016-05-15	5	Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.
abinnes6o@pcworld.com	S0000215	2016-08-03	1	Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.
hlinklet1a@answers.com	S0000126	2016-07-13	2	Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.
mquittonden51@acquirethisname.com	S0000102	2016-06-06	4	Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.
rdidball53@webs.com	S0000102	2016-11-05	4	Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.
bambersonv@wp.com	S000088 	2016-09-21	3	Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.
nleither16@google.it	S0000236	2016-09-09	5	Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.
umordacai5g@last.fm	S000086 	2016-06-13	3	Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.
agatrell49@slate.com	S000038 	2016-02-11	4	In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.
tjohnsson35@gizmodo.com	S0000183	2016-04-19	1	Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.
rhallick2d@shutterfly.com	S0000240	2016-08-27	2	Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.
ggamesonx@webs.com	S0000107	2016-07-10	4	Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.
lbarbrookm@google.co.uk	S000027 	2017-04-26	2	In congue. Etiam justo. Etiam pretium iaculis justo.
fboheao@baidu.com	S0000144	2016-08-29	4	Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
rjodrelle1c@latimes.com	S000068 	2017-04-17	3	Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.
pnursey4r@myspace.com	S0000230	2016-11-13	3	Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.
cbrumen4a@skype.com	S000030 	2017-01-14	3	Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.
dbasire4n@nasa.gov	S0000135	2016-04-11	4	Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.
cabby4b@cyberchimps.com	S0000204	2016-02-23	2	Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.
hlodford3j@slate.com	S0000201	2016-03-24	1	Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.
sphidgin3y@newyorker.com	S0000216	2016-01-01	4	Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.
medgell65@arizona.edu	S0000223	2017-04-19	1	Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.
ao4u@posterous.com	S000078 	2016-06-09	5	In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.
rmouland4l@psu.edu	S0000109	2016-01-03	2	Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.
ebridgwoodb@fotki.com	S00005  	2016-08-19	5	Ut at dolor quis odio consequat varius. Integer ac leo.
evinas1f@stanford.edu	S00002  	2017-01-02	1	Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.
jjeffcoat5e@npr.org	S0000225	2016-11-21	5	Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.
dhurne4@nydailynews.com	S0000157	2016-01-02	3	Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.
\.


--
-- Name: jasa_kirim jasa_kirim_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY jasa_kirim
    ADD CONSTRAINT jasa_kirim_pkey PRIMARY KEY (nama);


--
-- Name: kategori_utama kategori_utama_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY kategori_utama
    ADD CONSTRAINT kategori_utama_pkey PRIMARY KEY (kode);


--
-- Name: keranjang_belanja keranjang_belanja_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY keranjang_belanja
    ADD CONSTRAINT keranjang_belanja_pkey PRIMARY KEY (pembeli, kode_produk);


--
-- Name: komentar_diskusi komentar_diskusi_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY komentar_diskusi
    ADD CONSTRAINT komentar_diskusi_pkey PRIMARY KEY (pengirim, penerima, waktu);


--
-- Name: list_item list_item_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY list_item
    ADD CONSTRAINT list_item_pkey PRIMARY KEY (no_invoice, kode_produk);


--
-- Name: pelanggan pelanggan_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY pelanggan
    ADD CONSTRAINT pelanggan_pkey PRIMARY KEY (email);


--
-- Name: pengguna pengguna_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY pengguna
    ADD CONSTRAINT pengguna_pkey PRIMARY KEY (email);


--
-- Name: produk produk_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY produk
    ADD CONSTRAINT produk_pkey PRIMARY KEY (kode_produk);


--
-- Name: produk_pulsa produk_pulsa_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY produk_pulsa
    ADD CONSTRAINT produk_pulsa_pkey PRIMARY KEY (kode_produk);


--
-- Name: promo promo_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY promo
    ADD CONSTRAINT promo_pkey PRIMARY KEY (id);


--
-- Name: promo_produk promo_produk_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY promo_produk
    ADD CONSTRAINT promo_produk_pkey PRIMARY KEY (id_promo, kode_produk);


--
-- Name: shipped_produk shipped_produk_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY shipped_produk
    ADD CONSTRAINT shipped_produk_pkey PRIMARY KEY (kode_produk);


--
-- Name: sub_kategori sub_kategori_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY sub_kategori
    ADD CONSTRAINT sub_kategori_pkey PRIMARY KEY (kode);


--
-- Name: toko_jasa_kirim toko_jasa_kirim_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY toko_jasa_kirim
    ADD CONSTRAINT toko_jasa_kirim_pkey PRIMARY KEY (nama_toko, jasa_kirim);


--
-- Name: toko toko_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY toko
    ADD CONSTRAINT toko_pkey PRIMARY KEY (nama);


--
-- Name: transaksi_pulsa transaksi_pulsa_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_pulsa
    ADD CONSTRAINT transaksi_pulsa_pkey PRIMARY KEY (no_invoice);


--
-- Name: transaksi_shipped transaksi_shipped_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_shipped
    ADD CONSTRAINT transaksi_shipped_pkey PRIMARY KEY (no_invoice);


--
-- Name: ulasan ulasan_pkey; Type: CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY ulasan
    ADD CONSTRAINT ulasan_pkey PRIMARY KEY (email_pembeli, kode_produk);


--
-- Name: transaksi_shipped poin_trigger; Type: TRIGGER; Schema: tokokeren; Owner: d04
--

CREATE TRIGGER poin_trigger AFTER UPDATE ON transaksi_shipped FOR EACH ROW EXECUTE PROCEDURE hitung_poin();


--
-- Name: list_item upd_stok_trigger; Type: TRIGGER; Schema: tokokeren; Owner: d04
--

CREATE TRIGGER upd_stok_trigger AFTER INSERT OR DELETE OR UPDATE ON list_item FOR EACH ROW EXECUTE PROCEDURE upd_stok();


--
-- Name: keranjang_belanja keranjang_belanja_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY keranjang_belanja
    ADD CONSTRAINT keranjang_belanja_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES shipped_produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: keranjang_belanja keranjang_belanja_pembeli_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY keranjang_belanja
    ADD CONSTRAINT keranjang_belanja_pembeli_fkey FOREIGN KEY (pembeli) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: komentar_diskusi komentar_diskusi_penerima_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY komentar_diskusi
    ADD CONSTRAINT komentar_diskusi_penerima_fkey FOREIGN KEY (penerima) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: komentar_diskusi komentar_diskusi_pengirim_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY komentar_diskusi
    ADD CONSTRAINT komentar_diskusi_pengirim_fkey FOREIGN KEY (pengirim) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: list_item list_item_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY list_item
    ADD CONSTRAINT list_item_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES shipped_produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: list_item list_item_no_invoice_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY list_item
    ADD CONSTRAINT list_item_no_invoice_fkey FOREIGN KEY (no_invoice) REFERENCES transaksi_shipped(no_invoice) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pelanggan pelanggan_email_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY pelanggan
    ADD CONSTRAINT pelanggan_email_fkey FOREIGN KEY (email) REFERENCES pengguna(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: produk_pulsa produk_pulsa_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY produk_pulsa
    ADD CONSTRAINT produk_pulsa_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: promo_produk promo_produk_id_promo_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY promo_produk
    ADD CONSTRAINT promo_produk_id_promo_fkey FOREIGN KEY (id_promo) REFERENCES promo(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: promo_produk promo_produk_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY promo_produk
    ADD CONSTRAINT promo_produk_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: shipped_produk shipped_produk_kategori_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY shipped_produk
    ADD CONSTRAINT shipped_produk_kategori_fkey FOREIGN KEY (kategori) REFERENCES sub_kategori(kode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: shipped_produk shipped_produk_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY shipped_produk
    ADD CONSTRAINT shipped_produk_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: shipped_produk shipped_produk_nama_toko_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY shipped_produk
    ADD CONSTRAINT shipped_produk_nama_toko_fkey FOREIGN KEY (nama_toko) REFERENCES toko(nama) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sub_kategori sub_kategori_kode_kategori_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY sub_kategori
    ADD CONSTRAINT sub_kategori_kode_kategori_fkey FOREIGN KEY (kode_kategori) REFERENCES kategori_utama(kode) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: toko toko_email_penjual_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY toko
    ADD CONSTRAINT toko_email_penjual_fkey FOREIGN KEY (email_penjual) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: toko_jasa_kirim toko_jasa_kirim_jasa_kirim_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY toko_jasa_kirim
    ADD CONSTRAINT toko_jasa_kirim_jasa_kirim_fkey FOREIGN KEY (jasa_kirim) REFERENCES jasa_kirim(nama) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: toko_jasa_kirim toko_jasa_kirim_nama_toko_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY toko_jasa_kirim
    ADD CONSTRAINT toko_jasa_kirim_nama_toko_fkey FOREIGN KEY (nama_toko) REFERENCES toko(nama) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaksi_pulsa transaksi_pulsa_email_pembeli_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_pulsa
    ADD CONSTRAINT transaksi_pulsa_email_pembeli_fkey FOREIGN KEY (email_pembeli) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaksi_pulsa transaksi_pulsa_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_pulsa
    ADD CONSTRAINT transaksi_pulsa_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES produk_pulsa(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaksi_shipped transaksi_shipped_email_pembeli_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_shipped
    ADD CONSTRAINT transaksi_shipped_email_pembeli_fkey FOREIGN KEY (email_pembeli) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaksi_shipped transaksi_shipped_nama_toko_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY transaksi_shipped
    ADD CONSTRAINT transaksi_shipped_nama_toko_fkey FOREIGN KEY (nama_toko, nama_jasa_kirim) REFERENCES toko_jasa_kirim(nama_toko, jasa_kirim) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ulasan ulasan_email_pembeli_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY ulasan
    ADD CONSTRAINT ulasan_email_pembeli_fkey FOREIGN KEY (email_pembeli) REFERENCES pelanggan(email) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ulasan ulasan_kode_produk_fkey; Type: FK CONSTRAINT; Schema: tokokeren; Owner: d04
--

ALTER TABLE ONLY ulasan
    ADD CONSTRAINT ulasan_kode_produk_fkey FOREIGN KEY (kode_produk) REFERENCES shipped_produk(kode_produk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

