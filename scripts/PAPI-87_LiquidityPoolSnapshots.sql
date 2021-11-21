USE platform;

DELIMITER //

DROP PROCEDURE IF EXISTS BackFillPoolSnapshotOHLC; //

CREATE PROCEDURE BackFillPoolSnapshotOHLC()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE SnapshotId bigint unsigned;
    DECLARE SnapshotDetails JSON;

    -- declare cursor
    DEClARE snapshotCursor
        CURSOR FOR
            SELECT Id, Details FROM pool_liquidity_snapshot WHERE JSON_EXTRACT(Details, '$.reserves.usd.close') IS NULL;

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
        UPDATE pool_liquidity_snapshot SET Details = (SELECT JSON_MERGE_PRESERVE(
            JSON_OBJECT('cost', JSON_MERGE_PRESERVE(
                JSON_OBJECT('crsPerSrc', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.cost.crsPerSrc.low')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.cost.crsPerSrc.high')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.cost.crsPerSrc.open')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.cost.crsPerSrc.close'))
                                        )
                ),
                JSON_OBJECT('srcPerCrs', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.cost.srcPerCrs.low')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.cost.srcPerCrs.high')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.cost.srcPerCrs.open')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.cost.srcPerCrs.close'))
                                        )
                )
            )),
            JSON_OBJECT('volume', JSON_MERGE_PRESERVE(
                                    JSON_OBJECT('crs', JSON_EXTRACT(SnapshotDetails, '$.volume.crs')),
                                    JSON_OBJECT('src', JSON_EXTRACT(SnapshotDetails, '$.volume.src')),
                                    JSON_OBJECT('usd', JSON_EXTRACT(SnapshotDetails, '$.volume.usd'))
                                  )
            ),
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
            JSON_OBJECT('reserves', JSON_MERGE_PRESERVE(
                JSON_OBJECT('crs', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.reserves.crs')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.reserves.crs')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.reserves.crs')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.reserves.crs'))
                                        )
                ),
                JSON_OBJECT('src', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.reserves.src')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.reserves.src')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.reserves.src')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.reserves.src'))
                                        )
                ),
                JSON_OBJECT('usd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(SnapshotDetails, '$.reserves.usd')),
                                            JSON_OBJECT('high', JSON_EXTRACT(SnapshotDetails, '$.reserves.usd')),
                                            JSON_OBJECT('open', JSON_EXTRACT(SnapshotDetails, '$.reserves.usd')),
                                            JSON_OBJECT('close', JSON_EXTRACT(SnapshotDetails, '$.reserves.usd'))
                                        )
                )
            ))
        )) WHERE Id = SnapshotId;
    END LOOP getSnapshot;
    CLOSE snapshotCursor;

END //

CALL BackFillPoolSnapshotOHLC(); //

DROP PROCEDURE BackFillPoolSnapshotOHLC; //

DELIMITER ;