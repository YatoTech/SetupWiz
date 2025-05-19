// === Load Environment Variables ===
require('dotenv').config();

// === Import Dependencies ===
const express = require('express');
const { MongoClient } = require('mongodb');
const mongoose = require('mongoose');

// === Inisialisasi Aplikasi ===
const app = express();

// === Load Konfigurasi dari .env ===
const {
  PORT = 3000,
  NODE_ENV = 'development',
  MONGO_URI,
  MONGO_APP_DB
} = process.env;

// === Middleware Dasar ===
app.use(express.json());

// === Global Variables untuk Koneksi DB ===
let mongoClient;
let mongooseConnection;

// === Fungsi Koneksi ke MongoDB ===
async function connectDB() {
  try {
    // --- Native MongoDB Driver ---
    mongoClient = new MongoClient(MONGO_URI, {
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000 // cepat gagal jika tidak konek
    });
    await mongoClient.connect();
    console.log('✅ Terhubung ke MongoDB (Native Driver)');

    // --- Mongoose ---
    mongooseConnection = await mongoose.connect(MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('✅ Terhubung ke MongoDB (Mongoose)');
  } catch (err) {
    console.error('❌ Gagal terhubung ke MongoDB:', err.message);
    process.exit(1);
  }
}

// === Route Utama ===
app.get('/', (req, res) => {
  res.send(`
    <h1>🚀 Selamat Datang di SetupWiz Server</h1>
    <p>Server berjalan pada port <strong>${PORT}</strong></p>
    <h2>Environment:</h2>
    <pre>${JSON.stringify({
      PORT,
      NODE_ENV,
      MONGO_APP_DB,
      MONGO_URI
    }, null, 2)}</pre>
  `);
});

// === Route Health Check ===
app.get('/health', async (req, res) => {
  const nativeConnected = mongoClient && mongoClient.topology && mongoClient.topology.isConnected && mongoClient.topology.isConnected();
  const mongooseConnected = mongoose.connection.readyState === 1;

  res.status(nativeConnected && mongooseConnected ? 200 : 500).json({
    status: nativeConnected && mongooseConnected ? 'healthy' : 'unhealthy',
    timestamp: new Date(),
    database: {
      native: nativeConnected ? 'connected' : 'disconnected',
      mongoose: mongooseConnected ? 'connected' : 'disconnected'
    }
  });
});

// === Contoh Route Akses Data ===
app.get('/users', async (req, res, next) => {
  try {
    const isConnected = mongoClient && mongoClient.topology && mongoClient.topology.isConnected && mongoClient.topology.isConnected();
    if (!isConnected) throw new Error('MongoDB Native Client not connected');

    const db = mongoClient.db(MONGO_APP_DB);
    const users = await db.collection('users').find().toArray();

    res.json(users);
  } catch (err) {
    next(err);
  }
});

// === Error Handler Middleware ===
app.use((err, req, res, next) => {
  console.error('❌ Internal Server Error:', err.stack || err);
  res.status(500).json({ error: err.message || 'Internal Server Error' });
});

// === Mulai Server ===
async function startServer() {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`🌐 Server berjalan di: http://localhost:${PORT}`);
    console.log(`🌱 Environment: ${NODE_ENV}`);
  });
}

// === Graceful Shutdown ===
process.on('SIGINT', async () => {
  console.log('\n🛑 Menutup server...');
  try {
    if (mongoClient) await mongoClient.close();
    if (mongooseConnection) await mongoose.disconnect();
    console.log('✅ Koneksi MongoDB ditutup');
  } catch (err) {
    console.error('❌ Error saat menutup koneksi:', err.message);
  } finally {
    process.exit(0);
  }
});

// === Start App ===
startServer();
