#!/bin/bash

if [ "$COMMAND" = "start" ]; then
  npm install pm2

  sed -r -i "s#(\"start\": \"pm2 start )(./bin/www\")#\1--no-daemon \2#g" package.json
else
  npm install nodemon
fi

sed -r -i "s#(\"host\": \")[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(\")#\1$DB_HOST\2#g" config/configdb.json

npm $COMMAND
