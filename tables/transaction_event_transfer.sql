create table transaction_event_transfer
(
    Id            bigint      not null,
    TransactionId bigint      not null,
    Address       varchar(50) not null,
    `From`        varchar(50) not null,
    `To`          varchar(50) not null,
    Amount        varchar(78) not null,
    CreatedDate   datetime    not null,
    constraint transaction_event_transfer_Id_uindex
        unique (Id),
    constraint transaction_event_transfer_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

create index transaction_event_transfer_From_index
    on transaction_event_transfer (`From`);

alter table transaction_event_transfer
    add primary key (Id);

