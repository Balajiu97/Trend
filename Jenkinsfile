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
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
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
                withAWS(credentials: 'aws-eks-credentials', region: "${AWS_REGION}") {
                    sh '''
                        echo "🔑 Setting up kubeconfig for AWS EKS..."
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER} --kubeconfig kubeconfig.yaml
                        export KUBECONFIG=kubeconfig.yaml
                        echo "✅ Kubeconfig setup complete"
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "🚀 Running deploy.sh ..."
                    chmod +x deploy.sh
                    export KUBECONFIG=kubeconfig.yaml
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
