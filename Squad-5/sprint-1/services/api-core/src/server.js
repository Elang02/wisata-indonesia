require('dotenv').config();
const app = require('./app');

if (!process.env.JWT_SECRET) {
  console.error('ERROR: JWT_SECRET belum diatur di file .env');
  process.exit(1);
}

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`api-core berjalan di http://localhost:${PORT}`);
});
