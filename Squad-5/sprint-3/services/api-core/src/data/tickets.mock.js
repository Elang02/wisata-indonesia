/**
 * File: src/data/tickets.mock.js
 * Deskripsi: Data tiruan (mock) tiket untuk pengujian lokal Sprint 3
 */

const ticketsMock = [
  {
    ticketId: "TKT-001",
    bookingId: "BKG-20261122-001",
    destinationId: "DEST-BOROBUDUR",
    destinationName: "Candi Borobudur",
    visitorName: "George Blaciano",
    pax: 2,
    visitDate: "2026-11-24", // Tanggal kunjungan yang valid
    status: "ACTIVE", // 'ACTIVE' (belum dipakai) atau 'USED' (sudah discan)
    scannedAt: null,
  },
  // Note(George): Bisa tambahkan contoh tiket lain di sini untuk variasi pengujian
];

module.exports = ticketsMock;
