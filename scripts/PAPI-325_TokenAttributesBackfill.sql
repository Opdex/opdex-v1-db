DELIMITER //

CREATE PROCEDURE TokenAttributesBackfill ()
 BEGIN
    SELECT COUNT(*) into @exists
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA='platform'
        AND TABLE_NAME='token'
        AND column_name='IsLpt';

    IF @exists > 0 THEN
        ALTER TABLE token_attribute MODIFY Id BIGINT UNSIGNED AUTO_INCREMENT;

        INSERT IGNORE INTO token_attribute(TokenId, AttributeTypeId)
            (
                SELECT Id, (SELECT Id  FROM token_attribute_type WHERE AttributeType = 'Provisional') as AttributeTypeId
                FROM token
                WHERE IsLpt = true
            );

        INSERT IGNORE INTO token_attribute(TokenId, AttributeTypeId)
            (
                SELECT Id, (SELECT Id  FROM token_attribute_type WHERE AttributeType = 'NonProvisional') as AttributeTypeId
                FROM token
                WHERE IsLpt = false
            );

        INSERT IGNORE INTO token_attribute(TokenId, AttributeTypeId)
            (
                SELECT StakingTokenId as Id, (SELECT Id  FROM token_attribute_type WHERE AttributeType = 'Staking') as AttributeTypeId
                FROM market
                WHERE StakingTokenId > 0
            );

        ALTER TABLE token DROP COLUMN IsLpt;
    END IF;
 END;
//

CALL TokenAttributesBackfill();
//

DROP PROCEDURE TokenAttributesBackfill;
//

DELIMITER ;
