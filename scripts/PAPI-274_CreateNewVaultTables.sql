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
        AND table_name = 'vault_proposal';

    SELECT COUNT(*) into @proposalPledgeExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_proposal_pledge';

    SELECT COUNT(*) into @proposalStatusExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_proposal_status';

    SELECT COUNT(*) into @proposalTypeExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_proposal_type';

    SELECT COUNT(*) into @proposalVoteExists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE table_schema = 'platform'
        AND table_name = 'vault_proposal_vote';

    IF NOT @newVaultExists THEN
        CREATE TABLE IF NOT EXISTS vault_governance
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            TokenId             BIGINT UNSIGNED NOT NULL,
            Address             VARCHAR(50)     NOT NULL,
            UnassignedSupply    VARCHAR(78)     NOT NULL,
            VestingDuration     BIGINT UNSIGNED NOT NULL,
            ProposedSupply      VARCHAR(78)     NOT NULL,
            TotalPledgeMinimum  BIGINT UNSIGNED NOT NULL,
            TotalVoteMinimum    BIGINT UNSIGNED NOT NULL,
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
            VaultId             BIGINT UNSIGNED NOT NULL,
            Owner               VARCHAR(50)     NOT NULL,
            Amount              VARCHAR(78)     NOT NULL,
            Revoked             BIT             NOT NULL,
            Redeemed            BIT             NOT NULL,
            VestedBlock         BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_governance_certificate_owner_ix (Owner),
            INDEX vault_governance_certificate_redeemed_ix (Redeemed),
            INDEX vault_governance_certificate_revoked_ix (Revoked),
            INDEX vault_governance_certificate_vested_block_ix (VestedBlock),
            CONSTRAINT vault_governance_certificate_vault_governance_id_vault_id_fk
                FOREIGN KEY (VaultId)
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
        CREATE TABLE IF NOT EXISTS vault_proposal_status
        (
            Id              SMALLINT UNSIGNED   NOT NULL,
            ProposalStatus  VARCHAR(50)         NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_status_proposal_status_uq (ProposalStatus)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO vault_proposal_status(Id, ProposalStatus)
        VALUES
            (1, 'Pledge'),
            (2, 'Vote'),
            (3, 'Complete');
    END IF;

    IF NOT @proposalTypeExists THEN
        CREATE TABLE IF NOT EXISTS vault_proposal_type
        (
            Id           SMALLINT UNSIGNED  NOT NULL,
            ProposalType VARCHAR(50)        NOT NULL,
            PRIMARY KEY (Id),
            UNIQUE vault_proposal_type_proposal_type_uq (ProposalType)
        ) ENGINE=INNODB;

        INSERT IGNORE INTO vault_proposal_type(Id, ProposalType)
        VALUES
            (1, 'Create'),
            (2, 'Revoke'),
            (3, 'TotalPledgeMinimum'),
            (4, 'TotalVoteMinimum');
    END IF;

    IF NOT @proposalExists THEN
        CREATE TABLE IF NOT EXISTS vault_proposal
        (
            Id                  BIGINT UNSIGNED   AUTO_INCREMENT,
            PublicId            BIGINT UNSIGNED   NOT NULL,
            VaultGovernanceId   BIGINT UNSIGNED   NOT NULL,
            Creator             VARCHAR(50)       NOT NULL,
            Wallet              VARCHAR(50)       NOT NULL,
            Amount              VARCHAR(78)       NOT NULL,
            Description         VARCHAR(200)      NOT NULL,
            ProposalTypeId      SMALLINT UNSIGNED NOT NULL,
            ProposalStatusId    SMALLINT UNSIGNED NOT NULL,
            Expiration          BIGINT UNSIGNED   NOT NULL,
            YesAmount           BIGINT UNSIGNED   NOT NULL,
            NoAmount            BIGINT UNSIGNED   NOT NULL,
            PledgeAmount        BIGINT UNSIGNED   NOT NULL,
            CreatedBlock        BIGINT UNSIGNED   NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED   NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_public_id_ix (PublicId),
            INDEX vault_proposal_creator_ix (Creator),
            INDEX vault_proposal_wallet_ix (Wallet),
            INDEX vault_proposal_expiration_ix (Expiration),
            CONSTRAINT vault_proposal_vault_governance_id_vault_governance_id
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT vault_proposal_proposal_type_id_proposal_type_id_fk
                FOREIGN KEY (ProposalTypeId)
                REFERENCES proposal_type (Id),
            CONSTRAINT vault_proposal_proposal_status_id_proposal_status_id_fk
                FOREIGN KEY (ProposalStatusId)
                REFERENCES proposal_status (Id),
            CONSTRAINT vault_proposal_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @proposalPledgeExists THEN
        CREATE TABLE IF NOT EXISTS vault_proposal_pledge
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultGovernanceId   BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Pledger             VARCHAR(50)     NOT NULL,
            Pledge              BIGINT UNSIGNED NOT NULL,
            Balance             BIGINT UNSIGNED NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_pledge_pledger_ix (Pledger),
            INDEX vault_proposal_pledge_pledge_ix (Pledge),
            UNIQUE vault_proposal_pledge_vault_governance_id_proposal_id_pledger_uq (VaultGovernanceId, ProposalId, Pledger),
            CONSTRAINT vault_proposal_pledge_vault_governance_id_vault_governance_id_fk
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT vault_proposal_pledge_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES proposal (Id),
            CONSTRAINT vault_proposal_pledge_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_pledge_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    IF NOT @proposalVoteExists THEN
        CREATE TABLE IF NOT EXISTS vault_proposal_vote
        (
            Id                  BIGINT UNSIGNED AUTO_INCREMENT,
            VaultGovernanceId   BIGINT UNSIGNED NOT NULL,
            ProposalId          BIGINT UNSIGNED NOT NULL,
            Voter               VARCHAR(50)     NOT NULL,
            Vote                BIGINT UNSIGNED NOT NULL,
            Balance             BIGINT UNSIGNED NOT NULL,
            InFavor             BIT             NOT NULL,
            CreatedBlock        BIGINT UNSIGNED NOT NULL,
            ModifiedBlock       BIGINT UNSIGNED NOT NULL,
            PRIMARY KEY (Id),
            INDEX vault_proposal_vote_voter_ix (Voter),
            INDEX vault_proposal_vote_vote_ix (Vote),
            INDEX vault_proposal_vote_in_favor_ix (InFavor),
            UNIQUE vault_proposal_vote_vault_governance_id_proposal_id_voter_uq (VaultGovernanceId, ProposalId, Voter),
            CONSTRAINT vault_proposal_vote_vault_governance_id_vault_governance_id_fk
                FOREIGN KEY (VaultGovernanceId)
                REFERENCES vault_governance (Id),
            CONSTRAINT vault_proposal_vote_proposal_id_proposal_id_fk
                FOREIGN KEY (ProposalId)
                REFERENCES proposal (Id),
            CONSTRAINT vault_proposal_vote_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height),
            CONSTRAINT vault_proposal_vote_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height)
        ) ENGINE=INNODB;
    END IF;

    INSERT IGNORE INTO transaction_log_type(Id, LogType)
    VALUES
        (29, 'CreateVaultProposalLog'),
        (30, 'CompleteVaultProposalLog'),
        (31, 'VaultProposalPledgeLog'),
        (32, 'VaultProposalPledgeWithdrawLog'),
        (33, 'VaultProposalVoteLog'),
        (34, 'VaultProposalVoteWithdrawLog');

 END;
//

CALL CreateNewVaultTables();
//

DROP PROCEDURE CreateNewVaultTables;
//

DELIMITER ;
