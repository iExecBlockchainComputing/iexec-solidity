node("master") {
	stage("Choose Label") {
		LABEL = "jenkins-agent-machine-1"
	}
}

pipeline {

	environment {
		registry = "nexus.iex.ec"
		dockerImage1sec = ""
		dockerImage20sec = ""
		buildWhenTagContains = "lv"
	}

	agent {
		node {
			label "${LABEL}"
		}
	}

	stages {

		stage("Truffle tests") {
			agent {
				docker {
					image "node:11"
					label "${LABEL}"
				}
			}
			steps {
				script {
					try {
						sh "npm install"
						sh "npm run autotest fast"
					} finally {
						archiveArtifacts artifacts: "logs/**"
					}
				}
			}
		}

		stage("Solidity coverage") {
			agent {
				docker {
					image "node:11"
					label "${LABEL}"
				}
			}
			steps {
				script {
					try {
						sh "npm install"
						sh "npm run coverage"
					} finally {
						archiveArtifacts artifacts: "coverage/**"
					}
				}
			}
		}
	}
}
