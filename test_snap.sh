#!/bin/bash

echo "Testing snap functionality..."

# Check if snapd is running
echo "1. Checking snapd service status:"
sudo systemctl status snapd.service --no-pager

echo -e "\n2. Checking snapd socket status:"
sudo systemctl status snapd.socket --no-pager

echo -e "\n3. Testing snap command:"
snap version

echo -e "\n4. Listing available snaps:"
snap find hello

echo -e "\n5. Installing a test snap (hello-world):"
sudo snap install hello-world

echo -e "\n6. Running the test snap:"
hello-world

echo -e "\n7. Listing installed snaps:"
snap list

echo -e "\nSnap functionality test completed!"
