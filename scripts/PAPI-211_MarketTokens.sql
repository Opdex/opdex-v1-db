-- Creates the market_token table and backfills it with data from existing liquidity pools

DELIMITER //

DROP PROCEDURE IF EXISTS CreateMarketTokens;
//

CREATE PROCEDURE CreateMarketTokens ()
 BEGIN
 SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'market_token';

    IF @exists = 0 THEN
        CREATE TABLE market_token
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId      BIGINT UNSIGNED NOT NULL,
            TokenId       BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_token_market_id_token_id_uq (MarketId, TokenId),
            CONSTRAINT market_token_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_token_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_token_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_token_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO market_token (MarketId, TokenId, CreatedBlock, ModifiedBlock)
        SELECT MarketId, SrcTokenId, CreatedBlock, ModifiedBlock FROM pool_liquidity;
    END IF;
 END;
//

CALL CreateMarketTokens();
//

DROP PROCEDURE CreateMarketTokens;
//

DELIMITER ;
