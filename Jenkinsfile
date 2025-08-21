pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "balajiyuva/trend-app-project"
        DOCKER_TAG   = "latest"
        AWS_REGION   = "ap-south-1"
        EKS_CLUSTER  = "trend"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Balajiu97/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                   docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub_credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                       docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('Setup Kubeconfig') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-eks-credentials']]) {
                    sh '''
                       echo "🔑 Setting up kubeconfig for AWS EKS..."
                       export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                       export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                       export AWS_DEFAULT_REGION=${AWS_REGION}

                       aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                       echo "✅ Kubeconfig setup complete"

                       kubectl get nodes || true
                       kubectl get svc || true
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                   echo "🚀 Deploying application to EKS..."
                   chmod +x deploy.sh
                   ./deploy.sh
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build & Deploy successful!"
        }
        failure {
            echo "❌ Build or Deploy failed."
        }
    }
}
