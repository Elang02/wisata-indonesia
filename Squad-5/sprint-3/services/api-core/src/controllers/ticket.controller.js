/**
 * File: src/controllers/ticket.controller.js
 * Deskripsi: Menangani request HTTP untuk pembuatan e-tiket dan validasi scan gerbang
 */

const { verifyHMACSignature } = require("../utils/hmac.util");
const ticketsDb = require("../data/tickets.mock");

// 1. Endpoint Penerbitan E-Tiket
async function generateTicket(req, res) {
  // TODO (George):
  // 1. Ambil ticketId dari req.body
  // 2. Cari tiket di ticketsDb
  // 3. Panggil generateTicketQRCode() dari qr.util.js
  // 4. Kirim response JSON ke user
  return res.json({ message: "TODO: Implementasi generateTicket oleh George" });
}

// 2. Endpoint Validasi Scanner Gerbang Masuk
async function validateGateScan(req, res) {
  // TODO (George):
  // 1. Ambil qrToken dan gateDestinationId dari req.body
  // 2. Decode qrToken dari Base64 ke JSON
  // 3. Panggil verifyHMACSignature(payload, signature) untuk cek keaslian
  // 4. Cek apakah tiket ditemukan di ticketsDb
  // 5. Cek apakah tiket statusnya sudah 'USED' (cegah scan berulang)
  // 6. Bila semua valid: status diubah menjadi 'USED', waktu scan dicatat, dan kembalikan akses 'ACCESS_GRANTED'
  return res.json({
    message: "TODO: Implementasi validateGateScan oleh George",
  });
}

module.exports = {
  generateTicket,
  validateGateScan,
};
