**- Infrastructure -**

- Create self-managed Kubernetes cluster on Azure VMs using Terraform and provisioned with Ansible playbooks
- Use Ansible playbooks to update and upgrade packages, install Ansible, install Docker and Kubernetes dependencies on each VM
- As a security feature, disabled password authentification on each VM (login can be achieved only through ssh keys)


**- Networking -**

- Apply firewall rules on all created instances:
  - Allow all traffic between VMs
  - Allow SSH access from local machine to all the VMs
  - Allow HTTP/HTTPS access from everywhere
  - Add a firewall rule to only allow ICMP traffic from the VPN interface


**- CI/CD -**

- Deploy an open-source application in a containerized and orchestrated form
  - Create shell scripts to build and deploy the image
  - Create docker & kubernetes files
  - Set the replicas count for service to 3 and make sure that they are running one on each node
  - Expose a port for the service
- Used Azure DevOps CI/CD tool to build,deploy and test the application
  - Configure a CI/CD agent on one node of the cluster
  - Create a CI/CD configuration file that will run the scripts created for build and deploy
    
 
**- Kubernetes -**
- Deployment and configuration files
- Prepared for CKA certification

 
 **- Monitoring -**
- Created and deployed a monitoring stack comprised of: Prometheus, Grafana with NodeExporter
- Used Prometheus to monitor all infrastructure components as follows:
   - VMs resource usage (CPU,RAM,DISK,Network)
   - Container resource usage (CPU,RAM,DISK,Network)
   - Network connectivity through the VPN tunnel between all the nodes
   - Setup monitoring jobs using service discovery where applicable
- Setup cron jobs on VMs that push metrics to Prometheus
- Use Grafana to create an Infrastructure dashboard showing all the metrics collected using Prometheus
- Create alert rules for critical metrics
- Simulate a node failure and send alerts to email
