-- auto-generated definition
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