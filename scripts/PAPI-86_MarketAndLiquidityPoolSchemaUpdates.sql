DELIMITER //

CREATE PROCEDURE MarketAndLiquidityPoolSchemaUpdates ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='pool_liquidity'
        AND column_name='Name';

    IF @exists = 0 THEN
        ALTER TABLE pool_liquidity ADD COLUMN Name varchar(50) NULL AFTER Address;

        -- Backfill
        Update pool_liquidity pl
            SET Name = CONCAT((SELECT Symbol from token WHERE Id = pl.SrcTokenId), '-', (SELECT Symbol from token WHERE Address = 'CRS'));

        ALTER TABLE pool_liquidity MODIFY Name varchar(50) NOT NULL;
        ALTER TABLE pool_liquidity ADD INDEX pool_liquidity_name_ix (Name);
    END IF;

    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='market'
        AND column_name='StakingTokenId';

    IF @exists THEN
        ALTER TABLE market MODIFY StakingTokenId BIGINT UNSIGNED NOT NULL;
    END IF;
 END;
//

CALL MarketAndLiquidityPoolSchemaUpdates();
//

DROP PROCEDURE MarketAndLiquidityPoolSchemaUpdates;
//

DELIMITER ;
