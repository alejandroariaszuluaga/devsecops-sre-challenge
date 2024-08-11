#!/bin/bash
set -e

npm run migrate & PID=$!
# Wait for migration to finish
wait $PID

echo "Starting production server..."
npm start
