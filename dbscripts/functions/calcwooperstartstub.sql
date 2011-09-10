
CREATE OR REPLACE FUNCTION calcWooperStartStub(INTEGER, INTEGER) RETURNS DATE AS $$
DECLARE
  pWoId         ALIAS FOR $1;
  pBooitemSeqId ALIAS FOR $2;
  _result       DATE;
BEGIN

  IF ( SELECT ((metric_value='t') AND packageIsEnabled('xtmfg'))
         FROM metric
        WHERE(metric_name='Routings') ) THEN
    RETURN xtmfg.calcWooperStart(pWoId, pBooitemSeqId);
  END IF;
  RETURN null;
END;
$$ LANGUAGE 'plpgsql';

