SELECT VERSION();
    USE easy_bus;
    

CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
   
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_email (email),
    INDEX idx_users_phone (phone_number),
    
) ENGINE=InnoDB;

-- 2. USER_PROFILE table
CREATE TABLE user_profile (
    profile_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_profile_user_id (user_id)
) ENGINE=InnoDB;

-- 3. USER_ROLE table (in case we want many-to-many roles later)
CREATE TABLE user_role (
    role_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role_name varchar(50) NOT NULL, -- --ENUM('CUSTOMER', 'DRIVER', 'ADMIN') NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`permissions` text,
	 `created_by` varchar(255) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_role_user_id (user_id),
   FULLTEXT KEY `idx_permissions` (`permissions`),
    INDEX idx_user_role_role_name (role_name)
) ENGINE=InnoDB;



-- 4. USER_PREFERENCES table
CREATE TABLE user_preferences (
    preference_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    language VARCHAR(10) DEFAULT 'EN',
    currency VARCHAR(10) DEFAULT 'USD',
    notification_enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_preferences_user_id (user_id)
) ENGINE=InnoDB;

-- 5. USER_NOTIFICATIONS table
CREATE TABLE user_notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    type ENUM('BOOKING', 'PAYMENT', 'PROMOTION', 'SYSTEM') NOT NULL,
    status ENUM('SENT', 'DELIVERED', 'READ') DEFAULT 'SENT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_notifications_user_id (user_id),
    INDEX idx_user_notifications_status (status)
) ENGINE=InnoDB;

-- 6. USER_PAYMENT_METHODS table
CREATE TABLE user_payment_methods (
    payment_method_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    type ENUM('CARD', 'UPI', 'PAYPAL', 'NETBANKING') NOT NULL,
    provider VARCHAR(100),
    account_number VARCHAR(50),
    expiry_date DATE,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_payment_methods_user_id (user_id),
    INDEX idx_user_payment_methods_type (type)
) ENGINE=InnoDB;

-- 7. USER_LOGIN_HISTORY table
CREATE TABLE user_login_history (
    login_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    device_info VARCHAR(255),
    location VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_login_history_user_id (user_id),
    INDEX idx_user_login_history_login_time (login_time)
) ENGINE=InnoDB;


CREATE TABLE permissions (
  permission_id INT(6) ZEROFILL NOT NULL AUTO_INCREMENT,
  permission_uuid BINARY(16) NOT NULL,
  permission_key  VARCHAR(255) NOT NULL,
  permission_name VARCHAR(255) NOT NULL,

  -- audit & lifecycle
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  created_by VARCHAR(255) NULL,
  updated_by VARCHAR(255) NULL,

  -- active flag for filtered unique constraint
  is_active TINYINT(1) AS (deleted_at IS NULL) VIRTUAL,

  PRIMARY KEY (permission_id),
  UNIQUE KEY uq_permission_uuid (permission_uuid),
  -- Enforce uniqueness only among active rows
  UNIQUE KEY uq_permission_key_active (permission_key, is_active),

  KEY idx_permission_key (permission_key),
  KEY idx_permission_name (permission_name),
  KEY idx_permissions_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE vehicles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_role_id  BIGINT NOT NULL,
    vehicle_type ENUM('BUS', 'CAR', 'BIKE') NOT NULL,
    vehicle_no VARCHAR(20) NOT NULL,
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    purchase_date DATE,
    created_by BIGINT UNSIGNED,
    updated_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Unique index for vehicle_no
    UNIQUE KEY uq_vehicle_no (vehicle_no),

    -- Index for faster lookups by user_role_id
    INDEX idx_user_role_id (user_role_id),

    -- Optional index for type-based filtering
    INDEX idx_vehicle_type (vehicle_type),
   -- Foreign key with cascading safety
 CONSTRAINT fk_vehicle_user_role
FOREIGN KEY (user_role_id)
REFERENCES user_role(role_id)
ON UPDATE CASCADE
ON DELETE RESTRICT
        

);

