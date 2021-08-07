DELIMITER //

CREATE PROCEDURE InsertIndexLockId ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='index_lock'
        AND column_name='Id';

    IF @exists = 0 THEN
        ALTER TABLE index_lock
            ADD COLUMN Id bigint PRIMARY KEY DEFAULT(1)
            FIRST;
    END IF;
 END;
//

CALL InsertIndexLockId();
//

DROP PROCEDURE InsertIndexLockId;
//

DELIMITER ;
