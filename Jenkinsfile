pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')  // Retrieve AWS Account ID
        ECR_REPO_NAME = credentials('ECR_REPO_NAME')    // Retrieve ECR Repository Name
        AWS_REGION = credentials('AWS_REGION')          // Retrieve AWS Region for ECR
        GITHUB_USERNAME = credentials('github username') // Retrieve GitHub Username
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
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
                    string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION'),
                    string(credentialsId: 'github username', variable: 'GITHUB_USERNAME')
                ]) {
                    script {
                        // Log into AWS ECR
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME
                        """

                        // Tag Docker image for ECR
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
