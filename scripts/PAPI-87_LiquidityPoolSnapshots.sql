USE platform;

DELIMITER //

CREATE PROCEDURE BackFillPoolSnapshotOHLC ()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE Id bigint unsigned;
    DECLARE Details JSON;

    -- declare cursor
    DEClARE snapshotCursor
        CURSOR FOR
            SELECT * FROM pool_liquidity_snapshot WHERE JSON_EXTRACT(Details, '$.reserves.usd.close') IS NULL;

    -- declare NOT FOUND handler
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET finished = 1;

    OPEN snapshotCursor;

    getSnapshot: LOOP
        FETCH snapshotCursor INTO Id, Details;

        IF finished = 1 THEN
            LEAVE getSnapshot;
        END IF;

        -- Build new JSON and update record by Id with new JSON
        SELECT JSON_MERGE_PRESERVE(
            JSON_OBJECT('cost', JSON_MERGE_PRESERVE(
                JSON_OBJECT('crsPerSrc', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.cost.crsPerSrc.low')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.cost.crsPerSrc.high')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.cost.crsPerSrc.open')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.cost.crsPerSrc.close'))
                                        )
                ),
                JSON_OBJECT('srcPerCrs', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.cost.srcPerCrs.low')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.cost.srcPerCrs.high')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.cost.srcPerCrs.open')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.cost.srcPerCrs.close'))
                                        )
                )
            )),
            JSON_OBJECT('volume', JSON_MERGE_PRESERVE(
                                    JSON_OBJECT('crs', JSON_EXTRACT(@Details, '$.volume.crs')),
                                    JSON_OBJECT('src', JSON_EXTRACT(@Details, '$.volume.src')),
                                    JSON_OBJECT('usd', JSON_EXTRACT(@Details, '$.volume.usd')),
                                  )
            ),
            JSON_OBJECT('rewards', JSON_MERGE_PRESERVE(
                                    JSON_OBJECT('marketUsd', JSON_EXTRACT(@Details, '$.rewards.marketUsd')),
                                    JSON_OBJECT('providerUsd', JSON_EXTRACT(@Details, '$.rewards.providerUsd'))
                                  )
            ),
            JSON_OBJECT('staking', JSON_MERGE_PRESERVE(
                JSON_OBJECT('usd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.staking.usd')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.staking.usd')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.staking.usd')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.staking.usd'))
                                        )
                ),
                JSON_OBJECT('weight', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.staking.weight')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.staking.weight')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.staking.weight')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.staking.weight'))
                                        )
                )
            )),
            JSON_OBJECT('reserves', JSON_MERGE_PRESERVE(
                JSON_OBJECT('crs', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.reserves.crs')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.reserves.crs')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.reserves.crs')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.reserves.crs'))
                                        )
                ),
                JSON_OBJECT('src', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.reserves.src')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.reserves.src')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.reserves.src')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.reserves.src'))
                                        )
                ),
                JSON_OBJECT('usd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.reserves.usd')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.reserves.usd')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.reserves.usd')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.reserves.usd'))
                                        )
                )
            )),
        ) INTO @UpdatedDetails;

        UPDATE pool_liquidity_snapshot SET Details = @UpdatedDetails WHERE Id = @Id;
    END LOOP getSnapshot;
    CLOSE snapshotCursor;

END //

DELIMITER ;