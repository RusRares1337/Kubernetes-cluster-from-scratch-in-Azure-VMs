#!/bin/bash

sudo apt update && sleep 5;

sudo apt install -y ansible;
sleep 3;
echo "Ansible installed"

#echo "Generate and send public key to workers"
sudo ssh-keygen -t rsa
ssh-copy-id -i ~./shh/id_rsa.pub adminuser@10.0.1.4
ssh-copy-id -i ~./shh/id_rsa.pub adminuser@10.0.2.4
ssh-copy-id -i ~./shh/id_rsa.pub adminuser@10.0.3.4

#ansible-playbook -i hosts initial.yml

#ansible-playbook -i hosts kube-dependencies.yml

#ansible-playbook -i hosts master.yml

#ansible-playbook -i hosts workers.yml


