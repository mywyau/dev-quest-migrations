DROP TABLE IF EXISTS dev_submissions;
DROP TABLE IF EXISTS reward;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS users;

-- Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(255) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    user_type VARCHAR(50) CHECK (user_type IN ('Client', 'Dev', 'UnknownUserType')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_skills (
  id BIGSERIAL PRIMARY KEY,
  dev_id UUID REFERENCES users(user_id),
  skill TEXT NOT NULL,
  level INT NOT NULL DEFAULT 1,
  xp INT NOT NULL DEFAULT 0,
  UNIQUE (user_id, skill)
);

-- Quests table
CREATE TABLE quests (
    id BIGSERIAL PRIMARY KEY,
    quest_id VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(255) NOT NULL,
    dev_id VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    acceptance_criteria TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'NotStarted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dev_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- Quests Details table
CREATE TABLE quests_details (
    id BIGSERIAL PRIMARY KEY,
    quest_id VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(255) NOT NULL,
    dev_id VARCHAR(255),
    tags VARCHAR(255),
    tier VARCHAR(255),
    deadline TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dev_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Reward table
CREATE TABLE reward (
    id BIGSERIAL PRIMARY KEY,
    quest_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL, 
    dev_id VARCHAR(255) NOT NULL,
    base_reward NUMERIC NOT NULL,
    time_reward NUMERIC,
    completion_bonus NUMERIC,
    claimed BOOLEAN DEFAULT FALSE,
    eligible BOOLEAN DEFAULT TRUE,          -- If false, user is disqualified from reward
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quest_id) REFERENCES quests(quest_id) ON DELETE CASCADE
);

-- Dev Submissions (uploads) table
CREATE TABLE dev_submissions (
    id BIGSERIAL PRIMARY KEY,
    client_id VARCHAR(255) NOT NULL,
    dev_id VARCHAR(255) NOT NULL,
    quest_id VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type TEXT,
    file_size BIGINT,
    s3_object_key TEXT NOT NULL UNIQUE,
    bucket_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ,
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (dev_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (quest_id) REFERENCES quests(quest_id) ON DELETE CASCADE
);

