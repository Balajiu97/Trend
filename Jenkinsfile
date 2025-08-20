pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'balajiyuva'
        DOCKER_IMAGE = 'trend-app-project'
        DOCKER_REPO = "${DOCKER_HUB_USER}/${DOCKER_IMAGE}"
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-eks'
        DOCKER_CREDS_ID = 'dockerhub_credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/<your-repo>.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${DOCKER_REPO}:${BUILD_NUMBER} .
                  docker tag ${DOCKER_REPO}:${BUILD_NUMBER} ${DOCKER_REPO}:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                      echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                      docker push ${DOCKER_REPO}:${BUILD_NUMBER}
                      docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }

        stage('Setup Kubeconfig') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG_FILE')]) {
                    sh """
                      mkdir -p \$HOME/.kube
                      cp "\$KUBECONFIG_FILE" \$HOME/.kube/config
                      export KUBECONFIG=\$HOME/.kube/config
                      kubectl cluster-info
                      kubectl get nodes
                    """
                }
            }
        }

        stage('Apply Manifests (first/any run)') {
            steps {
                sh """
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                """
            }
        }

        stage('Rollout New Image') {
            steps {
                sh """
                  kubectl set image deployment/trend-app trend=${DOCKER_REPO}:${BUILD_NUMBER}
                  kubectl rollout status deployment/trend-app
                """
            }
        }
    }

    post {
        success { echo "✅ Build, Push, Deploy successful!" }
        failure { echo "❌ Build or Deploy failed." }
    }
}
