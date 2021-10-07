-- Creates the token_summary table

DELIMITER //

DROP PROCEDURE IF EXISTS CreateTokenSummary;
//

CREATE PROCEDURE CreateTokenSummary()
 BEGIN
 SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'token_summary';

    IF @exists = 0 THEN
        CREATE TABLE IF NOT EXISTS token_summary
        (
            Id              BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId        BIGINT UNSIGNED NOT NULL,
            TokenId         BIGINT UNSIGNED NOT NULL,
            DailyChangeUsd  DECIMAL(30, 8)  NOT NULL,
            PriceUsd        DECIMAL(30, 8)  NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX token_summary_market_id_ix (MarketId), -- No FK, CRS uses MarketId = 0
            INDEX token_summary_daily_change_usd_ix (DailyChangeUsd),
            INDEX token_summary_price_usd_ix (PriceUsd),
            CONSTRAINT token_summary_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE,
            CONSTRAINT token_summary_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_summary_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;
 END;
//

CALL CreateTokenSummary();
//

DROP PROCEDURE CreateTokenSummary;
//

DELIMITER ;
