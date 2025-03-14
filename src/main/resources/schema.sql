CREATE SCHEMA IF NOT EXISTS public
;

CREATE TABLE IF NOT EXISTS public.administrator_key (
    id bigint NOT NULL,
    key varchar(512) NOT NULL,
    owner_id bigint,
    user_id bigint NOT NULL,
    CONSTRAINT pk_administrator_key PRIMARY KEY (id)
)
;

CREATE TABLE IF NOT EXISTS public.app_client_type (
    code varchar(40) NOT NULL,
    CONSTRAINT pk_app_client_type PRIMARY KEY (code)
)
;

CREATE TABLE IF NOT EXISTS public.app_client (
    id uuid NOT NULL,
    name varchar(255) NOT NULL,
    client_type_code varchar(40) NOT NULL,
    target_usage text,
    register_date timestamptz NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT pk_app_client PRIMARY KEY (id)
)
;

CREATE TABLE IF NOT EXISTS public.api_token (
    id uuid NOT NULL,
    token varchar(512) NOT NULL,
    active boolean NOT NULL,
    client_id uuid NOT NULL,
    created_date timestamptz NOT NULL,
    last_change_date timestamptz NOT NULL,
    CONSTRAINT pk_api_token PRIMARY KEY (id)
)
;

CREATE TABLE IF NOT EXISTS public.request_status (
    request_id uuid NOT NULL,
    response_id uuid,
    request_body jsonb NOT NULL,
    response_body jsonb,
    user_id bigint NOT NULL,
    CONSTRAINT pk_request_status PRIMARY KEY (request_id)
)
;

ALTER TABLE public.app_client
    DROP CONSTRAINT IF EXISTS "fk_app_client_app_client_type"
;

ALTER TABLE public.api_token
    DROP CONSTRAINT IF EXISTS "fk_api_token_app_client"
;

ALTER TABLE public.app_client
    ADD CONSTRAINT "fk_app_client_app_client_type"
    FOREIGN KEY (client_type_code)
    REFERENCES public.app_client_type (code)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
;

ALTER TABLE public.api_token
    ADD CONSTRAINT "fk_api_token_app_client"
    FOREIGN KEY (client_id)
    REFERENCES public.app_client (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
;

CREATE UNIQUE INDEX IF NOT EXISTS "uidx_key"
    ON public.administrator_key
    USING btree(key)
;

CREATE INDEX IF NOT EXISTS "idx_key_owner_id"
    ON public.administrator_key
    USING btree(key, owner_id)
;

CREATE INDEX IF NOT EXISTS "idx_request_status"
    ON public.request_status
    USING btree(request_id, user_id)
;

CREATE INDEX IF NOT EXISTS "idx_client_name_client_type_code"
    ON public.app_client
    USING btree(name, client_type_code)
;

CREATE INDEX IF NOT EXISTS "ixfk_api_token_app_client"
    ON public.api_token
    USING btree(client_id)
;

CREATE INDEX IF NOT EXISTS "idx_token_client_id_active"
    ON public.api_token
    USING btree(token, client_id, active)
;

CREATE INDEX IF NOT EXISTS "idx_client_id"
    ON public.api_token
    USING btree(client_id)
;