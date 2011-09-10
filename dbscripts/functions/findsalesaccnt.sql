CREATE OR REPLACE FUNCTION findSalesAccnt(INTEGER, INTEGER) RETURNS INTEGER AS $$
BEGIN
  RETURN findSalesAccnt($1, 'IS', $2);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION findSalesAccnt(INTEGER, TEXT, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pid		ALIAS FOR $1;
  pidType	ALIAS FOR $2;
  pCustid	ALIAS FOR $3;
  _s RECORD;

BEGIN

  IF (pidType = 'I') THEN
    --  Check for a custtype specific rule
    SELECT salesaccnt_id,
	   CASE WHEN ( (salesaccnt_custtype_id<>-1) AND (salesaccnt_prodcat_id<>-1) ) THEN 'A'
		WHEN ( (salesaccnt_custtype_id<>-1) AND (salesaccnt_prodcat_id=-1) ) THEN 'B'
		WHEN ( (salesaccnt_custtype_id=-1) AND (salesaccnt_prodcat_id<>-1) ) THEN 'C'
		ELSE 'D'
	   END AS orderby INTO _s
    FROM salesaccnt, item, prodcat, custinfo, custtype
    WHERE ( (salesaccnt_warehous_id=-1)
      AND  (item_prodcat_id=prodcat_id)
      AND  (cust_custtype_id=custtype_id)
      AND  ( (salesaccnt_prodcat='.*') OR
	    ( (salesaccnt_prodcat_id=-1) AND
	      (salesaccnt_prodcat<>'') AND
	      (prodcat_code ~ salesaccnt_prodcat) ) OR
	    ( (salesaccnt_prodcat_id=prodcat_id) ) )
      AND  ( (salesaccnt_custtype='.*') OR
	    ( (salesaccnt_custtype_id=-1) AND
	      (salesaccnt_custtype<>'') AND
	      (custtype_code ~ salesaccnt_custtype) ) OR
	    ( (salesaccnt_custtype_id=custtype_id) ) )
      AND (item_id=pid)
      AND (cust_id=pCustid) )
     ORDER BY orderby, salesaccnt_custtype DESC, salesaccnt_prodcat DESC
     LIMIT 1;

  ELSIF (pidType = 'IS') THEN
    --  Check for a custtype specific rule
    SELECT salesaccnt_id,
	   CASE WHEN ( (salesaccnt_custtype_id<>-1) AND (salesaccnt_prodcat_id<>-1) ) THEN 'A'
		WHEN ( (salesaccnt_custtype_id<>-1) AND (salesaccnt_prodcat_id=-1) ) THEN 'B'
		WHEN ( (salesaccnt_custtype_id=-1) AND (salesaccnt_prodcat_id<>-1) ) THEN 'C'
		ELSE 'D'
	   END AS orderby INTO _s
    FROM salesaccnt, itemsite, item, prodcat, custinfo, custtype
    WHERE ( ( (salesaccnt_warehous_id=-1) OR
	      (salesaccnt_warehous_id=itemsite_warehous_id) )
     AND (itemsite_item_id=item_id)
     AND (item_prodcat_id=prodcat_id)
     AND (cust_custtype_id=custtype_id)
     AND ( (salesaccnt_prodcat='.*') OR
	   ( (salesaccnt_prodcat_id=-1) AND
	     (salesaccnt_prodcat<>'') AND
	     (prodcat_code ~ salesaccnt_prodcat) ) OR
	   ( (salesaccnt_prodcat_id=prodcat_id) ) )
     AND ( (salesaccnt_custtype='.*') OR
	   ( (salesaccnt_custtype_id=-1) AND
	     (salesaccnt_custtype<>'') AND
	     (custtype_code ~ salesaccnt_custtype) ) OR
	   ( (salesaccnt_custtype_id=custtype_id) ) )
     AND (itemsite_id=pid)
     AND (cust_id=pCustid) ) 
    ORDER BY orderby, salesaccnt_custtype DESC, salesaccnt_prodcat DESC
    LIMIT 1;

  ELSE
    RETURN -2;	-- invalid pidType
  END IF;

  IF (FOUND) THEN
    RETURN _s.salesaccnt_id;
  END IF;

  RETURN -1;

END;
$$
    LANGUAGE plpgsql;
