pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        ECR_REPO_NAME = credentials('ECR_REPO_NAME')
        AWS_REGION = credentials('AWS_REGION')
    }

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
                        sh '''
                            aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com
                        '''

                        echo "Tagging Docker image..."
                        sh '''
                            docker tag flask-demo-app:latest "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${ECR_REPO_NAME}":latest
                        '''

                        echo "Pushing Docker image to ECR..."
                        sh '''
                            docker push "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com/"${ECR_REPO_NAME}":latest
                        '''
                    }
                }
            }
        }
    }
}
