-- Clears tables for a resync.
-- Keeps CRS token and CRS snapshots around

-- ------
-- IMPORTANT - copy the transaction hashes for ODX deployment and Market Deployer Deployment transactions.
--           - Resync requires those and if you wipe them you'll have to go digging or redploy them.
-- ------

SET FOREIGN_KEY_CHECKS = 0;
delete FROM address_balance where Id > 0;
delete FROM address_mining where Id > 0;
delete FROM address_staking where Id > 0;
delete FROM block where Height > 0;
delete FROM mining_governance where Id > 0;
delete from mining_governance_nomination where Id > 0;
delete FROM market where Id > 0;
delete FROM market_deployer where Id > 0;
delete FROM market_permission where Id > 0;
delete FROM market_router where Id > 0;
delete FROM market_snapshot where Id > 0;
delete FROM market_token_attribute_blacklist where Id > 0;
delete FROM market_token_blacklist where Id > 0;
delete FROM pool_liquidity where Id > 0;
delete FROM pool_liquidity_snapshot where Id > 0;
delete FROM pool_liquidity_summary where Id > 0;
delete FROM pool_mining where Id > 0;
delete FROM token where Id > 1 AND Symbol != 'CRS';
delete FROM token_attribute where TokenId != 1;
delete FROM token_snapshot where TokenId != 1;
delete FROM token_summary where TokenId != 1;
delete FROM transaction where Id > 0;
delete FROM transaction_log where Id > 0;
delete from vault where Id > 0;
delete from vault_certificate where Id > 0;
delete from vault_governance where Id > 0;
delete from vault_governance_certificate where Id > 0;
delete from proposal where Id > 0;
delete from proposal_pledge where Id > 0;
delete from proposal_vote where Id > 0;
SET FOREIGN_KEY_CHECKS = 1;
