FROM flyway/flyway:9.22.1

# Copy migration scripts into the Flyway expected directory
COPY migrations/sql /flyway/sql

# Run Flyway automatically when container starts
ENTRYPOINT ["flyway", "migrate"]
