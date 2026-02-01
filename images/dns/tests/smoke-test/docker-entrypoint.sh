#!/bin/bash
set -e

# Create necessary directories
mkdir -p /run/sshd /var/run /var/log

# Start SSH server in foreground
echo "Starting SSH server..."
/usr/sbin/sshd -D

