CREATE OR REPLACE FUNCTION upd_stok()
RETURNS TRIGGER AS
$$
BEGIN
IF(TG_OP = 'INSERT') THEN
	UPDATE SHIPPED_PRODUK SP SET stok = stok - NEW.kuantitas
	WHERE SP.kode_produk = NEW.kode_produk;
	RETURN NEW;
END IF;

IF(TG_OP = 'UPDATE') THEN
	
	IF((NEW.kuantitas != NULL) AND (NEW.kode_produk != NULL)) THEN
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
$$
LANGUAGE plpgsql;

CREATE TRIGGER upd_stok_trigger
AFTER INSERT OR UPDATE OR DELETE
ON LIST_ITEM FOR EACH ROW
EXECUTE PROCEDURE upd_stok();
