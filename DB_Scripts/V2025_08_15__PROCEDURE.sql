-- ================  insert ---------------
DROP PROCEDURE IF EXISTS insert_user_with_vehicle;

DELIMITER //

CREATE PROCEDURE insert_user_with_vehicle (
    IN p_full_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_phone_number VARCHAR(15),
    IN p_password_hash VARCHAR(255),
    IN p_status ENUM('ACTIVE','INACTIVE'),
    IN p_role_name ENUM('OWNER','DRIVER','ADMIN'),
    IN p_permissions VARCHAR(255),
    IN p_vehicle_type ENUM('CAR','BIKE','TRUCK'),
    IN p_vehicle_no VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred, transaction rolled back' AS msg;
    END;

    START TRANSACTION;

    -- Step 1: Insert into users
    INSERT INTO users (full_name, email, phone_number, password_hash, status, created_at, updated_at)
    VALUES (p_full_name, p_email, p_phone_number, p_password_hash, p_status, NOW(), NOW());

    SET @uid = LAST_INSERT_ID();

    -- Step 2: Insert into user_role
    INSERT INTO user_role (user_id, role_name, permissions, assigned_at)
    VALUES (@uid, p_role_name, p_permissions, NOW());

    SET @rid = LAST_INSERT_ID();

    -- Step 3: Insert into vehicles
    INSERT INTO vehicles (user_role_id, vehicle_type, vehicle_no)
    VALUES (@rid, p_vehicle_type, p_vehicle_no);

    COMMIT;
END //

DELIMITER ;





CALL insert_user_with_vehicle(
    'Ravi Kumar',
    'ravi@example.com',
    '9876543210',
    'hashed_password',
    'ACTIVE',
    'OWNER',
    'CAN_ADD_VEHICLE',
    'CAR',
    'TS08AB1234'
);


-- Insert into vehicles table

DROP PROCEDURE IF EXISTS  insert_vehicle
DELIMITER $$

CREATE PROCEDURE insert_vehicle(
    IN p_user_role_id BIGINT UNSIGNED,
    IN p_vehicle_type ENUM('BUS','CAR','BIKE'),
    IN p_vehicle_no VARCHAR(20)
)
BEGIN
    DECLARE v_role_name VARCHAR(50);

    -- Check if user_role exists
    SELECT role_name
    INTO v_role_name
    FROM user_role
    WHERE role_id = p_user_role_id;

    -- If not found, throw an error
    IF v_role_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user_role_id';
    END IF;

    -- Check if role is OWNER
    IF v_role_name <> 'OWNER' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only OWNER role can add vehicles';
    END IF;

    -- Insert into vehicles table
    INSERT INTO vehicles (user_role_id, vehicle_type, vehicle_no)
    VALUES (p_user_role_id, p_vehicle_type, p_vehicle_no);
END$$

DELIMITER ;

--------- ended