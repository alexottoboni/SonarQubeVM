export QUBE_VERSION="5.4"
export MYSQL_PASSWORD="sonarqube"
export IP_ADDR="192.168.33.10"
export SCANNER_VERSION="2.4"
export REPO_URL=https://github.com/alexottoboni/Life--.git
export PROJECT_NAME=Life--

apt-get -y update
apt-get -y install wget
apt-get -y install unzip
apt-get -y install default-jre
apt-get -y install git
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
apt-get -y install mysql-server
echo "CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;" > ~/setup.sql
echo "CREATE USER 'sonar' IDENTIFIED BY 'sonar';" >> ~/setup.sql
echo "GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';" >> ~/setup.sql
echo "GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';" >> ~/setup.sql
echo "FLUSH PRIVILEGES;" >> ~/setup.sql
cat ~/setup.sql | mysql -u root --password=$MYSQL_PASSWORD
wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$QUBE_VERSION.zip
unzip sonarqube-$QUBE_VERSION.zip -d /opt/sonar
echo "sonar.jdbc.username=sonar" > ~/conf
echo "sonar.jdbc.password=sonar" >> ~/conf
echo "sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance" >> ~/conf
echo "sonar.web.host=$IP_ADDR" >> ~/conf
echo "sonar.web.port=80" >> ~/conf
cp ~/conf /opt/sonar/sonarqube-$QUBE_VERSION/conf/sonar.properties
/opt/sonar/sonarqube-$QUBE_VERSION/bin/linux-x86-64/sonar.sh start
echo "sonar.host.url=http://$IP_ADDR" > ~/scanner.conf
wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/$SCANNER_VERSION/sonar-runner-dist-$SCANNER_VERSION.zip
unzip ./sonar-runner-dist-$SCANNER_VERSION.zip -d /opt/sonar
echo "export SONAR_RUNNER_HOME=/opt/sonar/sonar-runner-$SCANNER_VERSION" >> ~/.bashrc
echo "PATH=/opt/sonar/sonar-runner-$SCANNER_VERSION/bin:$PATH" >> ~/.bashrc
PATH=/opt/sonar/sonar-runner-$SCANNER_VERSION/bin:$PATH
mv ~/scanner.conf /opt/sonar/sonar-runner-$SCANNER_VERSION/conf/sonar-runner.properties
cd ~ && git clone $REPO_URL
if ! [[ -e "~/$PROJECT_NAME/sonar-project.properties" ]]; then
   echo "sonar.projectKey=$PROJECT_NAME" > ~/$PROJECT_NAME/sonar-project.properties
   echo "sonar.projectName=$PROJECT_NAME" >> ~/$PROJECT_NAME/sonar-project.properties
   echo "sonar.projectVersion=1.0" >> ~/$PROJECT_NAME/sonar-project.properties
   echo "sonar.sources=." >> ~/$PROJECT_NAME/sonar-project.properties
fi
cd ~/$PROJECT_NAME && sonar-runner
