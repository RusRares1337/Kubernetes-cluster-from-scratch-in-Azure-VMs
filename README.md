Infrastructure
- Create Kubernetes cluster on Azure with Terraform and provisioned with ansible playbooks (1 master 2 workers)
- Use Ansible playbooks to update packages, install ansible and install kubeadm, docker and kubernetes dependencies on each VM
- As a security feature, disabled password authentification on each VM (login can be achieved only through ssh keys).

  Networking
  - Allow all traffic between VMs
  - Allow SSH access from local machine to all the VMs
  - Allow HTTP/HTTPS access from everywhere
  - Add a firewall rule to only allow ICMP traffic from the VPN interface
