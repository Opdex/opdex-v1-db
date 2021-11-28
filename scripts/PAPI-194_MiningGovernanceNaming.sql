-- Rename all references of 'governance' to 'mining governance'
DELIMITER //

DROP PROCEDURE IF EXISTS MiningGovernanceNaming;
//

CREATE PROCEDURE MiningGovernanceNaming ()
 BEGIN
    SELECT COUNT(*) into @governanceNominationsExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'governance_nomination';

    SELECT COUNT(*) into @governanceExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform' 
        AND table_name = 'governance';

    IF @governanceNominationsExists AND @governanceExists THEN
        ALTER TABLE governance_nomination
            DROP INDEX governance_nomination_gov_id_liquidity_pool_id_mining_pool_id_uq,
            DROP INDEX governance_nomination_is_nominated_ix,
            DROP FOREIGN KEY governance_nomination_governance_id_governance_id_fk,
            DROP FOREIGN KEY governance_nomination_liquidity_pool_id_pool_liquidity_id_fk,
            DROP FOREIGN KEY governance_nomination_mining_pool_id_pool_mining_id_fk,
            DROP FOREIGN KEY governance_nomination_created_block_block_height_fk,
            DROP FOREIGN KEY governance_nomination_modified_block_block_height_fk;
        ALTER TABLE governance_nomination RENAME COLUMN GovernanceId TO MiningGovernanceId;
        ALTER TABLE governance_nomination
            ADD UNIQUE mining_governance_nomination_gov_id_liq_pool_id_min_pool_id_uq
                (MiningGovernanceId, LiquidityPoolId, MiningPoolId),
            ADD INDEX mining_governance_nomination_is_nominated_ix (IsNominated),
            ADD CONSTRAINT mining_governance_nomination_gov_id_mining_governance_id_fk
                FOREIGN KEY (MiningGovernanceId) REFERENCES governance (Id),
            ADD CONSTRAINT mining_governance_nomination_liq_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id),
            ADD CONSTRAINT mining_governance_nomination_min_pool_id_pool_mining_id_fk
                FOREIGN KEY (MiningPoolId) REFERENCES pool_mining (Id),
            Add CONSTRAINT mining_governance_nomination_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock) REFERENCES block (Height),
            Add CONSTRAINT mining_governance_nomination_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock) REFERENCES block (Height);
        RENAME TABLE governance_nomination TO mining_governance_nomination;
        ALTER TABLE governance
            DROP INDEX governance_address_uq,
            DROP FOREIGN KEY governance_token_id_token_id_fk,
            DROP FOREIGN KEY governance_created_block_block_height_fk,
            DROP FOREIGN KEY governance_modified_block_block_height_fk;
        ALTER TABLE governance
            ADD UNIQUE mining_governance_address_uq (Address),
            ADD CONSTRAINT mining_governance_token_id_token_id_fk
                FOREIGN KEY (TokenId) REFERENCES token (Id),
            ADD CONSTRAINT mining_governance_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock) REFERENCES block (Height),
            ADD CONSTRAINT mining_governance_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock) REFERENCES block (Height);
        RENAME TABLE governance TO mining_governance;
    END IF;
 END;
//

CALL MiningGovernanceNaming();
//

DROP PROCEDURE MiningGovernanceNaming;
//

DELIMITER ;
