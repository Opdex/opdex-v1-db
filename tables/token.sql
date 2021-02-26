-- Author: Tyler Pena
-- Created: 2/25/21
-- Creates Transaction Table

use opdex;

create table token
(
    Id          bigint      not null,
    Address     varchar(50) not null,
    Symbol      varchar(10) not null,
    Name        varchar(50) not null,
    Decimals    smallint(2) not null,
    Sats        bigint      not null,
    TotalSupply varchar(78) not null,
    CreatedDate datetime    not null,
    constraint token_Address_uindex
        unique (Address),
    constraint token_Id_uindex
        unique (Id)
);

alter table token
    add primary key (Id);

