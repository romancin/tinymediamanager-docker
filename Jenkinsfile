pipeline {
  environment {
    registry = "romancin/tinymediamanager"
    repository = "tinymediamanager"
    withCredentials = 'dockerhub'
    registryCredential = 'dockerhub'
  }
  agent any
  stages {
    stage('Cloning Git Repository') {
      steps {
        git url: 'https://github.com/romancin/tinymediamanager-docker.git',
            branch: '$BRANCH_NAME'
      }
    }
    stage('Building image and pushing it to the registry (develop)') {
      when{
        branch 'develop'
        }
      steps {
        script {
          def gitbranch = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
          def version = readFile('VERSION')
          def versions = version.split('\\.')
          def major = gitbranch + '-' + versions[0]
          def minor = gitbranch + '-' + versions[0] + '.' + versions[1]
          def patch = gitbranch + '-' + version.trim()
          docker.withRegistry('', registryCredential) {
            def image = docker.build("$registry:$gitbranch",  "-f Dockerfile .")
            image.push()
            image.push(major)
            image.push(minor)
            image.push(patch)
            }
        }
      }
    }
    stage('Building image and pushing it to the registry (master)') {
      when{
        branch 'master'
        }
      steps {
        script {
          def version = readFile('VERSION')
          def versions = version.split('\\.')
          def major = versions[0]
          def minor = versions[0] + '.' + versions[1]
          def patch = version.trim()
          docker.withRegistry('', registryCredential) {
            def image = docker.build("$registry:latest", "-f Dockerfile .")
            image.push()
            image.push(major)
            image.push(minor)
            image.push(patch)
            }
        }
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
          docker.image('sheogorath/readme-to-dockerhub').run('-v $PWD:/data -e DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME -e DOCKERHUB_PASSWORD=$DOCKERHUB_PASSWORD -e DOCKERHUB_REPO_NAME=$repository')
          }
        }
      }
    }
  }
  post {
        success {
            telegramSend(message: '[Jenkins] - Pipeline QNAP Backup to Synology $BUILD_URL finalizado con estado :: $BUILD_STATUS', chatId: -395961814) }
  }
 }
