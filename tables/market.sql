-- auto-generated definition
create table market
(
    Id               bigint auto_increment,
    Address          varchar(50) not null,
    AuthProviders    bit         not null,
    AuthPoolCreators bit         not null,
    AuthTraders      bit         not null,
    Fee              smallint    not null,
    Staking          bit         not null,
    CreatedDate      datetime    not null,
    constraint market_Address_uindex
        unique (Address),
    constraint market_Id_uindex
        unique (Id)
);

alter table market
    add primary key (Id);
