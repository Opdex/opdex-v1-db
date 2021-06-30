-- Creates the database for use with Opdex Platform API

create table address_allowance
(
    Id              bigint auto_increment,
    TokenId         bigint          not null,
    Owner           varchar(50)     not null,
    Spender         varchar(50)     not null,
    Allowance       varchar(78)     not null,
    CreatedBlock    bigint unsigned not null,
    ModifiedBlock   bigint unsigned not null,
    constraint primary key (Id),
    constraint address_allowance_token_Id_fk foreign key (TokenId) references token (Id),
    unique address_allowance_TokenId_Owner_Spender_uq (TokenId, Owner, Spender),
    index address_allowance_ModifiedBlock_ix (ModifiedBlock)
);

create table address_balance
(
    Id              bigint auto_increment,
    TokenId         bigint          not null,
    LiquidityPoolId bigint          not null,
    Owner           varchar(50)     not null,
    Balance         varchar(78)     not null,
    CreatedBlock    bigint unsigned not null,
    ModifiedBlock   bigint unsigned not null,
    constraint primary key (Id),
    constraint address_balance_token_Id_fk foreign key (TokenId) references token (Id),
    constraint address_balance_pool_liquidity_Id_fk foreign key (LiquidityPoolId) references pool_liquidity (Id),
    unique address_balance_TokenId_LiquidityPoolId_Owner_uq (TokenId, LiquidityPoolId, Owner),
    index address_balance_ModifiedBlock_ix (ModifiedBlock)
);

create table address_mining
(
    Id            bigint auto_increment,
    MiningPoolId  bigint          not null,
    Owner         varchar(50)     not null,
    Balance       varchar(78)     null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint primary key (Id),
    constraint address_mining_pool_mining_Id_fk foreign key (MiningPoolId) references pool_mining (Id),
    unique address_mining_MiningPoolId_Owner_uq (MiningPoolId, Owner),
    index address_mining_ModifiedBlock_ix (ModifiedBlock)
);

create table address_staking
(
    Id              bigint auto_increment,
    LiquidityPoolId bigint          not null,
    Owner           varchar(50)     not null,
    Weight          varchar(78)     not null,
    CreatedBlock    bigint unsigned not null,
    ModifiedBlock   bigint unsigned not null,
    constraint primary key (Id),
    constraint address_staking_pool_liquidity_Id_fk foreign key (LiquidityPoolId) references pool_liquidity (Id),
    unique address_staking_LiquidityPoolId_Owner_uq (LiquidityPoolId, Owner),
    index address_staking_ModifiedBlock_ix (ModifiedBlock)
);

create table block
(
    Height     bigint unsigned not null,
    Hash       varchar(64)     not null,
    Time       datetime        not null,
    MedianTime datetime        not null,
    constraint block_Hash_uindex
        unique (Hash),
    constraint block_Height_uindex
        unique (Height)
);

create index block_MedianTime_index
    on block (MedianTime);

alter table block
    add primary key (Height);

create table index_lock
(
    Locked       bit      not null,
    ModifiedDate datetime not null
);

create table market_deployer
(
    Id            bigint auto_increment,
    Address       varchar(50)     not null,
    Owner         varchar(50)     not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint deployer_Address_uindex
        unique (Address),
    constraint deployer_Id_uindex
        unique (Id)
);

alter table market_deployer
    add primary key (Id);

create table market
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
    constraint market_Address_uindex
        unique (Address),
    constraint market_Id_uindex
        unique (Id),
    constraint market_deployer_Id_fk
        foreign key (DeployerId) references market_deployer (Id)
);

create index market_Owner_index
    on market (Owner);

create index market_token_Id_fk
    on market (StakingTokenId);

alter table market
    add primary key (Id);

create table market_permission_type
(
    Id             int         not null,
    PermissionType varchar(50) not null,
    constraint primary key (Id),
    constraint market_permission_type_PermissionType_uindex
        unique (PermissionType)
);

create table market_permission
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

