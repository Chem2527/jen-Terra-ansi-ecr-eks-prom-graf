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
        git 'https://github.com/Chem2527/jen-Terra-ansi-ecr-eks-prom-graf.git'
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
