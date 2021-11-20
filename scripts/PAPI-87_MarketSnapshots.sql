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
            SELECT * FROM market_snapshot WHERE JSON_EXTRACT(Details, '$.liquidityUsd.close') IS NULL;

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
            JSON_OBJECT('volume', JSON_EXTRACT(@Details, '$.volume')),
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
            JSON_OBJECT('liquidityUsd', JSON_MERGE_PRESERVE(
                                            JSON_OBJECT('low', JSON_EXTRACT(@Details, '$.liquidity')),
                                            JSON_OBJECT('high', JSON_EXTRACT(@Details, '$.liquidity')),
                                            JSON_OBJECT('open', JSON_EXTRACT(@Details, '$.liquidity')),
                                            JSON_OBJECT('close', JSON_EXTRACT(@Details, '$.liquidity'))
                                        ))
        ) INTO @UpdatedDetails;

        UPDATE market_snapshot SET Details = @UpdatedDetails WHERE Id = @Id;
    END LOOP getSnapshot;
    CLOSE snapshotCursor;

END //

DELIMITER ;