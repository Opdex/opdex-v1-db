-- ------------------------------------------------

-- Drop and Create Rewind to Block Stored Procedure
-- Execute during CI pipelines to initialize the stored procedure

-- ------------------------------------------------

DELIMITER //

DROP PROCEDURE IF EXISTS RewindToBlock;
//

-- Takes a rewindHeight block number
-- Deletes all records where CreatedBlock > rewindHeight, except the block table
-- Updates all remaining records and sets ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight
-- Delete all blocks where Height > rewindBlock.
-- Requires follow up in code to resolve the following:
--   Refresh stale records that had ModifiedBlock reset
--   Refresh snapshots from the beginning of the day
CREATE PROCEDURE RewindToBlock (
    IN rewindHeight bigint unsigned
)
BEGIN
    -- On exception - rollback transaction and return error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    -- Only move forward if we have the target block to delete against
    SELECT COUNT(*) INTO @exists FROM block WHERE Height = rewindHeight;

    IF @exists > 0 THEN
        SELECT 
            DATE_FORMAT(MedianTime, '%Y-%m-%d 00:00:00'), 
            DATE_FORMAT(MedianTime, '%Y-%m-%d %H:00:00') 
        INTO @rewindBlockStartOfDay, @rewindBlockStartOfHour
        FROM block 
        WHERE Height = rewindHeight;

        -- Delete records by CreatedBlock
        -- ----------------------------------
        DELETE FROM address_balance WHERE CreatedBlock > rewindHeight;
        DELETE FROM address_mining WHERE CreatedBlock > rewindHeight;
        DELETE FROM address_staking WHERE CreatedBlock > rewindHeight;
        DELETE FROM transaction WHERE Block > rewindHeight; -- on delete cascades transaction_log
        DELETE FROM vault_certificate WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault_proposal_vote WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault_proposal_pledge WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault_proposal WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault_governance_certificate WHERE CreatedBlock > rewindHeight;
        DELETE FROM vault_governance WHERE CreatedBlock > rewindHeight;
        DELETE FROM mining_governance_nomination WHERE CreatedBlock > rewindHeight;
        DELETE FROM mining_governance WHERE CreatedBlock > rewindHeight;
        DELETE FROM pool_mining WHERE CreatedBlock > rewindHeight;
        DELETE FROM pool_liquidity_summary WHERE CreatedBlock > rewindHeight;
        DELETE FROM pool_liquidity_snapshot WHERE StartDate >= @rewindBlockStartOfHour;
        DELETE FROM pool_liquidity WHERE CreatedBlock > rewindHeight;
        DELETE FROM token_summary WHERE CreatedBlock > rewindHeight;
        DELETE FROM token_snapshot WHERE TokenId > 1 AND StartDate >= @rewindBlockStartOfHour;
        DELETE FROM market_router WHERE CreatedBlock > rewindHeight;
        DELETE FROM market_permission WHERE CreatedBlock > rewindHeight;
        DELETE FROM market_summary WHERE CreatedBlock > rewindHeight;
        DELETE FROM market_snapshot WHERE StartDate >= @rewindBlockStartOfDay; -- only track daily snapshots
        DELETE FROM market WHERE CreatedBlock > rewindHeight;
        DELETE FROM market_deployer WHERE CreatedBlock > rewindHeight;
        DELETE FROM token_distribution WHERE CreatedBlock > rewindHeight;
        DELETE FROM token WHERE CreatedBlock > rewindHeight;

        -- Update any remaining records setting ModifiedBlock to the rewind height
        -- --------------------------------------------------------------------
        UPDATE address_balance SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE address_mining SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE address_staking SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE mining_governance_nomination SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE mining_governance SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE pool_mining SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE pool_liquidity_summary SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE pool_liquidity SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE token_summary SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE market_router SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE market_permission SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE market_summary SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE market SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE market_deployer SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE token_distribution SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE token SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_certificate SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_proposal_vote SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_proposal_pledge SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_proposal SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_governance_certificate SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;
        UPDATE vault_governance SET ModifiedBlock = rewindHeight WHERE ModifiedBlock > rewindHeight;

        -- Delete blocks
        -- --------------------------------------------------------------------
        DELETE FROM block WHERE Height > rewindHeight;

        -- In Code
        -- --------------------------------------------------------------------
        -- Retrieve every record where ModifiedBlock = rewindHeight and refresh based on FN data
        -- Refresh snapshots from the beginning of the day
    END IF;

    COMMIT;
END;
//

DELIMITER ;
