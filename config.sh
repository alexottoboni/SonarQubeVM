export QUBE_VERSION="5.4"
export MYSQL_PASSWORD="sonarqube"
export IP_ADDR="192.168.33.10"
export SCANNER_VERSION="2.4"
export REPO_URL=https://github.com/alexottoboni/Life--.git

apt-get -y update
apt-get -y install wget
apt-get -y install unzip
apt-get -y install default-jre
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
unzip sonarqube-$QUBE_VERSION.zip
mv sonarqube-$QUBE_VERSION /opt/sonar
echo "sonar.jdbc.username=sonar" > ~/conf
echo "sonar.jdbc.password=sonar" >> ~/conf
echo "sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance" >> ~/conf
echo "sonar.web.host=$IP_ADDR" >> ~/conf
echo "sonar.web.port=80" >> ~/conf
cp ~/conf /opt/sonar/conf/sonar.properties
/opt/sonar/bin/linux-x86-64/sonar.sh start
echo "sonar.host.url=http://$IP_ADDR" > ~/scanner.conf
wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-$SCANNER_VERSION.zip
cp ./sonar-runner-dist-$SCANNER_VERSION.zip ~/
unzip ~/sonar-runner-dist-$SCANNER_VERSION.zip -d ~/
echo "export SONAR_RUNNER_HOME=~/sonar-runner-$SCANNER_VERSION" >> ~/.bashrc
echo "PATH=~/sonar-runner-$SCANNER_VERSION/bin:$PATH" >> ~/.bashrc
mv ~/scanner.conf ~/sonar-runner-$SCANNER_VERSION/conf/sonar-runner.properties
git clone $REPO_URL ~
# Must have sonar-project.properties file in the root directory of project to work
# then go to directory of cloned repo and run sonar-scanner.
