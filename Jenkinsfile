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
                        // Changed 'sh' to Windows findstr equivalent 'bat'
                        bat 'findstr "<html>" index.html'
                    }
                }
                stage('Docker Specifications Check') {
                    steps {
                        echo 'Validating runtime context parameters...'
                        // Changed 'sh' to Windows findstr equivalent 'bat'
                        bat 'findstr "FROM nginx" dockerfile'
                    }
                }
            }
        }
        
        stage('Build & Build Verification') {
            steps {
                script {
                    // Changed to 'bat' for Windows execution
                    bat "docker build -t ${IMAGE_NAME}:${VERSION} ."
                    bat "docker run --rm ${IMAGE_NAME}:${VERSION} nginx -t"
                }
            }
        }
        
        stage('Publish Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // Changed to 'bat' for Windows authentication sequence
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
                    // Changed to 'bat' execution for cluster deployment tracking
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
            // Changed to 'bat' for post action cleanup
            bat "docker logout"
        }
    }
}
