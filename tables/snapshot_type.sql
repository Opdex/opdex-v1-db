-- auto-generated definition
create table snapshot_type
(
    Id           smallint(6)  not null,
    SnapshotType varchar(50) not null,
    constraint snapshot_type_Id_uindex
        unique (Id)
);

alter table snapshot_type
    add primary key (Id);

insert into snapshot_type
values
    (1, 'Minute'),
    (2, 'Hour'),
    (3, 'Day'),
    (4, 'Month'),
    (5, 'Year');