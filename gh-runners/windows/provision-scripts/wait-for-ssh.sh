#!/usr/bin/env bash

attempts=0
host=$1

if [ -z "$host" ]; then
  echo "SSH host must be provided as an argument"
  exit 1
fi

echo "Waiting for SSH..."
while [ $attempts -lt 60 ]; do
  if nc -z "$host" 22; then
    echo "SSH Connected!"
    exit 0
  fi

  ((attempts+=1))
  sleep 1
done

echo "SSH Connection Failed."
exit 1