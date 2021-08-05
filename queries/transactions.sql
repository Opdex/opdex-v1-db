SET @transcationType = 'RewardMiningPoolLog';

select t.* from transaction t
JOIN transaction_log tl ON tl.TransactionId = t.Id
JOIN transaction_log_type tlt ON tlt.Id = tl.LogTypeId
where tlt.LogType = @transcationType;