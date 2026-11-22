/**
 * File: src/routes/ticket.routes.js
 * Deskripsi: Rute URL endpoint API tiket
 */

const express = require("express");
const {
  generateTicket,
  validateGateScan,
} = require("../controllers/ticket.controller");

const router = express.Router();

// Route penerbitan tiket ber-QR
router.post("/generate", generateTicket);

// Route pemindaian tiket oleh scanner gerbang
router.post("/scan", validateGateScan);

module.exports = router;
