#!/bin/bash

if [ "$COMMAND" = "pm2:start" ]; then
  sed -r -i "s#(\"pm2:start\": \"pm2 start )(./bin/www\")#\1--no-daemon \2#g" package.json
fi

sed -r -i "s#(\"host\": \")[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(\")#\1$DB_HOST\2#g" config/dbConfig.json

npm run $COMMAND
