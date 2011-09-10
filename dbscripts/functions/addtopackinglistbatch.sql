CREATE OR REPLACE FUNCTION addToPackingListBatch(INTEGER) RETURNS INTEGER AS '
DECLARE
  pSoheadid	ALIAS FOR $1;
  returnVal	INTEGER;
BEGIN

  -- MIN because error codes are negative
  SELECT MIN(addToPackingListBatch(''SO'', pSoheadid, shiphead_id)) INTO returnVal
  FROM shiphead
  WHERE ((shiphead_order_id=pSoheadid)
    AND  (NOT shiphead_shipped)
    AND  (shiphead_order_type=''SO''));
  IF (NOT FOUND OR returnVal IS NULL) THEN
    returnVal := addToPackingListBatch(''SO'', pSoheadid, NULL);
  END IF;

  RETURN returnVal;
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION addToPackingListBatch(INTEGER, INTEGER) RETURNS INTEGER AS '
BEGIN
  RETURN addToPackingListBatch(''SO'', $1, $2);
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION addToPackingListBatch(TEXT, INTEGER) RETURNS INTEGER AS '
DECLARE
  pheadtype	ALIAS FOR $1;
  pheadid	ALIAS FOR $2;
  returnVal	INTEGER;
BEGIN
  -- MIN because error codes are negative
  SELECT MIN(addToPackingListBatch(pheadtype, pheadid, shiphead_id)) INTO returnVal
  FROM shiphead
  WHERE ((shiphead_order_id=pheadid)
    AND  (NOT shiphead_shipped)
    AND  (shiphead_order_type=pheadtype));

  IF (NOT FOUND OR returnVal IS NULL) THEN
    returnVal := addToPackingListBatch(pheadtype, pheadid, NULL);
  END IF;

  RETURN returnVal;
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION addToPackingListBatch(TEXT, INTEGER, INTEGER) RETURNS INTEGER AS '
DECLARE
  pheadtype	ALIAS FOR $1;
  pheadid	ALIAS FOR $2;
  pshipheadid	ALIAS FOR $3;
  _check INTEGER;

BEGIN
  SELECT pack_id INTO _check
  FROM pack
  WHERE ((pack_head_id=pheadid)
    AND  ((pack_shiphead_id=pshipheadid) OR 
	  (pshipheadid IS NULL AND pack_shiphead_id IS NULL))
    AND  (pack_head_type=pheadtype)
	);

  IF (NOT FOUND) THEN
    INSERT INTO pack
    ( pack_head_type, pack_head_id, pack_shiphead_id, pack_printed )
    VALUES
    ( pheadtype, pheadid, pshipheadid, FALSE );
    -- Auto Firm Sales Orders conditionally based on metric
    IF ( (pheadtype = ''SO'') AND (fetchMetricBool(''FirmSalesOrderPackingList'')) ) THEN
      UPDATE coitem SET coitem_firm=TRUE
      WHERE (coitem_cohead_id=pheadid);
    END IF; 
  END IF;

  RETURN pheadid;

END;
' LANGUAGE 'plpgsql';
