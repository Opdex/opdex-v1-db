DELIMITER //

CREATE PROCEDURE AddIndexLockReason ()
 BEGIN
    SELECT COUNT(*) into @indexLockExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'index_lock';

    SELECT COUNT(*) into @indexLockReasonExists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='index_lock'
        AND column_name='Reason';

    IF @indexLockExists AND !@indexLockReasonExists THEN
        ALTER TABLE platform.index_lock
            ADD COLUMN Reason varchar(20) NULL
            AFTER InstanceId;
    END IF;
 END;
//

CALL AddIndexLockReason();
//

DROP PROCEDURE AddIndexLockReason;
//

DELIMITER ;
