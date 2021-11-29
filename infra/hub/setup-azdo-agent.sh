#!/bin/sh

# Creates directory & download ADO agent install files

su - isa -c "
mkdir myagent && cd myagent
wget https://vstsagentpackage.azureedge.net/agent/2.186.1/vsts-agent-linux-x64-2.186.1.tar.gz
tar zxvf vsts-agent-linux-x64-2.186.1.tar.gz"

# Unattended install

echo $pwd
su - isa -c "
./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "https://dev.azure.com/beandrad" \
  --auth PAT \
  --token "" \
  --pool "boat" \
  --replace \
  --acceptTeeEula & wait $!"

cd /home/isa/
#Configure as a service
sudo ./svc.sh install isa

#Start svc
sudo ./svc.sh start
