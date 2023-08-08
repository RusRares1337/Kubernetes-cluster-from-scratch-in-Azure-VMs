#!/bin/bash

sudo apt update && sleep 5;

sudo apt install -y ansible;
sleep 3;
echo "Ansible installed"

echo "Running playbook"
ansible-playbook -u adminuser /home/adminuser/playbook.yaml