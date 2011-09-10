BEGIN;

-- Item Source Price View

SELECT dropIfExists('VIEW', 'itemsourceprice', 'api');

CREATE VIEW api.itemsourceprice AS
  SELECT item.item_number::VARCHAR AS item_number, 
	 vendinfo.vend_number::VARCHAR AS vendor, 
         itemsrcp.itemsrcp_qtybreak AS qty_break, 
         itemsrcp.itemsrcp_price AS price_per_unit,  
         curr_symbol.curr_abbr AS currency
   FROM itemsrcp
   LEFT JOIN itemsrc ON itemsrc.itemsrc_id = itemsrcp.itemsrcp_itemsrc_id
   LEFT JOIN item ON itemsrc.itemsrc_item_id = item.item_id
   LEFT JOIN vendinfo ON itemsrc.itemsrc_vend_id = vendinfo.vend_id
   LEFT JOIN curr_symbol ON itemsrcp.itemsrcp_curr_id = curr_symbol.curr_id
  ORDER BY item.item_number::VARCHAR(100), vendinfo.vend_number::VARCHAR(100);

GRANT ALL ON TABLE api.itemsourceprice TO xtrole;
COMMENT ON VIEW api.itemsourceprice IS 'Item Source Price';

-- Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.itemsourceprice DO INSTEAD

  INSERT INTO itemsrcp (
    itemsrcp_itemsrc_id, 
    itemsrcp_qtybreak, 
    itemsrcp_price, 
    itemsrcp_curr_id,
    itemsrcp_updated) 
    VALUES(
    getItemSrcId(new.item_number,new.vendor),
    new.qty_break,
    new.price_per_unit,
    getCurrId(new.currency),
    now());

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO api.itemsourceprice DO INSTEAD

  UPDATE itemsrcp SET 
    itemsrcp_qtybreak = new.qty_break, 
    itemsrcp_price = new.price_per_unit,
    itemsrcp_updated = now(), 
    itemsrcp_curr_id = getcurrid(new.currency)
  WHERE (itemsrcp_itemsrc_id=getItemSrcId(old.item_number,new.vendor)
  AND (itemsrcp_qtybreak=old.qty_break));

CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO api.itemsourceprice DO INSTEAD
    
  DELETE FROM itemsrcp
  WHERE (itemsrcp_itemsrc_id=getItemSrcId(old.item_number,old.vendor)
  AND (itemsrcp_qtybreak=old.qty_break));

COMMIT;
