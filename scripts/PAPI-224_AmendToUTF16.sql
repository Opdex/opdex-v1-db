DELIMITER //

CREATE PROCEDURE AmendToUTF16()
 BEGIN
    SELECT COUNT(*) into @nameExistsOnPoolLiquidity
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='pool_liquidity'
        AND column_name='Name';

    SELECT COUNT(*) into @nameExistsOnToken
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='token'
        AND column_name='Name';

    SELECT COUNT(*) into @symbolExistsOnToken
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='token'
        AND column_name='Symbol';

    IF @nameExistsOnPoolLiquidity THEN
        ALTER TABLE pool_liquidity
            MODIFY Name varchar(50) CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci;
    END IF;

    IF @nameExistsOnToken THEN
        ALTER TABLE token
            MODIFY Name varchar(50) CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci;
    END IF;

    IF @symbolExistsOnToken THEN
        ALTER TABLE token
            MODIFY Symbol varchar(20) CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci;
    END IF;
 END;
//

CALL AmendToUTF16();
//

DROP PROCEDURE AmendToUTF16;
//

DELIMITER ;