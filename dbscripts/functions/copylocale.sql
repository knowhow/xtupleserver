
CREATE OR REPLACE FUNCTION copyLocale(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pLocaleid ALIAS FOR $1;
  _localeid INTEGER;

BEGIN

  SELECT NEXTVAL('locale_locale_id_seq') INTO _localeid;

  INSERT INTO locale
        (locale_id, locale_code, locale_descrip,
         locale_lang_file,
         locale_dateformat,
         locale_currformat,
         locale_qtyformat,
         locale_comments,
         locale_qtyperformat,
         locale_salespriceformat,
         locale_extpriceformat,
         locale_timeformat,
         locale_timestampformat,
         local_costformat,
         locale_costformat,
         locale_purchpriceformat,
         locale_uomratioformat,
         locale_intervalformat,
         locale_lang_id,
         locale_country_id,
         locale_error_color,
         locale_warning_color,
         locale_emphasis_color,
         locale_altemphasis_color,
         locale_expired_color,
         locale_future_color,
         locale_curr_scale,
         locale_salesprice_scale,
         locale_purchprice_scale,
         locale_extprice_scale,
         locale_cost_scale,
         locale_qty_scale,
         locale_qtyper_scale,
         locale_uomratio_scale)
  SELECT _localeid, '', '',
         locale_lang_file,
         locale_dateformat,
         locale_currformat,
         locale_qtyformat,
         locale_comments,
         locale_qtyperformat,
         locale_salespriceformat,
         locale_extpriceformat,
         locale_timeformat,
         locale_timestampformat,
         local_costformat,
         locale_costformat,
         locale_purchpriceformat,
         locale_uomratioformat,
         locale_intervalformat,
         locale_lang_id,
         locale_country_id,
         locale_error_color,
         locale_warning_color,
         locale_emphasis_color,
         locale_altemphasis_color,
         locale_expired_color,
         locale_future_color,
         locale_curr_scale,
         locale_salesprice_scale,
         locale_purchprice_scale,
         locale_extprice_scale,
         locale_cost_scale,
         locale_qty_scale,
         locale_qtyper_scale,
         locale_uomratio_scale
    FROM locale
   WHERE(locale_id=pLocaleid);

  RETURN _localeid;

END;
$$ LANGUAGE 'plpgsql';

