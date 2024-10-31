// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.34.0')

def checkout_shallow()
{
    checkout scm: [
        $class: 'GitSCM',
        branches: scm.branches,
        userRemoteConfigs: scm.userRemoteConfigs,
        extensions: [[$class: 'CloneOption', depth: 1, shallow: true, noTags: false]]
    ]
}

def runningOn(machine) {
    println 'Stage running on:'
    println machine
}

def archiveSandbox(String repoName) {
    sh "cp ${WORKSPACE}/${repoName}/build/manifest.txt ${WORKSPACE}"
    sh "rm -rf .get_tools .venv"
    sh "git -C ${repoName} clean -xdf"
    def repoNameUpper = repoName.toUpperCase()
    zip zipFile: "${repoNameUpper}_sw.zip", archive: true, defaultExcludes: false
}

getApproval()
pipeline {
    agent {label 'documentation'}
    environment {
      REPO_NAME = 'an01009'
    }
    parameters {
      string(
        name: 'TOOLS_VERSION',
        defaultValue: '15.3.0',
        description: 'XTC tools version'
      )
      string(
        name: 'XMOSDOC_VERSION',
        defaultValue: 'v6.1.2',
        description: 'xmosdoc version'
      )
    } // parameters

    options {
        skipDefaultCheckout()
        timestamps()
        buildDiscarder(xmosDiscardBuildSettings(onlyArtifacts = false))
    } // options

    stages {
      stage('Checkout') {
        steps {
          runningOn(env.NODE_NAME)
          dir(REPO_NAME) {
            checkout_shallow()
          } // dir
        } // steps
      } // checkout

      stage('Code Build') {
        steps {
          dir(REPO_NAME) { withTools(params.TOOLS_VERSION) {
            sh "cmake -G 'Unix Makefiles' -B build -DDEPS_CLONE_SHALLOW=TRUE"
            sh 'xmake -C build'
          } } // tools, dir
        } // steps
      } // build

      stage('Doc Build') {
        steps {
          dir(REPO_NAME) { withTools(params.TOOLS_VERSION) {
            buildDocs()
          } } // tools, dir
        } // steps
      } // docs

      stage("Archive Sandbox") {
        steps {archiveSandbox(REPO_NAME)} // steps
      } // archive

    } // stages
    post {cleanup {xcoreCleanSandbox()}} // post
} // pipeline
