create table transaction_event_approval
(
    Id            bigint      not null,
    TransactionId bigint      not null,
    Address       varchar(50) not null,
    Owner         varchar(50) not null,
    Spender       varchar(50) not null,
    Amount        varchar(78) not null,
    CreatedDate   datetime    not null,
    constraint transaction_event_approval_Id_uindex
        unique (Id),
    constraint transaction_event_approval_transaction_Id_fk
        foreign key (TransactionId) references transaction (Id)
);

create index transaction_event_approval_Owner_index
    on transaction_event_approval (Owner);

alter table transaction_event_approval
    add primary key (Id);