create table market_router
(
    Id            bigint auto_increment,
    Address       varchar(50)     not null,
    MarketId      bigint          not null,
    IsActive      tinyint(1)      not null,
    ModifiedBlock bigint unsigned not null,
    CreatedBlock  bigint unsigned not null,
    constraint market_router_Address_uindex
        unique (Address),
    constraint market_router_Id_uindex
        unique (Id),
    constraint market_router_market_Id_fk
        foreign key (MarketId) references market (Id)
);

alter table market_router
    add primary key (Id);

create table odx_distribution
(
    Id                           bigint auto_increment,
    VaultDistribution            varchar(78)     null,
    MiningGovernanceDistribution varchar(78)     null,
    PeriodIndex                  int             not null,
    DistributionBlock            bigint unsigned not null,
    NextDistributionBlock        bigint unsigned not null,
    CreatedBlock                 bigint unsigned not null,
    ModifiedBlock                bigint unsigned not null,
    constraint odx_distribution_Id_uindex
        unique (Id)
);

alter table odx_distribution
    add primary key (Id);

create table odx_mining_governance
(
    Id                  bigint auto_increment,
    Address             varchar(50)              not null,
    TokenId             bigint                   not null,
    NominationPeriodEnd bigint unsigned          not null,
    MiningPoolsFunded   int unsigned default 0   not null,
    MiningPoolReward    varchar(78)  default '0' not null,
    CreatedBlock        bigint unsigned          not null,
    ModifiedBlock       bigint unsigned          not null,
    constraint governance_Address_uindex
        unique (Address),
    constraint governance_Id_uindex
        unique (Id)
);

alter table odx_mining_governance
    add primary key (Id);

create table odx_mining_governance_nomination
(
    Id              bigint          null,
    LiquidityPoolId bigint          not null,
    MiningPoolId    bigint          not null,
    IsNominated     bit             null,
    Weight          varchar(78)     not null,
    CreatedBlock    bigint unsigned not null,
    ModifiedBlock   bigint unsigned not null,
    constraint odx_mining_governance_nomination_Id_uindex
        unique (Id),
    constraint odx_mining_governance_nomination_LpId_mpId_uindex
        unique (LiquidityPoolId, MiningPoolId)
);

create index odx_mining_governance_nomination_IsNominated_index
    on odx_mining_governance_nomination (IsNominated);

create table odx_vault
(
    Id            bigint auto_increment,
    TokenId       bigint          not null,
    Address       varchar(70)     not null,
    Owner         varchar(50)     not null,
    Genesis       bigint unsigned not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint vault_Id_uindex
        unique (Id)
);

alter table odx_vault
    add primary key (Id);

create table odx_vault_certificate
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
    constraint vault_certificate_Id_uindex
        unique (Id)
);

alter table odx_vault_certificate
    add primary key (Id);

create table pool_mining_snapshot
(
    Id               bigint auto_increment,
    MiningPoolId     bigint                      not null,
    MiningWeight     varchar(78)    default '0'  not null,
    MiningUsd        decimal(20, 2) default 0.00 null,
    RemainingRewards varchar(78)    default '0'  null,
    constraint pool_mining_snapshot_Id_uindex
        unique (Id)
);

alter table pool_mining_snapshot
    add primary key (Id);

create table snapshot_type
(
    Id           smallint    not null,
    SnapshotType varchar(50) not null,
    constraint snapshot_type_Id_uindex
        unique (Id)
);

alter table snapshot_type
    add primary key (Id);

create table market_snapshot
(
    Id               bigint auto_increment,
    MarketId         bigint                      not null,
    TransactionCount int            default 0    not null,
    Liquidity        decimal(20, 2) default 0.00 not null,
    Volume           decimal(20, 2) default 0.00 not null,
    StakingWeight    varchar(78)    default '0'  not null,
    StakingUsd       decimal(20, 2) default 0.00 not null,
    StakerRewards    decimal(20, 2) default 0.00 not null,
    ProviderRewards  decimal(20, 2) default 0.00 not null,
    SnapshotTypeId   smallint                    not null,
    StartDate        datetime                    not null,
    EndDate          datetime                    not null,
    CreatedDate      datetime                    not null,
    constraint market_snapshot_Id_uindex
        unique (Id),
    constraint market_snapshot_market_Id_fk
        foreign key (MarketId) references market (Id),
    constraint market_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id)
);

