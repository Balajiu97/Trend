pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'balajiyuva'
        DOCKER_IMAGE = 'trend-app-project'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Balajiu97/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_HUB_USER/$DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_HUB_USER/$DOCKER_IMAGE:$BUILD_NUMBER'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/trend-app trend=$DOCKER_HUB_USER/$DOCKER_IMAGE:$BUILD_NUMBER --record
                kubectl rollout status deployment/trend-app
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build, Push, Deploy successful!"
        }
        failure {
            echo "❌ Build or Deploy failed."
        }
    }
}


