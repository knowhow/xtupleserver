
CREATE OR REPLACE FUNCTION creditmemototal(integer) RETURNS numeric AS $$
DECLARE
  pCreditmemoId ALIAS FOR $1;
  _result NUMERIC;

BEGIN

  -- TO DO:  Add in line item taxes
  SELECT COALESCE(cmhead_freight,0.0) + COALESCE(cmhead_misc,0.0) +
         ( SELECT COALESCE(ROUND(SUM((cmitem_qtycredit * cmitem_qty_invuomratio) * cmitem_unitprice / cmitem_price_invuomratio), 2), 0.0) 
             FROM cmitem
            WHERE (cmitem_cmhead_id=pCreditmemoId)
           ) +
         ( SELECT SUM(tax) * -1 AS tax
           FROM ( SELECT ROUND(SUM(taxdetail_tax),2) AS tax
                  FROM tax
                  JOIN calculateTaxDetailSummary('CM', pCreditmemoId, 'T') ON (taxdetail_tax_id=tax_id)
                  GROUP BY tax_id) AS data )
           INTO _result
  FROM cmhead
  WHERE (cmhead_id=pCreditmemoId);

  IF (NOT FOUND) THEN
    return 0;
  ELSE
    RETURN _result;
  END IF;

END;
$$ LANGUAGE 'plpgsql';

