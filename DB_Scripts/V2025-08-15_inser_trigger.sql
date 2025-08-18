INSERT INTO users (user_id, full_name, email, phone_number, password_hash, status, created_at, updated_at)
VALUES (6, 'John Owner', 'john@example.com', '9999999999', 'hashed_password', 'ACTIVE', NOW(), NOW());

-- Step 2: Assign OWNER role to user
INSERT INTO user_role (role_id, user_id, role_name)
VALUES (6, 6, 'OWNER');

-- Step 3: Insert vehicle for OWNER
INSERT INTO vehicles (id, user_role_id, vehicle_type, vehicle_no)
VALUES (1001, 6, 'BUS', 'KA01AB1234');


INSERT INTO users (user_id, full_name, email, phone_number, password_hash, status, created_at, updated_at)
VALUES (7, 'Mike Driver', 'mike@example.com', '8888888888', 'hashed_password', 'ACTIVE', NOW(), NOW());

INSERT INTO user_role (role_id, user_id, role_name)
VALUES (7, 7, 'DRIVER');

INSERT INTO vehicles (id, user_role_id, vehicle_type, vehicle_no)
VALUES (1002, 7, 'BUS', 'KA05CD5678'); -- ❌ This should trigger error: Only OWNER role can add vehicles




-- Insert a user
INSERT INTO users (full_name, email, phone_number, password_hash)
VALUES ('Test User', 'dup@example.com', '99999999', 'hash');

-- Try inserting duplicate email -> should raise your custom error
INSERT INTO users (full_name, email, phone_number, password_hash)
VALUES ('Another', 'dup@example.com', '888888888', 'hash');

-- Try updating another user to the same email -> should raise error
INSERT INTO users (full_name, email, phone_number, password_hash)
VALUES ('Third', 'third@example.com', '7777777777', 'hash');

UPDATE users
SET email = 'dup@example.com'
WHERE email = 'third@example.com';
