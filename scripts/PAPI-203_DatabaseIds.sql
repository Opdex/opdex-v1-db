-- Modifies database Id's to use bigint unsigned for Id's
-- Drops and recreates all FKs
-- Is not idempotent...

DELIMITER //

CREATE PROCEDURE ResetDatatypes ()
 BEGIN
    SET FOREIGN_KEY_CHECKS = 0;
        -- Drop all FKs
        ALTER TABLE market DROP FOREIGN KEY market_deployer_id_market_deployer_id_fk;
        ALTER TABLE market_permission DROP FOREIGN KEY market_permission_market_id_market_id_fk;
        ALTER TABLE market_router DROP FOREIGN KEY market_router_market_id_market_id_fk;
        ALTER TABLE token_distribution DROP FOREIGN KEY token_distribution_token_id_token_id_fk;
        ALTER TABLE market_snapshot DROP FOREIGN KEY market_snapshot_market_id_market_id_fk;
        ALTER TABLE pool_liquidity DROP FOREIGN KEY pool_liquidity_market_id_market_id_fk;
        ALTER TABLE pool_liquidity DROP FOREIGN KEY pool_liquidity_lp_token_id_token_id_fk;
        ALTER TABLE pool_liquidity DROP FOREIGN KEY pool_liquidity_src_token_id_token_id_fk;
        ALTER TABLE pool_liquidity_snapshot DROP FOREIGN KEY pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk;
        ALTER TABLE pool_liquidity_summary DROP FOREIGN KEY pool_liquidity_summary_liquidity_pool_id_pool_liquidity_id_fk;
        ALTER TABLE pool_mining DROP FOREIGN KEY pool_mining_liquidity_pool_id_pool_liquidity_id_fk;
        ALTER TABLE token_snapshot DROP FOREIGN KEY token_snapshot_token_id_token_id_fk;
        ALTER TABLE address_balance DROP FOREIGN KEY address_balance_token_id_fk;
        ALTER TABLE address_mining DROP FOREIGN KEY address_mining_pool_mining_id_fk;
        ALTER TABLE address_staking DROP FOREIGN KEY address_staking_pool_liquidity_id_fk;
        ALTER TABLE transaction_log DROP FOREIGN KEY transaction_log_transaction_id_transaction_id_fk;
        ALTER TABLE governance DROP FOREIGN KEY governance_token_id_token_id_fk;
        ALTER TABLE governance_nomination DROP FOREIGN KEY governance_nomination_governance_id_governance_id_fk;
        ALTER TABLE governance_nomination DROP FOREIGN KEY governance_nomination_liquidity_pool_id_pool_liquidity_id_fk;
        ALTER TABLE governance_nomination DROP FOREIGN KEY governance_nomination_mining_pool_id_pool_mining_id_fk;
        ALTER TABLE vault DROP FOREIGN KEY vault_token_id_token_id_fk;
        ALTER TABLE vault_certificate DROP FOREIGN KEY vault_certificate_vault_id_vault_id_fk;


        -- Change Primary Keys
        ALTER TABLE admin MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE token MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE market_deployer MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE market MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE index_lock MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE market_permission MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE market_router MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE token_distribution MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE market_snapshot MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE pool_liquidity MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE pool_liquidity_snapshot MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE pool_liquidity_summary MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE pool_mining MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE token_snapshot MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE address_balance MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE address_mining MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE address_staking MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE transaction MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE transaction_log MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE governance MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE governance_nomination MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE vault MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
        ALTER TABLE vault_certificate MODIFY Id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;


        -- Make Updates
        ALTER TABLE token MODIFY Sats BIGINT UNSIGNED NOT NULL;
        ALTER TABLE market MODIFY DeployerId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE market MODIFY StakingTokenId BIGINT UNSIGNED NULL;
        ALTER TABLE market_permission MODIFY MarketId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE market_router MODIFY MarketId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE token_distribution MODIFY TokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE market_snapshot MODIFY MarketId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_liquidity MODIFY SrcTokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_liquidity MODIFY LpTokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_liquidity MODIFY MarketId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_liquidity_snapshot MODIFY LiquidityPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_liquidity_summary MODIFY LiquidityPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE pool_mining MODIFY LiquidityPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE token_snapshot MODIFY TokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE token_snapshot MODIFY MarketId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE address_balance MODIFY TokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE address_mining MODIFY MiningPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE address_staking MODIFY LiquidityPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE transaction_log MODIFY TransactionId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE governance MODIFY TokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE governance_nomination MODIFY GovernanceId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE governance_nomination MODIFY LiquidityPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE governance_nomination MODIFY MiningPoolId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE vault MODIFY TokenId BIGINT UNSIGNED NOT NULL;
        ALTER TABLE vault_certificate MODIFY VaultId BIGINT UNSIGNED NOT NULL;


        -- Recreate all FKs
        ALTER TABLE market ADD CONSTRAINT market_deployer_id_market_deployer_id_fk FOREIGN KEY (DeployerId) REFERENCES market_deployer (Id);
        ALTER TABLE market_permission ADD CONSTRAINT market_permission_market_id_market_id_fk FOREIGN KEY (MarketId) REFERENCES market (Id);
        ALTER TABLE market_router ADD CONSTRAINT market_router_market_id_market_id_fk FOREIGN KEY (MarketId) REFERENCES market (Id);
        ALTER TABLE token_distribution ADD CONSTRAINT token_distribution_token_id_token_id_fk FOREIGN KEY (TokenId) REFERENCES token (Id);
        ALTER TABLE market_snapshot ADD CONSTRAINT market_snapshot_market_id_market_id_fk FOREIGN KEY (MarketId) REFERENCES market (Id) ON DELETE CASCADE;
        ALTER TABLE pool_liquidity ADD CONSTRAINT pool_liquidity_market_id_market_id_fk FOREIGN KEY (MarketId) REFERENCES market (Id);
        ALTER TABLE pool_liquidity ADD CONSTRAINT pool_liquidity_lp_token_id_token_id_fk FOREIGN KEY (LpTokenId) REFERENCES token (Id);
        ALTER TABLE pool_liquidity ADD CONSTRAINT pool_liquidity_src_token_id_token_id_fk FOREIGN KEY (SrcTokenId) REFERENCES token (Id);
        ALTER TABLE pool_liquidity_snapshot ADD CONSTRAINT pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id) ON DELETE CASCADE;
        ALTER TABLE pool_liquidity_summary ADD CONSTRAINT pool_liquidity_summary_liquidity_pool_id_pool_liquidity_id_fk FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id);
        ALTER TABLE pool_mining ADD CONSTRAINT pool_mining_liquidity_pool_id_pool_liquidity_id_fk FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id);
        ALTER TABLE token_snapshot ADD CONSTRAINT token_snapshot_token_id_token_id_fk FOREIGN KEY (TokenId) REFERENCES token (Id) ON DELETE CASCADE;
        ALTER TABLE address_balance ADD CONSTRAINT address_balance_token_id_token_id_fk FOREIGN KEY (TokenId) REFERENCES token (Id);
        ALTER TABLE address_mining ADD CONSTRAINT address_mining_mining_pool_id_pool_mining_id_fk FOREIGN KEY (MiningPoolId) REFERENCES pool_mining (Id);
        ALTER TABLE address_staking ADD CONSTRAINT address_staking_liquidity_pool_id_pool_liquidity_id_fk FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id);
        ALTER TABLE transaction_log ADD CONSTRAINT transaction_log_transaction_id_transaction_id_fk FOREIGN KEY (TransactionId) REFERENCES transaction (Id) ON DELETE CASCADE;
        ALTER TABLE governance ADD CONSTRAINT governance_token_id_token_id_fk FOREIGN KEY (TokenId) REFERENCES token (Id);
        ALTER TABLE governance_nomination ADD CONSTRAINT governance_nomination_governance_id_governance_id_fk FOREIGN KEY (GovernanceId) REFERENCES governance (Id);
        ALTER TABLE governance_nomination ADD CONSTRAINT governance_nomination_liquidity_pool_id_pool_liquidity_id_fk FOREIGN KEY (LiquidityPoolId) REFERENCES pool_liquidity (Id);
        ALTER TABLE governance_nomination ADD CONSTRAINT governance_nomination_mining_pool_id_pool_mining_id_fk FOREIGN KEY (MiningPoolId) REFERENCES pool_mining (Id);
        ALTER TABLE vault ADD CONSTRAINT vault_token_id_token_id_fk FOREIGN KEY (TokenId) REFERENCES token (Id);
        ALTER TABLE vault_certificate ADD CONSTRAINT vault_certificate_vault_id_vault_id_fk FOREIGN KEY (VaultId) REFERENCES vault (Id);
    SET FOREIGN_KEY_CHECKS = 1;
 END;
//

CALL ResetDatatypes();
//

DROP PROCEDURE ResetDatatypes;
//

DELIMITER ;
