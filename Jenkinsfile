pipeline {
  environment {
    registry = "romancin/tinymediamanager"
    registryCredential = 'dockerhub'
  }
  agent any
  stages {
    stage('Cloning Git Repository') {
      steps {
        git url: 'https://github.com/romancin/tinymediamanager-docker.git',
            branch: 'develop'
      }
    }
    stage('Building image and pushing it to the registry') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        def image = docker.build registry + ":develop"
                        image.push()
                    }
                }
            }
    }
 }
 post {
        success {
            telegramSend '[Jenkins] - Pipeline CI-tinymediamanager-docker $BUILD_URL finalizado con estado :: $BUILD_STATUS'    
        }
    }
}
