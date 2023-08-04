-- +goose Up
-- +goose StatementBegin
CREATE TYPE platform AS ENUM ('greenhouse', 'lever', 'bamboo')

CREATE TABLE companies (
   id SERIAL PRIMARY KEY,
   name VARCHAR(255) NOT NULL,
   platform platform NOT NULL,
   base_url VARCHAR(255) NOT NULL,
   last_scraped TIMESTAMP,
   created_at TIMESTAMP NOT NULL,
   updated_at TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE companies;

DROP TYPE platform;
-- +goose StatementEnd
