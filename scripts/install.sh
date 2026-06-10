# psycopg[binary] bundles libpq so the postgres backend works without a system libpq
uv tool install --python python3.11 'datacontract-cli[all]==1.0.1' --with 'psycopg[binary]'
uv tool install 'entropy-data==0.3.12'
uv tool update-shell
which datacontract
datacontract --version
which entropy-data
entropy-data --version
