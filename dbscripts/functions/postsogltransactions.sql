CREATE OR REPLACE FUNCTION postSoGLTransactions() RETURNS BOOLEAN AS '
BEGIN

  UPDATE gltrans
  SET gltrans_exported=TRUE
  WHERE ( (NOT gltrans_exported)
   AND (gltrans_source=''A/R'')
   AND (gltrans_doctype IN (''IN'', ''CM'')) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
