-- Creates the database for use with Opdex Platform API

create table block
(
    Height     bigint unsigned not null,
    Hash       varchar(64)     not null,
    Time       datetime        not null,
    MedianTime datetime        not null,
    constraint primary key (Height),
    constraint block_Hash_uindex
        unique (Hash)
);

create index block_MedianTime_index
    on block (MedianTime);

create table index_lock
(
    Available    bit      not null,
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
    constraint primary key (Id),
    constraint deployer_Address_uindex
        unique (Address)
);

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
    constraint primary key (Id),
    constraint market_Address_uindex
        unique (Address),
    constraint market_deployer_Id_fk
        foreign key (DeployerId) references market_deployer (Id)
);

create index market_Owner_index
    on market (Owner);

create index market_token_Id_fk
    on market (StakingTokenId);

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
    constraint primary key (Id),
    constraint market_router_Address_uindex
        unique (Address),
    constraint market_router_market_Id_fk
        foreign key (MarketId) references market (Id)
);

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
    constraint primary key (Id)
);

create table snapshot_type
(
    Id           smallint    not null,
    SnapshotType varchar(50) not null,
    constraint primary key (Id)
);

create table market_snapshot
(
    Id             bigint auto_increment,
    MarketId       bigint   not null,
    SnapshotTypeId smallint not null,
    StartDate      datetime not null,
    EndDate        datetime not null,
    ModifiedDate   datetime not null,
    Details        longtext not null,
    constraint primary key (Id),
    constraint market_snapshot_market_Id_fk
        foreign key (MarketId) references market (Id),
    constraint market_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id)
);

create index market_snapshot_EndDate_index
    on market_snapshot (EndDate);

create index market_snapshot_MarketId_StartDate_EndDate_index
    on market_snapshot (MarketId, StartDate, EndDate);

create index market_snapshot_StartDate_index
    on market_snapshot (StartDate);

create table token
(
    Id            bigint auto_increment,
    Address       varchar(50)     not null,
    IsLpt         bit default 0   not null,
    Symbol        varchar(10)     not null,
    Name          varchar(50)     not null,
    Decimals      smallint(2)     not null,
    Sats          bigint          not null,
    TotalSupply   varchar(78)     not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint primary key (Id),
    constraint token_Address_uindex
        unique (Address)
);

create index token_IsLpt_index
    on token (IsLpt);

create table pool_liquidity
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

create table pool_liquidity_snapshot
(
    Id               bigint auto_increment,
    LiquidityPoolId  bigint   not null,
    SnapshotTypeId   int      not null,
    TransactionCount int      not null,
    StartDate        datetime null,
    EndDate          datetime null,
    ModifiedDate     datetime null,
    Details          longtext null,
    constraint primary key (Id),
    constraint pool_liquidity_snapshot_pool_liquidity_Id_fk
        foreign key (LiquidityPoolId) references pool_liquidity (Id)
);

create index pool_liquidity_snapshot_EndDate_index
    on pool_liquidity_snapshot (EndDate);

create index pool_liquidity_snapshot_StartDate_index
    on pool_liquidity_snapshot (StartDate);

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
    constraint primary key (Id),
    constraint mining_pool_Address_uindex
        unique (Address),
    constraint mining_pool_LiquidityPoolId_uindex
        unique (LiquidityPoolId),
    constraint pool_mining_pool_liquidity_Id_fk
        foreign key (LiquidityPoolId) references pool_liquidity (Id)
);

create table token_snapshot
(
    Id             bigint auto_increment,
    TokenId        bigint   not null,
    MarketId       bigint   not null,
    SnapshotTypeId smallint not null,
    StartDate      datetime not null,
    EndDate        datetime not null,
    ModifiedDate   datetime not null,
    Details        longtext not null,
    constraint primary key (Id),
    constraint token_snapshot_TokenId_StartDate_EndDate_uindex
        unique (TokenId, StartDate, EndDate),
    constraint token_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id),
    constraint token_snapshot_token_Id_fk
        foreign key (TokenId) references token (Id)
);

create index token_snapshot_TokenId_index
    on token_snapshot (TokenId);

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
    unique address_allowance_Owner_Spender_TokenId_uq (Owner, Spender, TokenId),
    index address_allowance_Spender_ix (Spender),
    index address_allowance_ModifiedBlock_ix (ModifiedBlock)
);

create table address_balance
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
    unique address_mining_Owner_MiningPoolId_uq (Owner, MiningPoolId),
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
    unique address_staking_Owner_LiquidityPoolId_uq (Owner, LiquidityPoolId),
    index address_staking_ModifiedBlock_ix (ModifiedBlock)
);

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
    constraint primary key (Id),
    constraint transaction_block_Height_fk
        foreign key (Block) references block (Height)
);

create index transaction_Block_index
    on transaction (Block);

create index transaction_From_index
    on transaction (`From`);

create index transaction_Hash_index
    on transaction (Hash);

create table transaction_log_type
(
    Id      smallint    not null,
    LogType varchar(50) not null,
    constraint primary key (Id)
);

create table transaction_log
(
    Id            bigint auto_increment,
    TransactionId bigint                       not null,
    LogTypeId     smallint                     not null,
    SortOrder     smallint(2)                  not null,
    Contract      varchar(50)                  not null,
    Details       longtext collate utf8mb4_bin null,
    constraint primary key (Id),
    constraint transaction_log_transaction_log_type_Id_fk
        foreign key (LogTypeId) references transaction_log_type (Id),
    constraint Details
        check (json_valid(`Details`))
);

create index transaction_event_transaction_Id_fk
    on transaction_log (TransactionId);

create index transaction_log_Contract_index
    on transaction_log (Contract);

create table governance
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

create table governance_nomination
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
        unique (LiquidityPoolId, MiningPoolId)
);

create index governance_nomination_IsNominated_index
    on governance_nomination (IsNominated);
    
create table vault
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

create table vault_certificate
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

insert into token(Id, Address, Symbol, Name, Decimals, Sats, TotalSupply, CreatedBlock, ModifiedBlock)
values(1, 'CRS', 'CRS', 'Cirrus', 8, 100000000, '13000000000000000', 1, 1);

insert into index_lock(Locked, ModifiedDate)
values (0, 0, '0000-00-00 00:00:00');

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
