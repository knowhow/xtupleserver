CREATE OR REPLACE FUNCTION moveFlSpecUp(INTEGER) RETURNS INTEGER AS '
DECLARE
  pFlspecid ALIAS FOR $1;
  _from RECORD;
  _to RECORD;

BEGIN

  SELECT flspec_id AS id,
         flspec_flhead_id AS flhead_id,
         flspec_flgrp_id AS flgrp_id,
         flspec_order AS ord INTO _from
    FROM flspec
   WHERE (flspec_id=pFlspecid);
  IF (NOT FOUND) THEN
    RETURN -1;
  END IF;

  SELECT id, type, ord INTO _to
    FROM (SELECT flitem_id AS id, ''I'' AS type, flitem_order AS ord
            FROM flitem
           WHERE ((flitem_flgrp_id=_from.flgrp_id)
             AND  (flitem_flhead_id=_from.flhead_id))
           UNION
          SELECT flgrp_id AS id, ''G'' AS type, flgrp_order AS ord
            FROM flgrp
           WHERE ((flgrp_flgrp_id=_from.flgrp_id)
             AND  (flgrp_flhead_id=_from.flhead_id))
           UNION
          SELECT flspec_id AS id, ''S'' AS type, flspec_order AS ord
            FROM flspec
           WHERE ((flspec_flgrp_id=_from.flgrp_id)
             AND  (flspec_flhead_id=_from.flhead_id)) ) AS data
   WHERE (ord < _from.ord)
   ORDER BY ord DESC
   LIMIT 1;
  IF (FOUND) THEN
    UPDATE flspec
       SET flspec_order=_to.ord
     WHERE (flspec_id=_from.id);

    IF (_to.type=''I'') THEN
      UPDATE flitem
         SET flitem_order=_from.ord
       WHERE (flitem_id=_to.id);
    ELSE
      IF (_to.type=''G'') THEN
        UPDATE flgrp
           SET flgrp_order=_from.ord
         WHERE (flgrp_id=_to.id);
      ELSE
        IF (_to.type=''S'') THEN
          UPDATE flspec
             SET flspec_order=_from.ord
           WHERE (flspec_id=_to.id);
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN 0;

END;
' LANGUAGE 'plpgsql';