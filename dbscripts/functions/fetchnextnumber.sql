CREATE OR REPLACE FUNCTION fetchNextNumber(TEXT) RETURNS TEXT AS '
DECLARE
  psequence	ALIAS FOR $1;
  _number	TEXT;
  _numcol	TEXT;
  _select	TEXT;
  _table	TEXT;
  _test		TEXT;

BEGIN
  LOOP
    SELECT CAST(orderseq_number AS text), orderseq_table, orderseq_numcol
	INTO _number, _table, _numcol
    FROM orderseq
    WHERE (orderseq_name=psequence);
    IF (NOT FOUND) THEN
      RAISE EXCEPTION ''Invalid orderseq_name %'', psequence;
    END IF;

    _select := ''SELECT '' || quote_ident(_numcol) ||
	       '' FROM ''  || quote_ident(_table) ||
	       '' WHERE ('' || quote_ident(_numcol) || ''='' ||
               quote_literal(_number) || '');'';

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name=psequence);

    EXECUTE _select INTO _test;

    IF (_test IS NULL OR NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

RETURN _number;

END;
' LANGUAGE 'plpgsql';
