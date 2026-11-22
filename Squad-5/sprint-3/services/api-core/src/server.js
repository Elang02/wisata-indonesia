require("dotenv").config();
const app = require("./app");

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(
    `[Sprint 3] Server E-Ticketing berjalan di http://localhost:${PORT}`,
  );
});
