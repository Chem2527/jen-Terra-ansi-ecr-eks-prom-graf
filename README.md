# Jen-Terra-ansi-ecr-eks-prom-graf

## Sprint 1: Architecture Design, Dockerization, and Jenkins Setup

### 1. Overview
```bash
GitHub → Jenkins (on EC2) → Docker Build → Push to ECR → Deploy to EKS

Dockerized app is stored in ECR (Amazon Elastic Container Registry).

Kubernetes cluster (EKS) pulls the image from ECR and deploys the container.
```
### 2. Dockerize the Web Application



dockerfile ####(Place this Dockerfile in your project root.)

```bash
FROM python:3.9-slim

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

CMD ["python", "app.py"]
```

### 3. Set Up Jenkins Server on AWS EC2

Launch EC2 instance (Ubuntu 24.04)

Install Jenkins, Docker, AWS CLI:

```bash
    1  java --version
    2  sudo apt install openjdk-17-jre-headless
    3  java --version
    4  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    5  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]"   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
    6  sudo apt-get update
    7  sudo apt-get install jenkins
    8  sudo systemctl enable jenkins
    9  sudo systemctl start jenkins
   10  sudo systemctl status jenkins
   11  sudo apt  install docker.io
   12  systemctl status docker
   20  sudo apt update
   21  sudo apt install unzip curl
   22  sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   23  unzip awscliv2.zip
   24  sudo ./aws/install
   25  aws --version
   26 sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   27 sudo usermod -aG docker jenkins
   28 sudo systemctl restart jenkins
```
Access Jenkins at
```bash
http://<ec2-public-ip>:8080
```
### 4. Give Jenkins Access to AWS Resources

```bash
Option 1: Use IAM Role 

Attach an IAM role to EC2 instance with these permissions:

AmazonEC2ContainerRegistryFullAccess

AmazonEKSClusterPolicy

AmazonEKSWorkerNodePolicy

AmazonEKS_CNI_Policy
```

### 5. Install Jenkins Plugins

```bash
Docker Pipeline
Kubernetes CLI
Git
AWS Credentials
```
### 6. GitHub Integration

In Jenkins:

Create a new Pipeline project & Add your GitHub repo URL
Jenkinsfile inside repo should define CI/CD steps

### 7. Jenkins Pipeline (CI/CD)

```bash
pipeline {
    agent any

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'Git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t flask-demo-app .'
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID'),
                    string(credentialsId: 'ECR_REPO_NAME', variable: 'ECR_REPO_NAME'),
                    string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION')
                ]) {
                    script {
                        echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"
                        echo "ECR_REPO_NAME: ${ECR_REPO_NAME}"
                        echo "AWS_REGION: ${AWS_REGION}"

                        echo "Logging into ECR..."
                        sh """
                            aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com
                        """

                        echo "Tagging Docker image..."
                        sh """
                            docker tag flask-demo-app:latest "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${ECR_REPO_NAME}":latest
                        """

                        echo "Pushing Docker image to ECR..."
                        sh """
                            docker push "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${ECR_REPO_NAME}":latest
                        """
                    }
                }
            }
        }
    }
}

```
### 8. Storing the Credentials in Jenkins:
```bash

To securely store sensitive information such as the AWS Account ID, ECR Repository Name, and AWS Region in Jenkins, follow these steps:

a. Go to Jenkins Manage Credentials:
Open your Jenkins dashboard.

Navigate to Manage Jenkins > Manage Credentials.

b. Create String Credentials for Each Value:
Select the appropriate scope for your credentials (e.g., Global).

Click on (global) > Add Credentials > Kind: Secret text.

For each of the required variables:

AWS_ACCOUNT_ID:

Enter your AWS Account ID as the Secret.

ID: Name the credential AWS_ACCOUNT_ID.

ECR_REPO_NAME:

Enter your ECR repository name (e.g., flask-demo-app) as the Secret.

ID: Name the credential ECR_REPO_NAME.

AWS_REGION:

Enter your AWS region (e.g., ap-south-1) as the Secret.

ID: Name the credential AWS_REGION
```
### 9. Add Environmental variables in jenkins GUI

 Navigate to manage jenkins ---> system ---> check the nevironmental variables box and add below
 
```bash
AWS_ACCESS_KEY_ID: *******************
AWS_SECRET_ACCESS_KEY: ***************
```

