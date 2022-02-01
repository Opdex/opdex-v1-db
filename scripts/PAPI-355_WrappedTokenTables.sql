DELIMITER //

CREATE PROCEDURE CreateWrappedTokenTables ()
 BEGIN
    SELECT COUNT(*) into @chainTypeTableExists
    FROM INFORMATION_SCHEMA.TABLES
        WHERE table_schema = 'platform'
        AND table_name = 'chain_type';

    SELECT COUNT(*) into @tokenChainTableExists
    FROM INFORMATION_SCHEMA.TABLES
        WHERE table_schema = 'platform'
        AND table_name = 'token_chain';

    IF NOT @chainTypeTableExists THEN
        CREATE TABLE IF NOT EXISTS chain_type(
            Id      SMALLINT UNSIGNED NOT NULL,
            Name    VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE chain_type_name_uq (Name)
        ) ENGINE = INNODB;
    END IF;

    IF NOT @tokenChainTableExists THEN
        CREATE TABLE IF NOT EXISTS token_chain(
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId             BIGINT UNSIGNED NOT NULL,
            NativeChainTypeId   SMALLINT UNSIGNED NOT NULL,
            NativeAddress       VARCHAR(100) NULL,
            PRIMARY KEY (Id),
            UNIQUE token_chain_token_id_uq (TokenId),
            UNIQUE token_chain_native_address_uq (NativeAddress),
            CONSTRAINT token_chain_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id) ON DELETE CASCADE,
            CONSTRAINT token_chain_native_chain_type_id_chain_type_id_fk
                FOREIGN KEY (NativeChainTypeId)
                REFERENCES chain_type (Id)
        ) ENGINE = INNODB;
    END IF;

    INSERT IGNORE INTO chain_type (Id, Name) VALUES (1, 'Ethereum');

    INSERT IGNORE INTO token_attribute_type (Id, AttributeType) VALUES (5, 'Interflux');
 END;
//

CALL CreateWrappedTokenTables();
//

DROP PROCEDURE CreateWrappedTokenTables;
//

DELIMITER ;
