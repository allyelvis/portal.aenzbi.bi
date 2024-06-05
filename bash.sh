#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
sudo apt install python3 python3-pip build-essential wget git openjdk-11-jdk -y

# Install PostgreSQL
sudo apt install postgresql postgresql-server-dev-all -y

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create PostgreSQL user and database for Odoo
sudo -u postgres createuser -s odoo
sudo -u postgres createdb odoo

# Install wkhtmltopdf
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.5-1/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo apt install -f -y

# Clone Odoo from GitHub
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 --single-branch /opt/odoo

# Create a Python virtual environment and install requirements
sudo apt install python3-venv -y
cd /opt/odoo
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create Odoo configuration file
sudo tee /etc/odoo.conf > /dev/null <<EOL
[options]
; This is the password that allows database operations:
admin_passwd = admin
db_host = False
db_port = False
db_user = odoo
db_password = False
addons_path = /opt/odoo/addons
logfile = /var/log/odoo/odoo.log
EOL

# Create systemd service for Odoo
sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOL
[Unit]
Description=Odoo
Documentation=http://www.odoo.com
[Service]
# Ubuntu/Debian convention:
User=odoo
ExecStart=/opt/odoo/venv/bin/python3 /opt/odoo/odoo-bin -c /etc/odoo.conf
[Install]
WantedBy=default.target
EOL

# Start and enable the Odoo service
sudo systemctl start odoo
sudo systemctl enable odoo

# Download and install OpenBravo POS
wget https://downloads.sourceforge.net/project/openbravopos/releases/OpenbravoPOS-2.30.2.tar.gz
tar -xzf OpenbravoPOS-2.30.2.tar.gz -C /opt/

# Create a script to run OpenBravo POS
sudo tee /opt/OpenbravoPOS-2.30.2/start.sh > /dev/null <<EOL
#!/bin/bash
cd /opt/OpenbravoPOS-2.30.2
./start.sh
EOL

sudo chmod +x /opt/OpenbravoPOS-2.30.2/start.sh

# Open necessary ports in the firewall
sudo ufw allow 8069/tcp
sudo ufw allow 22/tcp
sudo ufw enable

echo "Setup is complete. You can access Odoo at http://<your-server-ip>:8069"
echo "To run OpenBravo POS, execute: /opt/OpenbravoPOS-2.30.2/start.sh"
