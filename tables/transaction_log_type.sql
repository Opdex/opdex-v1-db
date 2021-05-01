-- auto-generated definition
create table transaction_log_type
(
    Id      smallint(6) not null,
    LogType varchar(50) not null,
    constraint transaction_event_type_Id_uindex
        unique (Id)
);

alter table transaction_log_type
    add primary key (Id);

insert into transaction_log_type(Id, LogType)
values
       (1, 'MarketCreatedLog'),
       (2, 'LiquidityPoolCreatedLog'),
       (3, 'MarketOwnerChangeLog'),
       (4, 'PermissionsChangeLog'),
       (5, 'MintLog'),
       (6, 'BurnLog'),
       (7, 'SwapLog'),
       (8, 'ReservesLog'),
       (9, 'ApprovalLog'),
       (10, 'TransferLog'),
       (11, 'MarketChangeLog'),
       (12, 'StartStakingLog'),
       (13, 'CollectStakingRewardsLog'),
       (14, 'StopStakingLog'),
       (15, 'MiningPoolCreatedLog'),
       (16, 'RewardMiningPoolLog'),
       (17, 'NominationLog'),
       (18, 'StartMiningLog'),
       (19, 'CollectMiningRewardsLog'),
       (20, 'StopMiningLog'),
       (21, 'MiningPoolRewardedLog'),
       (22, 'OwnerChangeLog'),
       (23, 'DistributionLog');
