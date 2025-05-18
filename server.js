// === Load Environment Variables ===
require('dotenv').config();

// === Import Dependencies ===
const express = require('express');
const { MongoClient } = require('mongodb');
const mongoose = require('mongoose');

// === Konfigurasi (gunakan dari .env secara langsung) ===
const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const MONGO_URI = process.env.MONGO_URI;
const MONGO_DB = process.env.MONGO_APP_DB;

// === Middleware dasar ===
app.use(express.json());

// === Global Variables untuk koneksi DB ===
let mongoClient;
let mongooseConnection;

// === Fungsi Koneksi ke MongoDB ===
async function connectDB() {
  try {
    // Native MongoDB Driver
    mongoClient = new MongoClient(MONGO_URI, { useUnifiedTopology: true });
    await mongoClient.connect();
    console.log('✅ Terhubung ke MongoDB (native driver)');

    // Mongoose ODM
    mongooseConnection = await mongoose.connect(MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Terhubung ke MongoDB (Mongoose)');
  } catch (err) {
    console.error('❌ Gagal terhubung ke MongoDB:', err);
    process.exit(1);
  }
}

// === Route Utama ===
app.get('/', (req, res) => {
  res.send(`
    <h1>Selamat Datang di Server Dasar!</h1>
    <p>Server berjalan dengan baik di port ${PORT}</p>
    <h2>Environment Variables:</h2>
    <pre>${JSON.stringify({
      PORT,
      NODE_ENV,
      MONGO_APP_DB: MONGO_DB,
      MONGO_URI
    }, null, 2)}</pre>
  `);
});

// === Route Kesehatan /health ===
app.get('/health', (req, res) => {
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

// === Route Data Users ===
app.get('/users', async (req, res, next) => {
  try {
    if (!mongoClient || !mongoClient.topology || !mongoClient.topology.isConnected()) {
      throw new Error('Database not connected');
    }
    const db = mongoClient.db(MONGO_DB);
    const users = await db.collection('users').find().toArray();
    res.json(users);
  } catch (err) {
    next(err);
  }
});

// === Error Handler ===
app.use((err, req, res, next) => {
  console.error('❌ Internal server error:', err);
  res.status(500).json({ error: err.message || 'Internal Server Error' });
});

// === Mulai Server ===
async function startServer() {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
    console.log(`🌱 Mode: ${NODE_ENV}`);
  });
}

// === Graceful Shutdown ===
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down gracefully...');
  if (mongoClient) await mongoClient.close();
  if (mongooseConnection) await mongoose.disconnect();
  process.exit(0);
});

// === Start App ===
startServer();
