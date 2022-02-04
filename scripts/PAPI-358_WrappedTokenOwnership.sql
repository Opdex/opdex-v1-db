DELIMITER //

CREATE PROCEDURE CreateWrappedTokenOwnership ()
 BEGIN
    SELECT COUNT(*) into @tokenChainOwnershipExists
    FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = 'platform'
        AND table_name = 'token_chain'
        AND column_name='Owner';

    SELECT COUNT(*) into @tokenChainCreatedBlockExists
    FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = 'platform'
        AND table_name = 'token_chain'
        AND column_name='CreatedBlock';

    SELECT COUNT(*) into @tokenChainModifiedBlockExists
    FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = 'platform'
        AND table_name = 'token_chain'
        AND column_name='ModifiedBlock';

    IF NOT @tokenChainOwnershipExists THEN
        ALTER TABLE token_chain ADD COLUMN Owner VARCHAR(50) NOT NULL AFTER TokenId;
    END IF;

    IF NOT @tokenChainCreatedBlockExists THEN
        ALTER TABLE token_chain ADD COLUMN CreatedBlock BIGINT UNSIGNED NOT NULL;
        ALTER TABLE token_chain ADD CONSTRAINT token_wrapped_created_block_block_height_fk
                FOREIGN KEY (CreatedBlock)
                REFERENCES block (Height);
    END IF;

    IF NOT @tokenChainModifiedBlockExists THEN
        ALTER TABLE token_chain ADD COLUMN ModifiedBlock BIGINT UNSIGNED NOT NULL;
        ALTER TABLE token_chain ADD CONSTRAINT token_wrapped_modified_block_block_height_fk
                FOREIGN KEY (ModifiedBlock)
                REFERENCES block (Height);
    END IF;

    ALTER TABLE token_chain DROP FOREIGN KEY token_chain_token_id_token_id_fk;
    ALTER TABLE token_chain DROP FOREIGN KEY token_chain_native_chain_type_id_chain_type_id_fk;
    ALTER TABLE token_chain DROP INDEX token_chain_token_id_uq;
    ALTER TABLE token_chain DROP INDEX token_chain_native_address_ix;

    ALTER TABLE token_chain ADD INDEX token_wrapped_native_address_ix (NativeAddress);
    ALTER TABLE token_chain ADD CONSTRAINT token_wrapped_token_id_uq UNIQUE (TokenId);
    ALTER TABLE token_chain ADD CONSTRAINT token_wrapped_token_id_token_id_fk
                FOREIGN KEY (TokenId)
                REFERENCES token (Id) ON DELETE CASCADE;
    ALTER TABLE token_chain ADD CONSTRAINT token_wrapped_native_chain_type_id_chain_type_id_fk
                FOREIGN KEY (NativeChainTypeId)
                REFERENCES chain_type (Id);

    ALTER TABLE token_chain RENAME token_wrapped;
 END;
//

CALL CreateWrappedTokenOwnership();
//

DROP PROCEDURE CreateWrappedTokenOwnership;
//

DELIMITER ;
