
-- Gets tokens, their liquidity pools and mining pools
select t.Name, t.Symbol, t.Address as TokenAddress, pl.Id, pl.Address as LiquidityPoolAddress, mp.Id, mp.Address as MiningPoolAddress FROM token t
left JOIN pool_liquidity pl ON pl.TokenId = t.Id
left JOIN pool_mining mp ON mp.LiquidityPoolId = pl.Id;