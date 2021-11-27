DELIMITER //

DROP PROCEDURE IF EXISTS InsertPercentChange; //

CREATE PROCEDURE InsertPercentChange()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='pool_liquidity_summary'
        AND column_name='DailyLiquidityUsdChangePercent';

    IF @exists = 0 THEN
        ALTER TABLE pool_liquidity_summary ADD COLUMN DailyLiquidityUsdChangePercent DECIMAL(30,8) NULL AFTER LiquidityUsd;

        UPDATE pool_liquidity_summary SET DailyLiquidityUsdChangePercent = 0;

        ALTER TABLE pool_liquidity_summary MODIFY DailyLiquidityUsdChangePercent DECIMAL(30,8) NOT NULL;
        ALTER TABLE pool_liquidity_summary ADD INDEX pool_liquidity_summary_daily_liquidity_usd_change_ix (DailyLiquidityUsdChangePercent);
    END IF;

    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='pool_liquidity_summary'
        AND column_name='DailyStakingWeightChangePercent';

    IF @exists = 0 THEN
        ALTER TABLE pool_liquidity_summary ADD COLUMN DailyStakingWeightChangePercent DECIMAL(30,8) NULL AFTER StakingWeight;

        UPDATE pool_liquidity_summary SET DailyStakingWeightChangePercent = 0;

        ALTER TABLE pool_liquidity_summary MODIFY DailyStakingWeightChangePercent DECIMAL(30,8) NOT NULL;
        ALTER TABLE pool_liquidity_summary ADD INDEX pool_liquidity_summary_daily_staking_weight_change_ix (DailyStakingWeightChangePercent);
    END IF;
 END;
//

CALL InsertPercentChange();
//

DROP PROCEDURE InsertPercentChange;
//

DELIMITER ;