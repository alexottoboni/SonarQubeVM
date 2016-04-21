### Requirements
Vagrant
Virtualbox

### Instructions
- Make sure your project has a `sonar-project.properties` file in the root directory
- `vagrant up`
- `vagrant ssh`
- `sudo su`
- `cd ~/YOUR_PROJECT_NAME && sonar-scanner`
- Open a web browser to http://192.168.33.10/
