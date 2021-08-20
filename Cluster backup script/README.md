**The bash script used to take backup of a running kubernetes cluster in json format**


**Steps to run the script**
 1. Install jp JSON processor`#sudo apt-get install jp` 
 2. Run application using `#./backitup.sh`
 3. To apply the backup to a cluster `# kubectl apply -f <namespace folder>`