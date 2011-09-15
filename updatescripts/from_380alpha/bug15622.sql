UPDATE recurtype
   SET recurtype_donecheck = 'incdt_status IN (''R'', ''L'')'
 WHERE recurtype_type = 'INCDT';
