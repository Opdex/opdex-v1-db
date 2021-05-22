SET @transcationType = 'StartStakingLog';

select * from transaction_log tl
JOIN transaction_log_type tlt ON tlt.Id = tl.LogTypeId
where tlt.LogType = @transcationType;