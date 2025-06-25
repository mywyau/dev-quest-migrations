DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS stripe_accounts;
DROP TABLE IF EXISTS skill;
DROP TABLE IF EXISTS language;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS reward;
DROP TABLE IF EXISTS dev_submissions;


-- Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE,
    username VARCHAR(50),
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    user_type VARCHAR(50) CHECK (user_type IN ('Client', 'Dev', 'UnknownUserType')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stripe_accounts (
  id BIGSERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL UNIQUE,
  stripe_account_id VARCHAR(255) NOT NULL UNIQUE,
  onboarded BOOLEAN DEFAULT FALSE,
  charges_enabled BOOLEAN DEFAULT FALSE,
  payouts_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE skill (
  id BIGSERIAL PRIMARY KEY,
  dev_id VARCHAR(255),
  username VARCHAR(50),
  skill VARCHAR(255),
  level INT NOT NULL DEFAULT 1 CHECK (level >= 1 AND level <= 99),
  xp DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT unique_dev_skill UNIQUE (dev_id, skill),
  FOREIGN KEY (dev_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE language (
  id BIGSERIAL PRIMARY KEY,
  dev_id VARCHAR(255),
  username VARCHAR(50),
  language VARCHAR(255),
  level INT NOT NULL DEFAULT 1 CHECK (level >= 1 AND level <= 99),
  xp DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT unique_dev_language UNIQUE (dev_id, language),
  FOREIGN KEY (dev_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- Quests table
CREATE TABLE quests (
    id BIGSERIAL PRIMARY KEY,
    quest_id VARCHAR(255) NOT NULL UNIQUE,
    client_id VARCHAR(255) NOT NULL,
    dev_id VARCHAR(255),
    rank VARCHAR(50),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    acceptance_criteria TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'NotStarted',
    tags TEXT[],
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
    dev_id VARCHAR(255),
    reward_value NUMERIC,
    paid VARCHAR(50) DEFAULT 'NotPaid',
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

CREATE TABLE quest_estimations (
  id BIGSERIAL PRIMARY KEY,
  estimate_id VARCHAR(255) NOT NULL,
  quest_id VARCHAR(255) NOT NULL REFERENCES quests(quest_id) ON DELETE CASCADE,
  dev_id VARCHAR(255) NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  username VARCHAR(50),
  rank VARCHAR(50),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (quest_id, dev_id) -- Each dev can vote once per quest
);


