DELIMITER //

CREATE PROCEDURE CreateWrappedTokenOwnership ()
 BEGIN
    SELECT COUNT(*) into @tokenChainOwnershipExists
    FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = 'platform'
        AND table_name = 'token_chain'
        AND column_name='Owner';

    IF NOT @tokenChainOwnershipExists THEN
        ALTER TABLE token_chain ADD COLUMN Owner VARCHAR(50) NOT NULL AFTER TokenId;
    END IF;
 END;
//

CALL CreateWrappedTokenOwnership();
//

DROP PROCEDURE CreateWrappedTokenOwnership;
//

DELIMITER ;