==================================== not doing below table ========================================
/*
-- PERMISSIONS AUDIT
CREATE TABLE permissions_audit (
  audit_id BIGINT NOT NULL AUTO_INCREMENT,
  event_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actor VARCHAR(255) NULL,
  permission_uuid BINARY(16) NULL,
  permission_key  VARCHAR(255) NULL,
  old_data JSON NULL,
  new_data JSON NULL,
  PRIMARY KEY (audit_id),
  KEY idx_pa_uuid (permission_uuid),
  KEY idx_pa_event_time (event_type, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ROLES AUDIT
CREATE TABLE roles_audit (
  audit_id BIGINT NOT NULL AUTO_INCREMENT,
  event_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actor VARCHAR(255) NULL,
  role_uuid BINARY(16) NULL,
  role_key  VARCHAR(255) NULL,
  old_data JSON NULL,
  new_data JSON NULL,
  PRIMARY KEY (audit_id),
  KEY idx_ra_uuid (role_uuid),
  KEY idx_ra_event_time (event_type, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ROLE_PERMISSIONS AUDIT
CREATE TABLE role_permissions_audit (
  audit_id BIGINT NOT NULL AUTO_INCREMENT,
  event_type ENUM('INSERT','DELETE') NOT NULL, -- updates are disallowed
  occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actor VARCHAR(255) NULL,
  role_uuid BINARY(16) NULL,
  permission_uuid BINARY(16) NULL,
  data JSON NULL,
  PRIMARY KEY (audit_id),
  KEY idx_rpa_role_perm (role_uuid, permission_uuid),
  KEY idx_rpa_event_time (event_type, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ROLES
CREATE TABLE roles (
  role_id INT(6) ZEROFILL NOT NULL AUTO_INCREMENT,
  role_uuid BINARY(16) NOT NULL,
  role_key  VARCHAR(255) NOT NULL,
  role_name VARCHAR(255) NOT NULL,

  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  created_by VARCHAR(255) NULL,
  updated_by VARCHAR(255) NULL,

  is_active TINYINT(1) AS (deleted_at IS NULL) VIRTUAL,

  PRIMARY KEY (role_id),
  UNIQUE KEY uq_role_uuid (role_uuid),
  UNIQUE KEY uq_role_key_active (role_key, is_active),

  KEY idx_role_key (role_key),
  KEY idx_role_name (role_name),
  KEY idx_roles_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ROLE ↔ PERMISSION (many-to-many) — immutable pairs



CREATE TABLE role_permissions (
    role_permission_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
    permission_id INT(6) ZEROFILL NOT NULL,

    -- audit & lifecycle
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    created_by VARCHAR(255) NULL,
    updated_by VARCHAR(255) NULL,

    -- active flag for filtered unique constraint
    is_active TINYINT(1) AS (deleted_at IS NULL) VIRTUAL,

    -- Relationships
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id)
        REFERENCES user_role(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id)
        REFERENCES permissions(permission_id) ON DELETE CASCADE,

    -- Prevent assigning the same permission twice to the same role (only when active)
    UNIQUE KEY uq_role_permission_active (role_id, permission_id, is_active),

    -- Indexes
    KEY idx_role_permissions_role_id (role_id),
    KEY idx_role_permissions_permission_id (permission_id),
    KEY idx_role_permissions_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;  */



-- Use InnoDB and utf8mb4
SET NAMES utf8mb4;
-- Use UTF8MB4, InnoDB for FK + transactions

