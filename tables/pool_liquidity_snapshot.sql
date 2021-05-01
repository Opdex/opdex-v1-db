-- auto-generated definition
create table pool_liquidity_snapshot
(
    Id               bigint auto_increment,
    PoolId           bigint                      not null,
    TransactionCount int(11)        default 0    not null,
    ReserveCrs       varchar(78)    default '0'  not null,
    ReserveSrc       varchar(78)    default '0'  not null,
    ReserveUsd       decimal(20, 2)              not null,
    VolumeCrs        varchar(78)    default '0'  not null,
    VolumeSrc        varchar(78)    default '0'  not null,
    VolumeUsd        decimal(20, 2) default 0.00 not null,
    StakingWeight    varchar(78)    default '0'  not null,
    StakingUsd       decimal(20, 2) default 0.00 not null,
    ProviderRewards  decimal(20, 2) default 0.00 not null,
    StakerRewards    decimal(20, 2) default 0.00 not null,
    SnapshotType     smallint                    not null,
    StartDate        datetime                    not null,
    EndDate          datetime                    not null,
    constraint pair_snapshot_Id_uindex
        unique (Id),
    constraint pair_snapshot_PoolId_uindex
        unique (PoolId),
    constraint pool_liquidity_snapshot_pool_liquidity_Id_fk
        foreign key (PoolId) references pool_liquidity (Id),
    constraint pool_liquidity_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotType) references snapshot_type (Id)
);

create index pool_liquidity_snapshot_PoolId_StartDate_EndDate_index
    on pool_liquidity_snapshot (PoolId, StartDate, EndDate);

alter table pool_liquidity_snapshot
    add primary key (Id);

