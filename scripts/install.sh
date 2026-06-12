#!/bin/bash
# Keep the pinned versions in sync with install.bat and install.ps1 (the Windows variants).
uv tool install --python python3.11 'datacontract-cli[all]==1.0.2'
uv tool install 'entropy-data==0.3.12'
uv tool update-shell
which datacontract
datacontract --version
which entropy-data
entropy-data --version
# pre-pull the workshop database image (needs Docker running)
docker compose -f "$(dirname "$0")/../docker-compose.yml" pull
