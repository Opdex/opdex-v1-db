DELIMITER //

CREATE PROCEDURE CreateNewVaultTables ()
 BEGIN
    SELECT COUNT(*) into @newVaultExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_governance';

    SELECT COUNT(*) into @newVaultCertificateExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_governance_certificate';

    SELECT COUNT(*) into @proposalExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'proposal';

    SELECT COUNT(*) into @proposalPledgeExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'proposal_pledge';

    SELECT COUNT(*) into @proposalStatusExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'proposal_status';

    SELECT COUNT(*) into @proposalTypeExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'proposal_type';

    SELECT COUNT(*) into @proposalVoteExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'proposal_vote';

    IF NOT @newVaultExists THEN
        CREATE TABLE IF NOT EXISTS vault_governance
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId             BIGINT UNSIGNED NOT NULL,
            Address             VARCHAR(50)     NOT NULL,
            UnassignedSupply    VARCHAR(78)     NOT NULL,
            VestingDuration     BIGINT UNSIGNED NOT NULL,
            ProposedSupply      VARCHAR(78)     NOT NULL,
            PledgeMinimum       BIGINT UNSIGNED NOT NULL,
            ProposalMinimum     BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_governance_address_uq (Address),
            CONSTRAINT vault_governance_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id),
            CONSTRAINT vault_governance_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_governance_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @newVaultCertificateExists THEN
        CREATE TABLE IF NOT EXISTS vault_governance_certificate
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultGovernanceId   BIGINT UNSIGNED NOT NULL,
            Owner               VARCHAR(50)     NOT NULL,
            Amount              VARCHAR(78)     NOT NULL,
            Revoked             BIT             NOT NULL,
            VestedBlock         BIGINT UNSIGNED NOT NULL,
            Redeemed            BIT             NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_governance_certificate_vault_governance_id_owner_uq (VaultGovernanceId, Owner),
            CONSTRAINT vault_governance_certificate_vault_governance_id_vault_governance_id_fk
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT vault_governance_certificate_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_governance_certificate_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @proposalStatusExists THEN
        CREATE TABLE IF NOT EXISTS proposal_status
        (
            Id              SMALLINT UNSIGNED   NOT NULL,
            ProposalStatus  VARCHAR(50)         NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE proposal_status_proposal_status_uq (ProposalStatus)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO proposal_status(Id, ProposalStatus)
        VALUES
            (1, 'Pledge'),
            (2, 'Vote'),
            (3, 'Complete');
    END IF;

    IF NOT @proposalTypeExists THEN
        CREATE TABLE IF NOT EXISTS proposal_type
        (
            Id           SMALLINT UNSIGNED  NOT NULL,
            ProposalType VARCHAR(50)        NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE proposal_type_proposal_type_uq (ProposalType)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO proposal_type(Id, ProposalType)
        VALUES
            (1, 'Create'),
            (2, 'Revoke'),
            (3, 'PledgeMinimum'),
            (4, 'ProposalMinimum');
    END IF;

    IF NOT @proposalExists THEN
        CREATE TABLE IF NOT EXISTS proposal
        (
            Id                  BIGINT UNSIGNED   AUTO_INCREMENT,
            Wallet              VARCHAR(50)       NOT NULL,
            Amount              VARCHAR(78)       NOT NULL,
            Description         VARCHAR(200)      NOT NULL,
            ProposalTypeId      SMALLINT UNSIGNED NOT NULL,
            ProposalStatusId    SMALLINT UNSIGNED NOT NULL,
            Expiration          BIGINT UNSIGNED   NOT NULL,
            YesAmount           BIGINT UNSIGNED   NOT NULL,
            NoAmount            BIGINT UNSIGNED   NOT NULL,
            CreatedBlock        BIGINT UNSIGNED   NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED   NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE proposal_wallet_uq (Wallet),
            CONSTRAINT proposal_proposal_type_id_proposal_type_id_fk
                FOREIGN KEY (ProposalTypeId)
                REFERENCES proposal_type (Id),
            CONSTRAINT proposal_proposal_status_id_proposal_status_id_fk
                FOREIGN KEY (ProposalStatusId)
                REFERENCES proposal_status (Id),
            CONSTRAINT proposal_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT proposal_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @proposalPledgeExists THEN
        CREATE TABLE IF NOT EXISTS proposal_pledge
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultGovernanceId   BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Pledger             VARCHAR(50)     NOT NULL,
            Amount              VARCHAR(78)     NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE proposal_pledge_vault_governance_id_proposal_id_pledger_uq (VaultGovernanceId, ProposalId, Pledger),
            CONSTRAINT proposal_pledge_vault_governance_id_vault_governance_id_fk
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT proposal_pledge_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES proposal (Id),
            CONSTRAINT proposal_pledge_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT proposal_pledge_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @proposalVoteExists THEN
        CREATE TABLE IF NOT EXISTS proposal_vote
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultGovernanceId   BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Voter               VARCHAR(50)     NOT NULL,
            Amount              VARCHAR(78)     NOT NULL,
            InFavor             BIT             NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE proposal_vote_vault_governance_id_proposal_id_voter_uq (VaultGovernanceId, ProposalId, Voter),
            CONSTRAINT proposal_vote_vault_governance_id_vault_governance_id_fk
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT proposal_vote_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES proposal (Id),
            CONSTRAINT proposal_vote_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT proposal_vote_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;
 END;
//

CALL CreateNewVaultTables();
//

DROP PROCEDURE CreateNewVaultTables;
//

DELIMITER ;
