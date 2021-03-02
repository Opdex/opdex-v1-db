create table transaction_event_pair_created
(
    Id            bigint      not null,
    TransactionId bigint      not null,
    Address       varchar(50) not null,
    Pair          varchar(50) not null,
    Token         varchar(50) not null,
    CreatedDate   datetime    not null,
    constraint transaction_event_pair_created_Id_uindex
        unique (Id),
    constraint transaction_event_pair_created_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

alter table transaction_event_pair_created
    add primary key (Id);

