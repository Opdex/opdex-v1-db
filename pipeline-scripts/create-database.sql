-- Creates the database for use with Opdex Platform API
DELIMITER //

DROP PROCEDURE IF EXISTS CreateDatabase;
//

CREATE PROCEDURE CreateDatabase ()
    BEGIN
        CREATE TABLE IF NOT EXISTS admin(
            Id      BIGINT UNSIGNED AUTO_INCREMENT,
            Address VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE admin_address_uq (Address)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS block
        (
            Height     BIGINT UNSIGNED NOT NULL,
            Hash       VARCHAR(64)     NOT NULL,
            Time       DATETIME        NOT NULL,
            MedianTime DATETIME        NOT NULL,
            PRIMARY KEY (Height),
            UNIQUE block_hash_uq (Hash),
            INDEX block_median_time_ix (MedianTime)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
            Symbol        VARCHAR(20)     CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci,
            Name          VARCHAR(50)     CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci,
            Decimals      SMALLINT        NOT NULL,
            Sats          BIGINT UNSIGNED NOT NULL,
            TotalSupply   VARCHAR(78)     NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE token_address_uq (Address),
            INDEX token_symbol_ix (Symbol),
            INDEX token_name_ix (Name),
            CONSTRAINT token_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS index_lock
        (
            Id           BIGINT UNSIGNED,
            Available    BIT            NOT NULL,
            Locked       BIT            NOT NULL,
            InstanceId   VARCHAR(40)    NULL,
            Reason       VARCHAR(20)    NULL,
            ModifiedDate DATETIME       NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_deployer
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
            PendingOwner  VARCHAR(50)     NULL,
            Owner         VARCHAR(50)     NOT NULL,
            IsActive      BIT             NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE deployer_address_uq (Address),
            INDEX deployer_is_active_ix (IsActive),
            CONSTRAINT market_deployer_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_deployer_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market
        (
            Id               BIGINT UNSIGNED AUTO_INCREMENT,
            Address          VARCHAR(50)     NOT NULL,
            DeployerId       BIGINT UNSIGNED NOT NULL,
            StakingTokenId   BIGINT UNSIGNED NOT NULL,
            PendingOwner     VARCHAR(50)     NULL,
            Owner            VARCHAR(50)     NOT NULL,
            AuthPoolCreators BIT             NOT NULL,
            AuthTraders      BIT             NOT NULL,
            AuthProviders    BIT             NOT NULL,
            TransactionFee   SMALLINT        NOT NULL,
            MarketFeeEnabled BIT             NOT NULL,
            CreatedBlock     BIGINT UNSIGNED NOT NULL,
            ModifiedBlock    BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_address_uq (Address),
            INDEX market_staking_token_id_ix (StakingTokenId),
            CONSTRAINT market_deployer_id_market_deployer_id_fk
                FOREIGN KEY (DeployerId)
                REFERENCES market_deployer (Id),
            CONSTRAINT market_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_permission_type
        (
            Id             INT         NOT NULL,
            PermissionType VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_permission_type_permission_type_uq (PermissionType)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_permission
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId      BIGINT UNSIGNED NOT NULL,
            User          VARCHAR(50)     NOT NULL,
            Permission    INT             NOT NULL,
            IsAuthorized  BIT             NOT NULL,
            Blame         VARCHAR(50)     NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_permission_market_id_user_permission_uq (MarketId, User, Permission),
            CONSTRAINT market_permission_permission_market_permission_type_id_fk
                FOREIGN KEY (Permission)
                REFERENCES market_permission_type (Id),
            CONSTRAINT market_permission_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id),
            CONSTRAINT market_permission_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_permission_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_router
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
            MarketId      BIGINT UNSIGNED NOT NULL,
            IsActive      BIT             NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE market_router_address_uq (Address),
            INDEX market_router_is_active_ix (IsActive),
            CONSTRAINT market_router_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id),
            CONSTRAINT market_router_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT market_router_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token_distribution
        (
            Id                           BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId                      BIGINT UNSIGNED NOT NULL,
            VaultDistribution            VARCHAR(78)     NULL,
            MiningGovernanceDistribution VARCHAR(78)     NULL,
            PeriodIndex                  INT             NOT NULL,
            DistributionBlock            BIGINT UNSIGNED NOT NULL,
            NextDistributionBlock        BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT token_distribution_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS snapshot_type
        (
            Id           SMALLINT    NOT NULL,
            SnapshotType VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE snapshot_type_snapshot_type_uq (SnapshotType)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_snapshot
        (
            Id             BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId       BIGINT UNSIGNED NOT NULL,
            SnapshotTypeId SMALLINT        NOT NULL,
            StartDate      DATETIME        NOT NULL,
            EndDate        DATETIME        NOT NULL,
            ModifiedDate   DATETIME        NOT NULL,
            Details        JSON            NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX market_snapshot_end_date_ix (EndDate),
            INDEX market_snapshot_start_date_ix (StartDate),
            UNIQUE market_snapshot_market_id_start_date_end_date_uq (MarketId, StartDate, EndDate),
            CONSTRAINT market_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT market_snapshot_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

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
            LiquidityPoolCount              INT UNSIGNED NOT NULL,
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

        CREATE TABLE IF NOT EXISTS pool_liquidity
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            SrcTokenId    BIGINT UNSIGNED NOT NULL,
            LpTokenId     BIGINT UNSIGNED NOT NULL,
            MarketId      BIGINT UNSIGNED NOT NULL,
            Address       VARCHAR(50)     NOT NULL,
            Name          VARCHAR(50)     CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE pool_liquidity_address_uq (Address),
            UNIQUE pool_liquidity_market_id_token_id_uq (MarketId, SrcTokenId),
            INDEX pool_liquidity_name_ix (Name),
            CONSTRAINT pool_liquidity_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id),
            CONSTRAINT pool_liquidity_lp_token_id_token_id_fk
                FOREIGN KEY (LpTokenId)
                REFERENCES token (Id),
            CONSTRAINT pool_liquidity_src_token_id_token_id_fk
                FOREIGN KEY (SrcTokenId)
                REFERENCES token (Id),
            CONSTRAINT pool_liquidity_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT pool_liquidity_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS pool_liquidity_snapshot
        (
            Id               BIGINT UNSIGNED AUTO_INCREMENT,
            LiquidityPoolId  BIGINT UNSIGNED NOT NULL,
            SnapshotTypeId   SMALLINT        NOT NULL,
            TransactionCount INT             NOT NULL,
            StartDate        DATETIME        NULL,
            EndDate          DATETIME        NULL,
            ModifiedDate     DATETIME        NULL,
            Details          JSON            NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX pool_liquidity_snapshot_end_date_ix (EndDate),
            INDEX pool_liquidity_snapshot_start_date_ix (StartDate),
            UNIQUE pool_liquidity_snapshot_liquidity_pool_id_start_date_end_date_uq (LiquidityPoolId, StartDate, EndDate),
            CONSTRAINT pool_liquidity_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS pool_liquidity_summary
        (
            Id                              BIGINT UNSIGNED AUTO_INCREMENT,
            LiquidityPoolId                 BIGINT UNSIGNED    NOT NULL,
            LiquidityUsd                    DECIMAL(30, 8)     NOT NULL,
            DailyLiquidityUsdChangePercent  DECIMAL(30, 8)     NOT NULL,
            VolumeUsd                       DECIMAL(30, 8)     NOT NULL,
            StakingWeight                   BIGINT UNSIGNED    NOT NULL,
            DailyStakingWeightChangePercent DECIMAL(30, 8)     NOT NULL,
            LockedCrs                       BIGINT UNSIGNED    NOT NULL,
            LockedSrc                       VARCHAR(78)        NOT NULL,
            CreatedBlock                    BIGINT UNSIGNED    NOT NULL,
            ModifiedBlock                   BIGINT UNSIGNED    NOT NULL,
            PRIMARY KEY (Id),
            INDEX pool_liquidity_summary_liquidity_pool_id_ix (LiquidityPoolId),
            INDEX pool_liquidity_summary_liquidity_usd_ix (LiquidityUsd),
            INDEX pool_liquidity_summary_daily_liquidity_usd_change_ix (DailyLiquidityUsdChangePercent),
            INDEX pool_liquidity_summary_volume_usd_ix (VolumeUsd),
            INDEX pool_liquidity_summary_staking_weight_ix (StakingWeight),
            INDEX pool_liquidity_summary_daily_staking_weight_change_ix (DailyStakingWeightChangePercent),
            INDEX pool_liquidity_summary_locked_crs_ix (LockedCrs),
            CONSTRAINT pool_liquidity_summary_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id),
            CONSTRAINT pool_liquidity_summary_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT pool_liquidity_summary_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS pool_mining
        (
            Id                   BIGINT UNSIGNED AUTO_INCREMENT,
            LiquidityPoolId      BIGINT UNSIGNED         NOT NULL,
            Address              VARCHAR(50)             NOT NULL,
            RewardPerBlock       VARCHAR(78) DEFAULT '0' NOT NULL,
            RewardPerLpt         VARCHAR(78) DEFAULT '0' NOT NULL,
            MiningPeriodEndBlock BIGINT UNSIGNED         NOT NULL,
            CreatedBlock         BIGINT UNSIGNED         NOT NULL,
            ModifiedBlock        BIGINT UNSIGNED         NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE mining_pool_address_uq (Address),
            CONSTRAINT pool_mining_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id),
            CONSTRAINT pool_mining_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT pool_mining_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token_snapshot
        (
            Id             BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId        BIGINT UNSIGNED NOT NULL,
            MarketId       BIGINT UNSIGNED NOT NULL,
            SnapshotTypeId SMALLINT        NOT NULL,
            StartDate      DATETIME        NOT NULL,
            EndDate        DATETIME        NOT NULL,
            ModifiedDate   DATETIME        NOT NULL,
            Details        JSON            NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX token_snapshot_end_date_ix (EndDate),
            INDEX token_snapshot_start_date_ix (StartDate),
            INDEX token_snapshot_market_id_ix (MarketId), -- No FK, CRS uses MarketId = 0
            UNIQUE token_snapshot_market_id_token_id_start_date_end_date_uq (MarketId, TokenId, StartDate, EndDate),
            CONSTRAINT token_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT token_snapshot_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token_summary
        (
            Id                      BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId                BIGINT UNSIGNED NOT NULL,
            TokenId                 BIGINT UNSIGNED NOT NULL,
            DailyPriceChangePercent DECIMAL(30, 8)  NOT NULL,
            PriceUsd                DECIMAL(30, 8)  NOT NULL,
            CreatedBlock            BIGINT UNSIGNED NOT NULL,
            ModifiedBlock           BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX token_summary_market_id_ix (MarketId), -- No FK, CRS uses MarketId = 0
            INDEX token_summary_daily_price_change_percent_ix (DailyPriceChangePercent),
            INDEX token_summary_price_usd_ix (PriceUsd),
            CONSTRAINT token_summary_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE,
            CONSTRAINT token_summary_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_summary_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token_attribute_type
        (
            Id            SMALLINT UNSIGNED NOT NULL,
            AttributeType VARCHAR(50)       NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS token_attribute
        (
            Id              BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId         BIGINT UNSIGNED   NOT NULL,
            AttributeTypeId SMALLINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE token_attribute_token_id_attribute_type_id_uq (TokenId, AttributeTypeId),
            CONSTRAINT token_attribute_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE,
            CONSTRAINT token_attribute_attribute_type_id_token_attribute_type_id_fk
                FOREIGN KEY (AttributeTypeId)
                REFERENCES token_attribute_type (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS address_balance
        (
            Id              BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId         BIGINT UNSIGNED NOT NULL,
            Owner           VARCHAR(50)     NOT NULL,
            Balance         VARCHAR(78)     NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_balance_owner_token_id_uq (Owner, TokenId),
            CONSTRAINT address_balance_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT address_balance_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT address_balance_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS address_mining
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            MiningPoolId  BIGINT UNSIGNED NOT NULL,
            Owner         VARCHAR(50)     NOT NULL,
            Balance       VARCHAR(78)     NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_mining_owner_mining_pool_id_uq (Owner, MiningPoolId),
            CONSTRAINT address_mining_mining_pool_id_pool_mining_id_fk
                FOREIGN KEY (MiningPoolId)
                REFERENCES pool_mining (Id),
            CONSTRAINT address_mining_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT address_mining_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS address_staking
        (
            Id              BIGINT UNSIGNED AUTO_INCREMENT,
            LiquidityPoolId BIGINT UNSIGNED NOT NULL,
            Owner           VARCHAR(50)     NOT NULL,
            Weight          VARCHAR(78)     NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_staking_owner_liquidity_pool_id_uq (Owner, LiquidityPoolId),
            CONSTRAINT address_staking_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id),
            CONSTRAINT address_staking_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT address_staking_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS transaction
        (
            Id                 BIGINT UNSIGNED AUTO_INCREMENT,
            `From`             VARCHAR(50)      NOT NULL,
            `To`               VARCHAR(50)      NULL,
            NewContractAddress VARCHAR(50)      NULL,
            Hash               VARCHAR(64)      NOT NULL,
            Success            BIT DEFAULT b'0' NOT NULL,
            GasUsed            INT              NOT NULL,
            Block              BIGINT UNSIGNED  NOT NULL,
            Error              varchar(1000)    CHARACTER SET utf16 NULL COLLATE utf16_general_ci,
            PRIMARY KEY (Id),
            INDEX transaction_from_ix (`From`),
            UNIQUE transaction_hash_uq (Hash),
            INDEX transaction_new_contract_address_ix (NewContractAddress),
            CONSTRAINT transaction_block_block_height_fk
                FOREIGN KEY (Block)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS transaction_log_type
        (
            Id      SMALLINT    NOT NULL,
            LogType VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS transaction_log
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            TransactionId BIGINT UNSIGNED NOT NULL,
            LogTypeId     SMALLINT        NOT NULL,
            SortOrder     SMALLINT        NOT NULL,
            Contract      VARCHAR(50)     NOT NULL,
            Details       JSON            NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX transaction_log_contract_ix (Contract),
            CONSTRAINT transaction_log_log_type_id_transaction_log_type_id_fk
                FOREIGN KEY (LogTypeId)
                REFERENCES transaction_log_type (Id),
            CONSTRAINT transaction_log_transaction_id_transaction_id_fk
                FOREIGN KEY (TransactionId)
                REFERENCES transaction (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS mining_governance
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            Address             VARCHAR(50)              NOT NULL,
            TokenId             BIGINT UNSIGNED          NOT NULL,
            NominationPeriodEnd BIGINT UNSIGNED          NOT NULL,
            MiningDuration      BIGINT UNSIGNED          NOT NULL,
            MiningPoolsFunded   INT UNSIGNED DEFAULT 0   NOT NULL,
            MiningPoolReward    VARCHAR(78)  DEFAULT '0' NOT NULL,
            CreatedBlock        BIGINT UNSIGNED          NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED          NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE mining_governance_address_uq (Address),
            CONSTRAINT mining_governance_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT mining_governance_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT mining_governance_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS mining_governance_nomination
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            MiningGovernanceId  BIGINT UNSIGNED NOT NULL,
            LiquidityPoolId     BIGINT UNSIGNED NOT NULL,
            MiningPoolId        BIGINT UNSIGNED NOT NULL,
            IsNominated         BIT             NULL,
            Weight              VARCHAR(78)     NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            -- Deviate from naming standard with "gov_id", "liq_pool_id" and "min_pool_id" - name too long
            UNIQUE mining_governance_nomination_gov_id_liq_pool_id_min_pool_id_uq (MiningGovernanceId, LiquidityPoolId, MiningPoolId),
            INDEX mining_governance_nomination_is_nominated_ix (IsNominated),
            CONSTRAINT mining_governance_nomination_gov_id_mining_governance_id_fk
                FOREIGN KEY (MiningGovernanceId)
                REFERENCES mining_governance (Id),
            CONSTRAINT mining_governance_nomination_liq_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id),
            CONSTRAINT mining_governance_nomination_min_pool_id_pool_mining_id_fk
                FOREIGN KEY (MiningPoolId)
                REFERENCES pool_mining (Id),
            CONSTRAINT mining_governance_nomination_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT mining_governance_nomination_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId             BIGINT UNSIGNED NOT NULL,
            Address             VARCHAR(50)     NOT NULL,
            UnassignedSupply    VARCHAR(78)     NOT NULL,
            VestingDuration     BIGINT UNSIGNED NOT NULL,
            ProposedSupply      VARCHAR(78)     NOT NULL,
            TotalPledgeMinimum  BIGINT UNSIGNED NOT NULL,
            TotalVoteMinimum    BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_address_uq (Address),
            CONSTRAINT vault_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT vault_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_certificate
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultId             BIGINT UNSIGNED NOT NULL,
            Owner               VARCHAR(50)     NOT NULL,
            Amount              VARCHAR(78)     NOT NULL,
            Revoked             BIT             NOT NULL,
            Redeemed            BIT             NOT NULL,
            VestedBlock         BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_certificate_owner_ix (Owner),
            INDEX vault_certificate_redeemed_ix (Redeemed),
            INDEX vault_certificate_revoked_ix (Revoked),
            INDEX vault_certificate_vested_block_ix (VestedBlock),
            CONSTRAINT vault_certificate_vault_id_vault_id_fk
                FOREIGN KEY (VaultId)
                REFERENCES vault (Id),
            CONSTRAINT vault_certificate_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_certificate_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_token_blacklist
        (
            Id        BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId  BIGINT UNSIGNED NOT NULL,
            TokenId   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT market_token_blacklist_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_token_blacklist_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal_type
        (
            Id           SMALLINT UNSIGNED  NOT NULL,
            ProposalType VARCHAR(50)        NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_type_proposal_type_uq (ProposalType)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal_status
        (
            Id              SMALLINT UNSIGNED   NOT NULL,
            ProposalStatus  VARCHAR(50)         NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_status_proposal_status_uq (ProposalStatus)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal
        (
            Id                  BIGINT UNSIGNED   AUTO_INCREMENT,
            PublicId            BIGINT UNSIGNED   NOT NULL,
            VaultId             BIGINT UNSIGNED   NOT NULL,
            Creator             VARCHAR(50)       NOT NULL,
            Wallet              VARCHAR(50)       NOT NULL,
            Amount              VARCHAR(78)       NOT NULL,
            Description         VARCHAR(200)      CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci,
            ProposalTypeId      SMALLINT UNSIGNED NOT NULL,
            ProposalStatusId    SMALLINT UNSIGNED NOT NULL,
            Expiration          BIGINT UNSIGNED   NOT NULL,
            YesAmount           BIGINT UNSIGNED   NOT NULL,
            NoAmount            BIGINT UNSIGNED   NOT NULL,
            PledgeAmount        BIGINT UNSIGNED   NOT NULL,
            Approved            BIT               NOT NULL,
            CreatedBlock        BIGINT UNSIGNED   NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED   NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_public_id_ix (PublicId),
            INDEX vault_proposal_creator_ix (Creator),
            INDEX vault_proposal_wallet_ix (Wallet),
            INDEX vault_proposal_expiration_ix (Expiration),
            CONSTRAINT vault_proposal_vault_id_vault_id
                FOREIGN KEY (VaultId)
                REFERENCES vault (Id),
            CONSTRAINT vault_proposal_proposal_type_id_proposal_type_id_fk
                FOREIGN KEY (ProposalTypeId)
                REFERENCES vault_proposal_type (Id),
            CONSTRAINT vault_proposal_proposal_status_id_proposal_status_id_fk
                FOREIGN KEY (ProposalStatusId)
                REFERENCES vault_proposal_status (Id),
            CONSTRAINT vault_proposal_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal_certificate
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            ProposalId    BIGINT UNSIGNED NOT NULL,
            CertificateId BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_certificate_proposal_id_certificate_id_uq (ProposalId, CertificateId),
            CONSTRAINT vault_proposal_certificate_proposal_id_vault_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES vault_proposal (Id)
                ON DELETE CASCADE,
            CONSTRAINT vault_proposal_certificate_cert_id_vault_cert_id_fk
                FOREIGN KEY (CertificateId)
                REFERENCES vault_certificate (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal_pledge
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultId             BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Pledger             VARCHAR(50)     NOT NULL,
            Pledge              BIGINT UNSIGNED NOT NULL,
            Balance             BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_pledge_pledger_ix (Pledger),
            INDEX vault_proposal_pledge_pledge_ix (Pledge),
            UNIQUE vault_proposal_pledge_vault_id_proposal_id_pledger_uq (VaultId, ProposalId, Pledger),
            CONSTRAINT vault_proposal_pledge_vault_id_vault_id_fk
                FOREIGN KEY (VaultId)
                REFERENCES vault (Id),
            CONSTRAINT vault_proposal_pledge_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES vault_proposal (Id),
            CONSTRAINT vault_proposal_pledge_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_pledge_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault_proposal_vote
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultId             BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Voter               VARCHAR(50)     NOT NULL,
            Vote                BIGINT UNSIGNED NOT NULL,
            Balance             BIGINT UNSIGNED NOT NULL,
            InFavor             BIT             NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_vote_voter_ix (Voter),
            INDEX vault_proposal_vote_vote_ix (Vote),
            INDEX vault_proposal_vote_in_favor_ix (InFavor),
            UNIQUE vault_proposal_vote_vault_id_proposal_id_voter_uq (VaultId, ProposalId, Voter),
            CONSTRAINT vault_proposal_vote_vault_id_vault_id_fk
                FOREIGN KEY (VaultId)
                REFERENCES vault (Id),
            CONSTRAINT vault_proposal_vote_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES vault_proposal (Id),
            CONSTRAINT vault_proposal_vote_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_vote_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_token_attribute_blacklist
        (
            Id                    BIGINT UNSIGNED AUTO_INCREMENT,
            MarketId              BIGINT UNSIGNED   NOT NULL,
            TokenAttributeTypeId  SMALLINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT market_tablist_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
                ON DELETE CASCADE,
            CONSTRAINT market_tablist_tab_type_id_token_attribute_type_id_fk
                FOREIGN KEY (TokenAttributeTypeId)
                REFERENCES token_attribute_type (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS chain_type(
            Id      SMALLINT UNSIGNED NOT NULL,
            Name    VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE chain_type_name_uq (Name)
        ) ENGINE = INNODB;

        CREATE TABLE IF NOT EXISTS token_wrapped(
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId             BIGINT UNSIGNED NOT NULL,
            Owner               VARCHAR(50) NOT NULL,
            NativeChainTypeId   SMALLINT UNSIGNED NOT NULL,
            NativeAddress       VARCHAR(100) NULL,
            Validated           BIT NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE token_wrapped_token_id_uq (TokenId),
            INDEX token_wrapped_native_address_ix (NativeAddress),
            CONSTRAINT token_wrapped_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id) ON DELETE CASCADE,
            CONSTRAINT token_wrapped_native_chain_type_id_chain_type_id_fk
                FOREIGN KEY (NativeChainTypeId)
                REFERENCES chain_type (Id),
            CONSTRAINT token_wrapped_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_wrapped_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE = INNODB;

        CREATE TABLE IF NOT EXISTS auth_success(
            ConnectionId       VARCHAR(255) NOT NULL,
            Signer             VARCHAR(50) NOT NULL,
            Expiry             DATETIME NOT NULL,
            PRIMARY KEY (ConnectionId)
        ) ENGINE = INNODB;

        -- --------
        -- --------
        -- Populate Lookup Type Tables
        -- -------
        -- -------

        INSERT IGNORE INTO index_lock(Id, Available, Locked, ModifiedDate)
        VALUES (1, 0, 0, '0001-01-01 00:00:00');

        INSERT IGNORE INTO transaction_log_type(Id, LogType)
        VALUES
        (1, 'CreateMarketLog'),
        (2, 'SetPendingDeployerOwnershipLog'),
        (3, 'ClaimPendingDeployerOwnershipLog'),
        (4, 'CreateLiquidityPoolLog'),
        (5, 'SetPendingMarketOwnershipLog'),
        (6, 'ClaimPendingMarketOwnershipLog'),
        (7, 'ChangeMarketPermissionLog'),
        (8, 'MintLog'),
        (9, 'BurnLog'),
        (10, 'SwapLog'),
        (11, 'ReservesLog'),
        (12, 'ApprovalLog'),
        (13, 'TransferLog'),
        (14, 'StartStakingLog'),
        (15, 'StopStakingLog'),
        (16, 'CollectStakingRewardsLog'),
        (17, 'RewardMiningPoolLog'),
        (18, 'NominationLog'),
        (19, 'StartMiningLog'),
        (20, 'StopMiningLog'),
        (21, 'CollectMiningRewardsLog'),
        (22, 'EnableMiningLog'),
        (23, 'DistributionLog'),
        (24, 'CreateVaultCertificateLog'),
        (25, 'RevokeVaultCertificateLog'),
        (26, 'RedeemVaultCertificateLog'),
        (27, 'CreateVaultProposalLog'),
        (28, 'CompleteVaultProposalLog'),
        (29, 'VaultProposalPledgeLog'),
        (30, 'VaultProposalWithdrawPledgeLog'),
        (31, 'VaultProposalVoteLog'),
        (32, 'VaultProposalWithdrawVoteLog'),
        (33, 'OwnershipTransferredLog'),
        (34, 'SupplyChangeLog');

        INSERT IGNORE INTO snapshot_type(Id, SnapshotType)
        VALUES
            (1, 'Minute'),
            (2, 'Hour'),
            (3, 'Day'),
            (4, 'Week'),
            (5, 'Month');

        INSERT IGNORE INTO market_permission_type(Id, PermissionType)
        VALUES
            (1, 'CreatePool'),
            (2, 'Trade'),
            (3, 'Provide'),
            (4, 'SetPermissions');

        INSERT IGNORE INTO token_attribute_type(Id, AttributeType)
        VALUES
            (1, 'Provisional'),
            (2, 'NonProvisional'),
            (3, 'Staking'),
            (4, 'Security'),
            (5, 'Interflux');

        INSERT IGNORE INTO vault_proposal_type(Id, ProposalType)
        VALUES
            (1, 'Create'),
            (2, 'Revoke'),
            (3, 'PledgeMinimum'),
            (4, 'ProposalMinimum');

        INSERT IGNORE INTO vault_proposal_status(Id, ProposalStatus)
        VALUES
            (1, 'Pledge'),
            (2, 'Vote'),
            (3, 'Complete');


        INSERT IGNORE INTO chain_type(Id, Name)
        VALUES
            (1, 'Ethereum');
    END;
//

CALL CreateDatabase();
//

DROP PROCEDURE CreateDatabase;
//

-- --------
-- --------
-- Events
-- --------
-- --------

CREATE EVENT IF NOT EXISTS remove_expired_auth_success_event
ON SCHEDULE EVERY 5 MINUTE
DO
DELETE FROM auth_success WHERE Expiry < UTC_TIMESTAMP();
//

-- --------
-- --------
-- Stored Procedures
-- --------
-- --------

CREATE PROCEDURE UpdateMarketSummaryLiquidityPoolCount(IN marketId BIGINT UNSIGNED, IN blockHeight BIGINT UNSIGNED)
    BEGIN
        DECLARE _marketId BIGINT UNSIGNED DEFAULT marketId; # clear up ambiguity
        IF (_marketId > 0) THEN
            UPDATE market_summary ms
            SET LiquidityPoolCount = (SELECT COUNT(pl.Id) FROM pool_liquidity pl WHERE pl.MarketId = ms.MarketId), ModifiedBlock = blockHeight
            WHERE ms.MarketId = _marketId;
        ELSE
            UPDATE market_summary ms
            SET LiquidityPoolCount = (SELECT COUNT(pl.Id) FROM pool_liquidity pl WHERE pl.MarketId = ms.MarketId), ModifiedBlock = blockHeight
            WHERE ms.MarketId > 0; # without the WHERE clause, MYSQL will create a warning and won't execute the query
        END IF;
    END;
//

DELIMITER ;
