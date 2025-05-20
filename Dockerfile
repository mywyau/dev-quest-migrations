# Copy your SQL migration files into the Flyway location
# Use the official Flyway image as the base
FROM flyway/flyway:9.22.1

# Copy your SQL migrations into the Flyway migrations directory
COPY migrations/sql /flyway/sql

# Optional: config files if needed
# COPY conf /flyway/conf
