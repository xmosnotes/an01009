// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.40.0') _

getApproval()
pipeline {
    agent {
        label 'documentation'
    }
    parameters {
        string(
            name: 'TOOLS_VERSION',
            defaultValue: '15.3.1',
            description: 'XTC tools version'
        )
        string(
            name: 'XMOSDOC_VERSION',
            defaultValue: 'v7.3.0',
            description: 'xmosdoc version'
        )
        string(
            name: 'INFR_APPS_VERSION',
            defaultValue: 'v3.1.0',
            description: 'The infr_apps version'
        )
    }

    options {
        skipDefaultCheckout()
        timestamps()
        buildDiscarder(xmosDiscardBuildSettings(onlyArtifacts = false))
    }

    stages {
        stage('Checkout') {
            steps{

                println "Stage running on ${env.NODE_NAME}"

                script {
                    def (server, user, repo) = extractFromScmUrl()
                    env.REPO_NAME = repo
                }

                dir(REPO_NAME)
                {
                    checkoutScmShallow()
                }
            }
        }

        stage('Code build') {
            steps{
                dir(REPO_NAME) {
                    xcoreBuild()
                }
            }
        }

        stage('Repo checks') {
            steps {
                warnError("Repo checks failed")
                {
                    runRepoChecks("${WORKSPACE}/${REPO_NAME}", "${params.INFR_APPS_VERSION}")
                }
            }
        }

        stage('Doc build') {
            steps {
                dir(REPO_NAME) {
                    buildDocs()
                }
            }
        }

        stage("Archive sandbox") {
            steps
            {
                archiveSandbox(REPO_NAME)
            }
        }

    } // stages
    post
    {
        cleanup
        {
             xcoreCleanSandbox()
        }
    }
} // pipeline
