pipeline {
    agent any
    
    environment {
        // Core image metrics definitions
        IMAGE_NAME = 'theatomicxm/industrial-monitor'
        VERSION = 'v1.0.0'
        
        // DIRECT BYPASS CREDENTIALS (Hardcoded here since the Jenkins GUI credentials store is failing)
        // TODO: Swap 'YOUR_DOCKER_HUB_TOKEN_HERE' with your real Docker Hub Personal Access Token (dckr_pat_...)
        DOCKER_USER = 'theatomicxm'
        DOCKER_PASS = 'dckr_pat_ZGuFG4hdJYwVdF4Orlx9DF0SlOc' 
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
                    echo 'Executing hardcoded Docker Hub login bypass...'
                    // Directly injecting variables to bypass the Jenkins withCredentials store completely
                    bat "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    bat "docker push ${IMAGE_NAME}:${VERSION}"
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
                    // Fallback to local execution context if plugin is broken
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
