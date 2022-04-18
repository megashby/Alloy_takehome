#! /bin/bash


sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
cho "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html


# #install cloudwatch logs agent
# sudo yum install amazon-cloudwatch-agent

# echo 'Done!'