SELECT dropIfExists('VIEW','fltrialbal');
CREATE OR REPLACE VIEW fltrialbal AS (
  SELECT 
    trialbal_period_id,
    trialbal_accnt_id,
    trialbal_beginning,
    trialbal_ending,
    trialbal_credits,
    trialbal_debits
  FROM trialbal
);

GRANT ALL ON fltrialbal TO xtrole;
COMMENT ON VIEW fltrialbal IS 'fltrialbal is a placeholder view for Project Accounting functionality.'