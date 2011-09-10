SELECT dropIfExists('VIEW', 'ipsitem', 'public', true);
CREATE OR REPLACE VIEW ipsitem AS
  SELECT ipsitem_id,
         ipsitem_ipshead_id,
         ipsitem_item_id,
         ipsitem_qtybreak,
         ipsitem_price,
         ipsitem_qty_uom_id,
         ipsitem_price_uom_id,
         ipsitem_discntprcnt,
         ipsitem_fixedamtdiscount
    FROM ipsiteminfo
      JOIN item ON (ipsitem_item_id=item_id)
    WHERE ((ipsitem_discntprcnt=0.00)
       AND (ipsitem_fixedamtdiscount=0.00))
   UNION
  SELECT ipsitem_id,
         ipsitem_ipshead_id,
         ipsitem_item_id,
         ipsitem_qtybreak,
         noNeg(CAST((item_listprice - (item_listprice * ipsitem_discntprcnt) - ipsitem_fixedamtdiscount) AS NUMERIC(16,4))) AS ipsitem_price,
         ipsitem_qty_uom_id,
         ipsitem_price_uom_id,
         ipsitem_discntprcnt,
         ipsitem_fixedamtdiscount
    FROM ipsiteminfo
      JOIN item ON (ipsitem_item_id=item_id)
    WHERE ((ipsitem_discntprcnt<>0.00)
       OR  (ipsitem_fixedamtdiscount<>0.00));

REVOKE ALL ON TABLE ipsitem FROM PUBLIC;
GRANT ALL ON TABLE ipsitem TO GROUP xtrole;

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO ipsitem DO INSTEAD

INSERT INTO ipsiteminfo (
  ipsitem_id,
  ipsitem_ipshead_id,
  ipsitem_item_id,
  ipsitem_qtybreak,
  ipsitem_price,
  ipsitem_qty_uom_id,
  ipsitem_price_uom_id,
  ipsitem_discntprcnt,
  ipsitem_fixedamtdiscount) 
  VALUES (
  new.ipsitem_id,
  new.ipsitem_ipshead_id,
  new.ipsitem_item_id,
  new.ipsitem_qtybreak,
  new.ipsitem_price,
  new.ipsitem_qty_uom_id,
  new.ipsitem_price_uom_id,
  new.ipsitem_discntprcnt,
  new.ipsitem_fixedamtdiscount );

CREATE OR REPLACE RULE "_UPDATE" AS
    ON UPDATE TO ipsitem DO INSTEAD

UPDATE ipsiteminfo SET
  ipsitem_ipshead_id=new.ipsitem_ipshead_id,
  ipsitem_qtybreak=new.ipsitem_qtybreak,
  ipsitem_price=new.ipsitem_price,
  ipsitem_qty_uom_id=new.ipsitem_qty_uom_id,
  ipsitem_price_uom_id=new.ipsitem_price_uom_id,
  ipsitem_discntprcnt=new.ipsitem_discntprcnt,
  ipsitem_fixedamtdiscount=new.ipsitem_fixedamtdiscount
WHERE (ipsitem_id=old.ipsitem_id);

CREATE OR REPLACE RULE "_DELETE" AS
    ON DELETE TO ipsitem DO INSTEAD

DELETE FROM ipsiteminfo WHERE (ipsitem_id=old.ipsitem_id);