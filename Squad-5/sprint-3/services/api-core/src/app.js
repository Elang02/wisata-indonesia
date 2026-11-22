const express = require("express");
const ticketRoutes = require("./routes/ticket.routes");

const app = express();

app.use(express.json());

// Health check endpoint
app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "api-core-sprint3" });
});

// Daftarkan rute tiket
app.use("/api/v1/tickets", ticketRoutes);

module.exports = app;
