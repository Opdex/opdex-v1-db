-- Drops and recreates snapshot foreign key to delete cascade
DELIMITER //

CREATE PROCEDURE SnapshotOnDeleteCascade ()
 BEGIN
    --
    -- Drop and recreate market snapshot to market id foreign key
    --
    SELECT Count(*) into @marketForeignKeyExists
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_NAME = 'market_snapshot'
        AND REFERENCED_TABLE_NAME = 'market'
        AND CONSTRAINT_NAME = 'market_snapshot_market_id_market_id_fk'
        AND REFERENCED_COLUMN_NAME = 'Id';

    IF @marketForeignKeyExists > 0 THEN
        ALTER TABLE market_snapshot DROP FOREIGN KEY market_snapshot_market_id_market_id_fk;
    END IF;

    -- Recreate market FK
    ALTER TABLE market_snapshot
        ADD CONSTRAINT market_snapshot_market_id_market_id_fk
        FOREIGN KEY (MarketId)
        REFERENCES market (Id)
        ON DELETE CASCADE;


    --
    -- Drop and recreate liquidity pool snapshot to liquidity pool id foreign key
    --
    SELECT Count(*) into @pool_liquidityForeignKeyExists
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_NAME = 'pool_liquidity_snapshot'
        AND REFERENCED_TABLE_NAME = 'pool_liquidity'
        AND CONSTRAINT_NAME = 'pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk'
        AND REFERENCED_COLUMN_NAME = 'Id';

    IF @pool_liquidityForeignKeyExists > 0 THEN
        ALTER TABLE pool_liquidity_snapshot DROP FOREIGN KEY pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk;
    END IF;

    -- Recreate pool_liquidity FK
    ALTER TABLE pool_liquidity_snapshot
        ADD CONSTRAINT pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk
        FOREIGN KEY (LiquidityPoolId)
        REFERENCES pool_liquidity (Id)
        ON DELETE CASCADE;


    --
    -- Drop and recreate token snapshot to token id foreign key
    --
    SELECT Count(*) into @tokenForeignKeyExists
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_NAME = 'token_snapshot'
        AND REFERENCED_TABLE_NAME = 'token'
        AND CONSTRAINT_NAME = 'token_snapshot_token_id_token_id_fk'
        AND REFERENCED_COLUMN_NAME = 'Id';

    IF @tokenForeignKeyExists > 0 THEN
        ALTER TABLE token_snapshot DROP FOREIGN KEY token_snapshot_token_id_token_id_fk;
    END IF;

    -- Recreate Token FK
    ALTER TABLE token_snapshot
        ADD CONSTRAINT token_snapshot_token_id_token_id_fk
        FOREIGN KEY (TokenId)
        REFERENCES token (Id)
        ON DELETE CASCADE;
 END;
//

CALL SnapshotOnDeleteCascade();
//

DROP PROCEDURE SnapshotOnDeleteCascade;
//

DELIMITER ;
