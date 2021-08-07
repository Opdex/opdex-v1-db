-- Creates the database for use with Opdex Platform API
DELIMITER //

CREATE PROCEDURE init_db ()
 BEGIN

    create table if not exists token
    (
        Id            bigint auto_increment,
        Address       varchar(50)     not null,
        IsLpt         bit default 0   not null,
        Symbol        varchar(20)     not null,
        Name          varchar(50)     not null,
        Decimals      smallint(2)     not null,
        Sats          bigint          not null,
        TotalSupply   varchar(78)     not null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        constraint primary key (Id),
        constraint token_Address_uindex
            unique (Address),
        index token_IsLpt_ix (IsLpt)
    );

    create table if not exists block
    (
        Height     bigint unsigned not null,
        Hash       varchar(64)     not null,
        Time       datetime        not null,
        MedianTime datetime        not null,
        constraint primary key (Height),
        constraint block_Hash_uindex
            unique (Hash),
        index block_MedianTime_index (MedianTime)
    );

    create table if not exists index_lock
    (
        Id           bigint,
        Available    bit            not null,
        Locked       bit            not null,
        InstanceId   varchar(40)    null,
        ModifiedDate datetime       not null,
        constraint primary key (Id)
    );

    create table if not exists market_deployer
    (
        Id            bigint auto_increment,
        Address       varchar(50)     not null,
        Owner         varchar(50)     not null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        constraint primary key (Id),
        constraint deployer_Address_uindex
            unique (Address)
    );

    create table if not exists market
    (
        Id               bigint auto_increment,
        Address          varchar(50)     not null,
        DeployerId       bigint          not null,
        StakingTokenId   bigint          null,
        Owner            varchar(50)     not null,
        AuthPoolCreators bit             not null,
        AuthTraders      bit             not null,
        AuthProviders    bit             not null,
        TransactionFee   smallint        not null,
        MarketFeeEnabled bit             not null,
        CreatedBlock     bigint unsigned not null,
        ModifiedBlock    bigint unsigned not null,
        constraint primary key (Id),
        constraint market_Address_uindex
            unique (Address),
        constraint market_deployer_Id_fk
            foreign key (DeployerId) references market_deployer (Id),
        index market_Owner_ix (Owner),
        index market_staking_Token_Id_ix (StakingTokenId)
    );

    create table if not exists market_permission_type
    (
        Id             int         not null,
        PermissionType varchar(50) not null,
        constraint primary key (Id),
        constraint market_permission_type_PermissionType_uindex
            unique (PermissionType)
    );

    create table if not exists market_permission
    (
        Id            bigint auto_increment,
        MarketId      bigint          not null,
        User          varchar(50)     not null,
        Permission    int             not null,
        IsAuthorized  bit             not null,
        Blame         varchar(50)     not null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        constraint primary key (Id),
        constraint market_permission_MarketId_fk
            foreign key (MarketId) references market (Id),
        constraint market_permission_Permission_fk
            foreign key (Permission) references market_permission_type (Id),
        constraint market_permission_MarketId_User_Permission_uindex
            unique (MarketId, User, Permission)
    );

    create table if not exists market_router
    (
        Id            bigint auto_increment,
        Address       varchar(50)     not null,
        MarketId      bigint          not null,
        IsActive      tinyint(1)      not null,
        ModifiedBlock bigint unsigned not null,
        CreatedBlock  bigint unsigned not null,
        constraint primary key (Id),
        constraint market_router_Address_uindex
            unique (Address),
        constraint market_router_market_Id_fk
            foreign key (MarketId) references market (Id)
    );

    create table if not exists odx_distribution
    (
        Id                           bigint auto_increment,
        VaultDistribution            varchar(78)     null,
        MiningGovernanceDistribution varchar(78)     null,
        PeriodIndex                  int             not null,
        DistributionBlock            bigint unsigned not null,
        NextDistributionBlock        bigint unsigned not null,
        CreatedBlock                 bigint unsigned not null,
        ModifiedBlock                bigint unsigned not null,
        constraint primary key (Id)
    );

    create table if not exists snapshot_type
    (
        Id           smallint    not null,
        SnapshotType varchar(50) not null,
        constraint primary key (Id)
    );

    create table if not exists market_snapshot
    (
        Id             bigint auto_increment,
        MarketId       bigint   not null,
        SnapshotTypeId smallint not null,
        StartDate      datetime not null,
        EndDate        datetime not null,
        ModifiedDate   datetime not null,
        Details        json not null,
        constraint primary key (Id),
        constraint market_snapshot_market_Id_fk
            foreign key (MarketId) references market (Id),
        constraint market_snapshot_snapshot_type_Id_fk
            foreign key (SnapshotTypeId) references snapshot_type (Id),
        index market_snapshot_EndDate_ix (EndDate),
        index market_snapshot_StartDate_ix (StartDate),
        index market_snapshot_MarketId_StartDate_EndDate_ix (MarketId, StartDate, EndDate)
    );

    create table if not exists pool_liquidity
    (
        Id            bigint auto_increment,
        SrcTokenId    bigint          not null,
        LpTokenId     bigint          not null,
        MarketId      bigint          not null,
        Address       varchar(50)     not null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        constraint primary key (Id),
        constraint pair_Address_uindex
            unique (Address),
        constraint pool_liquidity_MarketId_TokenId_uindex
            unique (MarketId, SrcTokenId),
        constraint pool_liquidity_market_Id_fk
            foreign key (MarketId) references market (Id),
        constraint pool_liquidity_token_lp_Id_fk
            foreign key (LpTokenId) references token (Id),
        constraint pool_liquidity_token_src_Id_fk
            foreign key (SrcTokenId) references token (Id)
    );

    create table if not exists pool_liquidity_snapshot
    (
        Id               bigint auto_increment,
        LiquidityPoolId  bigint   not null,
        SnapshotTypeId   int      not null,
        TransactionCount int      not null,
        StartDate        datetime null,
        EndDate          datetime null,
        ModifiedDate     datetime null,
        Details          json null,
        constraint primary key (Id),
        constraint pool_liquidity_snapshot_pool_liquidity_Id_fk
            foreign key (LiquidityPoolId) references pool_liquidity (Id),
        index pool_liquidity_snapshot_EndDate_ix (EndDate),
        index pool_liquidity_snapshot_StartDate_ix (StartDate)
    );

    create table if not exists pool_mining
    (
        Id                   bigint auto_increment,
        LiquidityPoolId      bigint                  not null,
        Address              varchar(50)             not null,
        RewardPerBlock       varchar(78) default '0' not null,
        RewardPerLpt         varchar(78) default '0' not null,
        MiningPeriodEndBlock bigint unsigned         not null,
        CreatedBlock         bigint unsigned         not null,
        ModifiedBlock        bigint unsigned         not null,
        constraint primary key (Id),
        constraint mining_pool_Address_uindex
            unique (Address),
        constraint mining_pool_LiquidityPoolId_uindex
            unique (LiquidityPoolId),
        constraint pool_mining_pool_liquidity_Id_fk
            foreign key (LiquidityPoolId) references pool_liquidity (Id)
    );

    create table if not exists token_snapshot
    (
        Id             bigint auto_increment,
        TokenId        bigint   not null,
        MarketId       bigint   not null,
        SnapshotTypeId smallint not null,
        StartDate      datetime not null,
        EndDate        datetime not null,
        ModifiedDate   datetime not null,
        Details        json not null,
        constraint primary key (Id),
        constraint token_snapshot_TokenId_StartDate_EndDate_uindex
            unique (TokenId, StartDate, EndDate),
        constraint token_snapshot_snapshot_type_Id_fk
            foreign key (SnapshotTypeId) references snapshot_type (Id),
        constraint token_snapshot_token_Id_fk
            foreign key (TokenId) references token (Id),
        index token_snapshot_TokenId_ix (TokenId)
    );

    create table if not exists address_balance
    (
        Id              bigint auto_increment,
        TokenId         bigint          not null,
        Owner           varchar(50)     not null,
        Balance         varchar(78)     not null,
        CreatedBlock    bigint unsigned not null,
        ModifiedBlock   bigint unsigned not null,
        constraint primary key (Id),
        constraint address_balance_token_Id_fk foreign key (TokenId) references token (Id),
        unique address_balance_Owner_TokenId_uq (Owner, TokenId),
        index address_balance_ModifiedBlock_ix (ModifiedBlock)
    );

    create table if not exists address_mining
    (
        Id            bigint auto_increment,
        MiningPoolId  bigint          not null,
        Owner         varchar(50)     not null,
        Balance       varchar(78)     null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        constraint primary key (Id),
        constraint address_mining_pool_mining_Id_fk foreign key (MiningPoolId) references pool_mining (Id),
        unique address_mining_Owner_MiningPoolId_uq (Owner, MiningPoolId),
        index address_mining_ModifiedBlock_ix (ModifiedBlock)
    );

    create table if not exists address_staking
    (
        Id              bigint auto_increment,
        LiquidityPoolId bigint          not null,
        Owner           varchar(50)     not null,
        Weight          varchar(78)     not null,
        CreatedBlock    bigint unsigned not null,
        ModifiedBlock   bigint unsigned not null,
        constraint primary key (Id),
        constraint address_staking_pool_liquidity_Id_fk foreign key (LiquidityPoolId) references pool_liquidity (Id),
        unique address_staking_Owner_LiquidityPoolId_uq (Owner, LiquidityPoolId),
        index address_staking_ModifiedBlock_ix (ModifiedBlock)
    );

    create table if not exists transaction
    (
        Id                 bigint auto_increment,
        `From`             varchar(50)      not null,
        `To`               varchar(50)      null,
        NewContractAddress varchar(50)      null,
        Hash               varchar(64)      not null,
        Success            bit default b'0' not null,
        GasUsed            int              not null,
        Block              bigint unsigned  not null,
        constraint primary key (Id),
        constraint transaction_block_Height_fk
            foreign key (Block) references block (Height),
        index transaction_Block_ix (Block),
        index transaction_From_ix (`From`),
        index transaction_Hash_ix (Hash)
    );

    create table if not exists transaction_log_type
    (
        Id      smallint    not null,
        LogType varchar(50) not null,
        constraint primary key (Id)
    );

    create table if not exists transaction_log
    (
        Id            bigint auto_increment,
        TransactionId bigint                       not null,
        LogTypeId     smallint                     not null,
        SortOrder     smallint(2)                  not null,
        Contract      varchar(50)                  not null,
        Details       json                             null,
        constraint primary key (Id),
        constraint transaction_log_transaction_log_type_Id_fk
            foreign key (LogTypeId) references transaction_log_type (Id),
        constraint Details
            check (json_valid(`Details`)),
        constraint transaction_log_tranasction_Id_fk
            foreign key (TransactionId) references transaction (Id),
        index transaction_log_transaction_Id_ix (TransactionId),
        index transaction_log_contract_ix (Contract)
    );

    create table if not exists governance
    (
        Id                  bigint auto_increment,
        Address             varchar(50)              not null,
        TokenId             bigint                   not null,
        NominationPeriodEnd bigint unsigned          not null,
        MiningDuration      bigint unsigned          not null,
        MiningPoolsFunded   int unsigned default 0   not null,
        MiningPoolReward    varchar(78)  default '0' not null,
        CreatedBlock        bigint unsigned          not null,
        ModifiedBlock       bigint unsigned          not null,
        constraint primary key (Id),
        constraint governance_Address_uindex
            unique (Address),
        constraint governance_TokenId_uindex
            unique (TokenId),
        constraint governance_token_Id_fk
            foreign key (TokenId) references token (Id)
    );

    create table if not exists governance_nomination
    (
        Id              bigint auto_increment,
        LiquidityPoolId bigint          not null,
        MiningPoolId    bigint          not null,
        IsNominated     bit             null,
        Weight          varchar(78)     not null,
        CreatedBlock    bigint unsigned not null,
        ModifiedBlock   bigint unsigned not null,
        constraint primary key (Id),
        constraint governance_nomination_LiquidityPoolId_MiningPoolId_uindex
            unique (LiquidityPoolId, MiningPoolId),
        index governance_nomination_IsNominated_ix (IsNominated)
    );

    create table if not exists vault
    (
        Id                  bigint auto_increment,
        TokenId             bigint          not null,
        Address             varchar(50)     not null,
        Owner               varchar(50)     not null,
        Genesis             bigint unsigned not null,
        UnassignedSupply    varchar(78)     not null,
        CreatedBlock        bigint unsigned not null,
        ModifiedBlock       bigint unsigned not null,
        primary key (Id),
        constraint vault_token_Id_fk foreign key (TokenId) references token (Id),
        unique vault_Address_uq (Address),
        unique vault_TokenId_uq (TokenId)
    );

    create table if not exists vault_certificate
    (
        Id            bigint auto_increment,
        VaultId       bigint          not null,
        Owner         varchar(50)     not null,
        Amount        varchar(78)     not null,
        VestedBlock   bigint unsigned not null,
        Redeemed      bit             not null,
        Revoked       bit             not null,
        CreatedBlock  bigint unsigned not null,
        ModifiedBlock bigint unsigned not null,
        primary key (Id),
        constraint vault_certificate_vault_Id_fk foreign key (VaultId) references vault (Id),
        index vault_certificate_Owner_ix (Owner)
    );

    -- --------
    -- --------
    -- Populate Lookup Type Tables
    -- -------
    -- -------

    insert ignore into token(Id, Address, Symbol, Name, Decimals, Sats, TotalSupply, CreatedBlock, ModifiedBlock)
    values(1, 'CRS', 'CRS', 'Cirrus', 8, 100000000, '13000000000000000', 1, 1);

    insert ignore into index_lock(Id, Available, Locked, ModifiedDate)
    values (1, 0, 0, '0001-01-01 00:00:00');

    insert ignore into transaction_log_type(Id, LogType)
    values
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

    insert ignore into snapshot_type
    values
        (1, 'Minute'),
        (2, 'Hour'),
        (3, 'Day'),
        (4, 'Month'),
        (5, 'Year');

    insert ignore into market_permission_type
    values
        (1, 'CreatePool'),
        (2, 'Trade'),
        (3, 'Provide'),
        (4, 'SetPermissions');

 END;
//

CALL init_db();
//

DROP PROCEDURE init_db;
//

DELIMITER ;