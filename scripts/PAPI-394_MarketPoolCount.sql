DELIMITER //

DROP PROCEDURE IF EXISTS AddMarketPoolCount;
CREATE PROCEDURE AddMarketPoolCount()
    BEGIN
        SELECT COUNT(*) into @liquidityPoolCountExists
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = 'platform'
            AND table_name = 'market_summary'
            AND column_name = 'LiquidityPoolCount';

        IF !@liquidityPoolCountExists THEN
            ALTER TABLE market_summary ADD COLUMN LiquidityPoolCount INT UNSIGNED NOT NULL AFTER MarketRewardsDailyUsd;
        END IF;
    END;
//

CALL AddMarketPoolCount();
//

DROP PROCEDURE AddMarketPoolCount;
//

DROP PROCEDURE IF EXISTS UpdateMarketSummaryLiquidityPoolCount;
CREATE PROCEDURE UpdateMarketSummaryLiquidityPoolCount()
    BEGIN
        UPDATE market_summary ms
        SET LiquidityPoolCount = (SELECT COUNT(pl.Id) FROM pool_liquidity pl WHERE pl.MarketId = ms.MarketId)
        WHERE ms.Id > 0; # without the WHERE clause, MYSQL will create a warning and won't execute the query
    END;
//

CALL UpdateMarketSummaryLiquidityPoolCount();
//

DELIMITER ;