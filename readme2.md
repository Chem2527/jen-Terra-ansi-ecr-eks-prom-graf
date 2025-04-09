 Sprint 1: Terraform, ECR & Jenkins Setup
 1. Configure AWS Credentials in Jenkins
Go to Jenkins → Manage Credentials:

Add aws_access_key_id

Add aws_secret_access_key

Add them to Jenkins global environment or Jenkinsfile.

 2. Setup Terraform in Jenkins
Install Terraform plugin via Manage Jenkins → Plugin Manager.

In Jenkins pipeline:

groovy
Copy
Edit
sh '''
terraform init
terraform plan
terraform apply -auto-approve
'''
 3. Provision AWS Infrastructure via Terraform
Create Terraform code to provision:

VPC, Subnet, Internet Gateway

EC2 Instance

Security Groups

IAM Role

 4. Push Docker Image to Amazon ECR
Authenticate with ECR:

bash
Copy
Edit
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
Build and push image:

bash
Copy
Edit
docker build -t my-python-app .
docker tag my-python-app:latest <ecr_repo_url>
docker push <ecr_repo_url>
 Sprint 2: Ansible & EC2 Configuration
 1. Ansible Playbook: Configure EC2
Tasks:

Install Docker

Install kubectl

Install jq, unzip, and AWS CLI

Example Playbook: configure_ec2.yml

yaml
Copy
Edit
- hosts: all
  become: true
  tasks:
    - name: Install Docker
      apt:
        name: docker.io
        state: present
        update_cache: true

    - name: Install kubectl
      shell: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
2. Jenkinsfile to Run Ansible
groovy
Copy
Edit
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'Git'
            }
        }

        stage('Run Ansible') {
            steps {
                sh '''
                ansible-playbook -i localhost, /home/ubuntu/ansible/configure_ec2.yml
                '''
            }
        }
    }

    post {
        success { echo "Playbook ran successfully!" }
        failure { echo "An error occurred!" }
    }
}
 3. Manual Cleanup for Testing
Uninstall Docker/kubectl manually:

bash
Copy
Edit
sudo apt purge -y docker-ce docker-ce-cli containerd.io
sudo rm /usr/local/bin/kubectl
sudo apt autoremove -y
sudo rm -rf ~/.kube
Then re-run Jenkins pipeline to validate playbook works.

 Sprint 3: Setup EKS, Prometheus, and Grafana
 1. Setup EKS Cluster
Using Terraform or CLI:

bash
Copy
Edit
eksctl create cluster --name my-cluster --region eu-north-1 --nodes 2
Connect EKS to local:

bash
Copy
Edit
aws eks --region eu-north-1 update-kubeconfig --name my-cluster
kubectl get nodes
 2. Deploy Prometheus & Grafana
Use Helm:

bash
Copy
Edit
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
Get login credentials and port-forward to access UI:

bash
Copy
Edit
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
kubectl port-forward svc/prometheus-grafana 3000:80
 3. EKS Cluster Debugging Commands
bash
Copy
Edit
kubectl get pods
kubectl get deploy
kubectl logs <pod-name>
kubectl describe pod <pod-name>
 Pod CrashLoopBackOff Fix
Update resource limits:

yaml
Copy
Edit
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "1.5Gi"
    cpu: "1"
 Sprint 4: PostgreSQL & Python App Deployment
 1. Install PostgreSQL on EC2
bash
Copy
Edit
sudo apt update -y && sudo apt install postgresql
sudo systemctl start postgresql
sudo -i -u postgres
psql
CREATE USER kavitha WITH PASSWORD 'password';
ALTER ROLE kavitha WITH SUPERUSER;
CREATE DATABASE mydb1 OWNER kavitha;
 2. Configure PostgreSQL Access
Edit pg_hba.conf:

bash
Copy
Edit
local   all   all   md5
host    all   all   <your_ip>/32   md5
Edit postgresql.conf:

bash
Copy
Edit
listen_addresses = '*'
Restart:

bash
Copy
Edit
sudo systemctl restart postgresql
 3. Test DB Connection
bash
Copy
Edit
psql -U kavitha -d mydb1
\l
 4. Python App Dockerize & Deploy to EKS
Dockerfile:

Dockerfile
Copy
Edit
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
K8s Deployment:

yaml
Copy
Edit
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: app
        image: <ecr_image>
        ports:
        - containerPort: 5000
        env:
        - name: DB_HOST
          value: <postgres_ip>
        - name: DB_NAME
          value: mydb1
        - name: DB_USER
          value: kavitha
        - name: DB_PASS
          value: your_password
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "1.5Gi"
            cpu: "1"
 Jenkins File Permission Fix (Common Issue)
If Jenkins pipeline fails with permission issues:

bash
Copy
Edit
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace
sudo chmod -R u+w /var/lib/jenkins/workspace
