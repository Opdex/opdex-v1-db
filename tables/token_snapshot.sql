create table token_snapshot
(
    Id          bigint         not null,
    TokenId     bigint         not null,
    Price       decimal(10, 2) not null comment 'This field - in general - this table may be obsolete',
    CreatedDate datetime       not null,
    constraint token_snapshot_Id_uindex
        unique (Id),
    constraint token_snapshot_TokenId_uindex
        unique (TokenId),
    constraint token_snapshot_token_Id_fk
        foreign key (TokenId) references token (Id)
);

alter table token_snapshot
    add primary key (Id);

