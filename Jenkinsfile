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
        pipeline("${JENKINS_VERSION}", "${JENKINS_UID}", "${JENKINS_GID}", "${COMPOSE_VERSION}")
    }
    catch(e) {
        throw e
    }
    finally {
        cleanup()        
    }
}

def pipeline(jenkinsVersion, jenkinsUid, jenkinsGid, composeVersion) {
    stage('checkout') {
        checkout scm
    }

    stage('image build') {
        DOCKER_IMAGE = docker.build(
            "${DOCKER_REGISTRY}/${DOCKER_REPO}:${jenkinsVersion}",
            "--build-arg JENKINS_VERSION=${jenkinsVersion} " +
            "--build-arg JENKINS_UID=${jenkinsUid} " +
            "--build-arg JENKINS_GID=${jenkinsGid} " +
            "--build-arg COMPOSE_VERSION=${composeVersion} " +
            "--no-cache ${DOCKER_ARGS} ."
        )
    }

    stage('push image') {
        def shortHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        DOCKER_IMAGE.push()
        DOCKER_IMAGE.push(shortHash)
    }
}

def cleanup() {
    stage('schedule cleanup') {
        build job: '../Maintenance/dangling-container-cleanup', wait: false
    }
}
