FROM jenkins/jenkins:lts-jdk11
# disable the setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
# set jenkis url env
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.yaml
# become root user
USER root
#install recomended plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN  jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
# drop back to the regular jenkins user
USER jenkins
#
COPY jenkins.yaml /var/jenkins_home/jenkins.yaml