```bash
Navigate to manage jenkins ---> Tools ---> check install automatically for git,docker.
```
## sprint 2

### 1. Install plugin

Navigate to manage jenkins --> Manage plugins --> available and install below

```bash
Terraform 
```
### 2. Add below under credentials in jenkins

```bash
aws_access_key_id 
aws_secret_access_key
```
### 3. Download and install terraform in ec2

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
### 4. jenkins file for resource creation
```bash
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'Git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Navigate to the terraform-aws-infrastructure directory before running terraform init
                    dir('terraform-aws-infrastructure') {
                        // Initialize terraform
                        sh 'terraform init -backend-config="bucket=my-terraform-state-bucket733751" -backend-config="key=terraform.tfstate" -backend-config="region=eu-north-1"'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform-aws-infrastructure') {
                        // Apply terraform changes
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }
}
```
### 5. jenkins file for resource deletion

```bash
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'Git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Navigate to the terraform-aws-infrastructure directory before running terraform init
                    dir('terraform-aws-infrastructure') {
                        // Initialize terraform
                        sh 'terraform init -backend-config="bucket=my-terraform-state-bucket733751" -backend-config="key=terraform.tfstate" -backend-config="region=eu-north-1"'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    dir('terraform-aws-infrastructure') {
                        // Destroy terraform resources
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
```
### 6. storing state file remotely in s3
Add the below block  in the main.tf for storing the terraform.tfstate remotely under s3 and enable the versioning of bucket.
```bash
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket733751"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
  }
}
```
## Sprint 3

### 1. Install ansible in ec2 

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible --version
mkdir ansible
cd ansible/
```
#### create a file called configure_ec2.yml and add below code


```bash
---
- name: Configure EC2 instances for Docker and kubectl
  hosts: localhost
  connection: local
  become: true
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install required dependencies for Docker
      apt:
        name: "{{ item }}"
        state: present
      with_items:
        - apt-transport-https
        - ca-certificates
        - curl
        - software-properties-common

    - name: Add Docker’s official GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
        state: present

    - name: Install Docker
      apt:
        name: docker-ce
        state: present
        update_cache: yes

    - name: Add user (ubuntu) to the Docker group
      user:
        name: ubuntu
        group: docker
        append: yes

    - name: Install kubectl
      shell: |
        curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.24.0/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        mv ./kubectl /usr/local/bin/kubectl

    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes

    - name: Check kubectl version
      shell: kubectl version --client
      register: kubectl_version

    - name: Print kubectl version
      debug:
        msg: "kubectl version: {{ kubectl_version.stdout }}"

    - name: Check Docker version
      shell: docker --version
      register: docker_version

    - name: Print Docker version
      debug:
        msg: "Docker version: {{ docker_version.stdout }}"
```
### 2. Run the playbook
```bash
ansible-playbook -i localhost, configure_ec2.yml
docker --version
kubectl version --client
```
### 3. automate the ansible playbook using jenkins

Jenkinsfile

```bash
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'Git'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Run the Ansible playbook (e.g., configure EC2 instances for Docker and kubectl)
                    sh '''
                    ansible-playbook -i localhost, /home/ubuntu/ansible/configure_ec2.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Ansible playbook executed successfully!"
        }
        failure {
            echo "An error occurred while executing the Ansible playbook."
        }
    }
}
```
## step 4 check the pipeline is running smoothly or not

Uninstall the docker,kubectl packages manually and then run pipeline and check whether the deleted packages are installed or not.

```bash
docker --version
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo apt-get autoremove -y
kubectl version --client
sudo rm /usr/local/bin/kubectl
rm -rf ~/.kube
sudo rm /usr/local/bin/kustomize
sudo apt-get purge -y kubectl
sudo apt-get purge -y kubeadm kubectl kubelet kubernetes-cni
sudo apt-get autoremove -y
sudo rm /etc/apt/sources.list.d/kubernetes.list
sudo apt-get clean
kubectl version --client
```
```bash
sudo visudo
jenkins ALL=(ALL) NOPASSWD:ALL
```
```bash
sudo systemctl restart jenkins
kubectl version --client
docker --version
```
## step 5 connect to the created eks cluster from local machine using below steps

```bash
aws eks --region eu-north-1 update-kubeconfig --name <name of cluster>
echo $KUBECONFIG
kubectl get pods
kubectl get nodes
```