SET sql_notes = 0;
-- 1) ROUTE
CREATE TABLE IF NOT EXISTS route (
  route_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
  route_uuid      BINARY(16) NOT NULL UNIQUE,     -- app-level stable id (store UUID as BIN16)
  route_number    VARCHAR(32) NOT NULL UNIQUE,
  origin_city     VARCHAR(100) NOT NULL,
  destination_city VARCHAR(100) NOT NULL,
  distance_km     DECIMAL(7,2) NOT NULL CHECK (distance_km > 0),
  estimated_minutes INT NOT NULL CHECK (estimated_minutes > 0),
  active          TINYINT(1) NOT NULL DEFAULT 1,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_route_origin_dest ON route (origin_city, destination_city);
CREATE INDEX idx_route_active ON route (active);

-- 2) SCHEDULE
CREATE TABLE IF NOT EXISTS schedule (
  schedule_id      BIGINT PRIMARY KEY AUTO_INCREMENT,
  schedule_uuid    BINARY(16) NOT NULL UNIQUE,
  route_id         BIGINT NOT NULL,
  vehicle_id       BIGINT NOT NULL,
  effective_from   DATE NOT NULL,
  effective_to     DATE DEFAULT NULL,
  departure_time   TIME NOT NULL,
  arrival_time     TIME NOT NULL,
  frequency        VARCHAR(20) NOT NULL,        -- use lookup table for production if desired
  is_active        TINYINT(1) NOT NULL DEFAULT 1,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_schedule_route
    FOREIGN KEY (route_id) REFERENCES route(route_id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_schedule_route_valid ON schedule (route_id, is_active, effective_from, effective_to);
CREATE INDEX idx_schedule_departure ON schedule (route_id, departure_time);
CREATE INDEX idx_schedule_vehicle ON schedule (vehicle_id, is_active);

-- 3) TRIP_HISTORY (no partitioning)
CREATE TABLE IF NOT EXISTS trip_history (
  trip_id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  trip_uuid          BINARY(16) NOT NULL UNIQUE,
  schedule_id        BIGINT NOT NULL,
  route_id           BIGINT NOT NULL,   -- denormalized for fast filters and reporting
  trip_date          DATE NOT NULL,
  planned_departure  DATETIME NOT NULL,
  planned_arrival    DATETIME NOT NULL,
  actual_departure   DATETIME DEFAULT NULL,
  actual_arrival     DATETIME DEFAULT NULL,
  passengers_boarded INT NOT NULL DEFAULT 0,
  passengers_alighted INT NOT NULL DEFAULT 0,
  fare_collected     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status             VARCHAR(20) NOT NULL DEFAULT 'Completed',
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_trip_schedule
    FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_trip_route
    FOREIGN KEY (route_id) REFERENCES route(route_id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_trip_route_date ON trip_history (route_id, trip_date);
CREATE INDEX idx_trip_sched_date ON trip_history (schedule_id, trip_date);
CREATE INDEX idx_trip_status_date ON trip_history (status, trip_date);
CREATE INDEX idx_trip_rev_cover ON trip_history (trip_date, route_id, fare_collected);



---------------------
SELECT * FROM easy_bus.vehicles;

ALTER TABLE vehicles
MODIFY COLUMN vehicle_type ENUM('BUS', 'CAR', 'BIKE','AUTO') NOT NULL;



ALTER TABLE vehicles 
ADD COLUMN service_type ENUM('AC', 'Non-AC', 'Sleeper', 'Semi-Sleeper', 'Seater') NOT NULL,
ADD COLUMN depot_name                 VARCHAR(100) NOT NULL, -- Which depot this bus belongs to
ADD COLUMN  registration_date DATE,                              -- 3-time location latitude
ADD COLUMN   current_lng       DECIMAL(11, 8),                      -- Real-time location longitude
ADD COLUMN  amenities         VARCHAR(255),                      -- e.g., WiFi, Water Bottle, Charging Point
ADD COLUMN   seat_capacity     INT NOT NULL,                      -- Total seats
ADD COLUMN   operator_id       BIGINT NOT NULL,                   -- Bus operator/company
ADD COLUMN  route_id          BIGINT NOT NULL,                   -- Assigned route
ADD COLUMN      status            ENUM('Active', 'On Trip','Inactive', 'Maintenance') DEFAULT 'Active',
ADD COLUMN     fuel_type            ENUM('Diesel', 'Petrol', 'CNG', 'Electric', 'Hybrid') NOT NULL,
ADD COLUMN	    insurance_valid_upto DATE,                                  -- Insurance expiry date
ADD COLUMN     last_service_date    DATE,                                  -- Last maintenance date
ADD COLUMN  next_service_due     DATE,                                  -- Next maintenance due date

ADD COLUMN    color             VARCHAR(20);                        -- Color of vehicle

-------------000012345678999999