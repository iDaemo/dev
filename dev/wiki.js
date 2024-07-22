version: "3.9"
services:
  db:
    image: postgres
    container_name: Wiki.js-DB
    hostname: wiki-js-db
    mem_limit: 512m
    cpu_shares: 768
    security_opt:
      - no-new-privileges:true
    user: 1032:100
    healthcheck:
      test: ["CMD", "pg_isready", "-q", "-d", "wikijs", "-U", "wikiuser"]
      timeout: 45s
      interval: 10s
      retries: 10
    volumes:
      - /volume2/docker/wikijs/db:/var/lib/postgresql/data:rw
    environment:
      POSTGRES_DB: wikijs
      POSTGRES_USER: wikiuser
      POSTGRES_PASSWORD: wikipass
    restart: on-failure:5

  wiki:
    image: ghcr.io/linuxserver/wikijs:latest
    container_name: Wiki-js
    hostname: wiki-js
    mem_limit: 512m
    cpu_shares: 768
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: wget --no-verbose --tries=1 --spider http://localhost:3000
    ports:
      - 3540:3000
    volumes:
      - /volume2/docker/wikijs/config:/config:rw
      - /volume2/docker/wikijs/data:/data:rw
    environment:
      TZ: Asia/Bangkok
      PUID: 1032
      PGID: 100
      DB_TYPE: postgres
      DB_HOST: wiki-js-db
      DB_PORT: 5432
      DB_NAME: wikijs
      DB_USER: wikiuser
      DB_PASS: wikipass
    restart: on-failure:5
    depends_on:
      db:
        condition: service_healthy