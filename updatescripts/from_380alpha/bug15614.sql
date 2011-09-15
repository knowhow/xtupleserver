SELECT dropIfExists('FUNCTION', 'deleteVoucher(integer)', 'public');
SELECT dropIfExists('TRIGGER',  'voheadtrigger',          'public');
SELECT dropIfExists('FUNCTION', '_voheadTrigger()',       'public');

UPDATE recurtype
   SET recurtype_delfunc=NULL
 WHERE recurtype_table='vohead';
