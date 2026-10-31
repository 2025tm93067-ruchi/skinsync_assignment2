# SkinSync Assignment 2 Docker deployment

This starter extends the supplied Assignment 1 source with five service Dockerfiles,
Docker Compose, PostgreSQL initialization, readiness checks and containerized tools.
It is intended to make the core deployment reproducible on Docker Desktop for Mac.
Docker execution and end-to-end deployment still require verification on your machine.

## First deployment on macOS

Install and open Docker Desktop for your Mac architecture. In Terminal, enter this
project folder (the folder containing package.json, services and docker-compose.yml).

```sh
docker version
docker compose version
sh deployment/create-env.sh
mkdir -p evidence/assignment2
docker compose config --quiet
docker compose up --build
```

Keep that terminal open. In a second terminal, enter the same folder and run:

```sh
docker compose ps --all
docker compose --profile tools run --rm tools node deployment/check-services.js
docker compose --profile tools run --rm --no-deps tools npm test
docker compose --profile tools run --rm tools npm run e2e
```

Seven long-running containers are expected: five services, PostgreSQL and RabbitMQ.
The seed container should exit successfully with code 0. The tools container is
temporary and runs only when requested. Initial startup seeds an empty catalog;
later startups preserve products and stock. Each service migrates its own schema.

The main workflow is quiz -> recommendations -> cart -> order -> mock payment ->
RabbitMQ -> mock notification. The E2E script also checks a declined payment and
stock compensation. It writes fresh output to evidence/assignment2/tests.
Repeated E2E runs consume stock, so inspect quantities if a later run fails.
Existing evidence in other folders is from Assignment 1, not new deployment evidence.

## Service access

Catalog: http://localhost:3001/docs; quiz: http://localhost:3002/docs;
order: http://localhost:3003/docs; payment: http://localhost:3004/docs;
notification: http://localhost:3005/docs. Health is at /health on each port.
There is no shopping website in the supplied project; use Swagger UI or API clients.
RabbitMQ management is at http://localhost:15672 using the local .env credentials.

Inside containers, use service names such as http://catalog-service:3001 and
postgres:5432. localhost inside a container refers to that container.
Each service has its own database and login role in the PostgreSQL container.
Database and AMQP ports are not published to the Mac; clients in tools use the
Compose network. HTTP ports and the broker management port bind only to 127.0.0.1.

## Understand the files

Each service Dockerfile uses the Node 24 image, npm ci with the existing lockfile,
explicit copies, the unprivileged node user and a strict UP health check.
.dockerignore excludes .env, dependency folders, evidence, logs and local data.
docker-compose.yml passes configuration at runtime, waits for dependency health,
and retains PostgreSQL/RabbitMQ data in named volumes.
deployment/tools has a separate lockfile for test/API-client dependencies; no local
Node, npm, PostgreSQL or RabbitMQ installation is required for this Docker workflow.
The test-tools container does not run scripts/db.js or scripts/svc.js. Those scripts
manage local Assignment 1 processes and should not manage container services.
Payment simulation is enabled only to demonstrate this assignment's mock gateway.

## Capture evidence

```sh
docker compose ps --all > evidence/assignment2/containers.txt
docker compose images > evidence/assignment2/images.txt
docker compose logs --no-color --tail=100 > evidence/assignment2/container-logs.txt
docker compose --profile tools run --rm tools node deployment/check-services.js
docker compose --profile tools run --rm tools npm run e2e
```

Capture the actual image build/start in your recording. A healthcheck alone does
not prove cross-service calls work: show the full E2E and at least one manual API
flow. Do not share full `docker compose config` or full container inspect output
because they can contain the expanded credentials. `config --quiet` is safe for
syntax validation. Review logs before publishing. Never commit the local .env.

## Stop and restart without deleting data

```sh
docker compose down
docker compose up --build -d
docker compose --profile tools run --rm tools node deployment/check-services.js
docker compose --profile tools run --rm tools npm run e2e
```

Normal down keeps named volumes. Do not add --volumes/-v for the persistence demo:
that deletes database and broker data. Recreating credentials while volumes already
exist does not update stored database or broker passwords. Keep the existing .env.
Use `docker compose up -d` to apply changed environment settings; `restart` alone
does not apply a changed Compose environment.

## Troubleshooting evidence

Record a genuine problem you actually encounter. Capture the symptom, relevant
`docker compose ps`, logs and health output, the root cause, your change, then
successful rerun of the workflow. For example, conflicting host ports or using
localhost for an inter-container URL can cause deployment-specific failures.

A separately labeled controlled exercise is provided to study the latter:

```sh
docker compose -f docker-compose.yml -f deployment/compose.bad-url.yml up -d --no-deps --force-recreate quiz-service
docker compose --profile tools run --rm --no-deps tools npm run e2e
docker compose logs --tail=80 quiz-service
docker compose exec quiz-service node -e 'console.log(process.env.CATALOG_SERVICE_URL)'
docker compose exec quiz-service node -e 'fetch("http://catalog-service:3001/health").then(r=>r.json()).then(console.log).catch(e=>{console.error(e.message);process.exit(1)})'
docker compose up -d --no-deps --force-recreate quiz-service
docker compose --profile tools run --rm tools npm run e2e
```

The override points quiz-service at itself rather than catalog-service. The quiz
health endpoint only checks its DB, so it can be UP while recommendations fail.
Do not describe this deliberate exercise as an accidental real deployment incident.
The brief asks for a genuine encountered problem; ask the instructor if a controlled
reproduction can substitute when no genuine problem occurs.

## Submission

Submit the GitHub repository link, a deployment report of at most five pages
excluding appendices, and an approximately 6-8 minute demonstration video.
Include individual contributions and an accurate AI-use declaration in the report.
This starter addresses the core Docker tasks. It does not implement optional
Kubernetes, monitoring, tracing, HPA or rolling-update tasks and earns no automatic
advanced-task credit. See deployment/report-outline.txt and architecture.mmd.
