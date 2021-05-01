-- auto-generated definition
create table pool_mining
(
    Id                   bigint auto_increment,
    LiquidityPoolId      bigint(20)      not null,
    Address              varchar(50)     not null,
    RewardRate           varchar(78)     not null,
    MiningPeriodEndBlock bigint unsigned not null,
    CreatedDate          datetime        not null,
    constraint mining_pool_Address_uindex
        unique (Address),
    constraint mining_pool_Id_uindex
        unique (Id),
    constraint mining_pool_LiquidityPoolId_uindex
        unique (LiquidityPoolId),
    constraint pool_mining_pool_liquidity_Id_fk
        foreign key (LiquidityPoolId) references pool_liquidity (Id)
);

alter table pool_mining
    add primary key (Id);

