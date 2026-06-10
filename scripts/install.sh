# psycopg[binary] bundles libpq so the postgres backend works without a system libpq
uv tool install --python python3.11 'datacontract-cli[all]' --with 'psycopg[binary]'
uv tool upgrade datacontract-cli
uv tool install entropy-data
uv tool update-shell
which datacontract
datacontract --version
which entropy-data
entropy-data --version
