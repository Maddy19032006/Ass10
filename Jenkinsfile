pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY_CREDENTIALS = 'dockerhub-credentials-id' 
        IMAGE_NAME = 'theatomicxm/industrial-monitor'
        VERSION = 'v1.0.0'
    }
    
    stages {
        stage('Pull Code') {
            steps {
                cleanWs()
                checkout scm
            }
        }
        
        stage('Parallel Code Verification') {
            parallel {
                stage('Static HTML Analysis') {
                    steps {
                        echo 'Checking document structural integrity...'
                        bat 'findstr /I "html" index.html'
                    }
                }
                stage('Docker Specifications Check') {
                    steps {
                        echo 'Validating runtime context parameters...'
                        bat 'findstr /I "FROM nginx" dockerfile'
                    }
                }
            }
        }
        
        stage('Build & Build Verification') {
            steps {
                script {
                    bat "docker build -t ${IMAGE_NAME}:${VERSION} ."
                    bat "docker run --rm ${IMAGE_NAME}:${VERSION} nginx -t"
                }
            }
        }
        
        stage('Publish Image') {
            steps {
                script {
                    // Leverages the Jenkins credential manager safely
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // Using double quotes allows Jenkins to hide strings as **** in logs
                        bat "echo %PASS%| docker login -u %USER% --password-stdin"
                        bat "docker push ${IMAGE_NAME}:${VERSION}"
                    }
                }
            }
        }
        
        stage('Conditional Kubernetes Deployment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Deploying application to local cluster topology...'
                    bat "kubectl apply -f deployment.yaml"
                    bat "kubectl rollout status deployment/industrial-monitor --timeout=60s"
                }
            }
        }
    }
    
    post {
        always {
            bat "docker logout"
        }
    }
}
