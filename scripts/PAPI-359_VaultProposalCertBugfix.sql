DELIMITER //

CREATE PROCEDURE VaultProposalCertificateBugFix ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM information_schema.tables
    WHERE table_schema = 'platform'
        AND table_name = 'vault_proposal_certificate';

    IF @exists > 0 THEN
        -- Drop the table
        DROP TABLE vault_proposal_certificate;

        -- Recreate it correctly
        CREATE TABLE IF NOT EXISTS vault_proposal_certificate
        (
            Id            BIGINT UNSIGNED AUTO_INCREMENT,
            ProposalId    BIGINT UNSIGNED NOT NULL,
            CertificateId BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_certificate_proposal_id_certificate_id_uq (ProposalId, CertificateId),
            CONSTRAINT vault_proposal_certificate_proposal_id_vault_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES vault_proposal (Id)
                ON DELETE CASCADE,
            CONSTRAINT vault_proposal_certificate_cert_id_vault_cert_id_fk
                FOREIGN KEY (CertificateId)
                REFERENCES vault_certificate (Id)
                ON DELETE CASCADE
        ) ENGINE=INNODB;

        SELECT COUNT(*) INTO @createsExist
        FROM vault_proposal p
        LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
        LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
        WHERE vpt.ProposalType = 'Create' AND vc.Id IS NOT NULL;

        IF @createsExist > 0 THEN
            -- Create relationship for Created certificates
            INSERT IGNORE INTO vault_proposal_certificate
                SELECT
                    p.Id AS ProposalId,
                    vc.Id AS CertificateId
                FROM vault_proposal p
                LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
                LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
                WHERE vpt.ProposalType = 'Create' AND vc.Id IS NOT NULL;
        END IF;

        SELECT COUNT(*) INTO @revokesExist
        FROM vault_proposal p
        LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
        LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
        WHERE vpt.ProposalType = 'Revoke' AND vc.Id IS NOT NULL;

        IF @revokesExist > 0 THEN
            -- Create relationship for Revoked certificates
            INSERT IGNORE INTO vault_proposal_certificate
                SELECT
                    p.Id AS ProposalId,
                    vc.Id AS CertificateId
                FROM vault_proposal p
                LEFT JOIN vault_proposal_type vpt ON vpt.ProposalType = p.ProposalTypeId
                LEFT JOIN vault_certificate vc ON vc.Amount = p.Amount AND vc.Owner = p.Wallet AND vc.VaultId = p.VaultId
                WHERE vpt.ProposalType = 'Revoke' AND vc.Id IS NOT NULL;
        END IF;
    END IF;


    -- Separate Fix for changing FK on token_chain table
    SELECT COUNT(*) INTO @indexExists
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema='platform' AND table_name='token_chain' AND index_name='token_chain_native_address_uq';

    IF @indexExists > 0 THEN

        DROP INDEX token_chain_native_address_uq ON token_chain;
        ALTER TABLE token_chain ADD INDEX token_chain_native_address_ix (NativeAddress);
    END IF;
 END;
//

CALL VaultProposalCertificateBugFix();
//

DROP PROCEDURE VaultProposalCertificateBugFix;
//

DELIMITER ;
