-- Task Tracker Database Schema

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Grant permissions to taskuser
GRANT ALL PRIVILEGES ON TABLE tasks TO taskuser;
GRANT USAGE, SELECT ON SEQUENCE tasks_id_seq TO taskuser;

-- Create index on completed status for filtering
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

-- Seed data for demo
INSERT INTO tasks (title, description, completed) VALUES
  ('Build UBI container images', 'Build webapp and database containers using RHEL UBI base images', true),
  ('Build RHHI container images', 'Build webapp and database containers using Hummingbird base images', false),
  ('Run Trivy security scans', 'Scan both UBI and RHHI images for vulnerabilities', false),
  ('Generate SBOMs', 'Create CycloneDX Software Bill of Materials for supply chain transparency', false),
  ('Deploy to kvm151', 'Deploy demo stack using Podman quadlets', false);

-- Success message
\echo '✅ Database initialized successfully!'
\echo '📊 Created tasks table with indexes'
\echo '🌱 Inserted 5 seed tasks'
