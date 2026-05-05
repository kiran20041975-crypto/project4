pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'kiran1975'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kiran20041975-crypto/project4.git'
            }
        }

        stage('Debug Files') {
            steps {
                sh 'pwd'
                sh 'ls -l'
                sh 'ls -l userservice || true'
                sh 'ls -l productservice || true'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh "docker build -t ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ./userservice"
                sh "docker build -t ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ./productservice"

                sh "docker tag ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ${DOCKERHUB_USER}/user-service:latest"
                sh "docker tag ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ${DOCKERHUB_USER}/product-service:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                    sh "docker push ${DOCKERHUB_USER}/user-service:${IMAGE_TAG}"
                    sh "docker push ${DOCKERHUB_USER}/user-service:latest"

                    sh "docker push ${DOCKERHUB_USER}/product-service:${IMAGE_TAG}"
                    sh "docker push ${DOCKERHUB_USER}/product-service:latest"
                }
            }
        }

        // ✅ FIXED DEPLOY STAGE
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {

                    sh '''
                    export AWS_DEFAULT_REGION=ap-south-1

                    echo "🔐 Checking AWS identity..."
                    aws sts get-caller-identity

                    echo "⚙️ Updating kubeconfig..."
                    aws eks update-kubeconfig \
                      --region ap-south-1 \
                      --name ecom-eks

                    echo "📡 Testing cluster connection..."
                    kubectl get nodes

                    echo "🚀 Deploying app..."
                    kubectl apply -f k8s/ --validate=false

                    kubectl set image deployment/user-service user-service=''' + DOCKERHUB_USER + '''/user-service:${IMAGE_TAG}
                    kubectl set image deployment/product-service product-service=''' + DOCKERHUB_USER + '''/product-service:${IMAGE_TAG}

                    kubectl rollout status deployment/user-service
                    kubectl rollout status deployment/product-service
                    '''
                }
            }
        }

        stage('Canary Deploy (User Service)') {
            steps {
                sh "docker tag ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ${DOCKERHUB_USER}/user-service:canary"
                sh "docker push ${DOCKERHUB_USER}/user-service:canary"

                sh "kubectl apply -f k8s/canary-user.yaml --validate=false || true"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}