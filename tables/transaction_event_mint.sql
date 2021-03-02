create table transaction_event_mint
(
    Id            bigint          not null,
    TransactionId bigint          not null,
    Address       varchar(50)     not null,
    Sender        varchar(50)     not null,
    AmountCrs     bigint unsigned not null,
    AmountSrc     varchar(78)     not null,
    CreatedDate   datetime        not null,
    constraint transaction_event_mint_Id_uindex
        unique (Id),
    constraint transaction_event_mint_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

create index transaction_event_mint_Sender_index
    on transaction_event_mint (Sender);

alter table transaction_event_mint
    add primary key (Id);