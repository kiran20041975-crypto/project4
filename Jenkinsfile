pipeline {
agent any

environment {
DOCKERHUB_USER = 'kiran1975'
IMAGE_TAG = "${BUILD_NUMBER}"
KUBECONFIG = '/var/lib/jenkins/jenkins-kubeconfig.yaml'
}

stages {

```
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

// 🔹 Build all microservices
stage('Build Docker Images') {
  steps {
    sh "docker build -t ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ./userservice"
    sh "docker build -t ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ./productservice"

    sh "docker tag ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ${DOCKERHUB_USER}/user-service:latest"
    sh "docker tag ${DOCKERHUB_USER}/product-service:${IMAGE_TAG} ${DOCKERHUB_USER}/product-service:latest"
  }
}

// 🔹 Push all images
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

// 🔹 Deploy to Kubernetes
stage('Deploy to Kubernetes') {
  steps {
    sh "kubectl apply -f k8s/ --validate=false"

    sh "kubectl set image deployment/user-service user-service=${DOCKERHUB_USER}/user-service:${IMAGE_TAG}"
    sh "kubectl set image deployment/product-service product-service=${DOCKERHUB_USER}/product-service:${IMAGE_TAG}"

    sh "kubectl rollout status deployment/user-service"
    sh "kubectl rollout status deployment/product-service"
  }
}

// 🔹 Canary (optional advanced)
stage('Canary Deploy (User Service)') {
  steps {
    sh "docker tag ${DOCKERHUB_USER}/user-service:${IMAGE_TAG} ${DOCKERHUB_USER}/user-service:canary"
    sh "docker push ${DOCKERHUB_USER}/user-service:canary"

    sh "kubectl apply -f k8s/canary-user.yaml --validate=false || true"
  }
}
```

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
