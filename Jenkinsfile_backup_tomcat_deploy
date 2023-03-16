pipeline {
    agent any

    tools {
	    jdk 'java8'
        maven 'maven3'
    }

    stages {
        stage('clone') {
            steps {
       
                git 'https://github.com/jmstechhome20/spring3-mvc-maven-xml-hello-world.git'
            
            }
        }
		stage('build') {
            steps {
                sh "mvn clean package"
            
            }
        }
        stage('deploy') {
				steps{
                withCredentials([usernameColonPassword(credentialsId: 'new_tomcat', variable: 'toncat_cred')]) {
                 sh "curl -v -u $toncat_cred -T /var/lib/jenkins/workspace/spring3/target/spring3-mvc-maven-xml-hello-world-1.0-SNAPSHOT.war 'http://15.207.21.17:8080/manager/text/deploy?path=/myspringapp&update=true'"
                    }
             }
            
            }
    }
}
