-- auto-generated definition
create table deployer
(
    Id          bigint(20) auto_increment,
    Address     varchar(50) not null,
    CreatedDate datetime    not null,
    constraint deployer_Address_uindex
        unique (Address),
    constraint deployer_Id_uindex
        unique (Id)
);

alter table deployer
    add primary key (Id);

