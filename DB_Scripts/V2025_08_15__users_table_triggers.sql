--user  TRIGGER emial validations 

DROP TRIGGER IF EXISTS trg_users_email_bi;

DELIMITER $$

CREATE TRIGGER trg_users_email_bi
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_msg VARCHAR(300);

    SELECT COUNT(*) INTO v_cnt
    FROM users
    WHERE email = NEW.email;

    IF v_cnt > 0 THEN
        SET v_msg = CONCAT('Email already exists: ', NEW.email);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS trg_users_email_bu

DELIMITER $$

CREATE TRIGGER trg_users_email_bu
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_msg VARCHAR(300);

    -- Only check if email is changing
    IF NEW.email <> OLD.email THEN
        SELECT COUNT(*) INTO v_cnt
        FROM users
        WHERE email = NEW.email
          AND user_id <> NEW.user_id;  -- exclude this row

        IF v_cnt > 0 THEN
            SET v_msg = CONCAT('Email already exists: ', NEW.email);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
        END IF;
    END IF;
END$$

DELIMITER ;

---user ended 



DROP TRIGGER IF EXISTS  trg_vehicle_owner_only
DELIMITER $$

CREATE TRIGGER trg_vehicle_owner_only
BEFORE INSERT ON vehicles
FOR EACH ROW
BEGIN
    DECLARE role_val VARCHAR(50);

    -- Try to fetch the role from user_role
    SELECT role_name
    INTO role_val
    FROM user_role
    WHERE role_id = NEW.user_role_id
    LIMIT 1;

    -- If no role found, block insert
    IF role_val IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user_role_id — no such role exists';
    END IF;

    -- If role is not OWNER, block insert
    IF role_val <> 'OWNER' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only OWNER role can add vehicles';
    END IF;
END$$

DELIMITER ;
