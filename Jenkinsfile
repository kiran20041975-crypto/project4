pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        AWS_REGION = 'ap-south-1'
    }

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kiran20041975-crypto/project4.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker build -t kiran/user-service ./userservice'
                sh 'docker build -t kiran/product-service ./productservice'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push kiran/user-service'
                    sh 'docker push kiran/product-service'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
