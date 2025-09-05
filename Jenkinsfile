// Jenkinsfile
pipeline {
  agent any
  parameters {
    string(name: 'DOCKER_REGISTRY', defaultValue: 'docker.io', description: 'Docker registry (docker.io for Docker Hub)')
    string(name: 'DOCKER_REPO', defaultValue: 'yourdockerhubusername/redbus', description: 'Repo prefix e.g. user/repo')
    booleanParam(name: 'PUSH_TO_REGISTRY', defaultValue: false, description: 'Push built images to registry?')
    booleanParam(name: 'LOCAL_DEPLOY', defaultValue: true, description: 'Deploy on this Jenkins host (true) or SSH deploy (false)')
    string(name: 'REMOTE_HOST', defaultValue: 'user@your.server', description: 'Remote deploy target for SSH (if LOCAL_DEPLOY=false)')
    string(name: 'REMOTE_PATH', defaultValue: '/home/deploy', description: 'Remote path to place docker-compose.yml')
  }

  environment {
    BACKEND_IMAGE = "${params.DOCKER_REPO}:backend-${env.BUILD_NUMBER}"
    FRONTEND_IMAGE = "${params.DOCKER_REPO}:frontend-${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build backend image') {
      steps {
        sh "docker build -f back-end-redbus/Dockerfile -t ${env.BACKEND_IMAGE} ."
      }
    }

    stage('Build frontend image') {
      steps {
        // set REACT_APP_API_URL so SPA points to backend service name when running in compose
        sh "docker build --build-arg REACT_APP_API_URL=http://backend:5000 -f front-end-redbus/Dockerfile -t ${env.FRONTEND_IMAGE} ."
      }
    }

    stage('Push images (optional)') {
      when {
        expression { return params.PUSH_TO_REGISTRY }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin ${params.DOCKER_REGISTRY}"
          sh "docker push ${env.BACKEND_IMAGE}"
          sh "docker push ${env.FRONTEND_IMAGE}"
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          if (params.LOCAL_DEPLOY.toBoolean()) {
            // Deploy on same host (Jenkins agent). Uses deploy/docker-compose.yml but you may modify to use local build images.
            sh "cp deploy/docker-compose.yml /tmp/deploy-docker-compose.yml"
            // Replace image names in compose with the built tags
            sh "sed -i 's|yourdockerhubusername/redbus-backend:latest|${env.BACKEND_IMAGE}|g' /tmp/deploy-docker-compose.yml || true"
            sh "sed -i 's|yourdockerhubusername/redbus-frontend:latest|${env.FRONTEND_IMAGE}|g' /tmp/deploy-docker-compose.yml || true"
            sh "docker compose -f /tmp/deploy-docker-compose.yml up -d --remove-orphans"
          } else {
            // SSH deploy to remote host (uses deploy/deploy.sh). Make sure SSH credentials are configured (see README).
            sshagent(['deploy-ssh']) {
              sh "./deploy/deploy.sh ${params.REMOTE_HOST} ${params.REMOTE_PATH} deploy/docker-compose.yml"
            }
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" || true'
    }
  }
}
