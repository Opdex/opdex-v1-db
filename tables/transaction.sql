-- Author: Tyler Pena
-- Created: 2/25/21
-- Creates Transaction Table

use opdex;

create table transaction
(
    Id          bigint          not null,
    `From`      varchar(50)     not null,
    `To`        varchar(50)     not null,
    Hash        varchar(50)     not null,
    GasUsed     smallint        not null,
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

