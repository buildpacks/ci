#!/usr/bin/env bash

set -e

echo "> Downloading API token..."
TOKEN="$(op read op://Shared/4bqcschjgjcp3nvgy4hbwqhrgq/credential)"

CREDENTIALS_BLOCK="credentials \"app.terraform.io\" { token = \"${TOKEN}\" }"

FILE="$HOME/.terraformrc"
if [ -f "$FILE" ]; then
    echo "$FILE already exists..."
    if [ "$(grep $TOKEN $FILE)" != "" ]; then
        echo "Token already in file!"
        exit 0
    else
        echo "> Appending token to configuration..."
        echo $CREDENTIALS_BLOCK >> $FILE
        echo "> Done!"
    fi
else
    echo "> Creating configuration file..."
    echo $CREDENTIALS_BLOCK >> $FILE
    echo "> Done!"
fi