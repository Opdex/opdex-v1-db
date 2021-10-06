-- Creates the token_attribute_type and token_attribute tables

DELIMITER //

DROP PROCEDURE IF EXISTS CreateTokenAttributes;
//

CREATE PROCEDURE CreateTokenAttributes ()
 BEGIN
    SELECT COUNT(*) into @typeExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'token_attribute_type';

    IF @typeExists = 0 THEN
        CREATE TABLE IF NOT EXISTS token_attribute_type
        (
            Id            SMALLINT    NOT NULL,
            AttributeType VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO token_attribute_type(Id, AttributeType)
        VALUES
            (1, 'Mintable'),
            (2, 'Burnable'),
            (3, 'Staking'),
            (4, 'Security');
    END IF;

    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'token_attribute';

    IF @typeExists = 0 THEN
        CREATE TABLE IF NOT EXISTS token_attribute
        (
            Id              SMALLINT         NOT NULL,
            TokenId         BIGINT UNSIGNED  NOT NULL,
            AttributeTypeId SMALLINT         NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT token_attribute_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE,
            CONSTRAINT token_attribute_attribute_type_id_token_attribute_type_id_fk
                FOREIGN KEY (AttributeTypeId)
                REFERENCES token_attribute_type (Id)
        ) ENGINE=INNODB;
    END IF;
 END;
//

CALL CreateTokenAttributes();
//

DROP PROCEDURE CreateTokenAttributes;
//

DELIMITER ;
