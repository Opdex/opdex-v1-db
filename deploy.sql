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

create table governance
(
    Id                  bigint auto_increment,
    Address             varchar(50)              not null,
    TokenId             bigint                   not null,
    NominationPeriodEnd bigint unsigned          not null,
    MiningPoolsFunded   int unsigned default 0   not null,
    MiningPoolReward    varchar(78)  default '0' not null,
    CreatedBlock        bigint unsigned          not null,
    ModifiedBlock       bigint unsigned          not null,
    constraint primary key (Id),
    constraint governance_Address_uindex
        unique (Address)
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

create table odx_vault
(
    Id            bigint auto_increment,
    TokenId       bigint          not null,
    Address       varchar(70)     not null,
    Owner         varchar(50)     not null,
    Genesis       bigint unsigned not null,
    CreatedBlock  bigint unsigned not null,
    ModifiedBlock bigint unsigned not null,
    constraint primary key (Id)
);

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

-- historical CRS
insert into token_snapshot (TokenId, MarketId, SnapshotTypeId, StartDate, EndDate, ModifiedDate, Details)
values  (1, 0, 2, '2021-07-07 01:00:00', '2021-07-07 01:59:59', '2021-07-07 01:01:24', '{"Open":1.70773601,"High":1.70773601,"Low":1.70773601,"Close":1.70773601}'),
        (1, 0, 1, '2021-07-07 01:00:00', '2021-07-07 01:00:59', '2021-07-07 01:31:36', '{"Open":1.70773601,"High":1.70773601,"Low":1.70773601,"Close":1.70773601}'),
        (1, 0, 1, '2021-07-07 00:45:00', '2021-07-07 00:45:59', '2021-07-07 00:46:24', '{"Open":1.70803598,"High":1.70803598,"Low":1.70803598,"Close":1.70803598}'),
        (1, 0, 1, '2021-07-07 00:39:00', '2021-07-07 00:39:59', '2021-07-07 00:41:08', '{"Open":1.70790051,"High":1.70790051,"Low":1.70790051,"Close":1.70790051}'),
        (1, 0, 1, '2021-07-07 00:38:00', '2021-07-07 00:38:59', '2021-07-07 00:39:44', '{"Open":1.70563842,"High":1.70563842,"Low":1.70563842,"Close":1.70563842}'),
        (1, 0, 1, '2021-07-07 00:37:00', '2021-07-07 00:37:59', '2021-07-07 00:38:25', '{"Open":1.70435931,"High":1.70435931,"Low":1.70435931,"Close":1.70435931}'),
        (1, 0, 1, '2021-07-07 00:34:00', '2021-07-07 00:34:59', '2021-07-07 00:35:51', '{"Open":1.70117101,"High":1.70117101,"Low":1.70117101,"Close":1.70117101}'),
        (1, 0, 1, '2021-07-07 00:30:00', '2021-07-07 00:30:59', '2021-07-07 00:31:30', '{"Open":1.70983105,"High":1.70983105,"Low":1.70983105,"Close":1.70983105}'),
        (1, 0, 1, '2021-07-07 00:15:00', '2021-07-07 00:15:59', '2021-07-07 00:16:40', '{"Open":1.72896376,"High":1.72896376,"Low":1.72896376,"Close":1.72896376}'),
        (1, 0, 1, '2021-07-07 00:07:00', '2021-07-07 00:07:59', '2021-07-07 00:08:37', '{"Open":1.72239756,"High":1.72239756,"Low":1.72239756,"Close":1.72239756}'),
        (1, 0, 1, '2021-07-07 00:06:00', '2021-07-07 00:06:59', '2021-07-07 00:07:47', '{"Open":1.71857640,"High":1.71857640,"Low":1.71857640,"Close":1.71857640}'),
        (1, 0, 3, '2021-07-07 00:00:00', '2021-07-07 23:59:59', '2021-07-07 01:01:24', '{"Open":1.73524950,"High":1.73524950,"Low":1.70117101,"Close":1.70773601}'),
        (1, 0, 2, '2021-07-07 00:00:00', '2021-07-07 00:59:59', '2021-07-07 00:46:24', '{"Open":1.73524950,"High":1.73524950,"Low":1.70117101,"Close":1.70803598}'),
        (1, 0, 1, '2021-07-07 00:00:00', '2021-07-07 00:00:59', '2021-07-07 00:01:22', '{"Open":1.73524950,"High":1.73524950,"Low":1.73524950,"Close":1.73524950}'),
        (1, 0, 1, '2021-07-06 23:59:00', '2021-07-06 23:59:59', '2021-07-07 00:00:53', '{"Open":1.73524950,"High":1.73524950,"Low":1.73524950,"Close":1.73524950}'),
        (1, 0, 1, '2021-07-06 23:56:00', '2021-07-06 23:56:59', '2021-07-06 23:58:13', '{"Open":1.73605693,"High":1.73605693,"Low":1.73605693,"Close":1.73605693}'),
        (1, 0, 1, '2021-07-06 23:54:00', '2021-07-06 23:54:59', '2021-07-06 23:55:33', '{"Open":1.73276762,"High":1.73276762,"Low":1.73276762,"Close":1.73276762}'),
        (1, 0, 1, '2021-07-06 23:53:00', '2021-07-06 23:53:59', '2021-07-06 23:54:43', '{"Open":1.72660843,"High":1.72660843,"Low":1.72660843,"Close":1.72660843}'),
        (1, 0, 1, '2021-07-06 23:52:00', '2021-07-06 23:52:59', '2021-07-06 23:53:43', '{"Open":1.72277696,"High":1.72277696,"Low":1.72277696,"Close":1.72277696}'),
        (1, 0, 1, '2021-07-06 23:45:00', '2021-07-06 23:45:59', '2021-07-06 23:46:24', '{"Open":1.72918388,"High":1.72918388,"Low":1.72918388,"Close":1.72918388}'),
        (1, 0, 1, '2021-07-06 23:44:00', '2021-07-06 23:44:59', '2021-07-06 23:46:17', '{"Open":1.72918388,"High":1.72918388,"Low":1.72918388,"Close":1.72918388}'),
        (1, 0, 1, '2021-07-06 23:43:00', '2021-07-06 23:43:59', '2021-07-06 23:44:37', '{"Open":1.72550436,"High":1.72550436,"Low":1.72550436,"Close":1.72550436}'),
        (1, 0, 1, '2021-07-06 23:42:00', '2021-07-06 23:42:59', '2021-07-06 23:44:06', '{"Open":1.72597303,"High":1.72597303,"Low":1.72597303,"Close":1.72597303}'),
        (1, 0, 1, '2021-07-06 23:41:00', '2021-07-06 23:41:59', '2021-07-06 23:42:56', '{"Open":1.72603749,"High":1.72603749,"Low":1.72603749,"Close":1.72603749}'),
        (1, 0, 1, '2021-07-06 23:40:00', '2021-07-06 23:40:59', '2021-07-06 23:41:38', '{"Open":1.72545819,"High":1.72545819,"Low":1.72545819,"Close":1.72545819}'),
        (1, 0, 1, '2021-07-06 23:39:00', '2021-07-06 23:39:59', '2021-07-06 23:40:38', '{"Open":1.72545819,"High":1.72545819,"Low":1.72545819,"Close":1.72545819}'),
        (1, 0, 1, '2021-07-06 23:38:00', '2021-07-06 23:38:59', '2021-07-06 23:39:29', '{"Open":1.72999224,"High":1.72999224,"Low":1.72999224,"Close":1.72999224}'),
        (1, 0, 1, '2021-07-06 23:30:00', '2021-07-06 23:30:59', '2021-07-06 23:31:28', '{"Open":1.71822365,"High":1.71822365,"Low":1.71822365,"Close":1.71822365}'),
        (1, 0, 1, '2021-07-06 23:15:00', '2021-07-06 23:15:59', '2021-07-06 23:16:32', '{"Open":1.71859160,"High":1.71859160,"Low":1.71859160,"Close":1.71859160}'),
        (1, 0, 1, '2021-07-06 23:03:00', '2021-07-06 23:03:59', '2021-07-06 23:04:32', '{"Open":1.71776793,"High":1.71776793,"Low":1.71776793,"Close":1.71776793}'),
        (1, 0, 1, '2021-07-06 23:02:00', '2021-07-06 23:02:59', '2021-07-06 23:04:02', '{"Open":1.71865803,"High":1.71865803,"Low":1.71865803,"Close":1.71865803}'),
        (1, 0, 2, '2021-07-06 23:00:00', '2021-07-06 23:59:59', '2021-07-07 00:00:53', '{"Open":1.71873256,"High":1.73605693,"Low":1.71776793,"Close":1.73524950}'),
        (1, 0, 1, '2021-07-06 23:00:00', '2021-07-06 23:00:59', '2021-07-06 23:01:28', '{"Open":1.71873256,"High":1.71873256,"Low":1.71873256,"Close":1.71873256}'),
        (1, 0, 1, '2021-07-06 22:45:00', '2021-07-06 22:45:59', '2021-07-06 22:46:26', '{"Open":1.71289974,"High":1.71289974,"Low":1.71289974,"Close":1.71289974}'),
        (1, 0, 1, '2021-07-06 22:30:00', '2021-07-06 22:30:59', '2021-07-06 22:31:35', '{"Open":1.70367747,"High":1.70367747,"Low":1.70367747,"Close":1.70367747}'),
        (1, 0, 1, '2021-07-06 22:20:00', '2021-07-06 22:20:59', '2021-07-06 22:22:00', '{"Open":1.70384152,"High":1.70384152,"Low":1.70384152,"Close":1.70384152}'),
        (1, 0, 1, '2021-07-06 22:15:00', '2021-07-06 22:15:59', '2021-07-06 22:16:41', '{"Open":1.70604636,"High":1.70604636,"Low":1.70604636,"Close":1.70604636}'),
        (1, 0, 2, '2021-07-06 22:00:00', '2021-07-06 22:59:59', '2021-07-06 22:46:26', '{"Open":1.68669913,"High":1.71289974,"Low":1.68669913,"Close":1.71289974}'),
        (1, 0, 1, '2021-07-06 22:00:00', '2021-07-06 22:00:59', '2021-07-06 22:01:25', '{"Open":1.68669913,"High":1.68669913,"Low":1.68669913,"Close":1.68669913}'),
        (1, 0, 1, '2021-07-06 21:58:00', '2021-07-06 21:58:59', '2021-07-06 22:00:10', '{"Open":1.68670909,"High":1.68670909,"Low":1.68670909,"Close":1.68670909}'),
        (1, 0, 1, '2021-07-06 21:57:00', '2021-07-06 21:57:59', '2021-07-06 21:58:57', '{"Open":1.68681113,"High":1.68681113,"Low":1.68681113,"Close":1.68681113}'),
        (1, 0, 1, '2021-07-06 21:50:00', '2021-07-06 21:50:59', '2021-07-06 21:51:44', '{"Open":1.69589798,"High":1.69589798,"Low":1.69589798,"Close":1.69589798}'),
        (1, 0, 1, '2021-07-06 21:45:00', '2021-07-06 21:45:59', '2021-07-06 21:46:29', '{"Open":1.70317476,"High":1.70317476,"Low":1.70317476,"Close":1.70317476}'),
        (1, 0, 1, '2021-07-06 21:37:00', '2021-07-06 21:37:59', '2021-07-06 21:38:30', '{"Open":1.70324549,"High":1.70324549,"Low":1.70324549,"Close":1.70324549}'),
        (1, 0, 1, '2021-07-06 21:30:00', '2021-07-06 21:30:59', '2021-07-06 21:31:32', '{"Open":1.69705370,"High":1.69705370,"Low":1.69705370,"Close":1.69705370}'),
        (1, 0, 1, '2021-07-06 21:15:00', '2021-07-06 21:15:59', '2021-07-06 21:16:34', '{"Open":1.69511880,"High":1.69511880,"Low":1.69511880,"Close":1.69511880}'),
        (1, 0, 2, '2021-07-06 21:00:00', '2021-07-06 21:59:59', '2021-07-06 22:00:10', '{"Open":1.69568403,"High":1.70324549,"Low":1.68670909,"Close":1.68670909}'),
        (1, 0, 1, '2021-07-06 21:00:00', '2021-07-06 21:00:59', '2021-07-06 21:01:22', '{"Open":1.69568403,"High":1.69568403,"Low":1.69568403,"Close":1.69568403}'),
        (1, 0, 1, '2021-07-06 20:45:00', '2021-07-06 20:45:59', '2021-07-06 20:46:31', '{"Open":1.69255232,"High":1.69255232,"Low":1.69255232,"Close":1.69255232}'),
        (1, 0, 3, '2021-07-06 00:00:00', '2021-07-06 23:59:59', '2021-07-07 00:00:53', '{"Open":1.70087542,"High":1.73605693,"Low":1.68669913,"Close":1.73524950}'),
        (1, 0, 2, '2021-07-06 20:00:00', '2021-07-06 20:59:59', '2021-07-06 20:46:31', '{"Open":1.70087542,"High":1.70087542,"Low":1.69255232,"Close":1.69255232}'),
        (1, 0, 1, '2021-07-06 20:30:00', '2021-07-06 20:30:59', '2021-07-06 20:32:28', '{"Open":1.70087542,"High":1.70087542,"Low":1.70087542,"Close":1.70087542}'),
        (1, 0, 1, '2021-07-04 02:30:00', '2021-07-04 02:30:59', '2021-07-06 20:16:37', '{"Open":1.69566863,"High":1.69566863,"Low":1.69566863,"Close":1.69566863}'),
        (1, 0, 1, '2021-07-04 02:15:00', '2021-07-04 02:15:59', '2021-07-04 02:16:53', '{"Open":1.69364914,"High":1.69364914,"Low":1.69364914,"Close":1.69364914}'),
        (1, 0, 2, '2021-07-04 02:00:00', '2021-07-04 02:59:59', '2021-07-04 02:31:53', '{"Open":1.68679955,"High":1.69566863,"Low":1.68679955,"Close":1.69566863}'),
        (1, 0, 1, '2021-07-04 02:00:00', '2021-07-04 02:00:59', '2021-07-04 02:01:53', '{"Open":1.68679955,"High":1.68679955,"Low":1.68679955,"Close":1.68679955}'),
        (1, 0, 1, '2021-07-04 01:45:00', '2021-07-04 01:45:59', '2021-07-04 01:46:53', '{"Open":1.69805819,"High":1.69805819,"Low":1.69805819,"Close":1.69805819}'),
        (1, 0, 1, '2021-07-04 01:30:00', '2021-07-04 01:30:59', '2021-07-04 01:31:53', '{"Open":1.68597961,"High":1.68597961,"Low":1.68597961,"Close":1.68597961}'),
        (1, 0, 1, '2021-07-04 01:15:00', '2021-07-04 01:15:59', '2021-07-04 01:16:53', '{"Open":1.68952394,"High":1.68952394,"Low":1.68952394,"Close":1.68952394}'),
        (1, 0, 2, '2021-07-04 01:00:00', '2021-07-04 01:59:59', '2021-07-04 01:46:53', '{"Open":1.69804490,"High":1.69805819,"Low":1.68597961,"Close":1.69805819}'),
        (1, 0, 1, '2021-07-04 01:00:00', '2021-07-04 01:00:59', '2021-07-04 01:01:53', '{"Open":1.69804490,"High":1.69804490,"Low":1.69804490,"Close":1.69804490}'),
        (1, 0, 1, '2021-07-04 00:45:00', '2021-07-04 00:45:59', '2021-07-04 00:47:17', '{"Open":1.70465055,"High":1.70465055,"Low":1.70465055,"Close":1.70465055}'),
        (1, 0, 1, '2021-07-04 00:30:00', '2021-07-04 00:30:59', '2021-07-04 00:31:53', '{"Open":1.72103159,"High":1.72103159,"Low":1.72103159,"Close":1.72103159}'),
        (1, 0, 1, '2021-07-04 00:15:00', '2021-07-04 00:15:59', '2021-07-04 00:16:57', '{"Open":1.70860981,"High":1.70860981,"Low":1.70860981,"Close":1.70860981}'),
        (1, 0, 3, '2021-07-04 00:00:00', '2021-07-04 23:59:59', '2021-07-04 02:31:53', '{"Open":1.74231736,"High":1.74231736,"Low":1.68597961,"Close":1.69566863}'),
        (1, 0, 2, '2021-07-04 00:00:00', '2021-07-04 00:59:59', '2021-07-04 00:47:17', '{"Open":1.74231736,"High":1.74231736,"Low":1.70465055,"Close":1.70465055}'),
        (1, 0, 1, '2021-07-04 00:00:00', '2021-07-04 00:00:59', '2021-07-04 00:01:54', '{"Open":1.74231736,"High":1.74231736,"Low":1.74231736,"Close":1.74231736}'),
        (1, 0, 1, '2021-07-03 23:45:00', '2021-07-03 23:45:59', '2021-07-03 23:46:53', '{"Open":1.75553084,"High":1.75553084,"Low":1.75553084,"Close":1.75553084}'),
        (1, 0, 1, '2021-07-03 23:30:00', '2021-07-03 23:30:59', '2021-07-03 23:31:53', '{"Open":1.75365163,"High":1.75365163,"Low":1.75365163,"Close":1.75365163}'),
        (1, 0, 1, '2021-07-03 23:15:00', '2021-07-03 23:15:59', '2021-07-03 23:17:02', '{"Open":1.74843799,"High":1.74843799,"Low":1.74843799,"Close":1.74843799}'),
        (1, 0, 2, '2021-07-03 23:00:00', '2021-07-03 23:59:59', '2021-07-03 23:46:53', '{"Open":1.75346313,"High":1.75553084,"Low":1.74843799,"Close":1.75553084}'),
        (1, 0, 1, '2021-07-03 23:00:00', '2021-07-03 23:00:59', '2021-07-03 23:01:28', '{"Open":1.75346313,"High":1.75346313,"Low":1.75346313,"Close":1.75346313}'),
        (1, 0, 2, '2021-07-03 22:00:00', '2021-07-03 22:59:59', '2021-07-03 22:59:59', '{"Open":1.74917017,"High":1.74917017,"Low":1.74917017,"Close":1.74917017}'),
        (1, 0, 1, '2021-07-03 22:45:00', '2021-07-03 22:45:59', '2021-07-03 22:59:59', '{"Open":1.74917017,"High":1.74917017,"Low":1.74917017,"Close":1.74917017}'),
        (1, 0, 1, '2021-07-03 01:17:00', '2021-07-03 01:17:59', '2021-07-03 21:51:15', '{"Open":1.75907241,"High":1.75907241,"Low":1.75907241,"Close":1.75907241}'),
        (1, 0, 1, '2021-07-03 01:15:00', '2021-07-03 01:15:59', '2021-07-03 01:18:22', '{"Open":1.72127368,"High":1.72127368,"Low":1.72127368,"Close":1.72127368}'),
        (1, 0, 3, '2021-07-03 00:00:00', '2021-07-03 23:59:59', '2021-07-03 23:46:53', '{"Open":1.73369655,"High":1.75907241,"Low":1.72127368,"Close":1.75553084}'),
        (1, 0, 2, '2021-07-03 01:00:00', '2021-07-03 01:59:59', '2021-07-03 21:51:15', '{"Open":1.73369655,"High":1.75907241,"Low":1.72127368,"Close":1.75907241}'),
        (1, 0, 1, '2021-07-03 01:00:00', '2021-07-03 01:00:59', '2021-07-03 01:15:19', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 21:15:00', '2021-07-02 21:15:59', '2021-07-03 01:15:18', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 20:30:00', '2021-07-02 20:30:59', '2021-07-03 01:15:16', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 20:21:00', '2021-07-02 20:21:59', '2021-07-03 01:15:16', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 20:20:00', '2021-07-02 20:20:59', '2021-07-03 01:15:15', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 17:15:00', '2021-07-02 17:15:59', '2021-07-03 01:15:15', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-02 17:00:00', '2021-07-02 17:59:59', '2021-07-03 01:15:15', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 17:00:00', '2021-07-02 17:00:59', '2021-07-03 01:15:14', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 02:15:00', '2021-07-02 02:15:59', '2021-07-03 01:15:13', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-02 02:00:00', '2021-07-02 02:59:59', '2021-07-03 01:15:13', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 02:00:00', '2021-07-02 02:00:59', '2021-07-03 01:15:13', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:45:00', '2021-07-02 01:45:59', '2021-07-03 01:15:12', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:30:00', '2021-07-02 01:30:59', '2021-07-03 01:15:11', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:15:00', '2021-07-02 01:15:59', '2021-07-03 01:15:11', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:14:00', '2021-07-02 01:14:59', '2021-07-03 01:15:11', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:11:00', '2021-07-02 01:11:59', '2021-07-03 01:15:10', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-02 01:00:00', '2021-07-02 01:59:59', '2021-07-03 01:15:12', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 01:00:00', '2021-07-02 01:00:59', '2021-07-03 01:14:38', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 00:45:00', '2021-07-02 00:45:59', '2021-07-03 01:14:37', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-02 00:00:00', '2021-07-02 00:59:59', '2021-07-03 01:14:37', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 00:30:00', '2021-07-02 00:30:59', '2021-07-03 01:14:36', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-01 21:15:00', '2021-07-01 21:15:59', '2021-07-03 01:14:35', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-01 21:00:00', '2021-07-01 21:59:59', '2021-07-03 01:14:35', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-01 21:00:00', '2021-07-01 21:00:59', '2021-07-03 01:14:35', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 3, '2021-07-01 00:00:00', '2021-07-01 23:59:59', '2021-07-03 01:14:35', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-01 20:00:00', '2021-07-01 20:59:59', '2021-07-03 01:14:34', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-01 20:45:00', '2021-07-01 20:45:59', '2021-07-03 01:14:34', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-29 02:45:00', '2021-06-29 02:45:59', '2021-07-03 01:14:33', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-29 02:30:00', '2021-06-29 02:30:59', '2021-07-03 01:14:33', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-29 02:00:00', '2021-06-29 02:00:59', '2021-07-03 01:14:32', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-28 18:30:00', '2021-06-28 18:30:59', '2021-07-03 01:14:31', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-28 00:00:00', '2021-06-28 00:00:59', '2021-07-03 01:14:30', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-27 23:45:00', '2021-06-27 23:45:59', '2021-07-03 01:14:29', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-27 23:30:00', '2021-06-27 23:30:59', '2021-07-03 01:14:28', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-27 23:00:00', '2021-06-27 23:00:59', '2021-07-03 01:14:27', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-27 22:45:00', '2021-06-27 22:45:59', '2021-07-03 01:14:26', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-27 22:00:00', '2021-06-27 22:59:59', '2021-07-03 01:14:26', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-27 22:30:00', '2021-06-27 22:30:59', '2021-07-03 01:14:26', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 17:00:00', '2021-06-26 17:00:59', '2021-07-03 01:14:25', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 16:45:00', '2021-06-26 16:45:59', '2021-07-03 01:14:24', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-26 04:00:00', '2021-06-26 04:59:59', '2021-07-03 01:14:23', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 04:00:00', '2021-06-26 04:00:59', '2021-07-03 01:14:23', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 03:45:00', '2021-06-26 03:45:59', '2021-07-03 01:14:22', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 03:30:00', '2021-06-26 03:30:59', '2021-07-03 01:14:22', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 03:00:00', '2021-06-26 03:00:59', '2021-07-03 01:14:21', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 02:45:00', '2021-06-26 02:45:59', '2021-07-03 01:14:20', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 02:30:00', '2021-06-26 02:30:59', '2021-07-03 01:14:19', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 00:30:00', '2021-06-26 00:30:59', '2021-07-03 01:14:18', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 00:00:00', '2021-06-26 00:00:59', '2021-07-03 01:14:16', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 23:45:00', '2021-06-25 23:45:59', '2021-07-03 01:14:16', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 23:30:00', '2021-06-25 23:30:59', '2021-07-03 01:14:15', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 23:00:00', '2021-06-25 23:00:59', '2021-07-03 01:14:14', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 22:30:00', '2021-06-25 22:30:59', '2021-07-03 01:14:13', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 22:00:00', '2021-06-25 22:00:59', '2021-07-03 01:13:41', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 21:45:00', '2021-06-25 21:45:59', '2021-07-03 01:13:39', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 21:30:00', '2021-06-25 21:30:59', '2021-07-03 01:13:39', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 21:00:00', '2021-06-25 21:00:59', '2021-07-03 01:13:38', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 20:45:00', '2021-06-25 20:45:59', '2021-07-03 01:13:37', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 20:30:00', '2021-06-25 20:30:59', '2021-07-03 01:13:36', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 20:00:00', '2021-06-25 20:00:59', '2021-07-03 01:13:35', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 19:45:00', '2021-06-25 19:45:59', '2021-07-03 01:13:35', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 19:30:00', '2021-06-25 19:30:59', '2021-07-03 01:13:34', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 19:00:00', '2021-06-25 19:00:59', '2021-07-03 01:13:33', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 18:45:00', '2021-06-25 18:45:59', '2021-07-03 01:13:32', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 18:30:00', '2021-06-25 18:30:59', '2021-07-03 01:13:31', '{"Open":1.72868850,"High":1.72868850,"Low":1.72868850,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-25 17:00:00', '2021-06-25 17:59:59', '2021-07-03 01:13:29', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 17:00:00', '2021-06-25 17:00:59', '2021-07-03 01:13:29', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 02:45:00', '2021-06-25 02:45:59', '2021-07-03 01:13:29', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 02:30:00', '2021-06-25 02:30:59', '2021-07-03 01:13:28', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 02:00:00', '2021-06-25 02:00:59', '2021-07-03 01:13:26', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 01:45:00', '2021-06-25 01:45:59', '2021-07-03 01:13:26', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 01:30:00', '2021-06-25 01:30:59', '2021-07-03 01:13:25', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 01:00:00', '2021-06-25 01:00:59', '2021-07-03 01:13:23', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 00:45:00', '2021-06-25 00:45:59', '2021-07-03 01:13:23', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 00:30:00', '2021-06-25 00:30:59', '2021-07-03 01:13:22', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 00:00:00', '2021-06-25 00:00:59', '2021-07-03 01:13:21', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 23:45:00', '2021-06-24 23:45:59', '2021-07-03 01:13:20', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 23:30:00', '2021-06-24 23:30:59', '2021-07-03 01:13:19', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 23:00:00', '2021-06-24 23:00:59', '2021-07-03 01:13:18', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 22:45:00', '2021-06-24 22:45:59', '2021-07-03 01:13:17', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 22:30:00', '2021-06-24 22:30:59', '2021-07-03 01:13:17', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 22:00:00', '2021-06-24 22:00:59', '2021-07-03 01:13:16', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 21:45:00', '2021-06-24 21:45:59', '2021-07-03 01:13:15', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 21:30:00', '2021-06-24 21:30:59', '2021-07-03 01:13:14', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 21:00:00', '2021-06-24 21:00:59', '2021-07-03 01:12:41', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 2, '2021-06-24 02:00:00', '2021-06-24 02:59:59', '2021-07-03 01:12:40', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 02:00:00', '2021-06-24 02:00:59', '2021-07-03 01:12:40', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 01:45:00', '2021-06-24 01:45:59', '2021-07-03 01:12:40', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 01:30:00', '2021-06-24 01:30:59', '2021-07-03 01:12:39', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 19:00:00', '2021-06-23 19:00:59', '2021-07-03 01:12:38', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 18:45:00', '2021-06-23 18:45:59', '2021-07-03 01:12:38', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 18:30:00', '2021-06-23 18:30:59', '2021-07-03 01:12:37', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 18:00:00', '2021-06-23 18:00:59', '2021-07-03 01:12:36', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 17:45:00', '2021-06-23 17:45:59', '2021-07-03 01:12:35', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 17:30:00', '2021-06-23 17:30:59', '2021-07-03 01:12:34', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 17:00:00', '2021-06-23 17:00:59', '2021-07-03 01:12:33', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 16:45:00', '2021-06-23 16:45:59', '2021-07-03 01:12:33', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 16:30:00', '2021-06-23 16:30:59', '2021-07-03 01:12:32', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 16:00:00', '2021-06-23 16:00:59', '2021-07-03 01:12:31', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 15:45:00', '2021-06-23 15:45:59', '2021-07-03 01:12:30', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 15:30:00', '2021-06-23 15:30:59', '2021-07-03 01:12:30', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 15:00:00', '2021-06-23 15:00:59', '2021-07-03 01:12:29', '{"Open":1.72254585,"High":1.72254585,"Low":1.72254585,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 06:45:00', '2021-06-23 06:45:59', '2021-07-03 01:12:28', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 06:30:00', '2021-06-23 06:30:59', '2021-07-03 01:12:28', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 06:00:00', '2021-06-23 06:00:59', '2021-07-03 01:12:27', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 05:45:00', '2021-06-23 05:45:59', '2021-07-03 01:12:26', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 05:30:00', '2021-06-23 05:30:59', '2021-07-03 01:12:25', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 05:00:00', '2021-06-23 05:00:59', '2021-07-03 01:12:24', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 04:45:00', '2021-06-23 04:45:59', '2021-07-03 01:12:23', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 04:30:00', '2021-06-23 04:30:59', '2021-07-03 01:12:22', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 04:00:00', '2021-06-23 04:00:59', '2021-07-03 01:12:21', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 03:45:00', '2021-06-23 03:45:59', '2021-07-03 01:12:20', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 03:30:00', '2021-06-23 03:30:59', '2021-07-03 01:12:20', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 02:30:00', '2021-06-23 02:30:59', '2021-07-03 01:12:19', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 23:30:00', '2021-06-22 23:30:59', '2021-07-03 01:12:17', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 23:00:00', '2021-06-22 23:00:59', '2021-07-03 01:11:44', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 22:45:00', '2021-06-22 22:45:59', '2021-07-03 01:11:43', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 22:30:00', '2021-06-22 22:30:59', '2021-07-03 01:11:43', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 19:30:00', '2021-06-22 19:30:59', '2021-07-03 01:11:42', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 01:45:00', '2021-06-22 01:45:59', '2021-07-03 01:11:41', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 01:30:00', '2021-06-22 01:30:59', '2021-07-03 01:11:40', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 20:45:00', '2021-06-20 20:45:59', '2021-07-03 01:11:39', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 20:30:00', '2021-06-20 20:30:59', '2021-07-03 01:11:38', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 20:00:00', '2021-06-20 20:00:59', '2021-07-03 01:11:36', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 19:45:00', '2021-06-20 19:45:59', '2021-07-03 01:11:36', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 19:30:00', '2021-06-20 19:30:59', '2021-07-03 01:11:35', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 2, '2021-06-20 19:00:00', '2021-06-20 19:59:59', '2021-07-03 01:11:36', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 19:00:00', '2021-06-20 19:00:59', '2021-07-03 01:11:34', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 22:45:00', '2021-06-18 22:45:59', '2021-07-03 01:11:34', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 22:30:00', '2021-06-18 22:30:59', '2021-07-03 01:11:33', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 22:00:00', '2021-06-18 22:00:59', '2021-07-03 01:11:32', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 21:45:00', '2021-06-18 21:45:59', '2021-07-03 01:11:31', '{"Open":1.72276772,"High":1.72276772,"Low":1.72276772,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 21:30:00', '2021-06-18 21:30:59', '2021-07-03 01:11:31', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-18 21:00:00', '2021-06-18 21:00:59', '2021-07-03 01:11:29', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-18 20:45:00', '2021-06-18 20:45:59', '2021-07-03 01:11:28', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-18 20:00:00', '2021-06-18 20:59:59', '2021-07-03 01:11:28', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-18 20:30:00', '2021-06-18 20:30:59', '2021-07-03 01:11:28', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 22:45:00', '2021-06-16 22:45:59', '2021-07-03 01:11:27', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 22:30:00', '2021-06-16 22:30:59', '2021-07-03 01:11:26', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-16 22:00:00', '2021-06-16 22:59:59', '2021-07-03 01:11:27', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 22:00:00', '2021-06-16 22:00:59', '2021-07-03 01:11:25', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 21:45:00', '2021-06-16 21:45:59', '2021-07-03 01:11:24', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-16 21:00:00', '2021-06-16 21:59:59', '2021-07-03 01:11:24', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 21:30:00', '2021-06-16 21:30:59', '2021-07-03 01:11:24', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 02:30:00', '2021-06-16 02:30:59', '2021-07-03 01:11:23', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 01:30:00', '2021-06-16 01:30:59', '2021-07-03 01:11:22', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-16 01:00:00', '2021-06-16 01:59:59', '2021-07-03 01:11:22', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 01:00:00', '2021-06-16 01:00:59', '2021-07-03 01:11:21', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-16 00:00:00', '2021-06-16 00:59:59', '2021-07-03 01:11:21', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 00:45:00', '2021-06-16 00:45:59', '2021-07-03 01:11:21', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 02:30:00', '2021-06-15 02:30:59', '2021-07-03 01:11:20', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 02:00:00', '2021-06-15 02:00:59', '2021-07-03 01:10:47', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 01:45:00', '2021-06-15 01:45:59', '2021-07-03 01:10:46', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 01:30:00', '2021-06-15 01:30:59', '2021-07-03 01:10:45', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 01:00:00', '2021-06-15 01:00:59', '2021-07-03 01:10:44', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 00:45:00', '2021-06-15 00:45:59', '2021-07-03 01:10:44', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 00:30:00', '2021-06-15 00:30:59', '2021-07-03 01:10:42', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 00:00:00', '2021-06-15 00:00:59', '2021-07-03 01:10:41', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 23:45:00', '2021-06-14 23:45:59', '2021-07-03 01:10:40', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 23:30:00', '2021-06-14 23:30:59', '2021-07-03 01:10:39', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 23:00:00', '2021-06-14 23:00:59', '2021-07-03 01:10:38', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 22:45:00', '2021-06-14 22:45:59', '2021-07-03 01:10:38', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 22:30:00', '2021-06-14 22:30:59', '2021-07-03 01:10:37', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 22:00:00', '2021-06-14 22:00:59', '2021-07-03 01:10:35', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 21:45:00', '2021-06-14 21:45:59', '2021-07-03 01:10:34', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 21:00:00', '2021-06-14 21:00:59', '2021-07-03 01:10:32', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 20:45:00', '2021-06-14 20:45:59', '2021-07-03 01:10:32', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 20:30:00', '2021-06-14 20:30:59', '2021-07-03 01:10:31', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 20:00:00', '2021-06-14 20:00:59', '2021-07-03 01:10:30', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 19:45:00', '2021-06-14 19:45:59', '2021-07-03 01:10:30', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 19:00:00', '2021-06-14 19:00:59', '2021-07-03 01:10:29', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-14 18:00:00', '2021-06-14 18:59:59', '2021-07-03 01:10:28', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 18:45:00', '2021-06-14 18:45:59', '2021-07-03 01:10:28', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 07:45:00', '2021-06-14 07:45:59', '2021-07-03 01:10:27', '{"Open":1.71948090,"High":1.71948090,"Low":1.71948090,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 07:30:00', '2021-06-14 07:30:59', '2021-07-03 01:10:27', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-14 07:00:00', '2021-06-14 07:00:59', '2021-07-03 01:10:25', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-14 06:45:00', '2021-06-14 06:45:59', '2021-07-03 01:10:25', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-14 06:30:00', '2021-06-14 06:30:59', '2021-07-03 01:10:23', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-14 06:00:00', '2021-06-14 06:00:59', '2021-07-03 01:10:22', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-13 19:45:00', '2021-06-13 19:45:59', '2021-07-03 01:10:21', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-13 19:30:00', '2021-06-13 19:30:59', '2021-07-03 01:10:20', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 3, '2021-06-12 00:00:00', '2021-06-12 23:59:59', '2021-07-03 01:10:19', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 2, '2021-06-12 00:00:00', '2021-06-12 00:59:59', '2021-07-03 01:10:19', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-12 00:00:00', '2021-06-12 00:00:59', '2021-07-03 01:10:19', '{"Open":1.72114981,"High":1.72114981,"Low":1.72114981,"Close":1.72114981}'),
        (1, 0, 2, '2021-07-02 21:00:00', '2021-07-02 21:59:59', '2021-07-03 01:15:18', '{"Open":1.73369655,"High":1.73369655,"Low":1.73369655,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 21:00:00', '2021-07-02 21:00:59', '2021-07-03 00:57:12', '{"Open":0.0,"High":0.0,"Low":0.0,"Close":0.0}'),
        (1, 0, 1, '2021-07-02 20:50:00', '2021-07-02 20:50:59', '2021-07-02 20:51:28', '{"Open":1.55860477,"High":1.55860477,"Low":1.55860477,"Close":1.55860477}'),
        (1, 0, 1, '2021-07-02 20:49:00', '2021-07-02 20:49:59', '2021-07-02 20:51:22', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:48:00', '2021-07-02 20:48:59', '2021-07-02 20:51:21', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:47:00', '2021-07-02 20:47:59', '2021-07-02 20:51:21', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:46:00', '2021-07-02 20:46:59', '2021-07-02 20:51:21', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:45:00', '2021-07-02 20:45:59', '2021-07-02 20:51:21', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:44:00', '2021-07-02 20:44:59', '2021-07-02 20:51:21', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:43:00', '2021-07-02 20:43:59', '2021-07-02 20:51:20', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 1, '2021-07-02 20:42:00', '2021-07-02 20:42:59', '2021-07-02 20:51:20', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 3, '2021-07-02 00:00:00', '2021-07-02 23:59:59', '2021-07-03 01:15:18', '{"Open":1.55866400,"High":1.73369655,"Low":0.0,"Close":1.73369655}'),
        (1, 0, 2, '2021-07-02 20:00:00', '2021-07-02 20:59:59', '2021-07-03 01:15:16', '{"Open":1.55866400,"High":1.73369655,"Low":1.55860477,"Close":1.73369655}'),
        (1, 0, 1, '2021-07-02 20:41:00', '2021-07-02 20:41:59', '2021-07-02 20:51:20', '{"Open":1.55866400,"High":1.55866400,"Low":1.55866400,"Close":1.55866400}'),
        (1, 0, 2, '2021-06-29 02:00:00', '2021-06-29 02:59:59', '2021-07-03 01:14:33', '{"Open":1.42883214,"High":1.73369655,"Low":1.42883214,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-29 02:15:00', '2021-06-29 02:15:59', '2021-07-02 20:47:20', '{"Open":1.42883214,"High":1.42883214,"Low":1.42883214,"Close":1.42883214}'),
        (1, 0, 1, '2021-06-29 01:58:00', '2021-06-29 01:58:59', '2021-06-29 02:00:12', '{"Open":1.41687602,"High":1.41687602,"Low":1.41687602,"Close":1.41687602}'),
        (1, 0, 3, '2021-06-29 00:00:00', '2021-06-29 23:59:59', '2021-07-03 01:14:33', '{"Open":1.41381739,"High":1.73369655,"Low":1.41381739,"Close":1.73369655}'),
        (1, 0, 2, '2021-06-29 01:00:00', '2021-06-29 01:59:59', '2021-06-29 02:00:12', '{"Open":1.41381739,"High":1.41687602,"Low":1.41381739,"Close":1.41687602}'),
        (1, 0, 1, '2021-06-29 01:57:00', '2021-06-29 01:57:59', '2021-06-29 01:59:18', '{"Open":1.41381739,"High":1.41381739,"Low":1.41381739,"Close":1.41381739}'),
        (1, 0, 1, '2021-06-28 18:15:00', '2021-06-28 18:15:59', '2021-06-28 18:16:41', '{"Open":1.32968537,"High":1.32968537,"Low":1.32968537,"Close":1.32968537}'),
        (1, 0, 2, '2021-06-28 18:00:00', '2021-06-28 18:59:59', '2021-07-03 01:14:31', '{"Open":1.32042520,"High":1.73369655,"Low":1.32042520,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-28 18:00:00', '2021-06-28 18:00:59', '2021-06-28 18:01:44', '{"Open":1.32042520,"High":1.32042520,"Low":1.32042520,"Close":1.32042520}'),
        (1, 0, 3, '2021-06-28 00:00:00', '2021-06-28 23:59:59', '2021-07-03 01:14:31', '{"Open":1.31527306,"High":1.73369655,"Low":1.31527306,"Close":1.73369655}'),
        (1, 0, 2, '2021-06-28 00:00:00', '2021-06-28 00:59:59', '2021-07-03 01:14:30', '{"Open":1.31527306,"High":1.73369655,"Low":1.31527306,"Close":1.73369655}'),
        (1, 0, 1, '2021-06-28 00:15:00', '2021-06-28 00:15:59', '2021-06-28 17:59:09', '{"Open":1.31527306,"High":1.31527306,"Low":1.31527306,"Close":1.31527306}'),
        (1, 0, 3, '2021-06-27 00:00:00', '2021-06-27 23:59:59', '2021-07-03 01:14:29', '{"Open":1.31527306,"High":1.72868850,"Low":1.31527306,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-27 23:00:00', '2021-06-27 23:59:59', '2021-07-03 01:14:29', '{"Open":1.31527306,"High":1.72868850,"Low":1.31527306,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-27 23:15:00', '2021-06-27 23:15:59', '2021-06-28 17:59:07', '{"Open":1.31527306,"High":1.31527306,"Low":1.31527306,"Close":1.31527306}'),
        (1, 0, 2, '2021-06-26 17:00:00', '2021-06-26 17:59:59', '2021-07-03 01:14:25', '{"Open":1.25295981,"High":1.72868850,"Low":1.25295981,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 17:15:00', '2021-06-26 17:15:59', '2021-06-27 22:29:02', '{"Open":1.25295981,"High":1.25295981,"Low":1.25295981,"Close":1.25295981}'),
        (1, 0, 1, '2021-06-26 16:51:00', '2021-06-26 16:51:59', '2021-06-26 16:53:04', '{"Open":1.17187639,"High":1.17187639,"Low":1.17187639,"Close":1.17187639}'),
        (1, 0, 1, '2021-06-26 16:50:00', '2021-06-26 16:50:59', '2021-06-26 16:51:59', '{"Open":1.17449262,"High":1.17449262,"Low":1.17449262,"Close":1.17449262}'),
        (1, 0, 1, '2021-06-26 16:49:00', '2021-06-26 16:49:59', '2021-06-26 16:50:49', '{"Open":1.16551747,"High":1.16551747,"Low":1.16551747,"Close":1.16551747}'),
        (1, 0, 2, '2021-06-26 16:00:00', '2021-06-26 16:59:59', '2021-07-03 01:14:24', '{"Open":1.16542922,"High":1.72868850,"Low":1.16542922,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 16:47:00', '2021-06-26 16:47:59', '2021-06-26 16:49:09', '{"Open":1.16542922,"High":1.16542922,"Low":1.16542922,"Close":1.16542922}'),
        (1, 0, 2, '2021-06-26 03:00:00', '2021-06-26 03:59:59', '2021-07-03 01:14:22', '{"Open":1.20526392,"High":1.72868850,"Low":1.20526392,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 03:15:00', '2021-06-26 03:15:59', '2021-06-26 03:16:39', '{"Open":1.20526392,"High":1.20526392,"Low":1.20526392,"Close":1.20526392}'),
        (1, 0, 1, '2021-06-26 02:42:00', '2021-06-26 02:42:59', '2021-06-26 02:44:06', '{"Open":1.18690302,"High":1.18690302,"Low":1.18690302,"Close":1.18690302}'),
        (1, 0, 1, '2021-06-26 02:41:00', '2021-06-26 02:41:59', '2021-06-26 02:42:46', '{"Open":1.18681330,"High":1.18681330,"Low":1.18681330,"Close":1.18681330}'),
        (1, 0, 1, '2021-06-26 02:38:00', '2021-06-26 02:38:59', '2021-06-26 02:40:08', '{"Open":1.18367088,"High":1.18367088,"Low":1.18367088,"Close":1.18367088}'),
        (1, 0, 2, '2021-06-26 02:00:00', '2021-06-26 02:59:59', '2021-07-03 01:14:20', '{"Open":1.18482093,"High":1.72868850,"Low":1.18367088,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 02:34:00', '2021-06-26 02:34:59', '2021-06-26 02:36:18', '{"Open":1.18482093,"High":1.18482093,"Low":1.18482093,"Close":1.18482093}'),
        (1, 0, 3, '2021-06-26 00:00:00', '2021-06-26 23:59:59', '2021-07-03 01:14:25', '{"Open":1.19192232,"High":1.72868850,"Low":1.16542922,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-26 00:00:00', '2021-06-26 00:59:59', '2021-07-03 01:14:18', '{"Open":1.19192232,"High":1.72868850,"Low":1.19192232,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-26 00:15:00', '2021-06-26 00:15:59', '2021-06-26 00:16:31', '{"Open":1.19192232,"High":1.19192232,"Low":1.19192232,"Close":1.19192232}'),
        (1, 0, 2, '2021-06-25 23:00:00', '2021-06-25 23:59:59', '2021-07-03 01:14:16', '{"Open":1.18979983,"High":1.72868850,"Low":1.18979983,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 23:15:00', '2021-06-25 23:15:59', '2021-06-25 23:16:37', '{"Open":1.18979983,"High":1.18979983,"Low":1.18979983,"Close":1.18979983}'),
        (1, 0, 1, '2021-06-25 22:45:00', '2021-06-25 22:45:59', '2021-06-25 22:46:31', '{"Open":1.19206222,"High":1.19206222,"Low":1.19206222,"Close":1.19206222}'),
        (1, 0, 1, '2021-06-25 22:42:00', '2021-06-25 22:42:59', '2021-06-25 22:43:46', '{"Open":1.18752479,"High":1.18752479,"Low":1.18752479,"Close":1.18752479}'),
        (1, 0, 1, '2021-06-25 22:41:00', '2021-06-25 22:41:59', '2021-06-25 22:42:40', '{"Open":1.19373597,"High":1.19373597,"Low":1.19373597,"Close":1.19373597}'),
        (1, 0, 1, '2021-06-25 22:29:00', '2021-06-25 22:29:59', '2021-06-25 22:30:33', '{"Open":1.19171197,"High":1.19171197,"Low":1.19171197,"Close":1.19171197}'),
        (1, 0, 1, '2021-06-25 22:15:00', '2021-06-25 22:15:59', '2021-06-25 22:16:34', '{"Open":1.19183900,"High":1.19183900,"Low":1.19183900,"Close":1.19183900}'),
        (1, 0, 2, '2021-06-25 22:00:00', '2021-06-25 22:59:59', '2021-07-03 01:14:13', '{"Open":1.19259414,"High":1.72868850,"Low":1.18752479,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 22:09:00', '2021-06-25 22:09:59', '2021-06-25 22:10:58', '{"Open":1.19259414,"High":1.19259414,"Low":1.19259414,"Close":1.19259414}'),
        (1, 0, 1, '2021-06-25 21:53:00', '2021-06-25 21:53:59', '2021-06-25 21:54:24', '{"Open":1.18837797,"High":1.18837797,"Low":1.18837797,"Close":1.18837797}'),
        (1, 0, 2, '2021-06-25 21:00:00', '2021-06-25 21:59:59', '2021-07-03 01:13:39', '{"Open":1.18638499,"High":1.72868850,"Low":1.18638499,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 21:15:00', '2021-06-25 21:15:59', '2021-06-25 21:17:31', '{"Open":1.18638499,"High":1.18638499,"Low":1.18638499,"Close":1.18638499}'),
        (1, 0, 2, '2021-06-25 20:00:00', '2021-06-25 20:59:59', '2021-07-03 01:13:37', '{"Open":1.19841375,"High":1.72868850,"Low":1.19841375,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 20:15:00', '2021-06-25 20:15:59', '2021-06-25 20:16:34', '{"Open":1.19841375,"High":1.19841375,"Low":1.19841375,"Close":1.19841375}'),
        (1, 0, 2, '2021-06-25 19:00:00', '2021-06-25 19:59:59', '2021-07-03 01:13:35', '{"Open":1.20353823,"High":1.72868850,"Low":1.20353823,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 19:15:00', '2021-06-25 19:15:59', '2021-06-25 19:17:14', '{"Open":1.20353823,"High":1.20353823,"Low":1.20353823,"Close":1.20353823}'),
        (1, 0, 2, '2021-06-25 18:00:00', '2021-06-25 18:59:59', '2021-07-03 01:13:32', '{"Open":1.18229157,"High":1.72868850,"Low":1.18229157,"Close":1.72868850}'),
        (1, 0, 1, '2021-06-25 18:15:00', '2021-06-25 18:15:59', '2021-06-25 18:16:38', '{"Open":1.18229157,"High":1.18229157,"Low":1.18229157,"Close":1.18229157}'),
        (1, 0, 1, '2021-06-25 02:35:00', '2021-06-25 02:35:59', '2021-06-25 02:37:05', '{"Open":1.32372414,"High":1.32372414,"Low":1.32372414,"Close":1.32372414}'),
        (1, 0, 1, '2021-06-25 02:15:00', '2021-06-25 02:15:59', '2021-06-25 02:16:39', '{"Open":1.32366029,"High":1.32366029,"Low":1.32366029,"Close":1.32366029}'),
        (1, 0, 2, '2021-06-25 02:00:00', '2021-06-25 02:59:59', '2021-07-03 01:13:29', '{"Open":1.31715808,"High":1.72254585,"Low":1.31715808,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 02:04:00', '2021-06-25 02:04:59', '2021-06-25 02:05:53', '{"Open":1.31715808,"High":1.31715808,"Low":1.31715808,"Close":1.31715808}'),
        (1, 0, 2, '2021-06-25 01:00:00', '2021-06-25 01:59:59', '2021-07-03 01:13:26', '{"Open":1.28007285,"High":1.72254585,"Low":1.28007285,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 01:15:00', '2021-06-25 01:15:59', '2021-06-25 01:16:31', '{"Open":1.28007285,"High":1.28007285,"Low":1.28007285,"Close":1.28007285}'),
        (1, 0, 3, '2021-06-25 00:00:00', '2021-06-25 23:59:59', '2021-07-03 01:14:16', '{"Open":1.31568890,"High":1.72868850,"Low":1.18229157,"Close":1.72868850}'),
        (1, 0, 2, '2021-06-25 00:00:00', '2021-06-25 00:59:59', '2021-07-03 01:13:23', '{"Open":1.31568890,"High":1.72254585,"Low":1.31568890,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-25 00:15:00', '2021-06-25 00:15:59', '2021-06-25 00:16:33', '{"Open":1.31568890,"High":1.31568890,"Low":1.31568890,"Close":1.31568890}'),
        (1, 0, 2, '2021-06-24 23:00:00', '2021-06-24 23:59:59', '2021-07-03 01:13:20', '{"Open":1.31868710,"High":1.72254585,"Low":1.31868710,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 23:15:00', '2021-06-24 23:15:59', '2021-06-24 23:17:01', '{"Open":1.31868710,"High":1.31868710,"Low":1.31868710,"Close":1.31868710}'),
        (1, 0, 2, '2021-06-24 22:00:00', '2021-06-24 22:59:59', '2021-07-03 01:13:17', '{"Open":1.33093371,"High":1.72254585,"Low":1.33093371,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 22:15:00', '2021-06-24 22:15:59', '2021-06-24 22:20:10', '{"Open":1.33093371,"High":1.33093371,"Low":1.33093371,"Close":1.33093371}'),
        (1, 0, 2, '2021-06-24 21:00:00', '2021-06-24 21:59:59', '2021-07-03 01:13:15', '{"Open":1.30451773,"High":1.72254585,"Low":1.30451773,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 21:15:00', '2021-06-24 21:15:59', '2021-06-24 21:17:03', '{"Open":1.30451773,"High":1.30451773,"Low":1.30451773,"Close":1.30451773}'),
        (1, 0, 3, '2021-06-24 00:00:00', '2021-06-24 23:59:59', '2021-07-03 01:13:20', '{"Open":1.30893790,"High":1.72254585,"Low":1.30451773,"Close":1.72254585}'),
        (1, 0, 2, '2021-06-24 01:00:00', '2021-06-24 01:59:59', '2021-07-03 01:12:40', '{"Open":1.30893790,"High":1.72254585,"Low":1.30893790,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-24 01:33:00', '2021-06-24 01:33:59', '2021-06-24 01:35:17', '{"Open":1.30893790,"High":1.30893790,"Low":1.30893790,"Close":1.30893790}'),
        (1, 0, 2, '2021-06-23 19:00:00', '2021-06-23 19:59:59', '2021-07-03 01:12:38', '{"Open":1.16820918,"High":1.72254585,"Low":1.16820918,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 19:15:00', '2021-06-23 19:15:59', '2021-06-23 19:17:13', '{"Open":1.16820918,"High":1.16820918,"Low":1.16820918,"Close":1.16820918}'),
        (1, 0, 1, '2021-06-23 18:39:00', '2021-06-23 18:39:59', '2021-06-23 18:40:50', '{"Open":1.17087693,"High":1.17087693,"Low":1.17087693,"Close":1.17087693}'),
        (1, 0, 2, '2021-06-23 18:00:00', '2021-06-23 18:59:59', '2021-07-03 01:12:38', '{"Open":1.16138068,"High":1.72254585,"Low":1.16138068,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 18:15:00', '2021-06-23 18:15:59', '2021-06-23 18:17:12', '{"Open":1.16138068,"High":1.16138068,"Low":1.16138068,"Close":1.16138068}'),
        (1, 0, 1, '2021-06-23 17:15:00', '2021-06-23 17:15:59', '2021-06-23 17:16:32', '{"Open":1.18827415,"High":1.18827415,"Low":1.18827415,"Close":1.18827415}'),
        (1, 0, 2, '2021-06-23 17:00:00', '2021-06-23 17:59:59', '2021-07-03 01:12:35', '{"Open":1.18564851,"High":1.72254585,"Low":1.18564851,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 17:06:00', '2021-06-23 17:06:59', '2021-06-23 17:07:33', '{"Open":1.18564851,"High":1.18564851,"Low":1.18564851,"Close":1.18564851}'),
        (1, 0, 2, '2021-06-23 16:00:00', '2021-06-23 16:59:59', '2021-07-03 01:12:33', '{"Open":1.17342544,"High":1.72254585,"Low":1.17342544,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 16:15:00', '2021-06-23 16:15:59', '2021-06-23 16:17:12', '{"Open":1.17342544,"High":1.17342544,"Low":1.17342544,"Close":1.17342544}'),
        (1, 0, 2, '2021-06-23 15:00:00', '2021-06-23 15:59:59', '2021-07-03 01:12:30', '{"Open":1.19976489,"High":1.72254585,"Low":1.19976489,"Close":1.72254585}'),
        (1, 0, 1, '2021-06-23 15:15:00', '2021-06-23 15:15:59', '2021-06-23 15:16:36', '{"Open":1.19976489,"High":1.19976489,"Low":1.19976489,"Close":1.19976489}'),
        (1, 0, 1, '2021-06-23 06:37:00', '2021-06-23 06:37:59', '2021-06-23 06:38:48', '{"Open":1.17480698,"High":1.17480698,"Low":1.17480698,"Close":1.17480698}'),
        (1, 0, 1, '2021-06-23 06:35:00', '2021-06-23 06:35:59', '2021-06-23 06:36:48', '{"Open":1.17486258,"High":1.17486258,"Low":1.17486258,"Close":1.17486258}'),
        (1, 0, 1, '2021-06-23 06:32:00', '2021-06-23 06:32:59', '2021-06-23 06:33:44', '{"Open":1.17591805,"High":1.17591805,"Low":1.17591805,"Close":1.17591805}'),
        (1, 0, 1, '2021-06-23 06:22:00', '2021-06-23 06:22:59', '2021-06-23 06:23:44', '{"Open":1.18097680,"High":1.18097680,"Low":1.18097680,"Close":1.18097680}'),
        (1, 0, 1, '2021-06-23 06:18:00', '2021-06-23 06:18:59', '2021-06-23 06:19:28', '{"Open":1.17744138,"High":1.17744138,"Low":1.17744138,"Close":1.17744138}'),
        (1, 0, 2, '2021-06-23 06:00:00', '2021-06-23 06:59:59', '2021-07-03 01:12:28', '{"Open":1.16719203,"High":1.72276772,"Low":1.16719203,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 06:15:00', '2021-06-23 06:15:59', '2021-06-23 06:16:32', '{"Open":1.16719203,"High":1.16719203,"Low":1.16719203,"Close":1.16719203}'),
        (1, 0, 1, '2021-06-23 05:59:00', '2021-06-23 05:59:59', '2021-06-23 06:00:50', '{"Open":1.17990405,"High":1.17990405,"Low":1.17990405,"Close":1.17990405}'),
        (1, 0, 1, '2021-06-23 05:57:00', '2021-06-23 05:57:59', '2021-06-23 05:58:40', '{"Open":1.18096992,"High":1.18096992,"Low":1.18096992,"Close":1.18096992}'),
        (1, 0, 1, '2021-06-23 05:52:00', '2021-06-23 05:52:59', '2021-06-23 05:53:27', '{"Open":1.17760454,"High":1.17760454,"Low":1.17760454,"Close":1.17760454}'),
        (1, 0, 1, '2021-06-23 05:15:00', '2021-06-23 05:15:59', '2021-06-23 05:16:39', '{"Open":1.16860188,"High":1.16860188,"Low":1.16860188,"Close":1.16860188}'),
        (1, 0, 1, '2021-06-23 05:08:00', '2021-06-23 05:08:59', '2021-06-23 05:09:22', '{"Open":1.16730970,"High":1.16730970,"Low":1.16730970,"Close":1.16730970}'),
        (1, 0, 2, '2021-06-23 05:00:00', '2021-06-23 05:59:59', '2021-07-03 01:12:26', '{"Open":1.16116179,"High":1.72276772,"Low":1.16116179,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 05:04:00', '2021-06-23 05:04:59', '2021-06-23 05:06:00', '{"Open":1.16116179,"High":1.16116179,"Low":1.16116179,"Close":1.16116179}'),
        (1, 0, 1, '2021-06-23 04:57:00', '2021-06-23 04:57:59', '2021-06-23 04:59:04', '{"Open":1.17967889,"High":1.17967889,"Low":1.17967889,"Close":1.17967889}'),
        (1, 0, 1, '2021-06-23 04:56:00', '2021-06-23 04:56:59', '2021-06-23 04:57:24', '{"Open":1.17851121,"High":1.17851121,"Low":1.17851121,"Close":1.17851121}'),
        (1, 0, 1, '2021-06-23 04:55:00', '2021-06-23 04:55:59', '2021-06-23 04:56:34', '{"Open":1.17737581,"High":1.17737581,"Low":1.17737581,"Close":1.17737581}'),
        (1, 0, 1, '2021-06-23 04:54:00', '2021-06-23 04:54:59', '2021-06-23 04:56:24', '{"Open":1.17737581,"High":1.17737581,"Low":1.17737581,"Close":1.17737581}'),
        (1, 0, 1, '2021-06-23 04:53:00', '2021-06-23 04:53:59', '2021-06-23 04:54:29', '{"Open":1.17658778,"High":1.17658778,"Low":1.17658778,"Close":1.17658778}'),
        (1, 0, 1, '2021-06-23 04:52:00', '2021-06-23 04:52:59', '2021-06-23 04:53:39', '{"Open":1.17344380,"High":1.17344380,"Low":1.17344380,"Close":1.17344380}'),
        (1, 0, 1, '2021-06-23 04:51:00', '2021-06-23 04:51:59', '2021-06-23 04:52:49', '{"Open":1.17113979,"High":1.17113979,"Low":1.17113979,"Close":1.17113979}'),
        (1, 0, 1, '2021-06-23 04:50:00', '2021-06-23 04:50:59', '2021-06-23 04:52:09', '{"Open":1.17056826,"High":1.17056826,"Low":1.17056826,"Close":1.17056826}'),
        (1, 0, 1, '2021-06-23 04:48:00', '2021-06-23 04:48:59', '2021-06-23 04:49:29', '{"Open":1.16264509,"High":1.16264509,"Low":1.16264509,"Close":1.16264509}'),
        (1, 0, 1, '2021-06-23 04:26:00', '2021-06-23 04:26:59', '2021-06-23 04:27:27', '{"Open":1.16082952,"High":1.16082952,"Low":1.16082952,"Close":1.16082952}'),
        (1, 0, 1, '2021-06-23 04:20:00', '2021-06-23 04:20:59', '2021-06-23 04:21:37', '{"Open":1.14857469,"High":1.14857469,"Low":1.14857469,"Close":1.14857469}'),
        (1, 0, 1, '2021-06-23 04:15:00', '2021-06-23 04:15:59', '2021-06-23 04:16:33', '{"Open":1.14854165,"High":1.14854165,"Low":1.14854165,"Close":1.14854165}'),
        (1, 0, 1, '2021-06-23 04:14:00', '2021-06-23 04:14:59', '2021-06-23 04:16:03', '{"Open":1.14852553,"High":1.14852553,"Low":1.14852553,"Close":1.14852553}'),
        (1, 0, 1, '2021-06-23 04:13:00', '2021-06-23 04:13:59', '2021-06-23 04:15:13', '{"Open":1.15246328,"High":1.15246328,"Low":1.15246328,"Close":1.15246328}'),
        (1, 0, 1, '2021-06-23 04:08:00', '2021-06-23 04:08:59', '2021-06-23 04:10:07', '{"Open":1.15466246,"High":1.15466246,"Low":1.15466246,"Close":1.15466246}'),
        (1, 0, 2, '2021-06-23 04:00:00', '2021-06-23 04:59:59', '2021-07-03 01:12:23', '{"Open":1.15974334,"High":1.72276772,"Low":1.14852553,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 04:07:00', '2021-06-23 04:07:59', '2021-06-23 04:08:52', '{"Open":1.15974334,"High":1.15974334,"Low":1.15974334,"Close":1.15974334}'),
        (1, 0, 1, '2021-06-23 03:57:00', '2021-06-23 03:57:59', '2021-06-23 03:59:12', '{"Open":1.15913117,"High":1.15913117,"Low":1.15913117,"Close":1.15913117}'),
        (1, 0, 1, '2021-06-23 03:56:00', '2021-06-23 03:56:59', '2021-06-23 03:57:52', '{"Open":1.15897881,"High":1.15897881,"Low":1.15897881,"Close":1.15897881}'),
        (1, 0, 1, '2021-06-23 03:54:00', '2021-06-23 03:54:59', '2021-06-23 03:55:51', '{"Open":1.15898352,"High":1.15898352,"Low":1.15898352,"Close":1.15898352}'),
        (1, 0, 1, '2021-06-23 03:15:00', '2021-06-23 03:15:59', '2021-06-23 03:16:34', '{"Open":1.15105118,"High":1.15105118,"Low":1.15105118,"Close":1.15105118}'),
        (1, 0, 1, '2021-06-23 03:14:00', '2021-06-23 03:14:59', '2021-06-23 03:15:34', '{"Open":1.15520485,"High":1.15520485,"Low":1.15520485,"Close":1.15520485}'),
        (1, 0, 2, '2021-06-23 03:00:00', '2021-06-23 03:59:59', '2021-07-03 01:12:20', '{"Open":1.15818269,"High":1.72276772,"Low":1.15105118,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 03:12:00', '2021-06-23 03:12:59', '2021-06-23 03:13:55', '{"Open":1.15818269,"High":1.15818269,"Low":1.15818269,"Close":1.15818269}'),
        (1, 0, 1, '2021-06-23 02:15:00', '2021-06-23 02:15:59', '2021-06-23 02:30:47', '{"Open":1.17108716,"High":1.17108716,"Low":1.17108716,"Close":1.17108716}'),
        (1, 0, 1, '2021-06-23 02:08:00', '2021-06-23 02:08:59', '2021-06-23 02:10:15', '{"Open":1.15838433,"High":1.15838433,"Low":1.15838433,"Close":1.15838433}'),
        (1, 0, 3, '2021-06-23 00:00:00', '2021-06-23 23:59:59', '2021-07-03 01:12:38', '{"Open":1.15838433,"High":1.72276772,"Low":1.14852553,"Close":1.72254585}'),
        (1, 0, 2, '2021-06-23 02:00:00', '2021-06-23 02:59:59', '2021-07-03 01:12:19', '{"Open":1.15838433,"High":1.72276772,"Low":1.15838433,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-23 02:06:00', '2021-06-23 02:06:59', '2021-06-23 02:10:14', '{"Open":1.15838433,"High":1.15838433,"Low":1.15838433,"Close":1.15838433}'),
        (1, 0, 2, '2021-06-22 23:00:00', '2021-06-22 23:59:59', '2021-07-03 01:12:17', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 23:15:00', '2021-06-22 23:15:59', '2021-06-22 23:40:17', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-22 22:00:00', '2021-06-22 22:59:59', '2021-07-03 01:11:43', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 22:15:00', '2021-06-22 22:15:59', '2021-06-22 23:40:16', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-22 19:00:00', '2021-06-22 19:59:59', '2021-07-03 01:11:42', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 19:15:00', '2021-06-22 19:15:59', '2021-06-22 23:40:15', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-22 00:00:00', '2021-06-22 23:59:59', '2021-07-03 01:12:17', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 2, '2021-06-22 01:00:00', '2021-06-22 01:59:59', '2021-07-03 01:11:41', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-22 01:15:00', '2021-06-22 01:15:59', '2021-06-22 23:40:14', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-20 00:00:00', '2021-06-20 23:59:59', '2021-07-03 01:11:39', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 2, '2021-06-20 20:00:00', '2021-06-20 20:59:59', '2021-07-03 01:11:39', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-20 20:15:00', '2021-06-20 20:15:59', '2021-06-22 23:40:13', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-18 22:00:00', '2021-06-18 22:59:59', '2021-07-03 01:11:34', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 22:15:00', '2021-06-18 22:15:59', '2021-06-22 23:40:11', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-18 00:00:00', '2021-06-18 23:59:59', '2021-07-03 01:11:34', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 2, '2021-06-18 21:00:00', '2021-06-18 21:59:59', '2021-07-03 01:11:31', '{"Open":1.10810667,"High":1.72276772,"Low":1.10810667,"Close":1.72276772}'),
        (1, 0, 1, '2021-06-18 21:15:00', '2021-06-18 21:15:59', '2021-06-22 23:40:09', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-16 02:32:00', '2021-06-16 02:32:59', '2021-06-22 23:40:05', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-16 02:28:00', '2021-06-16 02:28:59', '2021-06-22 23:40:04', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-16 02:26:00', '2021-06-16 02:26:59', '2021-06-22 23:40:03', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-16 02:25:00', '2021-06-16 02:25:59', '2021-06-22 23:40:00', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-16 00:00:00', '2021-06-16 23:59:59', '2021-07-03 01:11:27', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-16 02:00:00', '2021-06-16 02:59:59', '2021-07-03 01:11:23', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-16 02:23:00', '2021-06-16 02:23:59', '2021-06-22 23:40:00', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-15 02:00:00', '2021-06-15 02:59:59', '2021-07-03 01:11:20', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 02:15:00', '2021-06-15 02:15:59', '2021-06-22 23:39:52', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-15 01:15:00', '2021-06-15 01:15:59', '2021-06-22 23:39:51', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-15 01:00:00', '2021-06-15 01:59:59', '2021-07-03 01:10:46', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 01:11:00', '2021-06-15 01:11:59', '2021-06-22 23:39:51', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-15 00:15:00', '2021-06-15 00:15:59', '2021-06-22 23:39:49', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-15 00:04:00', '2021-06-15 00:04:59', '2021-06-22 23:39:49', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-15 00:00:00', '2021-06-15 23:59:59', '2021-07-03 01:11:20', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-15 00:00:00', '2021-06-15 00:59:59', '2021-07-03 01:10:44', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-15 00:01:00', '2021-06-15 00:01:59', '2021-06-22 23:39:48', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 23:00:00', '2021-06-14 23:59:59', '2021-07-03 01:10:40', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 23:15:00', '2021-06-14 23:15:59', '2021-06-22 23:39:47', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 22:00:00', '2021-06-14 22:59:59', '2021-07-03 01:10:38', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 22:15:00', '2021-06-14 22:15:59', '2021-06-22 23:39:46', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 21:30:00', '2021-06-14 21:30:59', '2021-06-22 23:39:44', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 21:00:00', '2021-06-14 21:59:59', '2021-07-03 01:10:34', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 21:15:00', '2021-06-14 21:15:59', '2021-06-22 23:39:44', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 20:00:00', '2021-06-14 20:59:59', '2021-07-03 01:10:32', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 20:15:00', '2021-06-14 20:15:59', '2021-06-22 23:39:42', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 19:00:00', '2021-06-14 19:59:59', '2021-07-03 01:10:30', '{"Open":1.10810667,"High":1.71948090,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 19:09:00', '2021-06-14 19:09:59', '2021-06-22 23:39:41', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:23:00', '2021-06-14 07:23:59', '2021-06-22 23:39:39', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:20:00', '2021-06-14 07:20:59', '2021-06-22 23:39:39', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:18:00', '2021-06-14 07:18:59', '2021-06-22 23:39:39', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:15:00', '2021-06-14 07:15:59', '2021-06-22 23:39:38', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:05:00', '2021-06-14 07:05:59', '2021-06-22 23:39:38', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 07:04:00', '2021-06-14 07:04:59', '2021-06-22 23:39:38', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-14 07:00:00', '2021-06-14 07:59:59', '2021-07-03 01:10:27', '{"Open":1.10810667,"High":1.72114981,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 1, '2021-06-14 07:02:00', '2021-06-14 07:02:59', '2021-06-22 23:39:37', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 06:56:00', '2021-06-14 06:56:59', '2021-06-22 23:39:37', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 06:44:00', '2021-06-14 06:44:59', '2021-06-22 23:39:37', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-14 06:15:00', '2021-06-14 06:15:59', '2021-06-22 23:39:36', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-14 00:00:00', '2021-06-14 23:59:59', '2021-07-03 01:10:40', '{"Open":1.10810667,"High":1.72114981,"Low":1.10810667,"Close":1.71948090}'),
        (1, 0, 2, '2021-06-14 06:00:00', '2021-06-14 06:59:59', '2021-07-03 01:10:25', '{"Open":1.10810667,"High":1.72114981,"Low":1.10810667,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-14 06:08:00', '2021-06-14 06:08:59', '2021-06-22 23:39:35', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-13 00:00:00', '2021-06-13 23:59:59', '2021-07-03 01:10:21', '{"Open":1.10810667,"High":1.72114981,"Low":1.10810667,"Close":1.72114981}'),
        (1, 0, 2, '2021-06-13 19:00:00', '2021-06-13 19:59:59', '2021-07-03 01:10:21', '{"Open":1.10810667,"High":1.72114981,"Low":1.10810667,"Close":1.72114981}'),
        (1, 0, 1, '2021-06-13 19:15:00', '2021-06-13 19:15:59', '2021-06-22 23:39:33', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 23:03:00', '2021-06-11 23:03:59', '2021-06-22 23:39:32', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 23:02:00', '2021-06-11 23:02:59', '2021-06-22 23:39:32', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 23:01:00', '2021-06-11 23:01:59', '2021-06-22 23:39:31', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-11 23:00:00', '2021-06-11 23:59:59', '2021-06-22 23:39:32', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 23:00:00', '2021-06-11 23:00:59', '2021-06-22 23:39:31', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 22:59:00', '2021-06-11 22:59:59', '2021-06-22 23:39:30', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 3, '2021-06-11 00:00:00', '2021-06-11 23:59:59', '2021-06-22 23:39:32', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 2, '2021-06-11 22:00:00', '2021-06-11 22:59:59', '2021-06-22 23:39:31', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}'),
        (1, 0, 1, '2021-06-11 22:58:00', '2021-06-11 22:58:59', '2021-06-22 23:39:30', '{"Open":1.10810667,"High":1.10810667,"Low":1.10810667,"Close":1.10810667}');