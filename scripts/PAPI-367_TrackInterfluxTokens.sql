DELIMITER //

CREATE PROCEDURE TrackInterfluxTokens ()
 BEGIN
     INSERT INTO platform.transaction_log_type (Id, LogType)
         VALUES
             (33, 'OwnershipTransferredLog'),
             (34, 'SupplyChangeLog');
 END;
//

CALL TrackInterfluxTokens();
//

DROP PROCEDURE TrackInterfluxTokens;
//

DELIMITER ;
