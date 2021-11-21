USE platform;

DELIMITER //

DROP PROCEDURE IF EXISTS BackFillMarketSnapshotOHLC; //

CREATE PROCEDURE BackFillMarketSnapshotOHLC()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE SnapshotId bigint unsigned;
    DECLARE SnapshotDetails JSON;

    -- declare cursor
    DEClARE snapshotCursor
        CURSOR FOR
            SELECT Id, Details FROM market_snapshot WHERE JSON_EXTRACT(Details, '$.liquidityUsd.close') IS NULL;

    -- declare NOT FOUND handler
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET finished = 1;

    OPEN snapshotCursor;

    getSnapshot: LOOP
        FETCH snapshotCursor INTO SnapshotId, SnapshotDetails;

        IF finished = 1 THEN
            LEAVE getSnapshot;
        END IF;

        -- Build new JSON and update record by Id with new JSON
        UPDATE market_snapshot SET Details = (SELECT JSON_MERGE_PRESERVE(
            JSON_OBJECT('volume', JSON_EXTRACT(SnapshotDetails, '$.volume')),
            JSON_OBJECT('rewards', JSON_MERGE_PRESERVE(
                                    JSON_OBJECT('marketUsd', JSON_EXTRACT(SnapshotDetails, '$.rewards.marketUsd')),
                                    JSON_OBJECT('providerUsd', JSON_EXTRACT(SnapshotDetails, '$.rewards.providerUsd'))
                                  )
            ),
            JSON_OBJECT('staking', JSON_MERGE_PRESERVE(
                JSON_OBJECT('usd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.staking.usd')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.staking.usd')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.staking.usd')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.staking.usd'))
                                        )
                ),
                JSON_OBJECT('weight', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.staking.weight')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.staking.weight')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.staking.weight')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.staking.weight'))
                                        )
                )
            )),
            JSON_OBJECT('liquidityUsd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.liquidity')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.liquidity')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.liquidity')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.liquidity'))
                                        ))
        )) WHERE Id = SnapshotId;
    END LOOP getSnapshot;
    CLOSE snapshotCursor;

END //

CALL BackFillMarketSnapshotOHLC(); //

DROP PROCEDURE BackFillMarketSnapshotOHLC; //

DELIMITER ;