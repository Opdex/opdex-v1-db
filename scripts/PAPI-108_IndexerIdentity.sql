-- Creates the InstanceId column of the index_lock table used to determine who is responsible for 
-- locking and unlocking the table.
DELIMITER //

CREATE PROCEDURE InsertIndexLockIdentity ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='index_lock'
        AND column_name='InstanceId';

    IF @exists = 0 THEN
        ALTER TABLE index_lock
            ADD COLUMN InstanceId varchar(40) null
            AFTER LOCKED;
    END IF;
 END;
//

CALL InsertIndexLockIdentity();
//

DROP PROCEDURE InsertIndexLockIdentity;
//

DELIMITER ;
