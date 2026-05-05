pipeline {
    agent any
    
    environment {
        // Docker Hub credentials
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_HUB_REPO = 'saigorijala/microservices-app'
        APP_PORT = '3002'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/SaiGorijala/microservices-.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${DOCKER_HUB_REPO}:latest .
                    docker tag ${DOCKER_HUB_REPO}:latest ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "Pushing image to Docker Hub..."
                    echo "${DOCKER_HUB_CREDENTIALS_PSW}" | docker login -u "${DOCKER_HUB_CREDENTIALS_USR}" --password-stdin
                    docker push ${DOCKER_HUB_REPO}:latest
                    docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Deploy Docker Container') {
            steps {
                sh '''
                    echo "Deploying container..."
                    
                    # Stop and remove existing container if running
                    docker stop microservices-app 2>/dev/null || true
                    docker rm microservices-app 2>/dev/null || true
                    
                    # Run new container
                    docker run -d \
                      --name microservices-app \
                      -p ${APP_PORT}:${APP_PORT} \
                      --restart unless-stopped \
                      ${DOCKER_HUB_REPO}:latest
                    
                    # Verify container is running
                    sleep 5
                    if docker ps | grep -q microservices-app; then
                        echo "Application deployed successfully on port ${APP_PORT}"
                        docker ps --filter "name=microservices-app"
                    else
                        echo "Container failed to start"
                        docker logs microservices-app --tail 50
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            script {
                echo "Pipeline execution completed for build ${BUILD_NUMBER}"
                sh 'docker image prune -f --filter "until=24h" || echo "Cleanup skipped"'
            }
        }
        
        success {
            echo "Pipeline completed successfully! ✅"
        }
        
        failure {
            echo "Pipeline failed! ❌"
            script {
                sh 'docker logs microservices-app --tail 50 2>/dev/null || echo "No container logs"'
            }
        }
    }
}
