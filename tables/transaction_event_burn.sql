create table transaction_event_burn
(
    Id            bigint          not null,
    TransactionId bigint          not null,
    Address       varchar(50)     not null,
    Sender        varchar(50)     not null,
    `To`          varchar(50)     not null,
    AmountCrs     bigint unsigned not null,
    AmountSrc     varchar(78)     not null,
    CreatedDate   datetime        not null,
    constraint transaction_event_burn_Id_uindex
        unique (Id),
    constraint transaction_event_burn_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

create index transaction_event_burn_Sender_index
    on transaction_event_burn (Sender);

alter table transaction_event_burn
    add primary key (Id);

