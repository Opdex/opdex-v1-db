DELIMITER //

CREATE PROCEDURE RemoveTokenDistributionAudit ()
 BEGIN
     ALTER TABLE token_distribution DROP FOREIGN KEY token_distribution_created_block_block_height_fk;
     ALTER TABLE token_distribution DROP FOREIGN KEY token_distribution_modified_block_block_height_fk;

     ALTER TABLE token_distribution DROP COLUMN ModifiedBlock;
     ALTER TABLE token_distribution DROP COLUMN CreatedBlock;
 END;
//

CALL RemoveTokenDistributionAudit();
//

DROP PROCEDURE RemoveTokenDistributionAudit;
//

DELIMITER ;
