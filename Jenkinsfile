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
                        sh 'grep -q "<html>" index.html'
                    }
                }
                stage('Docker Specifications Check') {
                    steps {
                        echo 'Validating runtime context parameters...'
                        sh 'grep -q "FROM nginx" Dockerfile'
                    }
                }
            }
        }
        
        stage('Build & Build Verification') {
            steps {
                script {
                    // Build container image locally
                    sh "docker build -t ${IMAGE_NAME}:${VERSION} ."
                    
                    // Verify the container runs and returns a valid code
                    sh "docker run --rm ${IMAGE_NAME}:${VERSION} nginx -t"
                }
            }
        }
        
        stage('Publish Image') {
            steps {
                script {
                    // Authenticate and push image to Registry storage
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${VERSION}"
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
                    // Execute local cluster apply configuration
                    withKubeConfig([credentialsId: 'kubernetes-config-id']) {
                        sh "kubectl apply -f deployment.yaml"
                        
                        // Verification validation checks
                        sh "kubectl rollout status deployment/industrial-monitor --timeout=60s"
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh "docker logout"
        }
    }
}
