CREATE OR REPLACE FUNCTION saveCntct(int,text,int,int,text,text,text,text,text,text,bool,text,text,text,text,text,text,text,text, text) RETURNS INTEGER AS '
DECLARE
  pCntctId ALIAS FOR $1;
  pContactNumber ALIAS FOR $2;
  pCrmAcctId ALIAS FOR $3;
  pAddrId ALIAS FOR $4;
  pHonorific ALIAS FOR $5;
  pFirstName ALIAS FOR $6;
  pMiddleName ALIAS FOR $7;
  pLastName ALIAS FOR $8;
  pSuffix ALIAS FOR $9;
  pInitials ALIAS FOR $10;
  pActive ALIAS FOR $11;
  pPhone ALIAS FOR $12;
  pPhone2 ALIAS FOR $13;
  pFax ALIAS FOR $14;
  pEmail ALIAS FOR $15;
  pWebAddr ALIAS FOR $16;
  pNotes ALIAS FOR $17;
  pTitle ALIAS FOR $18;
  pFlag ALIAS FOR $19;
  pOwnerUsername ALIAS FOR $20;
  _cntctId INTEGER;
  _cntctNumber TEXT;
  _isNew BOOLEAN;
  _flag TEXT;
  _contactCount INTEGER := 0;

BEGIN
  --Validate
  IF ((pFlag IS NULL) OR (pFlag = '''') OR (pFlag = ''CHECK'') OR (pFlag = ''CHANGEONE'') OR (pFlag = ''CHANGEALL'')) THEN
    IF (pFlag='''') THEN
      _flag := ''CHECK'';
    ELSE
      _flag := COALESCE(pFlag,''CHECK'');
    END IF;
  ELSE
	RAISE EXCEPTION ''Invalid Flag (%). Valid flags are CHECK, CHANGEONE or CHANGEALL'', pFlag;
  END IF;
  
  --If there is nothing here get out
  IF ( (pCntctId IS NULL OR pCntctId = -1)
	AND (pAddrId IS NULL)
	AND (COALESCE(pFirstName, '''') = '''')
	AND (COALESCE(pMiddleName, '''') = '''')
	AND (COALESCE(pLastName, '''') = '''')
	AND (COALESCE(pSuffix, '''') = '''')
	AND (COALESCE(pHonorific, '''') = '''')
	AND (COALESCE(pInitials, '''') = '''')
	AND (COALESCE(pPhone, '''') = '''')
	AND (COALESCE(pPhone2, '''') = '''')
	AND (COALESCE(pFax, '''') = '''')
	AND (COALESCE(pEmail, '''') = '''')
	AND (COALESCE(pWebAddr, '''') = '''')
	AND (COALESCE(pNotes, '''') = '''')
	AND (COALESCE(pTitle, '''') = '''') ) THEN
	
	RETURN NULL;

  END IF;
  
  IF (pCntctId IS NULL OR pCntctId = -1) THEN 
    _isNew := true;
    _cntctId := nextval(''cntct_cntct_id_seq'');
    _cntctNumber := COALESCE(pContactNumber,fetchNextNumber(''ContactNumber''));
  ELSE
    SELECT COUNT(cntct_id) INTO _contactCount
      FROM cntct
      WHERE ((cntct_id=pCntctId)
      AND (cntct_first_name=pFirstName)
      AND (cntct_last_name=pLastName));

    -- ask whether new or update if name changes
    -- but only if this isn''t a new record with a pre-allocated id
    IF (_contactCount < 1 AND _flag = ''CHECK'') THEN
      IF (EXISTS(SELECT cntct_id
                 FROM cntct
                 WHERE (cntct_id=pCntctId))) THEN
        RETURN -10;
      ELSE
        _isNew := true;
        _cntctNumber := fetchNextNumber(''ContactNumber'');
      END IF;
    ELSIF (_flag = ''CHANGEONE'') THEN
      _isNew := true;
      _cntctId := nextval(''cntct_cntct_id_seq'');
      _cntctNumber := fetchNextNumber(''ContactNumber'');
    ELSIF (_flag = ''CHANGEALL'') THEN
      _isNew := false;
    END IF;
  END IF;

  IF (pContactNumber = '''') THEN
    _cntctNumber := fetchNextNumber(''ContactNumber'');
  ELSE
    _cntctNumber := COALESCE(_cntctNumber,pContactNumber,fetchNextNumber(''ContactNumber''));
  END IF;

  IF (_isNew) THEN
    _cntctId := COALESCE(_cntctId,pCntctId,nextval(''cntct_cntct_id_seq''));
 
    INSERT INTO cntct (
      cntct_id,cntct_number,
      cntct_crmacct_id,cntct_addr_id,cntct_first_name,
      cntct_last_name,cntct_honorific,cntct_initials,
      cntct_active,cntct_phone,cntct_phone2,
      cntct_fax,cntct_email,cntct_webaddr,
      cntct_notes,cntct_title,cntct_middle,cntct_suffix, cntct_owner_username ) 
    VALUES (
      _cntctId, COALESCE(_cntctNumber,fetchNextNumber(''ContactNumber'')) ,pCrmAcctId,pAddrId,
      pFirstName,pLastName,pHonorific,
      pInitials,COALESCE(pActive,true),pPhone,pPhone2,pFax,
      pEmail,pWebAddr,pNotes,pTitle,pMiddleName,pSuffix,pOwnerUsername );

    RETURN _cntctId;

  ELSE
    UPDATE cntct SET
      cntct_number=COALESCE(_cntctNumber,fetchNextNumber(''ContactNumber'')),
      cntct_crmacct_id=COALESCE(pCrmAcctId,cntct_crmacct_id),
      cntct_addr_id=COALESCE(pAddrId,cntct_addr_id),
      cntct_first_name=COALESCE(pFirstName,cntct_first_name),
      cntct_last_name=COALESCE(pLastName,cntct_last_name),
      cntct_honorific=COALESCE(pHonorific,cntct_honorific),
      cntct_initials=COALESCE(pInitials,cntct_initials),
      cntct_active=COALESCE(pActive,cntct_active),
      cntct_phone=COALESCE(pPhone,cntct_phone),
      cntct_phone2=COALESCE(pPhone2,cntct_phone2),
      cntct_fax=COALESCE(pFax,cntct_fax),
      cntct_email=COALESCE(pEmail,cntct_email),
      cntct_webaddr=COALESCE(pWebAddr,cntct_webaddr),
      cntct_notes=COALESCE(pNotes,cntct_notes),
      cntct_title=COALESCE(pTitle,cntct_title),
      cntct_middle=COALESCE(pMiddleName,cntct_middle),
      cntct_suffix=COALESCE(pSuffix,cntct_suffix),
      cntct_owner_username=COALESCE(pOwnerUsername, cntct_owner_username) 
    WHERE (cntct_id=pCntctId);
    
    RETURN pCntctId;

  END IF;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION saveCntct(int,text,int,int,text,text,text,text,text,text,bool,text,text,text,text,text,text,text,text) RETURNS INTEGER AS '
DECLARE
  pCntctId ALIAS FOR $1;
  pContactNumber ALIAS FOR $2;
  pCrmAcctId ALIAS FOR $3;
  pAddrId ALIAS FOR $4;
  pHonorific ALIAS FOR $5;
  pFirstName ALIAS FOR $6;
  pMiddleName ALIAS FOR $7;
  pLastName ALIAS FOR $8;
  pSuffix ALIAS FOR $9;
  pInitials ALIAS FOR $10;
  pActive ALIAS FOR $11;
  pPhone ALIAS FOR $12;
  pPhone2 ALIAS FOR $13;
  pFax ALIAS FOR $14;
  pEmail ALIAS FOR $15;
  pWebAddr ALIAS FOR $16;
  pNotes ALIAS FOR $17;
  pTitle ALIAS FOR $18;
  pFlag ALIAS FOR $19;
  _returnVal INTEGER;

BEGIN
  
  SELECT saveCntct( pCntctId, pContactNumber, pCrmAcctId, pAddrId, pHonorific, pFirstName, pMiddleName, pLastName, pSuffix, pInitials, 
	pActive, pPhone, pPhone2, pFax, pEmail, pWebAddr, pNotes, pTitle, pFlag, NULL) INTO _returnVal;
  RETURN _returnVal;

END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION saveCntct(int,text,int,text,text,text,text,text,text,text,text,text,text,text,text) RETURNS INTEGER AS '
DECLARE
  pCntctId ALIAS FOR $1;
  pContactNumber ALIAS FOR $2;
  pAddrId ALIAS FOR $3;
  pHonorific ALIAS FOR $4;
  pFirstName ALIAS FOR $5;
  pMiddleName ALIAS FOR $6;
  pLastName ALIAS FOR $7;
  pSuffix ALIAS FOR $8;
  pPhone ALIAS FOR $9;
  pPhone2 ALIAS FOR $10;
  pFax ALIAS FOR $11;
  pEmail ALIAS FOR $12;
  pWebAddr ALIAS FOR $13;
  pTitle ALIAS FOR $14;
  pFlag ALIAS FOR $15;
  _returnVal INTEGER;

BEGIN
  
  SELECT saveCntct(pCntctId,pContactNumber,NULL,pAddrId,pHonorific,pFirstName,pMiddleName,pLastName,pSuffix,NULL,NULL,pPhone,pPhone2,pFax,pEmail,pWebAddr,NULL,pTitle,pFlag) INTO _returnVal;
  
  RETURN _returnVal;

END;
' LANGUAGE 'plpgsql';
