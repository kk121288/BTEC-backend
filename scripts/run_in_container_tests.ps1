# Runs docker compose build and executes the healthcheck pytest inside the backend container
param()

Write-Host "Rebuilding compose and starting services..."
docker compose up --build -d

Write-Host "Running healthcheck pytest inside backend container..."
docker compose exec backend pytest backend/tests/test_healthcheck.py -q

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "Tests completed successfully." -ForegroundColor Green
