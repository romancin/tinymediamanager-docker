registry="romancin/tinymediamanager"

podTemplate(label: 'github-docker-builder', cloud: 'kubernetes', serviceAccount: 'jenkins',
  containers: [
    containerTemplate(name: 'buildkit', image: 'moby/buildkit:master', ttyEnabled: true, privileged: true),
  ],
  volumes: [
    secretVolume(secretName: 'docker-config', mountPath: '/root/.docker')
  ]) {
    node('github-docker-builder') {
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
            container('buildkit') {
                script {
                  def gitbranch = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                  def version = readFile('VERSION')
                  def versions = version.split('\\.')
                  def major = gitbranch + '-' + versions[0]
                  def minor = gitbranch + '-' + versions[0] + '.' + versions[1]
                  def patch = gitbranch + '-' + version.trim()
                }
                sh """
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${gitbranch}-v3,push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${major},push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${minor},push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${patch},push=true
                   """
            }
          }
        }
        stage('Building image and pushing it to the registry (main)') {
          when{
            branch 'main'
          }
          steps {
            container('buildkit') {
                script {
                  def gitbranch = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                  def version = readFile('VERSION')
                  def versions = version.split('\\.')
                  def major = gitbranch + '-' + versions[0]
                  def minor = gitbranch + '-' + versions[0] + '.' + versions[1]
                  def patch = gitbranch + '-' + version.trim()
                }
                sh """
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:latest-v3,push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${major},push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${minor},push=true
                     buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${registry}:${patch},push=true
                   """
            }
          }
        }
}

properties([[
    $class: 'BuildDiscarderProperty',
    strategy: [
        $class: 'LogRotator',
        artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10']
    ]
]);


  post {
        success {
            telegramSend(message: '[Jenkins] - Pipeline CI-tinymediamanager-docker $BUILD_URL finalizado con estado :: $BUILD_STATUS', chatId: -395961814) }
  }
}
