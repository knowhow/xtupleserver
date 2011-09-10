CREATE OR REPLACE FUNCTION deleteCompany(INTEGER) RETURNS INTEGER AS '
DECLARE
  pcompanyid ALIAS FOR $1;

BEGIN
  IF (EXISTS(SELECT accnt_id
             FROM accnt, company
             WHERE ((accnt_company=company_number)
               AND  (company_id=pcompanyid))
            )) THEN
    RETURN -1;
  END IF;

  DELETE FROM company
  WHERE (company_id=pcompanyid);

  RETURN pcompanyid;

END;
' LANGUAGE 'plpgsql';
