DELIMITER //

CREATE PROCEDURE AddWrappedTokenTrustedField()
 BEGIN
     ALTER TABLE token_wrapped ADD COLUMN Trusted BIT NOT NULL AFTER Validated;
 END;
//

CALL AddWrappedTokenTrustedField();
//

DROP PROCEDURE AddWrappedTokenTrustedField;
//

DELIMITER ;
