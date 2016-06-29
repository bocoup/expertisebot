CREATE TABLE slack_team (
  id SERIAL PRIMARY KEY,
  token TEXT NOT NULL UNIQUE CHECK(token <> ''),
  slack_id TEXT NOT NULL,
  oauth_payload JSONB,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON slack_team
  FOR EACH ROW EXECUTE PROCEDURE updated_at();

CREATE TABLE slack_user (
  id SERIAL PRIMARY KEY,
  slack_id TEXT NOT NULL UNIQUE CHECK(slack_id <> ''),
  slack_team_id INTEGER NOT NULL REFERENCES slack_team(id),
  is_active BOOLEAN NOT NULL DEFAULT false,
  meta JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON slack_user
  FOR EACH ROW EXECUTE PROCEDURE updated_at();

CREATE TABLE expertise_category (
  id SERIAL PRIMARY KEY,
  parent_id INTEGER REFERENCES expertise_category(id),
  name TEXT NOT NULL CHECK(name <> ''),
  slack_team_id INTEGER NOT NULL REFERENCES slack_team(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON expertise_category
  FOR EACH ROW EXECUTE PROCEDURE updated_at();

CREATE TABLE expertise (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL CHECK(name <> ''),
  description TEXT,
  expertise_category_id INTEGER NOT NULL REFERENCES expertise_category(id),
  meta JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON expertise
  FOR EACH ROW EXECUTE PROCEDURE updated_at();

CREATE TABLE interest_scale (
  id SERIAL PRIMARY KEY,
  description TEXT NOT NULL CHECK(description <> ''),
  ranking INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON interest_scale
  FOR EACH ROW EXECUTE PROCEDURE updated_at();
INSERT INTO interest_scale
  (ranking, description)
VALUES
  (1, 'I really dislike this. Please do not ask me about this.'),
  (2, 'I would like to avoid this if possible.'),
  (3, 'I have no feelings for or against this.'),
  (4, 'I like this.'),
  (5, 'I love this. Please ask me about this!');

CREATE TABLE experience_scale (
  id SERIAL PRIMARY KEY,
  description TEXT NOT NULL CHECK(description <> ''),
  ranking INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON experience_scale
  FOR EACH ROW EXECUTE PROCEDURE updated_at();
INSERT INTO experience_scale
  (ranking, description)
VALUES
  (1, 'I have no experience with this.'),
  (2, 'I have some experience but I am not yet confident with this.'),
  (3, 'I have some experience and feel confident with this.'),
  (4, 'I have lots of experience and can teach others this.'),
  (5, 'I would feel comfortable having a team of people rely on me for this.');

CREATE TABLE expertise_slack_user_log (
  id SERIAL PRIMARY KEY,
  slack_user_id INTEGER NOT NULL REFERENCES slack_user(id),
  expertise_id INTEGER NOT NULL REFERENCES expertise(id),
  interest_scale_id INTEGER NOT NULL REFERENCES interest_scale(id),
  experience_scale_id INTEGER NOT NULL REFERENCES experience_scale(id),
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ
);
CREATE TRIGGER updated_at BEFORE UPDATE ON expertise_slack_user_log
  FOR EACH ROW EXECUTE PROCEDURE updated_at();

CREATE VIEW expertise_current AS
WITH ranked AS (
  SELECT
    id,
    slack_user_id,
    expertise_id,
    interest_scale_id,
    experience_scale_id,
    reason,
    created_at,
    RANK() OVER (PARTITION BY slack_user_id, expertise_id ORDER BY created_at DESC)
  FROM expertise_slack_user_log
)
SELECT
  id,
  slack_user_id,
  expertise_id,
  interest_scale_id,
  experience_scale_id,
  reason,
  created_at
FROM ranked
WHERE rank = 1
ORDER BY id;

---

DROP VIEW expertise_current;
DROP TABLE expertise_slack_user_log;
DROP TABLE experience_scale;
DROP TABLE interest_scale;
DROP TABLE expertise;
DROP TABLE expertise_category;
DROP TABLE slack_user;
DROP TABLE slack_team;
