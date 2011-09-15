BEGIN;

ALTER TABLE cashrcpt ADD COLUMN cashrcpt_curr_rate NUMERIC;
UPDATE cashrcpt SET
  cashrcpt_curr_rate = curr_rate
FROM curr_rate
WHERE ( (cashrcpt_curr_id = curr_rate.curr_id)
  AND (cashrcpt_distdate BETWEEN curr_effective AND curr_expires) );
ALTER TABLE cashrcpt ALTER COLUMN cashrcpt_curr_rate SET NOT NULL;

COMMIT;