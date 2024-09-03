pipeline {
    agent any
	
	  environment {
        SONARQUBE_SERVER = 'mysonarserver'
        SONARQUBE_PROJECT_KEY = 'java-sonar-runner-simple1'
        SONARQUBE_PROJECT_NAME = 'Simple-Java-project-analyzed-with-the-SonarQube-Runner'
		// This can be nexus3 or nexus2
        NEXUS_VERSION = "nexus3"
        // This can be http or https
        NEXUS_PROTOCOL = "http"
        // Where your Nexus is running
        NEXUS_URL = "65.0.106.189:8081"
        // Repository where we will upload the artifact
        NEXUS_REPOSITORY = "spring3"
        // Jenkins credential id to authenticate to Nexus OSS
        NEXUS_CREDENTIAL_ID = "nexus_credentials"
		registry = "mashood6106/spring3"
        registryCredential = 'dockerhub_credentials'
        dockerImage = ''
		KUBECONFIG = '/root/.kube/config'
    }
	
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/mashood6106/spring3-mvc-maven-xml-hello-world.git', branch: 'master'
            }
        }
        stage('Build') {
		     tools {
                    jdk 'jdk11'
                  }
            steps { 
                sh 'mvn clean package'
            }
        }
		
		stage('SonarQube Analysis') {
		     
			tools {
                  jdk 'jdk17'
               }
		 
            steps {
                script {
                    def scannerHome = tool 'mysonarscanner'
                    withSonarQubeEnv(SONARQUBE_SERVER) {
                        sh "${scannerHome}/bin/sonar-scanner " +
                           "-Dsonar.projectKey=${SONARQUBE_PROJECT_KEY} " +
                           "-Dsonar.projectName=${SONARQUBE_PROJECT_NAME} " +
                           "-Dsonar.sources=src "
                    }
                }
            }
        }
		
		stage("publish to nexus") {
            steps {
                script {
                    // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                    pom = readMavenPom file: "pom.xml";
                    // Find built artifact under target folder
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    // Print some info from the artifact found
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    // Extract the path from the File found
                    artifactPath = filesByGlob[0].path;
                    // Assign to a boolean response verifying If the artifact name exists
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                // Artifact generated such as .jar, .ear and .war files.
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                // Lets upload the pom.xml file for additional information for Transitive dependencies
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                     sh "curl -v  ${NEXUS_PROTOCOL}://${NEXUS_URL}/repository/${NEXUS_REPOSITORY}/com/mkyong/${pom.artifactId}/${BUILD_NUMBER}/${pom.artifactId}-${BUILD_NUMBER}.${pom.packaging} -o result.war"   
                
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
		 
		 stage('Building image') {
           steps {
             script {
                dockerImage = docker.build registry + ":v1"
        }
      }
    }
	
	    stage('push image') {
      steps {
        script {
           docker.withRegistry( '', registryCredential ) {
              dockerImage.push()
          }
        }
      }
    }
	
	  stage('Remove old docker image') {
      steps {
        sh "docker rmi $registry:v1"
      }
    }
	
	  stage('Apply Kubernetes Manifests') {
            steps {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
	
	post {
        always {
            cleanWs() 
        }
    }
}
