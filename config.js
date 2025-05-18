// config.js
require('dotenv').config();

const requiredEnvVars = [
  'PORT',
  'NODE_ENV',
  'MONGO_HOST',
  'MONGO_PORT',
  'MONGO_APP_USER',
  'MONGO_APP_PASS',
  'MONGO_APP_DB',
  'MONGO_URI',
];

function validateEnv() {
  const missingVars = requiredEnvVars.filter((key) => {
    const val = process.env[key];
    return !val || val.trim() === '';
  });
  if (missingVars.length > 0) {
    console.error(`[ERROR] Missing required environment variables: ${missingVars.join(', ')}`);
    process.exit(1); // Exit with error code
  }
}

validateEnv();

const config = {
  port: parseInt(process.env.PORT, 10) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',

  mongo: {
    host: process.env.MONGO_HOST,
    port: parseInt(process.env.MONGO_PORT, 10) || 27017,
    user: process.env.MONGO_APP_USER,
    pass: process.env.MONGO_APP_PASS,
    db: process.env.MONGO_APP_DB,

    // Gunakan MONGO_URI jika sudah ada di .env, 
    // fallback bikin URI dari komponen lain jika tidak ada
    uri:
      process.env.MONGO_URI ||
      `mongodb://${encodeURIComponent(process.env.MONGO_APP_USER)}:${encodeURIComponent(process.env.MONGO_APP_PASS)}@${process.env.MONGO_HOST}:${process.env.MONGO_PORT}/${process.env.MONGO_APP_DB}?authSource=admin`,
  },

  mysql: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    pass: process.env.DB_PASS || '',
    db: process.env.DB_NAME || '',
  },

  appName: process.env.APP_NAME || 'setupwiz',
  appDomain: process.env.APP_DOMAIN || 'http://localhost',

  logLevel: process.env.LOG_LEVEL || 'info',
  enablePm2: process.env.ENABLE_PM2 === 'true',
};

module.exports = config;