create index market_snapshot_MarketId_StartDate_EndDate_index
    on market_snapshot (MarketId, StartDate, EndDate);

alter table market_snapshot
    add primary key (Id);

create table token
(
    Id            bigint auto_increment,
    Address       varchar(50)     not null,
    Symbol        varchar(10)     not null,
    Name          varchar(50)     not null,
    Decimals      smallint(2)     not null,
    Sats          bigint          not null,
    TotalSupply   varchar(78)     not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint token_Address_uindex
        unique (Address),
    constraint token_Id_uindex
        unique (Id)
);

alter table token
    add primary key (Id);

create table pool_liquidity
(
    Id            bigint auto_increment,
    TokenId       bigint          not null,
    MarketId      bigint          null,
    Address       varchar(50)     not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint pair_Address_uindex
        unique (Address),
    constraint pair_Id_uindex
        unique (Id),
    constraint pool_liquidity_MarketId_TokenId_uindex
        unique (MarketId, TokenId),
    constraint pool_liquidity_market_Id_fk
        foreign key (MarketId) references market (Id),
    constraint pool_liquidity_token_Id_fk
        foreign key (TokenId) references token (Id)
);

alter table pool_liquidity
    add primary key (Id);

create table pool_liquidity_snapshot
(
    Id               bigint auto_increment,
    LiquidityPoolId  bigint                      not null,
    TransactionCount int            default 0    not null,
    ReserveCrs       varchar(78)    default '0'  not null,
    ReserveSrc       varchar(78)    default '0'  not null,
    ReserveUsd       decimal(20, 2) default 0.00 not null,
    VolumeCrs        varchar(78)    default '0'  not null,
    VolumeSrc        varchar(78)    default '0'  not null,
    VolumeUsd        decimal(20, 2) default 0.00 not null,
    StakingWeight    varchar(78)    default '0'  not null,
    StakingUsd       decimal(20, 2) default 0.00 not null,
    ProviderRewards  decimal(20, 2) default 0.00 not null,
    StakerRewards    decimal(20, 2) default 0.00 not null,
    SnapshotTypeId   smallint                    not null,
    StartDate        datetime                    not null,
    EndDate          datetime                    not null,
    constraint pair_snapshot_Id_uindex
        unique (Id),
    constraint pool_liquidity_snapshot_LiquidityPoolId_StartDate_EndDate_uindex
        unique (LiquidityPoolId, StartDate, EndDate),
    constraint pool_liquidity_snapshot_pool_liquidity_Id_fk
        foreign key (LiquidityPoolId) references pool_liquidity (Id),
    constraint pool_liquidity_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id)
);

alter table pool_liquidity_snapshot
    add primary key (Id);

create table pool_mining
(
    Id                   bigint auto_increment,
    LiquidityPoolId      bigint                  not null,
    Address              varchar(50)             not null,
    RewardPerBlock       varchar(78) default '0' not null,
    RewardPerLpt         varchar(78) default '0' not null,
    MiningPeriodEndBlock bigint unsigned         not null,
    CreatedBlock         bigint unsigned         not null,
    ModifiedBlock        bigint unsigned         not null,
    constraint mining_pool_Address_uindex
        unique (Address),
    constraint mining_pool_Id_uindex
        unique (Id),
    constraint mining_pool_LiquidityPoolId_uindex
        unique (LiquidityPoolId),
    constraint pool_mining_pool_liquidity_Id_fk
        foreign key (LiquidityPoolId) references pool_liquidity (Id)
);

alter table pool_mining
    add primary key (Id);

