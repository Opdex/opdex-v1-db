-- auto-generated definition
create table transaction
(
    Id          bigint auto_increment,
    `From`      varchar(50)     not null,
    `To`        varchar(50)     null,
    Hash        varchar(64)     not null,
    GasUsed     int             not null,
    Block       bigint unsigned not null,
    CreatedDate datetime        not null,
    constraint transaction_Id_uindex
        unique (Id),
    constraint transaction_block_Height_fk
        foreign key (Block) references block (Height)
);

create index transaction_Block_index
    on transaction (Block);

create index transaction_From_index
    on transaction (`From`);

create index transaction_Hash_index
    on transaction (Hash);

alter table transaction
    add primary key (Id);

