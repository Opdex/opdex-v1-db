create table pair_snapshot
(
    Id               bigint      not null,
    PairId           bigint      not null,
    Block            bigint      not null,
    TransactionCount int         not null,
    ReserveCrs       bigint      not null,
    ReserveSrc       varchar(78) not null,
    VolumeCrs        bigint      not null,
    VolumeSrc        varchar(78) not null,
    CreatedDate      datetime    not null,
    constraint pair_snapshot_Block_uindex
        unique (Block),
    constraint pair_snapshot_Id_uindex
        unique (Id),
    constraint pair_snapshot_PairId_uindex
        unique (PairId)
);

alter table pair_snapshot
    add primary key (Id);
