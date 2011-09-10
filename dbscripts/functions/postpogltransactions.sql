CREATE OR REPLACE FUNCTION postPoGLTransactions() RETURNS BOOLEAN AS '
BEGIN

  UPDATE gltrans
  SET gltrans_exported=TRUE
  WHERE ( (NOT gltrans_exported)
   AND (gltrans_source=''A/P'')
   AND (gltrans_doctype IN (''VO'')) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
