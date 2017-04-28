INSERT

CREATE OR REPLACE FUNCTION insert_list_item()
RETURNS trigger AS
$$
BEGIN
IF(TG_OP='INSERT')THEN
UPDATE SHIPPED_PRODUK K SET stok=(stok-NEW.kuantitas)
WHERE K.kode_produk=NEW.kode_produk;
END IF;
RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_list_item_trigger
AFTER INSERT
ON LIST_ITEM FOR EACH ROW
EXECUTE PROCEDURE insert_list_item();


UPDATE

CREATE OR REPLACE FUNCTION update_list_item()
RETURNS TRIGGER AS
$$
BEGIN
IF(TG_OP='UPDATE')THEN
UPDATE SHIPPED_PRODUK K SET stok=(stok-1)
WHERE K.kode_produk=OLD.kode_produk;

UPDATE SHIPPED_PRODUK K SET stok=(stok+1)
WHERE K.kode_produk=NEW.kode_produk;
END IF;
RETURN NEW
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_list_item_trigger
AFTER UPDATE
ON LIST_ITEM
EXECUTE PROCEDURE update_list_item();


DELETE

CREATE OR REPLACE FUNCTION delete_list_item()
RETURNS TRIGGER AS
$$
BEGIN
IF(TG_OP='DELETE')THEN
UPDATE SHIPPED_PRODUK K SET stok=(stok+OLD.kuantitas)
WHERE K.kode_produk=OLD.kode_produk;
END IF;
RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delete_detail_list_item
AFTER DELETE
ON LIST_ITEM FOR EACH ROW
EXECUTR PROCEDURE delete_list_item();