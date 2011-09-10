CREATE OR REPLACE FUNCTION deleteWoMaterial(INTEGER) RETURNS INTEGER AS '
DECLARE
  pWomatlid ALIAS FOR $1;

BEGIN

  UPDATE wo
  SET wo_adhoc=TRUE
  FROM womatl
  WHERE ((womatl_wo_id=wo_id)
   AND (womatl_id=pWomatlid));

--  Delete any created P/R for this Womatl
  PERFORM deletePr(''W'', pWomatlid);

  DELETE FROM womatl
  WHERE (womatl_id=pWomatlid);

  RETURN 0;
END;
' LANGUAGE 'plpgsql';