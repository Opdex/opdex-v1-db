-- Creates the market_summary table

DELIMITER //

DROP PROCEDURE IF EXISTS CreateMarketSummary;
//

CREATE PROCEDURE CreateMarketSummary()
 BEGIN
 SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'market_summary';

    IF @exists = 0 THEN
        CREATE TABLE IF NOT EXISTS market_summary
        (
            Id                              BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId                        BIGINT UNSIGNED NOT NULL,
            LiquidityUsd                    DECIMAL(30, 8)  NOT NULL,
            DailyLiquidityUsdChangePercent  DECIMAL(30, 8)  NOT NULL,
            VolumeUsd                       DECIMAL(30, 8)  NOT NULL,
            StakingWeight                   BIGINT UNSIGNED NOT NULL,
            DailyStakingWeightChangePercent DECIMAL(30, 8)  NOT NULL,
            StakingUsd                      DECIMAL(30, 8)  NOT NULL,
            DailyStakingUsdChangePercent    DECIMAL(30, 8)  NOT NULL,
            ProviderRewardsDailyUsd         DECIMAL(30, 8)  NOT NULL,
            MarketRewardsDailyUsd           DECIMAL(30, 8)  NOT NULL,
            CreatedBlock                    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock                   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_summary_market_id_uq (MarketId),
            INDEX market_summary_liquidity_usd_ix (LiquidityUsd),
            INDEX market_summary_daily_liquidity_usd_change_percent_ix (DailyLiquidityUsdChangePercent),
            INDEX market_summary_volume_usd_ix (VolumeUsd),
            INDEX market_summary_staking_weight_ix (StakingWeight),
            INDEX market_summary_daily_staking_weight_change_percent_ix (DailyStakingWeightChangePercent),
            INDEX market_summary_staking_usd_ix (StakingUsd),
            INDEX market_summary_daily_staking_usd_change_percent_ix (DailyStakingUsdChangePercent),
            INDEX market_summary_daily_provider_rewards_daily_usd_ix (ProviderRewardsDailyUsd),
            INDEX market_summary_daily_market_rewards_daily_usd_ix (MarketRewardsDailyUsd),
            CONSTRAINT market_summary_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_summary_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        -- The next indexing interval will snapshot and update market summaries
        INSERT IGNORE INTO market_summary(MarketId, LiquidityUsd, DailyLiquidityUsdChangePercent, VolumeUsd, StakingWeight, DailyStakingWeightChangePercent,
                                      StakingUsd, DailyStakingUsdChangePercent, ProviderRewardsDailyUsd, MarketRewardsDailyUsd, CreatedBlock, ModifiedBlock)
        SELECT
            Id,
            0.00000000 as LiquidityUsd,
            0.00000000 as DailyLiquidityUsdChangePercent,
            0.00000000 as VolumeUsd,
            0 as StakingWeight,
            0.00000000 as DailyStakingWeightChangePercent,
            0.00000000 as StakingUsd,
            0.00000000 as DailyStakingUsdChangePercent,
            0.00000000 as ProviderRewardsDailyUsd,
            0.00000000 as MarketRewardsDailyUsd,
            (SELECT Height FROM block ORDER BY Height DESC LIMIT 1) AS CreatedBlock,
            (SELECT Height FROM block ORDER BY Height DESC LIMIT 1) AS ModifiedBlock
        FROM market;
    END IF;
 END;
//

CALL CreateMarketSummary();
//

DROP PROCEDURE CreateMarketSummary;
//

DELIMITER ;
