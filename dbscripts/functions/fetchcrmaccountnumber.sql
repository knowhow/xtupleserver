CREATE OR REPLACE FUNCTION fetchCRMAccountNumber() RETURNS INTEGER AS $$
BEGIN
  RETURN fetchNextNumber('CRMAccountNumber');
END;
$$ LANGUAGE 'plpgsql';

