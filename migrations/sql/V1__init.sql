DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS reward;

CREATE TABLE users (
    user_id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    user_type VARCHAR(50) CHECK (user_type IN ('Client', 'Dev', 'UnknownUserType')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quests table
CREATE TABLE quests (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    quest_id VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'NotStarted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reward table
CREATE TABLE reward (
    id BIGSERIAL PRIMARY KEY,
    quest_id BIGINT NOT NULL REFERENCES quests(id),
    base_reward NUMERIC NOT NULL,
    time_reward NUMERIC NOT NULL,
    completion_reward NUMERIC NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
