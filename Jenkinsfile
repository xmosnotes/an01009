// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.33.0')

def runningOn(machine) {
    println 'Stage running on:'
    println machine
}

def buildDocs(String repoName) {
    withVenv {
        sh "pip install git+ssh://git@github.com/xmos/xmosdoc@v${params.XMOSDOC_VERSION}"
        sh 'xmosdoc'
        def repoNameUpper = repoName.toUpperCase()
        zip zipFile: "${repoNameUpper}_docs.zip", archive: true, dir: 'doc/_build'
    }
}

def archiveSandbox(String repoName) {
    sh "cp ${WORKSPACE}/${repoName}/build/manifest.txt ${WORKSPACE}"
    sh "rm -rf .get_tools .venv"
    sh "git -C ${repoName} clean -xdf"
    sh "cp ${WORKSPACE}/manifest.txt ${WORKSPACE}/${repoName}"
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
        defaultValue: '6.1.2',
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
        steps{
          runningOn(env.NODE_NAME)
          dir(REPO_NAME) {
            withTools(params.TOOLS_VERSION) {
              checkout scm
              createVenv()
            } // tools
          } // dir
        } // steps
      } // checkout

      stage('Code Build') {
        steps{
          dir(REPO_NAME) { withTools(params.TOOLS_VERSION) { withVenv {
            sh "cmake -G 'Unix Makefiles' -B build -DDEPS_CLONE_SHALLOW=TRUE"
            sh 'xmake -C build'
          } } } // venv, tools, dir
        } // steps
      } // build

      stage('Doc Build') {
        steps {
          dir(REPO_NAME) { withTools(params.TOOLS_VERSION) { withVenv {
            buildDocs(REPO_NAME)
          } } } // venv, tools, dir
        } // steps
      } // docs

      stage("Archive Sandbox") {
        steps {archiveSandbox(REPO_NAME)} // steps
      } // archive

    } // stages
    post {cleanup {cleanWs()}} // post
} // pipeline
