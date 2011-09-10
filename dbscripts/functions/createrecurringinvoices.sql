CREATE OR REPLACE FUNCTION createRecurringInvoices() RETURNS INTEGER AS $$
BEGIN
  RAISE NOTICE 'createRecurringInvoices() has been deprecated; use createRecurringItems(NULL, ''I'') instead.';

  RETURN createRecurringItems(NULL, 'I');
END;
$$ LANGUAGE 'plpgsql';
