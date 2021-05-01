-- auto-generated definition
create table token_snapshot
(
    Id             bigint auto_increment,
    TokenId        bigint                      not null,
    Price          decimal(20, 2) default 0.00 not null,
    SnapshotTypeId smallint(6)                 not null,
    StartDate      datetime                    not null,
    EndDate        datetime                    not null,
    constraint token_snapshot_Id_uindex
        unique (Id),
    constraint token_snapshot_TokenId_uindex
        unique (TokenId),
    constraint token_snapshot_snapshot_type_Id_fk
        foreign key (SnapshotTypeId) references snapshot_type (Id),
    constraint token_snapshot_token_Id_fk
        foreign key (TokenId) references token (Id)
);

create index token_snapshot_TokenId_StartDate_EndDate_index
    on token_snapshot (TokenId, StartDate, EndDate);

alter table token_snapshot
    add primary key (Id);

