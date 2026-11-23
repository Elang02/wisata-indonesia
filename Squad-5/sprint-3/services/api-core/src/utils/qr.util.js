/**
 * File: src/utils/qr.util.js
 * Deskripsi: Helper untuk membuat gambar QR Code dari token tiket
 */

// const QRCode = require('qrcode');
// const { generateHMACSignature } = require('./hmac.util');

async function generateTicketQRCode(ticketInfo) {
  // TODO (George):
  // 1. Ambil informasi penting dari ticketInfo (ticketId, bookingId, destinationId, visitDate)
  // 2. Gunakan generateHMACSignature() dari hmac.util.js untuk membuat signature
  // 3. Gabungkan payload + signature lalu ubah ke Base64 (qrToken)
  // 4. (Opsional) Gunakan QRCode.toDataURL(qrToken) untuk menghasilkan gambar QR Code
  
  return {
    qrToken: 'CONTOH_TOKEN_BASE64',
    qrImage: null,
  };
}

module.exports = {
  generateTicketQRCode,
};
