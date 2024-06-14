const readlineSync = require('readline-sync');
const axios = require('axios');
const mysql = require('mysql2/promise');

// Prompt the user for database credentials and API host
const dbHost = readlineSync.question('Enter database host: ');
const dbName = readlineSync.question('Enter database name: ');
const dbUser = readlineSync.question('Enter database user: ');
const dbPassword = readlineSync.question('Enter database password: ', {
  hideEchoBack: true // The typed text on screen is hidden
});
const apiHost = readlineSync.question('Enter API host (e.g., ebms.obr.gov.bi:9443): ');

// Prompt for API credentials
const apiUsername = readlineSync.question('Enter API username: ');
const apiPassword = readlineSync.question('Enter API password: ', {
  hideEchoBack: true // The typed text on screen is hidden
});

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
    process.exit(1);
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
    process.exit(1);
  }
}

// Function to insert data into the database
async function insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData) {
  const connection = await mysql.createConnection({
    host: dbHost,
    user: dbUser,
    password: dbPassword,
    database: dbName
  });

  try {
    for (const sale of salesData) {
      const { invoice_id, customer_name, total_amount, sale_date } = sale;
      await connection.execute(
        `INSERT INTO sales_transactions (invoice_id, customer_name, total_amount, sale_date)
         VALUES (?, ?, ?, ?)`,
        [invoice_id, customer_name, total_amount, sale_date]
      );
    }
  } catch (error) {
    console.error('Error inserting data:', error);
  } finally {
    await connection.end();
  }
}

// Main script execution
(async () => {
  const bearerToken = await getBearerToken(apiHost, apiUsername, apiPassword);
  const salesData = await fetchSalesTransactions(apiHost, bearerToken);
  await insertSalesData(dbHost, dbName, dbUser, dbPassword, salesData);
  console.log('Sales data successfully inserted into the database.');
})();