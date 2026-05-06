#!/bin/bash

# Function to kill background processes on exit
cleanup() {
    echo "Shutting down..."
    kill $(jobs -p) 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

echo "Cleaning up existing processes on ports 8000 and 5173..."
fuser -k 8000/tcp 2>/dev/null
fuser -k 5173/tcp 2>/dev/null

echo "Starting Backend with GPU support..."
./run_backend.sh &

echo "Starting Frontend..."
cd frontend
# Using --port 5173 explicitly to match the browser open command
npm run dev -- --port 5173 &

# Wait for frontend to be ready
echo "Waiting for services to start..."
until curl -s http://localhost:5173 > /dev/null; do
  sleep 1
done

echo "Opening browser..."
xdg-open http://localhost:5173 2>/dev/null || sensible-browser http://localhost:5173 2>/dev/null || python3 -m webbrowser http://localhost:5173

# Keep script running to maintain background processes
wait
