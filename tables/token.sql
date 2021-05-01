-- auto-generated definition
create table token
(
    Id          bigint auto_increment,
    Address     varchar(50) not null,
    Symbol      varchar(10) not null,
    Name        varchar(50) not null,
    Decimals    smallint(2) not null,
    Sats        bigint(20)  not null,
    TotalSupply varchar(78) not null,
    CreatedDate datetime    not null,
    constraint token_Address_uindex
        unique (Address),
    constraint token_Id_uindex
        unique (Id)
);

alter table token
    add primary key (Id);

