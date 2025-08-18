/**********************************************************************
 Script Name  : users_and_roles_demo.sql
 Description  : Inserts sample data into users & user_role tables,
                applies updates in a transaction, and provides rollback.
 Author       : Bharath
 Created On   : 2025-08-18
**********************************************************************/

-- ================================================================
-- 1. INSERT SAMPLE USERS
-- ================================================================
INSERT INTO users (full_name, email, phone_number, password_hash, status)
VALUES
('Alice Johnson', 'alice.johnson@example.com', '+919876543210', 'hash_pw_123', 'ACTIVE'),
('Bob Smith', 'bob.smith@example.com', '+919812345678', 'hash_pw_456', 'INACTIVE'),
('Charlie Brown', 'charlie.brown@example.com', '+919811122233', 'hash_pw_789', 'ACTIVE'),
('Diana Prince', 'diana.prince@example.com', '+919822233344', 'hash_pw_abc', 'BLOCKED'),
('Ethan Hunt', 'ethan.hunt@example.com', '+919833344455', 'hash_pw_def', 'ACTIVE');

-- ================================================================
-- 2. INSERT SAMPLE USER ROLES (linked with users)
-- ================================================================
INSERT INTO user_role (user_id, role_name, permissions, created_by, updated_by)
VALUES
(1, 'ADMIN', 'CREATE,READ,UPDATE,DELETE', 'system', 'system'),
(2, 'MANAGER', 'READ,UPDATE', 'system', 'system'),
(3, 'DEVELOPER', 'READ,COMMIT,CODE_PUSH', 'system', 'system'),
(4, 'TESTER', 'READ,EXECUTE_TESTS,REPORT_BUGS', 'system', 'system'),
(5, 'INTERN', 'READ', 'system', 'system');

-- ================================================================
-- 3. TRANSACTION-SAFE UPDATE SCRIPT
-- ================================================================
START TRANSACTION;

-- USERS table updates
UPDATE users 
SET phone_number = '+919899998888'
WHERE email = 'bob.smith@example.com';

UPDATE users 
SET status = 'ACTIVE'
WHERE email = 'diana.prince@example.com';

UPDATE users 
SET full_name = 'Charles Brown'
WHERE email = 'charlie.brown@example.com';

UPDATE users 
SET password_hash = 'hash_pw_new123'
WHERE email = 'alice.johnson@example.com';

UPDATE users 
SET status = 'INACTIVE'
WHERE email = 'ethan.hunt@example.com';

-- USER_ROLE table updates
UPDATE user_role
SET permissions = 'READ,COMMIT,CODE_PUSH,DEPLOY', updated_by = 'admin'
WHERE role_name = 'DEVELOPER' AND user_id = 3;

UPDATE user_role
SET role_name = 'TRAINEE', updated_by = 'admin'
WHERE role_name = 'INTERN' AND user_id = 5;

UPDATE user_role
SET role_name = 'SENIOR_TESTER',
    permissions = 'READ,EXECUTE_TESTS,REPORT_BUGS,APPROVE_RELEASES',
    updated_by = 'lead_manager'
WHERE role_name = 'TESTER' AND user_id = 4;

-- If all good
COMMIT;

-- If something goes wrong
-- ROLLBACK;


-- ================================================================
-- 4. TRANSACTION-SAFE ROLLBACK SCRIPT
-- ================================================================
START TRANSACTION;

-- USERS table rollbacks
UPDATE users 
SET phone_number = '+919812345678'
WHERE email = 'bob.smith@example.com';

UPDATE users 
SET status = 'BLOCKED'
WHERE email = 'diana.prince@example.com';

UPDATE users 
SET full_name = 'Charlie Brown'
WHERE email = 'charlie.brown@example.com';

UPDATE users 
SET password_hash = 'hash_pw_123'
WHERE email = 'alice.johnson@example.com';

UPDATE users 
SET status = 'ACTIVE'
WHERE email = 'ethan.hunt@example.com';

-- USER_ROLE table rollbacks
UPDATE user_role
SET permissions = 'READ,COMMIT,CODE_PUSH', updated_by = 'system'
WHERE role_name = 'DEVELOPER' AND user_id = 3;

UPDATE user_role
SET role_name = 'INTERN', updated_by = 'system'
WHERE role_name = 'TRAINEE' AND user_id = 5;

UPDATE user_role
SET role_name = 'TESTER',
    permissions = 'READ,EXECUTE_TESTS,REPORT_BUGS',
    updated_by = 'system'
WHERE role_name = 'SENIOR_TESTER' AND user_id = 4;

COMMIT;

-- ================================================================
-- END OF SCRIPT
-- ================================================================



START TRANSACTION;

UPDATE user_role
SET role_name = 'EDITOR',
    updated_by = 'audit_script'
WHERE user_id = 2 AND role_name = 'ADMIN';

-- If something goes wrong
-- ROLLBACK;

COMMIT;

------------------ PROCEDURE ----------
DELIMITER $$

CREATE PROCEDURE sp_update_user_role(
    IN p_user_id BIGINT,
    IN p_new_role VARCHAR(50),
    IN p_updated_by VARCHAR(255)
)
BEGIN
    UPDATE user_role
    SET role_name = p_new_role,
        updated_by = p_updated_by
    WHERE user_id = p_user_id;
END$$

DELIMITER ;

-- Call the procedure
CALL sp_update_user_role(3, 'MANAGER', 'hr_admin');








-------------- PROCEDURE for user and role-----------
DELIMITER $$

CREATE PROCEDURE sp_update_user_and_role(
    IN p_user_id BIGINT,
    IN p_new_role VARCHAR(50),
    IN p_updated_by VARCHAR(255),
    IN p_new_status VARCHAR(50)
)
BEGIN
    -- Start transaction to ensure both updates succeed together
    START TRANSACTION;

    -- Update user_role table
    UPDATE user_role
    SET role_name = p_new_role,
        updated_by = p_updated_by
    WHERE user_id = p_user_id;

    -- Update user table
    UPDATE user
    SET status = p_new_status,
        updated_by = p_updated_by,
        updated_at = NOW()
    WHERE id = p_user_id;

    COMMIT;
END$$

DELIMITER ;


CALL sp_update_user_and_role(101, 'MANAGER', 'admin_script', 'ACTIVE');
