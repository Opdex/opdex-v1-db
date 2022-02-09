DELIMITER //

CREATE PROCEDURE AddWrappedTokenValidateField ()
 BEGIN
     ALTER TABLE token_wrapped ADD COLUMN Validated BIT NOT NULL AFTER NativeAddress;
 END;
//

CALL AddWrappedTokenValidateField();
//

DROP PROCEDURE AddWrappedTokenValidateField;
//

DELIMITER ;
