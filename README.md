Here's the `README.md` file with the server information replaced by your specified domain and IP address.

```markdown
# Business Management System and Point of Sale Setup

This script sets up a Business Management System (Odoo) and Point of Sale (OpenBravo POS) on an Ubuntu server.

## Prerequisites

- A VPS or dedicated server running Ubuntu 20.04 or later.
- SSH access to the server.
- Basic knowledge of Linux command line.

## Installation Steps

1. **Update the System**

   Make sure your system is up-to-date:

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Download the Setup Script**

   Save the setup script to a file:

   ```bash
   wget https://example.com/setup_bms_pos.sh -O setup_bms_pos.sh
   ```

3. **Make the Script Executable**

   ```bash
   chmod +x setup_bms_pos.sh
   ```

4. **Run the Script**

   ```bash
   sudo ./setup_bms_pos.sh
   ```

## Accessing Odoo

After the script completes, you can access Odoo at:

```
http://portal.aenzbi.bi:8069
```

or

```
http://10.0.2.88:8069
```

### Default Admin Credentials

- **Username:** admin
- **Password:** admin

You should change the default password immediately after logging in for the first time.

## Running OpenBravo POS

To run OpenBravo POS, execute the following command:

```bash
/opt/OpenbravoPOS-2.30.2/start.sh
```

## Firewall Configuration

The script opens the necessary ports:

- **Odoo:** TCP port `8069`
- **SSH:** TCP port `22`

## Logs

- **Odoo logs:** `/var/log/odoo/odoo.log`

## Additional Configuration

### Secure Odoo with SSL (Optional)

For better security, you might want to set up a reverse proxy with Nginx and secure it using SSL certificates from Let's Encrypt.

### Example Nginx Configuration

1. **Install Nginx**

   ```bash
   sudo apt install nginx -y
   ```

2. **Install Certbot**

   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   ```

3. **Obtain SSL Certificate**

   ```bash
   sudo certbot --nginx -d portal.aenzbi.bi -d www.portal.aenzbi.bi
   ```

4. **Configure Nginx**

   Edit the Nginx configuration file for Odoo:

   ```bash
   sudo nano /etc/nginx/sites-available/odoo
   ```

   Add the following configuration:

   ```nginx
   server {
       listen 80;
       server_name portal.aenzbi.bi www.portal.aenzbi.bi;

       location / {
           proxy_pass http://127.0.0.1:8069;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       location ~* /web/static/ {
           proxy_cache_valid 200 90m;
           proxy_buffering on;
           expires 864000;
           proxy_pass http://127.0.0.1:8069;
       }
   }

   server {
       listen 443 ssl;
       server_name portal.aenzbi.bi www.portal.aenzbi.bi;

       ssl_certificate /etc/letsencrypt/live/portal.aenzbi.bi/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/portal.aenzbi.bi/privkey.pem;
       include /etc/letsencrypt/options-ssl-nginx.conf;
       ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

       location / {
           proxy_pass http://127.0.0.1:8069;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       location ~* /web/static/ {
           proxy_cache_valid 200 90m;
           proxy_buffering on;
           expires 864000;
           proxy_pass http://127.0.0.1:8069;
       }
   }
   ```

5.
