-- +goose Up
-- +goose StatementBegin
CREATE TYPE remote AS ENUM ('remote', 'onsite', 'hybrid');

CREATE TABLE jobs (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      department VARCHAR(255),
      location VARCHAR(255),
      remote remote NOT NULL,
      link VARCHAR(255),
      description TEXT NOT NULL,
      company_id INTEGER REFERENCES companies(id),
      created_at TIMESTAMP NOT NULL,
      updated_at TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE jobs;

DROP TYPE remote;
-- +goose StatementEnd
