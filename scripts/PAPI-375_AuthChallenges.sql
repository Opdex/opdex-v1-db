DELIMITER //

CREATE PROCEDURE AuthChallenges ()
 BEGIN
        CREATE TABLE IF NOT EXISTS auth_success(
            ConnectionId       VARCHAR(255) NOT NULL,
            Signer             VARCHAR(50) NOT NULL,
            Expiry             DATETIME NOT NULL,
            PRIMARY KEY (ConnectionId)
        ) ENGINE = INNODB;
 END;
//

CALL AuthChallenges();
//

DROP PROCEDURE AuthChallenges;
//

CREATE EVENT IF NOT EXISTS remove_expired_auth_success_event
ON SCHEDULE EVERY 5 MINUTE
DO
DELETE FROM auth_success WHERE Expiry < UTC_TIMESTAMP();
//

DELIMITER ;
