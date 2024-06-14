#!/bin/bash

# Update package list and install Node.js, npm, and PostgreSQL client
echo "Updating package list and installing Node.js, npm, and PostgreSQL client..."
sudo apt-get update
sudo apt-get install -y nodejs npm postgresql-client

# Install necessary Node.js packages
echo "Installing necessary Node.js packages..."
npm install readline-sync axios pg express body-parser

# Create project directory
echo "Setting up project directory..."
mkdir ebms_pos
cd ebms_pos

# Create server script
echo "Creating server script..."
cat << 'EOF' > server.js
const readlineSync = require('readline-sync');
const axios = require('axios');
const { Client } = require('pg');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

app.post('/setup', async (req, res) => {
  const { dbHost, dbName, dbUser, dbPassword, apiHost, apiUsername, apiPassword } = req.body;

  // Function to get Bearer Token
  async function getBearerToken(apiHost, username, password) {
    try {
      const response = await axios.post(`https://${apiHost}/ebms_api/login`, {
        username: username,
        password: password
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      return response.data.token;
    } catch (error) {
      console.error('Error getting token:', error.response.data);
      res.status(500).send('Error getting token');
    }
  }

  // Function to fetch sales transactions
  async function fetchSalesTransactions(apiHost, bearerToken) {
    try {
      const response = await axios.get(`https://${apiHost}/ebms_api/getInvoice`, {
        headers: {
          'Authorization': `Bearer ${bearerToken}`
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching sales transactions:', error.response.data);
      res.status(500).send('Error fetching sales transactions');
    }
  }

  // Function to insert data into the database
  async function insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData) {
    const client = new Client({
      host: dbHost,
      user: dbUser,
      password: dbPassword,
      database: dbName
    });

    try {
      await client.connect();

      for (const sale of salesData) {
        const { invoice_id, customer_name, total_amount, sale_date } = sale;
        await client.query(
          `INSERT INTO sales_transactions (invoice_id, customer_name, total_amount, sale_date)
           VALUES ($1, $2, $3, $4)`,
          [invoice_id, customer_name, total_amount, sale_date]
        );
      }
      res.send('Sales data successfully inserted into the database.');
    } catch (error) {
      console.error('Error inserting data:', error);
      res.status(500).send('Error inserting data');
    } finally {
      await client.end();
    }
  }

  // Main execution
  (async () => {
    const bearerToken = await getBearerToken(apiHost, apiUsername, apiPassword);
    const salesData = await fetchSalesTransactions(apiHost, bearerToken);
    await insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData);
  })();
});

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
EOF

# Create package.json
echo "Creating package.json..."
cat << 'EOF' > package.json
{
  "name": "ebms_pos",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "axios": "^0.21.1",
    "body-parser": "^1.19.0",
    "express": "^4.17.1",
    "pg": "^8.5.1",
    "readline-sync": "^1.4.10"
  },
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

# Start the server
echo "Starting the server..."
npm start
#!/bin/bash

# Update package list and install Node.js, npm, and PostgreSQL client
echo "Updating package list and installing Node.js, npm, and PostgreSQL client..."
sudo apt-get update
sudo apt-get install -y nodejs npm postgresql-client

# Install necessary Node.js packages
echo "Installing necessary Node.js packages..."
npm install readline-sync axios pg express body-parser

# Create project directory
echo "Setting up project directory..."
mkdir ebms_pos
cd ebms_pos

# Create server script
echo "Creating server script..."
cat << 'EOF' > server.js
const readlineSync = require('readline-sync');
const axios = require('axios');
const { Client } = require('pg');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

app.post('/setup', async (req, res) => {
  const { dbHost, dbName, dbUser, dbPassword, apiHost, apiUsername, apiPassword } = req.body;

  // Function to get Bearer Token
  async function getBearerToken(apiHost, username, password) {
    try {
      const response = await axios.post(`https://${apiHost}/ebms_api/login`, {
        username: username,
        password: password
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      return response.data.token;
    } catch (error) {
      console.error('Error getting token:', error.response.data);
      res.status(500).send('Error getting token');
    }
  }

  // Function to fetch sales transactions
  async function fetchSalesTransactions(apiHost, bearerToken) {
    try {
      const response = await axios.get(`https://${apiHost}/ebms_api/getInvoice`, {
        headers: {
          'Authorization': `Bearer ${bearerToken}`
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching sales transactions:', error.response.data);
      res.status(500).send('Error fetching sales transactions');
    }
  }

  // Function to insert data into the database
  async function insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData) {
    const client = new Client({
      host: dbHost,
      user: dbUser,
      password: dbPassword,
      database: dbName
    });

    try {
      await client.connect();

      for (const sale of salesData) {
        const { invoice_id, customer_name, total_amount, sale_date } = sale;
        await client.query(
          `INSERT INTO sales_transactions (invoice_id, customer_name, total_amount, sale_date)
           VALUES ($1, $2, $3, $4)`,
          [invoice_id, customer_name, total_amount, sale_date]
        );
      }
      res.send('Sales data successfully inserted into the database.');
    } catch (error) {
      console.error('Error inserting data:', error);
      res.status(500).send('Error inserting data');
    } finally {
      await client.end();
    }
  }

  // Main execution
  (async () => {
    const bearerToken = await getBearerToken(apiHost, apiUsername, apiPassword);
    const salesData = await fetchSalesTransactions(apiHost, bearerToken);
    await insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData);
  })();
});

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
EOF

# Create package.json
echo "Creating package.json..."
cat << 'EOF' > package.json
{
  "name": "ebms_pos",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "axios": "^0.21.1",
    "body-parser": "^1.19.0",
    "express": "^4.17.1",
    "pg": "^8.5.1",
    "readline-sync": "^1.4.10"
  },
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

# Start the server
echo "Starting the server..."
npm start