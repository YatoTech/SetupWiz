require('dotenv').config();
const express = require('express');
const { MongoClient } = require('mongodb');
const mongoose = require('mongoose');
const config = require('./config');

const app = express();
const PORT = config.port;

// Middleware dasar
app.use(express.json());

let mongoClient;
let mongooseConnection;

async function connectDB() {
  try {
    mongoClient = new MongoClient(config.mongo.uri, { useUnifiedTopology: true });
    await mongoClient.connect();
    console.log('Terhubung ke MongoDB (native driver)');

    mongooseConnection = await mongoose.connect(config.mongo.uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Terhubung ke MongoDB (Mongoose)');
  } catch (err) {
    console.error('Gagal terhubung ke MongoDB:', err);
    process.exit(1);
  }
}

app.get('/', (req, res) => {
  res.send(`
    <h1>Selamat Datang di Server Dasar!</h1>
    <p>Server berjalan dengan baik di port ${PORT}</p>
    <h2>Environment Variables:</h2>
    <pre>${JSON.stringify({
      PORT: config.port,
      NODE_ENV: config.nodeEnv,
      MONGO_APP_DB: config.mongo.db
    }, null, 2)}</pre>
  `);
});

app.get('/health', async (req, res) => {
  try {
    const nativeStatus = mongoClient && mongoClient.topology && mongoClient.topology.isConnected() ? 'connected' : 'disconnected';
    const mongooseStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';

    res.json({
      status: 'healthy',
      timestamp: new Date(),
      database: {
        native: nativeStatus,
        mongoose: mongooseStatus
      }
    });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', error: err.message });
  }
});

app.get('/users', async (req, res, next) => {
  try {
    if (!mongoClient || !mongoClient.topology.isConnected()) {
      throw new Error('Database not connected');
    }
    const db = mongoClient.db(config.mongo.db);
    const users = await db.collection('users').find().toArray();
    res.json(users);
  } catch (err) {
    next(err);
  }
});

// Middleware error handler global
app.use((err, req, res, next) => {
  console.error('Internal server error:', err);
  res.status(500).json({ error: err.message || 'Internal Server Error' });
});

async function startServer() {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server berjalan di http://localhost:${PORT}`);
    console.log(`Mode: ${config.nodeEnv}`);
  });
}

startServer();

process.on('SIGINT', async () => {
  console.log('\nShutting down gracefully...');
  if (mongoClient) await mongoClient.close();
  if (mongooseConnection) await mongoose.disconnect();
  process.exit(0);
});
