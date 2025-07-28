#!/bin/sh

sudo apt clean
docker image prune -af
sudo apt-get remove -y azure-cli google-cloud-cli google-cloud-cli-anthoscli
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf "/usr/local/share/boost"
sudo rm -rf "$AGENT_TOOLSDIRECTORY"
sudo rm -rf /usr/share/dotnet/