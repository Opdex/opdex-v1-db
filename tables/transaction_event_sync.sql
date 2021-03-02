create table transaction_event_sync
(
    Id            bigint          not null,
    TransactionId bigint          not null,
    Address       varchar(50)     not null,
    ReserveCrs    bigint unsigned not null,
    ReserveSrc    varchar(78)     not null,
    CreatedDate   datetime        not null,
    constraint transaction_event_sync_Id_uindex
        unique (Id),
    constraint transaction_event_sync_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

alter table transaction_event_sync
    add primary key (Id);

