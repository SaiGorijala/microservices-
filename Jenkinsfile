pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_HUB_REPO = 'saigorijala/microservices-app'
        APP_PORT = '3002'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/SaiGorijala/microservices-.git',
                    credentialsId: '2ccd5f53-df6a-46a0-9876-c85853d96da0'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    cd /var/jenkins_home/workspace/jenkins
                    docker build -t ${DOCKER_HUB_REPO}:latest .
                    docker tag ${DOCKER_HUB_REPO}:latest ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "Logging into Docker Hub..."
                    echo "${DOCKER_HUB_CREDENTIALS_PSW}" | docker login -u "${DOCKER_HUB_CREDENTIALS_USR}" --password-stdin
                    
                    echo "Pushing image to Docker Hub..."
                    docker push ${DOCKER_HUB_REPO}:latest
                    docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                    
                    docker logout
                    echo "Push completed!"
                '''
            }
        }
        
        stage('Deploy Container') {
            steps {
                sh '''
                    echo "Deploying container..."
                    
                    # Stop and remove existing container
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
                        echo "✅ Application deployed successfully on port ${APP_PORT}"
                        docker ps --filter "name=microservices-app"
                    else
                        echo "❌ Container failed to start"
                        docker logs microservices-app --tail 50
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo "🎉 Pipeline completed successfully! 🎉"
        }
        failure {
            echo "💥 Pipeline failed! 💥"
            sh 'docker logs microservices-app --tail 100 2>/dev/null || echo "No logs available"'
        }
        always {
            echo "Pipeline execution finished for build ${BUILD_NUMBER}"
            sh 'docker image prune -f --filter "until=24h" 2>/dev/null || true'
        }
    }
}
