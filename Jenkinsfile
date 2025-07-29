// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@feature/release_flow_2') _

getApproval()
pipeline {

    agent none

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
        booleanParam(
            name: 'TRIGGER_RELEASE',
            defaultValue: false,
            description: '''WARNING:
              Only press if you are happy to be noted as the deployer of this release.
              Make sure it is reviewed and of release quality!'''
        )
    }

    options {
        skipDefaultCheckout()
        timestamps()
        buildDiscarder(xmosDiscardBuildSettings(onlyArtifacts = false))
    }

    stages {
        stage('🏗️ Build and test') {
            agent {
                label "documentation"
            }

            stages {
                stage('Checkout') {
                    steps {

                        println "Stage running on ${env.NODE_NAME}"

                        script {
                            def (server, user, repo) = extractFromScmUrl()
                            env.REPO_NAME = repo
                            env.REPO = repo // For triggerRelease
                        }

                        dir(REPO_NAME)
                        {
                            checkoutScmShallow()
                        }
                    }
                }

                stage('Code build') {
                    steps {
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
            post {
                cleanup
                {
                    xcoreCleanSandbox()
                }
            }
        } // stage 'Build and test'

        stage('🚀 Release') {
            when {
                expression { params.TRIGGER_RELEASE }
            }
            steps {
                triggerRelease()
            }
        }
    } // stages
} // pipeline
