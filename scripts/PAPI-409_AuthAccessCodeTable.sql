DELIMITER //

CREATE PROCEDURE AuthAccessCode ()
 BEGIN
        CREATE TABLE IF NOT EXISTS auth_access_code(
            Id                 BIGINT UNSIGNED AUTO_INCREMENT,
            AccessCode         VARCHAR(50) NOT NULL,
            Signer             VARCHAR(50) NOT NULL,
            Expiry             DATETIME NOT NULL,
            PRIMARY KEY (ConnectionId)
        ) ENGINE = INNODB;

        DROP EVENT IF EXISTS remove_expired_auth_success_event;

        CREATE EVENT IF NOT EXISTS remove_expired_auth_success_event
        ON SCHEDULE EVERY 5 MINUTE
        DO
            BEGIN
                DELETE FROM auth_success WHERE Expiry < UTC_TIMESTAMP();
                DELETE FROM auth_access_code WHERE Expiry < UTC_TIMESTAMP();
            END
 END;
//

CALL AuthAccessCode();
//

DROP PROCEDURE AuthAccessCode;
//

DELIMITER ;
