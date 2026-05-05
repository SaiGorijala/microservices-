FROM postgres:16-alpine

ENV POSTGRES_DB=appdb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

COPY migrations/ /docker-entrypoint-initdb.d/migrations/
COPY seeds/ /docker-entrypoint-initdb.d/seeds/
COPY init.sh /docker-entrypoint-initdb.d/init.sh

RUN chmod +x /docker-entrypoint-initdb.d/init.sh

EXPOSE 5432
