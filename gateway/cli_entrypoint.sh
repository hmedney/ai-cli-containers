#!/bin/sh

# Start the SSH tunnel in the background
# We use a loop so it restarts if it ever drops
until ssh -i /home/node/id_rsa \
    -o StrictHostKeyChecking=no \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=60 \
    -N -f \
    -L 127.0.0.1:1234:192.168.1.30:1234 \
    tunneluser@gateway; do
  echo "Tunnel failed to start, retrying in 2 seconds..."
  sleep 2
done

echo "Tunnel established successfully."

# Launch the main application
# 'exec' ensures the app becomes PID 1
exec "$@"
