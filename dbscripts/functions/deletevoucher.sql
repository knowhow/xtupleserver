CREATE OR REPLACE FUNCTION deleteVoucher(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pVoheadid ALIAS FOR $1;

BEGIN

  DELETE FROM vodist
  WHERE (vodist_vohead_id=pVoheadid);

  UPDATE recv SET recv_vohead_id=NULL, recv_voitem_id=NULL, recv_invoiced=False
  WHERE (recv_vohead_id=pVoheadid);

  UPDATE poreject SET poreject_vohead_id=NULL, poreject_voitem_id=NULL, poreject_invoiced=False
  WHERE (poreject_vohead_id=pVoheadid);

  DELETE FROM voitem
  WHERE (voitem_vohead_id=pVoheadid);

  DELETE FROM vohead
  WHERE (vohead_id=pVoheadid);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
