-- auto-generated definition
create table block
(
    Height      bigint unsigned not null,
    Hash        varchar(50)     not null,
    Time        datetime        not null,
    MedianTime  datetime        not null,
    CreatedDate datetime        not null,
    constraint block_Hash_uindex
        unique (Hash),
    constraint block_Height_uindex
        unique (Height)
);

alter table block
    add primary key (Height);

