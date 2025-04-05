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
                    git url: 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git', branch: 'main', credentialsId: 'git'
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
                        echo "Logging into ECR..."
                        sh """
                            aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com
                        """

                        echo "Tagging Docker image..."
                        sh """
                            docker tag flask-demo-app:latest ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:latest
                        """

                        echo "Pushing Docker image to ECR..."
                        sh """
                            docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:latest
                        """
                    }
                }
            }
        }
    }
}
