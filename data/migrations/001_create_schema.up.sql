-- 1. Create the 'users' table
CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
    );

-- 2. Create the 'documents' table
CREATE TABLE IF NOT EXISTS documents (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        file_name VARCHAR(255) NOT NULL,
        file_path VARCHAR(255) NOT NULL,
        uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
        file_size INT,
        status VARCHAR(50) NOT NULL DEFAULT 'uploaded',
        CONSTRAINT fk_documents_user_id
            FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE
    );

-- 3. Create the 'payments' table
CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(12, 2) NOT NULL,
        currency VARCHAR(10) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'pending',
        payment_method VARCHAR(50),
        transaction_id VARCHAR(255),
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
        CONSTRAINT fk_payments_user_id
            FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE
    );

-- 4. Create the 'terminals' table
CREATE TABLE IF NOT EXISTS terminals (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        location VARCHAR(255),
        ip_address VARCHAR(50),
        status VARCHAR(50) NOT NULL DEFAULT 'offline',
        last_seen TIMESTAMP
    );

-- 5. Create the 'telemetry' table
CREATE TABLE IF NOT EXISTS telemetry (
        id SERIAL PRIMARY KEY,
        terminal_id INT NOT NULL,
        metric_type VARCHAR(50) NOT NULL,
        metric_value VARCHAR(50) NOT NULL,
        recorded_at TIMESTAMP NOT NULL DEFAULT NOW(),
        CONSTRAINT fk_telemetry_terminal_id
            FOREIGN KEY (terminal_id) REFERENCES terminals(id)
            ON DELETE CASCADE
    );

-- 6. Create the 'printjobs' table
CREATE TABLE IF NOT EXISTS printjobs (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        document_id INT NOT NULL,
        terminal_id INT NOT NULL,
        copies INT NOT NULL DEFAULT 1,
        format VARCHAR(20) NOT NULL DEFAULT 'A4',
        color BOOLEAN NOT NULL DEFAULT FALSE,
        duplex BOOLEAN NOT NULL DEFAULT FALSE,
        status VARCHAR(50) NOT NULL DEFAULT 'queued',
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
        payment_id INT,
        CONSTRAINT fk_printjobs_user_id
            FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE,
        CONSTRAINT fk_printjobs_document_id
            FOREIGN KEY (document_id) REFERENCES documents(id)
            ON DELETE CASCADE,
        CONSTRAINT fk_printjobs_terminal_id
            FOREIGN KEY (terminal_id) REFERENCES terminals(id)
            ON DELETE CASCADE,
        CONSTRAINT fk_printjobs_payment_id
            FOREIGN KEY (payment_id) REFERENCES payments(id)
            ON DELETE SET NULL
    );
