# Setup instructions for Mao App on EC2
<p> This script sets up a new EC2 instance with all the necessary dependencies to run the Mao App. The script does the following:  </p>

  -Installs git and updates the system
  
  -Installs Node.js 14.16.1 via NVM
  
  -Clones the Mao App repositories and installs dependencies for both the frontend and backend
  
  -Builds the frontend and starts it with PM2
  
  -Creates an artifact of the Mao App directory for backup purposes
  
<h1> Getting started </h1>

<p> Launch a new EC2 instance on AWS with Amazon Linux 2 as the operating system. </p>

<p> Connect to the instance via SSH.</p>

<p> Clone the Mao App setup script from GitHub to your instance: </p>

    yum install git -y
    git clone https://github.com/selflove7/mao-app.git
    
<h1> Make the script executable: </h1>
    
    chmod +x mao-app/mao.sh

<h1> Run the script: </h1>
    
      cd /path/to/script_directory
      ./mao.sh

<p> The script may take a few minutes to complete. After the script is done, 
  the Mao App frontend should be accessible at http://instance-public-IP:3000. </p>


