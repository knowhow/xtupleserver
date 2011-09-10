CREATE OR REPLACE FUNCTION qtyAllocated(INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pLookAheaddays ALIAS FOR $2;

BEGIN

  RETURN qtyAllocated(pItemsiteid, startOfTime(), (CURRENT_DATE + pLookAheadDays));

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION qtyAllocated(INTEGER, DATE) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pDate ALIAS FOR $2;

BEGIN

  RETURN qtyAllocated(pItemsiteid, startOfTime(), pDate);

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION qtyAllocated(INTEGER, DATE, DATE) RETURNS numeric AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pStartDate ALIAS FOR $2;
  pEndDate ALIAS FOR $3;

BEGIN
 
  IF ( SELECT metric_value
	FROM metric
	WHERE ((metric_name = ''MultiWhs'')
	AND (metric_value = ''t''))) THEN
    IF ( SELECT item_sold
         FROM itemsite, item
         WHERE ((itemsite_item_id=item_id)
         AND (itemsite_id=pItemsiteid)) ) THEN
      RETURN (allocatedForTo(pItemsiteid, pStartDate, pEndDate) +
	      allocatedForWo(pItemsiteid, pStartDate, pEndDate) +
	      allocatedForSo(pItemsiteid, pStartDate, pEndDate));
    ELSE
      RETURN (allocatedForTo(pItemsiteid, pStartDate, pEndDate) +
	      allocatedForWo(pItemsiteid, pStartDate, pEndDate));
    END IF;
  ELSE
    IF ( SELECT item_sold
         FROM itemsite, item
         WHERE ((itemsite_item_id=item_id)
         AND (itemsite_id=pItemsiteid)) ) THEN
      RETURN (allocatedForWo(pItemsiteid, pStartDate, pEndDate) +
	      allocatedForSo(pItemsiteid, pStartDate, pEndDate));
    ELSE
      RETURN (allocatedForWo(pItemsiteid, pStartDate, pEndDate));
    END IF;
  END IF;
END;
' LANGUAGE 'plpgsql';
