-- auto-generated definition
create table market_snapshot
(
    Id               bigint auto_increment,
    MarketId         bigint                      not null,
    TransactionCount int(11)        default 0    not null,
    Liquidity        decimal(20, 2) default 0.00 not null,
    Volume           decimal(20, 2) default 0.00 not null,
    StakingWeight    varchar(78)    default '0'  not null,
    StakingUsd       decimal(20, 2) default 0.00 not null,
    StakerRewards    decimal(20, 2) default 0.00 not null,
    ProviderRewards  decimal(20, 2) default 0.00 not null,
    SnapshotType     smallint(6)                 not null,
    StartDate        datetime                    not null,
    EndDate          datetime                    not null,
    CreatedDate      datetime                    not null,
    constraint market_snapshot_Id_uindex
        unique (Id),
    constraint market_snapshot_market_Id_fk
        foreign key (MarketId) references market (Id),
    constraint market_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotType) references snapshot_type (Id)
);

create index market_snapshot_MarketId_StartDate_EndDate_index
    on market_snapshot (MarketId, StartDate, EndDate);

alter table market_snapshot
    add primary key (Id);
