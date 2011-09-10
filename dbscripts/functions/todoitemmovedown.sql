
CREATE OR REPLACE FUNCTION todoItemMoveDown(INTEGER) RETURNS INTEGER AS '
  DECLARE
    ptodoItemId ALIAS FOR $1;
  BEGIN
    RETURN todoItemMove(ptodoItemId, 1);        -- move toward end of list
  END;
' LANGUAGE 'plpgsql';

