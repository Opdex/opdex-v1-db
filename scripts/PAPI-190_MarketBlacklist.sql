-- Create the market_token_blacklist and market_token_attribute_blacklist tables
DELIMITER //

DROP PROCEDURE IF EXISTS MarketBlacklist;
//

CREATE PROCEDURE MarketBlacklist ()
 BEGIN
    SELECT COUNT(*) into @tokenBlacklistExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'market_token_blacklist';

    IF @tokenBlacklistExists = 0 THEN
        CREATE TABLE IF NOT EXISTS market_token_blacklist
        (
            Id        BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId  BIGINT UNSIGNED NOT NULL,
            TokenId   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT market_token_blacklist_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_token_blacklist_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;
    END IF;

    SELECT COUNT(*) into @attributeBlacklistExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'market_token_attribute_blacklist';

    IF @attributeBlacklistExists = 0 THEN
        CREATE TABLE IF NOT EXISTS market_token_attribute_blacklist
        (
            Id                    BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId              BIGINT UNSIGNED   NOT NULL,
            TokenAttributeTypeId  SMALLINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT market_tablist_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_tablist_tab_type_id_token_attribute_type_id_fk
                FOREIGN KEY (TokenAttributeTypeId)
                REFERENCES token_attribute_type (Id)
        ) ENGINE=INNODB;
    END IF;
 END;
//

CALL MarketBlacklist();
//

DROP PROCEDURE MarketBlacklist;
//

DELIMITER ;