create table token_snapshot
(
    Id             bigint auto_increment,
    TokenId        bigint                      not null,
    MarketId       bigint                      not null,
    SnapshotTypeId smallint                    not null,
    Price          decimal(20, 2) default 0.00 not null,
    StartDate      datetime                    not null,
    EndDate        datetime                    not null,
    constraint token_snapshot_Id_uindex
        unique (Id),
    constraint token_snapshot_TokenId_StartDate_EndDate_uindex
        unique (TokenId, StartDate, EndDate),
    constraint token_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id),
    constraint token_snapshot_token_Id_fk
        foreign key (TokenId) references token (Id)
);

create index token_snapshot_TokenId_index
    on token_snapshot (TokenId);

alter table token_snapshot
    add primary key (Id);

create table transaction
(
    Id                 bigint auto_increment,
    `From`             varchar(50)      not null,
    `To`               varchar(50)      null,
    NewContractAddress varchar(50)      null,
    Hash               varchar(64)      not null,
    Success            bit default b'0' not null,
    GasUsed            int              not null,
    Block              bigint unsigned  not null,
    constraint transaction_Id_uindex
        unique (Id),
    constraint transaction_block_Height_fk
        foreign key (Block) references block (Height)
);

create index transaction_Block_index
    on transaction (Block);

create index transaction_From_index
    on transaction (`From`);

create index transaction_Hash_index
    on transaction (Hash);

alter table transaction
    add primary key (Id);

create table transaction_log_type
(
    Id      smallint    not null,
    LogType varchar(50) not null,
    constraint transaction_event_type_Id_uindex
        unique (Id)
);

alter table transaction_log_type
    add primary key (Id);

create table transaction_log
(
    Id            bigint auto_increment,
    TransactionId bigint                       not null,
    LogTypeId     smallint                     not null,
    SortOrder     smallint(2)                  not null,
    Contract      varchar(50)                  not null,
    Details       longtext collate utf8mb4_bin null,
    constraint transaction_event_Id_uindex
        unique (Id),
    constraint transaction_log_transaction_log_type_Id_fk
        foreign key (LogTypeId) references transaction_log_type (Id),
    constraint Details
        check (json_valid(`Details`))
);

create index transaction_event_transaction_Id_fk
    on transaction_log (TransactionId);

create index transaction_log_Contract_index
    on transaction_log (Contract);

alter table transaction_log
    add primary key (Id);


-- --------
-- --------
-- Populate Lookup Type Tables
-- -------
-- -------

insert into token(Id, Address, Symbol, Name, Decimals, Sats, TotalSupply, CreatedBlock, ModifiedBlock)
values(1, 'CRS', 'CRS', 'Cirrus', 8, 100000000, '13000000000000000', 1, 1);

insert into index_lock(Locked, ModifiedDate)
values (0, '0000-00-00 00:00:00');

insert into transaction_log_type(Id, LogType)
values
(1, 'CreateMarketLog'),
(2, 'ChangeDeployerOwnerLog'),
(3, 'CreateLiquidityPoolLog'),
(4, 'ChangeMarketOwnerLog'),
(5, 'ChangeMarketPermissionLog'),
(6, 'MintLog'),
(7, 'BurnLog'),
(8, 'SwapLog'),
(9, 'ReservesLog'),
(10, 'ApprovalLog'),
(11, 'TransferLog'),
(12, 'ChangeMarketLog'),
(13, 'StakeLog'),
(14, 'CollectStakingRewardsLog'),
(15, 'RewardMiningPoolLog'),
(16, 'NominationLog'),
(17, 'MineLog'),
(18, 'CollectMiningRewardsLog'),
(19, 'EnableMiningLog'),
(20, 'DistributionLog'),
(21, 'CreateVaultCertificateLog'),
(22, 'RevokeVaultCertificateLog'),
(23, 'RedeemVaultCertificateLog'),
(24, 'ChangeVaultOwnerLog');

insert into snapshot_type
values
    (1, 'Minute'),
    (2, 'Hour'),
    (3, 'Day'),
    (4, 'Month'),
    (5, 'Year');

insert into market_permission_type
values
    (1, 'CreatePool'),
    (2, 'Trade'),
    (3, 'Provide'),
    (4, 'SetPermissions');