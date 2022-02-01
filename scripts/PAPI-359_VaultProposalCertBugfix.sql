DELIMITER //

CREATE PROCEDURE VaultProposalCertificateBugFix ()
 BEGIN
    -- Disable checks
    SET FOREIGN_KEY_CHECKS = 0;

    -- Remove and correctly re-add the FK
    ALTER TABLE vault_proposal_certificate DROP FOREIGN KEY vault_proposal_certificate_cert_id_vault_cert_id_fk;
    ALTER TABLE vault_proposal_certificate ADD CONSTRAINT vault_proposal_certificate_cert_id_vault_cert_id_fk FOREIGN KEY (CertificateId) REFERENCES vault_certificate (Id);

    -- Create relationship for Created certificates
    INSERT IGNORE INTO vault_proposal_certificate
        SELECT
            p.Id AS ProposalId,
            vc.Id AS CertificateId,
            vc.CreatedBlock AS CreatedBlock,
            vc.CreatedBlock AS ModifiedBlock
        FROM vault_proposal p
        LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
        LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
        WHERE vpt.ProposalType = 'Create' AND vc.Id IS NOT NULL;

    -- Create relationship for Revoked certificates
    INSERT IGNORE INTO vault_proposal_certificate
        SELECT
            p.Id,
            vc.Id,
            p.CreatedBlock,
            p.CreatedBlock
        FROM vault_proposal p
        LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
        LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
        WHERE vpt.ProposalType = 'Revoke' AND vc.Id IS NOT NULL;

    -- Enable checks
    SET FOREIGN_KEY_CHECKS = 1;
 END;
//

CALL VaultProposalCertificateBugFix();
//

DROP PROCEDURE VaultProposalCertificateBugFix;
//

DELIMITER ;
