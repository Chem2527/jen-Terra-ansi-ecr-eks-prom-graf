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
### Note: manually delete the elb before running the jenkins job for resource deletion as nic is dependent of elb 
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

## sprint 4

 created an python application and postgres db and deployed the application to eks.


## Run below steps in Ec2 where u want to host PostgresDb:
```bash
1. sudo apt update -y

2. sudo apt upgrade -y

3. sudo apt install postgresql

4. sudo systemctl start postgresql

5. sudo systemctl status postgresql # (it will show active status)


6.  su - ubuntu # (switch to  ubuntu user - This is mandatory step so wherever your current  path is  just change directory  in upcoming steps u will get to know why)

7.   psql ( It will throw  error psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "ubuntu" does not exist)

8. sudo -i -u postgres # (Switch to postgres Default user "postgres")

9. psql

10. CREATE ROLE ubuntu WITH LOGIN PASSWORD 'ubuntu';   #(Note: create the username with exactly as"ubuntu" as by default only peer authentication is enabled in ec2.)

11. vi /etc/postgresql/16/main pg_hba.conf # (If someone wants to create a different role name navigate to "/etc/postgresql/<version>/main/" and modify   file pg_hba.conf by looking for  words "all all peer" and modify this to as shown below
```
```bash
**Note:** Update the pg_hba.conf file to allow connections from the IP address of the machine where your application is running. This ensures PostgreSQL permits access from that specific remote server rather than just the local host.


root@ip-172-31-6-55:~# sudo cat /etc/postgresql/16/main/pg_hba.conf


# PostgreSQL Client Authentication Configuration File
# ===================================================
#
# Refer to the "Client Authentication" section in the PostgreSQL
# documentation for a complete description of this file. A short
# synopsis follows.
#
# ----------------------
# Authentication Records
# ----------------------
#
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which PostgreSQL user names they can use, which
# databases they can access.  Records take one of these forms:
#
# local         DATABASE  USER  METHOD  [OPTIONS]
# host          DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostssl       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnossl     DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostgssenc    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnogssenc  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
#
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type:
# - "local" is a Unix-domain socket
# - "host" is a TCP/IP socket (encrypted or not)
# - "hostssl" is a TCP/IP socket that is SSL-encrypted
# - "hostnossl" is a TCP/IP socket that is not SSL-encrypted
# - "hostgssenc" is a TCP/IP socket that is GSSAPI-encrypted
# - "hostnogssenc" is a TCP/IP socket that is not GSSAPI-encrypted
#
# DATABASE can be "all", "sameuser", "samerole", "replication", a
# database name, a regular expression (if it starts with a slash (/))
# or a comma-separated list thereof.  The "all" keyword does not match
# "replication".  Access to replication must be enabled in a separate
# record (see example below).
#
# USER can be "all", a user name, a group name prefixed with "+", a
# regular expression (if it starts with a slash (/)) or a comma-separated
# list thereof.  In both the DATABASE and USER fields you can also write
# a file name prefixed with "@" to include names from a separate file.
#
# ADDRESS specifies the set of hosts the record matches.  It can be a
# host name, or it is made up of an IP address and a CIDR mask that is
# an integer (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that
# specifies the number of significant bits in the mask.  A host name
# that starts with a dot (.) matches a suffix of the actual host name.
# Alternatively, you can write an IP address and netmask in separate
# columns to specify the set of hosts.  Instead of a CIDR-address, you
# can write "samehost" to match any of the server's own IP addresses,
# or "samenet" to match any address in any subnet that the server is
# directly connected to.
#
# METHOD can be "trust", "reject", "md5", "password", "scram-sha-256",
# "gss", "sspi", "ident", "peer", "pam", "ldap", "radius" or "cert".
# Note that "password" sends passwords in clear text; "md5" or
# "scram-sha-256" are preferred since they send encrypted passwords.
#
# OPTIONS are a set of options for the authentication in the format
# NAME=VALUE.  The available options depend on the different
# authentication methods -- refer to the "Client Authentication"
# section in the documentation for a list of which options are
# available for which authentication methods.
#
# Database and user names containing spaces, commas, quotes and other
# special characters must be quoted.  Quoting one of the keywords
# "all", "sameuser", "samerole" or "replication" makes the name lose
# its special character, and just match a database or username with
# that name.
#
# ---------------
# Include Records
# ---------------
#
# This file allows the inclusion of external files or directories holding
# more records, using the following keywords:
#
# include           FILE
# include_if_exists FILE
# include_dir       DIRECTORY
#
# FILE is the file name to include, and DIR is the directory name containing
# the file(s) to include.  Any file in a directory will be loaded if suffixed
# with ".conf".  The files of a directory are ordered by name.
# include_if_exists ignores missing files.  FILE and DIRECTORY can be
# specified as a relative or an absolute path, and can be double-quoted if
# they contain spaces.
#
# -------------
# Miscellaneous
# -------------
#
# This file is read on server startup and when the server receives a
# SIGHUP signal.  If you edit the file on a running system, you have to
# SIGHUP the server for the changes to take effect, run "pg_ctl reload",
# or execute "SELECT pg_reload_conf()".
#
# ----------------------------------
# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records.  In that case you will also need to make PostgreSQL
# listen on a non-local interface via the listen_addresses
# configuration parameter, or via the -i or -h command line switches.

# DO NOT DISABLE!
# If you change this first entry you will need to make sure that the
# database superuser can access the database using some other method.
# Noninteractive access to all databases is required during automatic
# maintenance (custom daily cronjobs, replication, and similar tasks).
#
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
host    mydb1    kavitha    152.59.204.19/32    md5
```


"local" is for Unix domain socket connections only
local   all             all                                     md5 )

**md5 changes authentication from local to password based**

 ### Note: Im using password based authentication so creating role with name "kavitha" and im going to create database "mydb1"

```bash
12. CREATE USER kavitha WITH PASSWORD 'your_password';

13. ALTER ROLE kavitha WITH SUPERUSER; # (Providing root access to ubuntu user- not recommened)


14. \q # (exit postgresql)

15. createdb mydb1 -O kavitha

16. exit

17. psql -U kavitha -d mydb1 # (For testing purpose we will be establishing a connection to database which is owned by ubuntu user)

18. \l #(it will list all the databases )

19. Navigate to ubuntu@postgres:/etc/postgresql/16/main and modify   **postgresql.conf** and look for **#listen_addresses = 'localhost'** and replace it with **listen_addresses = '*'**




20. sudo systemctl restart postgresql

21. sudo service postgresql restart
```


 <img width="788" alt="image" src="https://github.com/user-attachments/assets/c6448e0d-bed7-4842-b215-3554507057fe" />
 

<img width="619" alt="image" src="https://github.com/user-attachments/assets/bd3351ec-b0fb-467e-8297-e2b76aa3ac02" />

Run the below for providng

```bash
 sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace
sudo chmod -R u+w /var/lib/jenkins/workspace
```
