# jen-Terra-ansi-ecr-eks-prom-graf

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

Pipeline

AWS CLI Plugin (optional if using system CLI)
```
### 6. GitHub Integration

In Jenkins:

Create a new Pipeline project & Add your GitHub repo URL
Jenkinsfile inside repo should define CI/CD steps

### 7. Jenkins Pipeline (CI/CD)

```bash
pipeline {
  agent any

  environment {
    IMAGE_TAG = "latest"  // Define the image tag for the Docker image
  }

  stages {
    // Stage 1: Clone the source code from GitHub repository
    stage('Clone Code') {
      steps {
        // Git clone step to pull the code from the repository
        git 'https://github.com/your-username/demo-app.git'
      }
    }

    // Stage 2: Build the Docker image
    stage('Build Docker Image') {
      steps {
        // Build the Docker image with the tag "flask-demo-app"
        sh 'docker build -t flask-demo-app .'
      }
    }

    // Stage 3: Push the built Docker image to AWS ECR
    stage('Push to ECR') {
      steps {
        // Securely retrieve credentials from Jenkins
        withCredentials([
          string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID'),
          string(credentialsId: 'ECR_REPO_NAME', variable: 'ECR_REPO_NAME'),
          string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION')
        ]) {
          script {
            // Dynamically construct the ECR repository URL using credentials
            def ecrRepo = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

            // Log in to AWS ECR and push the Docker image
            sh """
              aws ecr get-login-password --region ${AWS_REGION} | \
              docker login --username AWS --password-stdin ${ecrRepo}
              docker tag flask-demo-app:latest ${ecrRepo}:${IMAGE_TAG}
              docker push ${ecrRepo}:${IMAGE_TAG}
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


