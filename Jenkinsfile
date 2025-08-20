pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "balajiyuva/trend-app-project"
        DOCKER_TAG   = "7"
        AWS_REGION   = "us-east-1"          // <-- change to your EKS region
        EKS_CLUSTER  = "my-cluster-v2"     // <-- change to your EKS cluster name
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
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
                          credentialsId: 'aws-eks-creds']]) {
            sh '''
                echo "🔑 Setting up kubeconfig for AWS EKS..."
                export KUBECONFIG=/var/lib/jenkins/.kube/config
                aws eks update-kubeconfig --region us-east-1 --name my-cluster-v2
                echo "✅ Kubeconfig setup complete"
                kubectl get svc
            '''
        }
    }
}

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                   echo "🚀 Deploying new image to Kubernetes..."
                   kubectl set image deployment/trend-app trend=${DOCKER_IMAGE}:${DOCKER_TAG}
                   kubectl rollout status deployment/trend-app
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

