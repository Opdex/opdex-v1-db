DELIMITER //

CREATE PROCEDURE UTF16ProposalDescription()
 BEGIN
    SELECT COUNT(*) into @descriptionExistsOnVaultProposal
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='vault_proposal'
        AND column_name='Description';

    IF @descriptionExistsOnVaultProposal THEN
        ALTER TABLE vault_proposal
            MODIFY Description varchar(200) CHARACTER SET utf16 NOT NULL COLLATE utf16_general_ci;
    END IF;
 END;
//

CALL UTF16ProposalDescription();
//

DROP PROCEDURE UTF16ProposalDescription;
//

DELIMITER ;