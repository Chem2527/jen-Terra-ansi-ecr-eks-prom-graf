pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')  // Retrieve AWS Account ID
        ECR_REPO_NAME = credentials('ECR_REPO_NAME')    // Retrieve ECR Repository Name
        AWS_REGION = credentials('AWS_REGION')          // Retrieve AWS Region for ECR
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Ensure the GitHub credentials with ID 'git' are used to checkout the repository
                    git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', credentialsId: 'git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
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
                        // Log in to AWS ECR using the AWS credentials
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME
                        """

                        // Tag the Docker image for ECR
                        sh """
                            docker tag flask-demo-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                        """

                        // Push Docker image to ECR
                        sh """
                            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                        """
                    }
                }
            }
        }
    }
}
