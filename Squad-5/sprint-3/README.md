# Sprint 3 - Squad 5 (NusantaraGo)

**Tugas Utama (Issue #15):** Generator QR Code e-tiket terenkripsi HMAC & Scanner Validation  
**Penanggung Jawab:** George Blaciano Kunemara Putra (Squad Lead)

---

## 📁 Struktur Direktori

```text
sprint-3/
└── services/
    └── api-core/
        ├── .env.example
        ├── package.json
        └── src/
            ├── controllers/
            │   └── ticket.controller.js  (Handler generate QR & scanner gate)
            ├── data/
            │   └── tickets.mock.js       (Simulasi database tiket)
            ├── routes/
            │   └── ticket.routes.js      (Daftar endpoint API)
            ├── utils/
            │   ├── hmac.util.js          (Mesin enkripsi HMAC-SHA256 - CONTOH UTAMA)
            │   └── qr.util.js            (Helper visual QRCode)
            ├── app.js                    (Konfigurasi Express)
            └── server.js                 (Entry point server)
```

---

## 🎯 Alur Logika Singkat

1. **Penerbitan Tiket:** Pengunjung membeli tiket -> Server membuat payload (ID tiket, tanggal, destinasi) -> Diberi tanda tangan digital **HMAC-SHA256** menggunakan secret server -> Di-generate menjadi QR Code.
2. **Validasi Scanner:** Petugas gerbang scan QR -> Server memvalidasi signature HMAC -> Cek tanggal & status -> Jika valid, status diubah menjadi `USED` dan akses gerbang terbuka.
