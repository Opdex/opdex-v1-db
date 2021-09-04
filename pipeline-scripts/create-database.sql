-- Creates the database for use with Opdex Platform API
DELIMITER //

DROP PROCEDURE IF EXISTS CreateDatabase;
//

CREATE PROCEDURE CreateDatabase ()
    BEGIN
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
            Id            BIGINT AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
            IsLpt         BIT DEFAULT 0   NOT NULL,
            Symbol        VARCHAR(20)     NOT NULL,
            Name          VARCHAR(50)     NOT NULL,
            Decimals      SMALLINT        NOT NULL,
            Sats          BIGINT          NOT NULL,
            TotalSupply   VARCHAR(78)     NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE token_address_uq (Address),
            INDEX token_symbol_ix (Symbol),
            INDEX token_name_ix (Name),
            INDEX token_is_lpt_ix (IsLpt),
            CONSTRAINT token_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS index_lock
        (
            Id           BIGINT,
            Available    BIT            NOT NULL,
            Locked       BIT            NOT NULL,
            InstanceId   VARCHAR(40)    NULL,
            ModifiedDate DATETIME       NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_deployer
        (
            Id            BIGINT AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
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
            Id               BIGINT AUTO_INCREMENT,
            Address          VARCHAR(50)     NOT NULL,
            DeployerId       BIGINT          NOT NULL,
            StakingTokenId   BIGINT          NULL,
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
            Id            BIGINT AUTO_INCREMENT,
            MarketId      BIGINT          NOT NULL,
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
            Id            BIGINT AUTO_INCREMENT,
            Address       VARCHAR(50)     NOT NULL,
            MarketId      BIGINT          NOT NULL,
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
            Id                           BIGINT AUTO_INCREMENT,
            TokenId                      BIGINT          NOT NULL,
            VaultDistribution            VARCHAR(78)     NULL,
            MiningGovernanceDistribution VARCHAR(78)     NULL,
            PeriodIndex                  INT             NOT NULL,
            DistributionBlock            BIGINT UNSIGNED NOT NULL,
            NextDistributionBlock        BIGINT UNSIGNED NOT NULL,
            CreatedBlock                 BIGINT UNSIGNED NOT NULL,
            ModifiedBlock                BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            CONSTRAINT token_distribution_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT token_distribution_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT token_distribution_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS snapshot_type
        (
            Id           SMALLINT    NOT NULL,
            SnapshotType VARCHAR(50) NOT NULL,
            PRIMARY KEY (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS market_snapshot
        (
            Id             BIGINT AUTO_INCREMENT,
            MarketId       BIGINT   NOT NULL,
            SnapshotTypeId SMALLINT NOT NULL,
            StartDate      DATETIME NOT NULL,
            EndDate        DATETIME NOT NULL,
            ModifiedDate   DATETIME NOT NULL,
            Details        JSON     NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX market_snapshot_end_date_ix (EndDate),
            INDEX market_snapshot_start_date_ix (StartDate),
            UNIQUE market_snapshot_market_id_start_date_end_date_ix (MarketId, StartDate, EndDate),
            CONSTRAINT market_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT market_snapshot_market_id_market_id_fk
                FOREIGN KEY (MarketId)
                REFERENCES market (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS pool_liquidity
        (
            Id            BIGINT AUTO_INCREMENT,
            SrcTokenId    BIGINT          NOT NULL,
            LpTokenId     BIGINT          NOT NULL,
            MarketId      BIGINT          NOT NULL,
            Address       VARCHAR(50)     NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE pool_liquidity_address_uq (Address),
            UNIQUE pool_liquidity_market_id_token_id_uq (MarketId, SrcTokenId),
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
            Id               BIGINT AUTO_INCREMENT,
            LiquidityPoolId  BIGINT   NOT NULL,
            SnapshotTypeId   SMALLINT NOT NULL,
            TransactionCount INT      NOT NULL,
            StartDate        DATETIME NULL,
            EndDate          DATETIME NULL,
            ModifiedDate     DATETIME NULL,
            Details          JSON     NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX pool_liquidity_snapshot_end_date_ix (EndDate),
            INDEX pool_liquidity_snapshot_start_date_ix (StartDate),
            UNIQUE market_snapshot_market_id_start_date_end_date_ix (LiquidityPoolId, StartDate, EndDate),
            CONSTRAINT pool_liquidity_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT pool_liquidity_snapshot_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS pool_liquidity_summary
        (
            Id               BIGINT             AUTO_INCREMENT,
            LiquidityPoolId  BIGINT             NOT NULL,
            LiquidityUsd     DECIMAL(30, 8)     NOT NULL,
            VolumeUsd        DECIMAL(30, 8)     NOT NULL,
            StakingWeight    BIGINT UNSIGNED    NOT NULL,
            LockedCrs        BIGINT UNSIGNED    NOT NULL,
            LockedSrc        VARCHAR(78)        NOT NULL,
            CreatedBlock     BIGINT UNSIGNED    NOT NULL,
            ModifiedBlock    BIGINT UNSIGNED    NOT NULL,
            PRIMARY KEY (Id),
            INDEX pool_liquidity_summary_liquidity_pool_id_ix (LiquidityPoolId),
            INDEX pool_liquidity_summary_liquidity_usd_ix (LiquidityUsd),
            INDEX pool_liquidity_summary_volume_usd_ix (VolumeUsd),
            INDEX pool_liquidity_summary_staking_weight_ix (StakingWeight),
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
            Id                   BIGINT AUTO_INCREMENT,
            LiquidityPoolId      BIGINT                  NOT NULL,
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
            Id             BIGINT AUTO_INCREMENT,
            TokenId        BIGINT   NOT NULL,
            MarketId       BIGINT   NOT NULL,
            SnapshotTypeId SMALLINT NOT NULL,
            StartDate      DATETIME NOT NULL,
            EndDate        DATETIME NOT NULL,
            ModifiedDate   DATETIME NOT NULL,
            Details        JSON     NOT NULL,
            PRIMARY KEY (Id),
            CHECK (JSON_valid(`Details`)),
            INDEX token_snapshot_end_date_ix (EndDate),
            INDEX token_snapshot_start_date_ix (StartDate),
            INDEX token_snapshot_market_id_ix (StartDate), -- No FK, CRS uses MarketId = 0
            UNIQUE token_snapshot_token_id_start_date_end_date_uq (MarketId, TokenId, StartDate, EndDate),
            CONSTRAINT token_snapshot_snapshot_type_id_snapshot_type_id_fk
                FOREIGN KEY (SnapshotTypeId)
                REFERENCES snapshot_type (Id),
            CONSTRAINT token_snapshot_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS address_balance
        (
            Id              BIGINT AUTO_INCREMENT,
            TokenId         BIGINT          NOT NULL,
            Owner           VARCHAR(50)     NOT NULL,
            Balance         VARCHAR(78)     NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_balance_owner_token_id_uq (Owner, TokenId),
            CONSTRAINT address_balance_token_id_fk
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
            Id            BIGINT AUTO_INCREMENT,
            MiningPoolId  BIGINT          NOT NULL,
            Owner         VARCHAR(50)     NOT NULL,
            Balance       VARCHAR(78)     NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_mining_owner_mining_pool_id_uq (Owner, MiningPoolId),
            CONSTRAINT address_mining_pool_mining_id_fk
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
            Id              BIGINT AUTO_INCREMENT,
            LiquidityPoolId BIGINT          NOT NULL,
            Owner           VARCHAR(50)     NOT NULL,
            Weight          VARCHAR(78)     NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE address_staking_owner_liquidity_pool_id_uq (Owner, LiquidityPoolId),
            CONSTRAINT address_staking_pool_liquidity_id_fk
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
            Id                 BIGINT AUTO_INCREMENT,
            `From`             VARCHAR(50)      NOT NULL,
            `To`               VARCHAR(50)      NULL,
            NewContractAddress VARCHAR(50)      NULL,
            Hash               VARCHAR(64)      NOT NULL,
            Success            BIT DEFAULT b'0' NOT NULL,
            GasUsed            INT              NOT NULL,
            Block              BIGINT UNSIGNED  NOT NULL,
            PRIMARY KEY (Id),
            INDEX transaction_from_ix (`From`),
            UNIQUE transaction_hash_uq (Hash),
            UNIQUE transaction_new_contract_address_uq (NewContractAddress),
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
            Id            BIGINT AUTO_INCREMENT,
            TransactionId BIGINT                       NOT NULL,
            LogTypeId     SMALLINT                     NOT NULL,
            SortOrder     SMALLINT                     NOT NULL,
            Contract      VARCHAR(50)                  NOT NULL,
            Details       JSON                             NULL,
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

        CREATE TABLE IF NOT EXISTS governance
        (
            Id                  BIGINT AUTO_INCREMENT,
            Address             VARCHAR(50)              NOT NULL,
            TokenId             BIGINT                   NOT NULL,
            NominationPeriodEnd BIGINT UNSIGNED          NOT NULL,
            MiningDuration      BIGINT UNSIGNED          NOT NULL,
            MiningPoolsFunded   INT UNSIGNED DEFAULT 0   NOT NULL,
            MiningPoolReward    VARCHAR(78)  DEFAULT '0' NOT NULL,
            CreatedBlock        BIGINT UNSIGNED          NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED          NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE governance_address_uq (Address),
            CONSTRAINT governance_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT governance_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT governance_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS governance_nomination
        (
            Id              BIGINT AUTO_INCREMENT,
            GovernanceId    BIGINT          NOT NULL,
            LiquidityPoolId BIGINT          NOT NULL,
            MiningPoolId    BIGINT          NOT NULL,
            IsNominated     BIT             NULL,
            Weight          VARCHAR(78)     NOT NULL,
            CreatedBlock    BIGINT UNSIGNED NOT NULL,
            ModifiedBlock   BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            -- Deviate from naming standard with "gov_id" - name too long
            UNIQUE governance_nomination_gov_id_liquidity_pool_id_mining_pool_id_uq (GovernanceId, LiquidityPoolId, MiningPoolId),
            INDEX governance_nomination_is_nominated_ix (IsNominated),
            CONSTRAINT governance_nomination_governance_id_governance_id_fk
                FOREIGN KEY (GovernanceId)
                REFERENCES governance (Id),
            CONSTRAINT governance_nomination_liquidity_pool_id_pool_liquidity_id_fk
                FOREIGN KEY (LiquidityPoolId)
                REFERENCES pool_liquidity (Id),
            CONSTRAINT governance_nomination_mining_pool_id_pool_mining_id_fk
                FOREIGN KEY (MiningPoolId)
                REFERENCES pool_mining (Id),
            CONSTRAINT governance_nomination_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT governance_nomination_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;

        CREATE TABLE IF NOT EXISTS vault
        (
            Id                  BIGINT AUTO_INCREMENT,
            TokenId             BIGINT          NOT NULL,
            Address             VARCHAR(50)     NOT NULL,
            Owner               VARCHAR(50)     NOT NULL,
            Genesis             BIGINT UNSIGNED NOT NULL,
            UnassignedSupply    VARCHAR(78)     NOT NULL,
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
            Id            BIGINT AUTO_INCREMENT,
            VaultId       BIGINT          NOT NULL,
            Owner         VARCHAR(50)     NOT NULL,
            Amount        VARCHAR(78)     NOT NULL,
            VestedBlock   BIGINT UNSIGNED NOT NULL,
            Redeemed      BIT             NOT NULL,
            Revoked       BIT             NOT NULL,
            CreatedBlock  BIGINT UNSIGNED NOT NULL,
            ModifiedBlock BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_certificate_owner_ix (Owner),
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

        -- --------
        -- --------
        -- Populate Lookup Type Tables
        -- -------
        -- -------

        INSERT IGNORE INTO block(Height, Hash, Time, MedianTime)
        VALUES(1, 'default', '0001-01-01 00:00:00', '0001-01-01 00:00:00');

        INSERT IGNORE INTO token(Id, Address, IsLpt, Symbol, Name, Decimals, Sats, TotalSupply, CreatedBlock, ModifiedBlock)
        VALUES(1, 'CRS', false, 'CRS', 'Cirrus', 8, 100000000, '13000000000000000', 1, 1);

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
        (27, 'SetPendingVaultOwnershipLog'),
        (28, 'ClaimPendingVaultOwnershipLog');

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
    END;
//

CALL CreateDatabase();
//

DROP PROCEDURE CreateDatabase;
//

DELIMITER ;