CREATE TABLE IF NOT EXISTS users (
    id serial PRIMARY KEY,
    username varchar(50) NOT NULL UNIQUE,
    email varchar(100) NOT NULL UNIQUE,
    password_hash varchar(255) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS roles (
    id serial PRIMARY KEY,
    name varchar(50) NOT NULL UNIQUE,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id int NOT NULL,
    role_id int NOT NULL,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS teams (
    id serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS team_roles (
    id serial PRIMARY KEY,
    name varchar(50) NOT NULL UNIQUE,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_teams (
    user_id int NOT NULL,
    team_id int NOT NULL,
    role_team int,
    joined_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, team_id),
    CONSTRAINT fk_user_teams_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_teams_team FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_teams_team_role FOREIGN KEY (role_team) REFERENCES team_roles (id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS contests (
    id serial PRIMARY KEY,
    title varchar(150) NOT NULL,
    description text,
    start_date timestamptz NOT NULL,
    end_date timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS team_contests (
    team_id int NOT NULL,
    contest_id int NOT NULL,
    registered_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, contest_id),
    CONSTRAINT fk_team_contests_team FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
    CONSTRAINT fk_team_contests_contest FOREIGN KEY (contest_id) REFERENCES contests (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_team_contests (
    user_id int NOT NULL,
    team_id int NOT NULL,
    contest_id int NOT NULL,
    step_count int NOT NULL DEFAULT 0,
    participation_status varchar(50) NOT NULL,
    participated_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, team_id, contest_id),
    CONSTRAINT fk_utc_user_team FOREIGN KEY (user_id, team_id) REFERENCES user_teams (user_id, team_id) ON DELETE CASCADE,
    CONSTRAINT fk_utc_contest FOREIGN KEY (contest_id) REFERENCES contests (id) ON DELETE CASCADE
);

-- Indexes supplémentaires (si besoin)
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at);
CREATE INDEX IF NOT EXISTS idx_teams_created_at ON teams (created_at);
CREATE INDEX IF NOT EXISTS idx_contests_start_date ON contests (start_date);

-- Data insertion
INSERT INTO roles (name, description) VALUES
('admin', 'Administrator with full access'),
('user', 'Regular user with limited access');

INSERT INTO TeamRoles (name, description) VALUES
('leader', 'Team leader with management privileges'),
('member', 'Regular team member');

INSERT INTO Teams (name) VALUES
('Alpha Team'),
('Beta Team');

INSERT INTO Contests (title, description, start_date, end_date) VALUES
('Spring Challenge', 'A contest to welcome the spring season', '2024-03-01 00:00:00', '2024-03-31 23:59:59'),
('Summer Showdown', 'A summer-themed contest for all teams', '2024-06-01 00:00:00', '2024-06-30 23:59:59');

INSERT INTO Users (username, email, password_hash) VALUES
('john_doe', 'johndoe@example.com', 'hashed_password_here');
INSERT INTO Users (username, email, password_hash) VALUES
('jane_smith', 'janesmith@example.com', 'hashed_password_here');
INSERT INTO Users (username, email, password_hash) VALUES
('alice_wonder', 'alicewonder@example.com', 'hashed_password_here');

INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1),  -- john_doe as admin
(2, 2),  -- jane_smith as user
(3, 2);  -- alice_wonder as user

INSERT INTO user_teams (user_id, team_id, role_team) VALUES
(1, 1, 1),  -- john_doe as leader of Alpha Team
(2, 1, 2),  -- jane_smith as member of Alpha Team
(3, 2, 1);  -- alice_wonder as leader of Beta Team

INSERT INTO team_contests (team_id, contest_id) VALUES
(1, 1),  -- Alpha Team in Spring Challenge
(2, 2);  -- Beta Team in Summer Showdown

INSERT INTO user_team_contests (user_id, team_id, contest_id, step_count, participation_status, participated_at) VALUES
(1, 1, 1, 10000, 'completed', '2024-03-15 10:00:00'),  -- john_doe in Spring Challenge
(2, 1, 1, 8000, 'completed', '2024-03-16 11:00:00'),   -- jane_smith in Spring Challenge
(3, 2, 2, 12000, 'completed', '2024-06-20 09:30:00'),  -- alice_wonder in Summer Showdown
(1, 1, 1, 5000, 'in_progress', NULL),                  -- john_doe still in Spring Challenge
(2, 1, 1, 3000, 'in_progress', NULL),                  -- jane_smith still in Spring Challenge
(3, 2, 2, 7000, 'in_progress', NULL);                  -- alice_wonder still in Summer Showdown
