/**
 * ============================================================================
 * CONTOH IMPLEMENTASI LENGKAP: MESIN ENKRIPSI & VERIFIKASI HMAC-SHA256
 * File: src/utils/hmac.util.js
 * ============================================================================
 * 
 * Fungsi modul ini:
 * 1. Mengunci data tiket dengan "tanda tangan digital" (signature) menggunakan Secret Key server.
 * 2. Memastikan tiket yang discan belum pernah diubah/diedit oleh orang lain (anti-tampering).
 */

const crypto = require('crypto');

// Kunci rahasia server (diambil dari environment variable atau fallback default)
const SECRET_KEY = process.env.HMAC_TICKET_SECRET || 'kunci-rahasia-tiket-nusantarago-squad5';

/**
 * 1. Membuat tanda tangan HMAC-SHA256 dari data tiket
 * @param {object} payload - Objek data tiket (misal: { ticketId, bookingId, visitDate })
 * @returns {string} String signature dalam format Hexadecimal
 */
function generateHMACSignature(payload) {
  // Urutkan key secara alfabetis agar serialisasi selalu identik
  const serializedData = Object.keys(payload)
    .sort()
    .map((key) => `${key}=${payload[key]}`)
    .join('&');

  // Buat hash HMAC-SHA256
  return crypto
    .createHmac('sha256', SECRET_KEY)
    .update(serializedData)
    .digest('hex');
}

/**
 * 2. Memverifikasi keaslian data tiket dan signature yang diterima scanner
 * @param {object} payload - Data tiket hasil decode dari QR
 * @param {string} signature - Tanda tangan digital dari QR
 * @returns {boolean} true jika asli & cocok, false jika palsu/diubah
 */
function verifyHMACSignature(payload, signature) {
  if (!payload || !signature) {
    return false;
  }

  // Hitung signature yang seharusnya berdasarkan payload
  const expectedSignature = generateHMACSignature(payload);

  const expectedBuffer = Buffer.from(expectedSignature, 'utf8');
  const signatureBuffer = Buffer.from(signature, 'utf8');

  // Cegah serangan timing attack dengan memeriksa panjang buffer terlebih dahulu
  if (expectedBuffer.length !== signatureBuffer.length) {
    return false;
  }

  // Bandingkan buffer secara konstan waktu (aman dari hacker)
  return crypto.timingSafeEqual(expectedBuffer, signatureBuffer);
}

module.exports = {
  generateHMACSignature,
  verifyHMACSignature,
};
