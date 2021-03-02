create table pair
(
    Id          bigint          not null,
    Address     varchar(50)     not null,
    TokenId     bigint          not null,
    ReserveCrs  bigint unsigned not null,
    ReserveSrc  varchar(78)     not null,
    CreatedDate datetime        not null,
    constraint pair_Address_uindex
        unique (Address),
    constraint pair_Id_uindex
        unique (Id),
    constraint pair_TokenId_uindex
        unique (TokenId),
    constraint pair_token_Id_fk
        foreign key (TokenId) references token (Id)
);

alter table pair
    add primary key (Id);