pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "balajiyuva/trend-app-project"
        DOCKER_TAG   = "latest"
        AWS_REGION   = "ap-south-1"      // your EKS region
        EKS_CLUSTER  = "trend"           // your EKS cluster name
        KUBECONFIG   = "/var/lib/jenkins/.kube/config"
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
                    sh """
                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                       docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Setup Kubeconfig') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-eks-credentials') {
                    sh """
                        echo "🔑 Setting up kubeconfig for AWS EKS..."
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER} --kubeconfig ${KUBECONFIG}
                        echo "✅ Kubeconfig setup complete"
                        kubectl get nodes
                        kubectl get svc
                        chmod +x deploy.sh
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                   ./deploy.sh
                """
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
