create table market_snapshot
(
    Id                    bigint         not null,
    TokenCount            int            not null,
    PairCount             int            not null,
    DailyTransactionCount int            null,
    CrsPrice              decimal(10, 2) not null,
    Liquidity             decimal(10, 2) not null,
    DailyVolume           decimal(10, 2) not null,
    DailyFees             decimal(10, 2) not null,
    Block                 bigint         not null,
    CreatedDate           datetime       not null,
    constraint market_snapshot_Block_uindex
        unique (Block),
    constraint market_snapshot_Id_uindex
        unique (Id)
);

alter table market_snapshot
    add primary key (Id);

