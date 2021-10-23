DELIMITER //

CREATE PROCEDURE MarketTokenSummaryNameChange ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='token_summary'
        AND column_name='DailyChangeUsd';

    IF @exists = 0 THEN
        ALTER TABLE token_summary RENAME COLUMN DailyChangeUsd TO DailyPriceChangePercent;
        ALTER TABLE token_summary RENAME INDEX token_summary_daily_change_usd_ix TO token_summary_daily_price_change_percent_ix;
    END IF;
 END;
//

CALL MarketTokenSummaryNameChange();
//

DROP PROCEDURE MarketTokenSummaryNameChange;
//

DELIMITER ;
