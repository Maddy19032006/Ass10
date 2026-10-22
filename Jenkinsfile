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
                        // Added /I for case-insensitive verification scanning
                        bat 'findstr /I "html" index.html'
                    }
                }
                stage('Docker Specifications Check') {
                    steps {
                        echo 'Validating runtime context parameters...'
                        // Added /I for case-insensitive verification scanning
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
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        bat "echo %PASS% | docker login -u %USER% --password-stdin"
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
                    withKubeConfig([credentialsId: 'kubernetes-config-id']) {
                        bat "kubectl apply -f deployment.yaml"
                        bat "kubectl rollout status deployment/industrial-monitor --timeout=60s"
                    }
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
