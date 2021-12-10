DOCKER_IMAGE = ''
DOCKER_ARGS = '--network=services_default'
DOCKER_REGISTRY = 'registry.n-os.org:5000'
DOCKER_REPO = "${JOB_BASE_NAME}"

properties([
    parameters([
        string(defaultValue: '2.324', name: 'JENKINS_VERSION', description: "Jenkins version upstream docker image"),
        string(defaultValue: '1010', name: 'JENKINS_UID', description: "Jenkins user UID in image"),
        string(defaultValue: '120', name: 'JENKINS_GID', description: "Jenkins user GID in image"),
        string(defaultValue: '2.2.2', name: 'COMPOSE_VERSION', description: "Docker Compose version for image")
    ])
])

node {
    try {
        pipeline()
    }
    catch(e) {
        setBuildStatus(e.toString().take(140), 'FAILURE')
        throw e
    }
    finally {
        cleanup()        
    }
}

def pipeline() {
    stage('checkout') {
        checkout scm
        setBuildStatus('In progress...', 'PENDING')
    }

    stage('image build') {
        DOCKER_IMAGE = docker.build(
            "${DOCKER_REGISTRY}/${DOCKER_REPO}:${JENKINS_VERSION}",
            "--build-arg JENKINS_VERSION=${JENKINS_VERSION} " +
            "--build-arg JENKINS_UID=${JENKINS_UID} " +
            "--build-arg JENKINS_GID=${JENKINS_GID} " +
            "--build-arg COMPOSE_VERSION=${COMPOSE_VERSION} " +
            "--no-cache ${DOCKER_ARGS} ."
        )
    }

    stage('push image') {
        def shortHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        DOCKER_IMAGE.push()
        DOCKER_IMAGE.push(shortHash)
        setBuildStatus('Success', 'SUCCESS')
    }
}


// --- standard helper functions ---
def cleanup() {
    stage('schedule cleanup') {
        build job: '../Maintenance/dangling-container-cleanup', wait: false
    }
}

void setBuildStatus(message, state) {
  def repoUrl = sh(script: 'git config --get remote.origin.url', returnStdout: true).trim()
  echo repoUrl
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}
