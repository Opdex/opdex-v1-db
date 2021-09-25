DELIMITER //

CREATE PROCEDURE AddPendingOwner ()
 BEGIN
    SELECT COUNT(*) into @existsOnMarket
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='market'
        AND column_name='PendingOwner';
        
    SELECT COUNT(*) into @existsOnVault
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='vault'
        AND column_name='PendingOwner';
        
    SELECT COUNT(*) into @existsOnDeployer
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='market_deployer'
        AND column_name='PendingOwner';

    IF @existsOnMarket = 0 THEN
        ALTER TABLE market
            ADD COLUMN PendingOwner varchar(50) NULL
            AFTER StakingTokenId;
    END IF;
    
    IF @existsOnVault = 0 THEN
        ALTER TABLE vault
            ADD COLUMN PendingOwner varchar(50) NULL
            AFTER Address;
    END IF;
    
    IF @existsOnDeployer = 0 THEN
        ALTER TABLE market_deployer
            ADD COLUMN PendingOwner varchar(50) NULL
            AFTER Address;
    END IF;
 END;
//

CALL AddPendingOwner();
//

DROP PROCEDURE AddPendingOwner;
//

DELIMITER ;
