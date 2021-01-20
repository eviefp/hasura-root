#!/usr/bin/env sh

cd mono/server

cabal run -- exe:graphql-engine \
      --database-url="$DATABASE_URL" \
      serve \
      --enable-console \
      --console-assets-dir=../console/static/dist \
      --enabled-log-types "startup,http-log,webhook-log,websocket-log,query-log" \
    | jq -R 'fromjson?'
