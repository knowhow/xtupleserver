
CREATE OR REPLACE FUNCTION todoItemMoveUp(INTEGER) RETURNS INTEGER AS '
  DECLARE
    ptodoItemId ALIAS FOR $1;
  BEGIN
    RETURN todoItemMove(ptodoItemId, -1);       -- move toward front of list
  END;
' LANGUAGE 'plpgsql';

