pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'kiran1975'
        IMAGE_TAG = "${BUILD_NUMBER}"
        NAMESPACE = 'ecommerce'
        CLUSTER_NAME = 'ecom-eks'
        AWS_REGION = 'ap-south-1'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kiran20041975-crypto/project4.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh """
                docker build -t ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ./userservice
                docker build -t ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ./productservice

                docker tag ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ${DOCKERHUB_USER}/user-service:latest
                docker tag ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ${DOCKERHUB_USER}/product-service:latest
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin

                    docker push ${DOCKERHUB_USER}/user-service:${IMAGE_TAG}
                    docker push ${DOCKERHUB_USER}/user-service:latest

                    docker push ${DOCKERHUB_USER}/product-service:${IMAGE_TAG}
                    docker push ${DOCKERHUB_USER}/product-service:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {

                    sh """
                    export AWS_DEFAULT_REGION=${AWS_REGION}

                    echo "🔐 Checking AWS identity..."
                    aws sts get-caller-identity

                    echo "⚙️ Updating kubeconfig..."
                    aws eks update-kubeconfig \
                      --region ${AWS_REGION} \
                      --name ${CLUSTER_NAME}

                    echo "📡 Cluster nodes:"
                    kubectl get nodes

                    echo "🚀 Applying Kubernetes manifests..."
                    kubectl apply -f k8s/ -n ${NAMESPACE} --validate=false

                    echo "⏳ Waiting for deployments to be ready..."
                    kubectl rollout status deployment/user-service -n ${NAMESPACE}
                    kubectl rollout status deployment/product-service -n ${NAMESPACE}

                    echo "📦 Updating images..."
                    kubectl set image deployment/user-service \
                      user-service=${DOCKERHUB_USER}/user-service:${IMAGE_TAG} -n ${NAMESPACE}

                    kubectl set image deployment/product-service \
                      product-service=${DOCKERHUB_USER}/product-service:${IMAGE_TAG} -n ${NAMESPACE}

                    echo "⏳ Waiting for rollout after update..."
                    kubectl rollout status deployment/user-service -n ${NAMESPACE}
                    kubectl rollout status deployment/product-service -n ${NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded! Deployment updated successfully.'
        }
        failure {
            echo '❌ Pipeline failed! Check logs for errors.'
        }
    }
}