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
```


