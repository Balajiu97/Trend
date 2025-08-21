pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "balajiyuva/trend-app-project"
        DOCKER_TAG   = "latest"
        AWS_REGION   = "ap-south-1"          // change to your EKS region
        EKS_CLUSTER  = "my-cluster-v2"     // change to your EKS cluster name
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
                    sh """
                        echo "🔑 Setting up kubeconfig for AWS EKS..."
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                        echo "✅ Kubeconfig setup complete"
                        kubectl get nodes
                        kubectl get svc
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                   echo "🚀 Running deployment script..."
                   chmod +x deploy.sh
                   ./deploy.sh ${DOCKER_IMAGE}:${DOCKER_TAG}
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

