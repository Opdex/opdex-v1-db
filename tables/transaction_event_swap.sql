create table transaction_event_swap
(
    Id            bigint          not null,
    TransactionId bigint          not null,
    Address       varchar(50)     not null,
    Sender        varchar(50)     not null,
    `To`          varchar(50)     not null,
    AmountCrsIn   bigint unsigned not null,
    AmountSrcIn   varchar(78)     not null,
    AmountCrsOut  bigint unsigned not null,
    AmountSrcOut  varchar(78)     not null,
    CreatedDate   datetime        not null,
    constraint transaction_event_swap_Id_uindex
        unique (Id),
    constraint transaction_event_swap_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

create index transaction_event_swap_Sender_index
    on transaction_event_swap (Sender);

alter table transaction_event_swap
    add primary key (Id);

