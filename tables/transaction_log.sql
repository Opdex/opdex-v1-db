-- auto-generated definition
create table transaction_log
(
    Id            bigint auto_increment,
    TransactionId bigint(20)                   not null,
    LogTypeId     smallint(6)                  not null,
    SortOrder     smallint(2)                  not null,
    Contract      varchar(50)                  not null,
    Details       longtext collate utf8mb4_bin null,
    CreatedDate   datetime                     not null,
    constraint transaction_event_Id_uindex
        unique (Id),
    constraint transaction_log_transaction_log_type_Id_fk
        foreign key (LogTypeId) references transaction_log_type (Id),
    constraint Details
        check (json_valid(`Details`))
);

create index transaction_event_transaction_Id_fk
    on transaction_log (TransactionId);

create index transaction_log_Contract_index
    on transaction_log (Contract);

alter table transaction_log
    add primary key (Id);

