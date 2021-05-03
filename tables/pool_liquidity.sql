-- auto-generated definition
create table pool_liquidity
(
    Id          bigint auto_increment,
    TokenId     bigint      not null,
    MarketId    bigint      null,
    Address     varchar(50) not null,
    CreatedDate datetime    not null,
    constraint pair_Address_uindex
        unique (Address),
    constraint pair_Id_uindex
        unique (Id),
    constraint pair_TokenId_uindex
        unique (TokenId),
    constraint pool_liquidity_market_Id_fk
        foreign key (MarketId) references market (Id),
    constraint pool_liquidity_token_Id_fk
        foreign key (TokenId) references token (Id)
);

alter table pool_liquidity
    add primary key (Id);
