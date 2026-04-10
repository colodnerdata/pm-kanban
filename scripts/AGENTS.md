# Scripts

Start and stop scripts for running the app locally in Docker.

## Scripts

| Script | Platform | Purpose |
|---|---|---|
| `start-mac.sh` | Mac / Linux | Build Docker image and start container in detached mode |
| `stop-mac.sh` | Mac / Linux | Stop and remove the container |
| `start-linux.sh` | Linux | Same as start-mac.sh |
| `stop-linux.sh` | Linux | Same as stop-mac.sh |
| `start-windows.ps1` | Windows | PowerShell equivalent of start-mac.sh |
| `stop-windows.ps1` | Windows | PowerShell equivalent of stop-mac.sh |

## What the start scripts do
1. Build the Docker image tagged `pm-app` from the repo root Dockerfile.
2. Remove any existing `pm-app` container.
3. Start a new detached container named `pm-app` on port 8000.
4. Load `.env` from the project root if the file exists (optional for Parts 1-7).

## Notes
- App is available at http://localhost:8000 after the container starts.
- The `.env` file is optional. If present, it is passed to the container via `--env-file`.
- The container runs as non-root user `appuser` for security.
- A HEALTHCHECK at `/health` is built into the image.
