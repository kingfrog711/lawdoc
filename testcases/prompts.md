# LawDoc — Tanya Dulu Chatbot Test Cases

Each prompt is a realistic user message. Expected output structure:
`{ summary, legal_basis: { pasal, text }, steps[], disclaimer }`

---

## WARIS (Inheritance)

### W-01 · Basic inheritance dispute
```
Ayah saya meninggal 3 bulan lalu tanpa meninggalkan wasiat. Ada 3 anak: saya, kakak perempuan, dan adik laki-laki. Ibu saya masih hidup. Bagaimana harta warisan dibagi?
```
**Expected**: cites KUHPerdata Pasal 832 (ahli waris), 852 (bagian anak), 852a (bagian suami/istri)

---

### W-02 · Excluded from inheritance
```
Saya anak kandung tapi nama saya tidak ada di surat waris yang dibuat kakak saya setelah ayah meninggal. Apakah saya masih berhak atas warisan?
```
**Expected**: cites Pasal 832, 834, 838 (pengecualian ahli waris)

---

### W-03 · Will validity challenge
```
Ibu saya sebelum meninggal membuat wasiat yang memberikan semua harta ke saudara tiri saya. Apakah wasiat itu sah dan bisa saya gugat?
```
**Expected**: cites Pasal 875 (wasiat/testamen), 913 (legitieme portie / bagian wajib anak)

---

### W-04 · Inheritance with debt
```
Ayah saya meninggal dengan hutang Rp 200 juta ke bank. Apakah hutang itu otomatis menjadi tanggungan kami sebagai ahli waris?
```
**Expected**: cites Pasal 833 (saisine — ahli waris menggantikan posisi pewaris termasuk hutangnya), opsi penolakan warisan

---

### W-05 · Out-of-wedlock child
```
Saya anak di luar nikah. Ayah biologis saya baru saja meninggal. Apakah saya berhak mendapat warisan dari dia?
```
**Expected**: cites Pasal 863 (anak luar kawin yang diakui), 272 (pengakuan anak)

---

## PERCERAIAN (Divorce)

### P-01 · Grounds for divorce
```
Suami saya sudah 2 tahun tidak memberi nafkah dan pergi meninggalkan rumah tanpa kabar. Apa alasan hukum yang bisa saya pakai untuk cerai?
```
**Expected**: cites Pasal 39 UU Perkawinan No. 1/1974, PP No. 9/1975 Pasal 19 (alasan perceraian)

---

### P-02 · Asset division after divorce
```
Kami menikah 8 tahun. Selama menikah kami beli rumah atas nama suami. Setelah cerai, apakah saya berhak setengah dari rumah itu?
```
**Expected**: cites Pasal 35, 37 UU Perkawinan (harta bersama/gono-gini); Pasal 119 KUHPerdata (persatuan harta)

---

### P-03 · Child custody
```
Kami bercerai dan punya anak umur 4 tahun dan 9 tahun. Siapa yang mendapat hak asuh? Apakah anak laki-laki berbeda dengan anak perempuan?
```
**Expected**: cites Pasal 41 UU Perkawinan, Pasal 105 KHI (anak di bawah 12 tahun ikut ibu); kepentingan terbaik anak

---

### P-04 · Prenuptial agreement
```
Sebelum menikah kami buat perjanjian pranikah yang bilang harta tetap terpisah. Tapi suami sekarang mengklaim setengah bisnis saya. Apakah perjanjian pranikah itu berlaku?
```
**Expected**: cites Pasal 29 UU Perkawinan, Pasal 139–154 KUHPerdata (perjanjian kawin)

---

### P-05 · Divorce process steps
```
Saya mau cerai tapi tidak tahu harus mulai dari mana. Suami setuju untuk cerai. Apa langkah-langkahnya dan berapa biayanya kira-kira?
```
**Expected**: procedural answer — Pengadilan Agama (Muslim) vs Pengadilan Negeri (non-Muslim), cerai gugat vs talak

---

## UTANG PIUTANG (Debt)

### U-01 · Informal debt dispute
```
Teman saya meminjam uang Rp 50 juta 2 tahun lalu dan berjanji bayar 6 bulan. Tidak ada kontrak tertulis, hanya chat WhatsApp. Apakah saya bisa menagih secara hukum?
```
**Expected**: cites Pasal 1313 (perjanjian), 1320 (syarat sah perjanjian), 1233/1234 (perikatan); chat WA sebagai bukti elektronik UU ITE

---

### U-02 · Debt with written agreement
```
Saya punya surat perjanjian hutang yang sudah dinotariskan. Debitur tidak bayar sudah 8 bulan. Apa yang bisa saya lakukan?
```
**Expected**: cites Pasal 1238 (wanprestasi/somasi), 1243 (ganti rugi); jalur gugatan perdata, somasi tertulis

---

### U-03 · Debt collector harassment
```
Debt collector datang ke rumah setiap hari, teriak-teriak, dan mengancam saya. Apa hak saya dan apa yang bisa saya lakukan?
```
**Expected**: POJK No. 22/2023 (penagihan kredit), Pasal 335 KUHP (perbuatan tidak menyenangkan/ancaman); lapor OJK atau polisi

---

### U-04 · Online loan (pinjol) trap
```
Saya terjebak pinjaman online ilegal. Mereka minta akses kontak HP saya dan sekarang mengirim pesan ke keluarga saya. Bunga sudah 300%. Apa yang bisa saya lakukan?
```
**Expected**: OJK daftar hitam, Pasal 27 UU ITE (penyebaran data), Satgas Waspada Investasi; bisa lapor OJK/Polri

---

### U-05 · Business debt personal liability
```
CV saya bangkrut dan punya hutang ke supplier Rp 150 juta. Apakah hutang CV bisa ditagih ke harta pribadi saya?
```
**Expected**: CV vs PT perbedaan tanggung jawab; Pasal 18 KUHD (CV — sekutu komplementer bertanggung jawab penuh); rekomendasi konsultasi notaris

---

## SENGKETA TANAH (Land Dispute)

### T-01 · Neighbor encroachment
```
Tetangga saya membangun pagar yang masuk ke tanah saya sekitar 1,5 meter. Sertifikat tanah saya jelas menunjukkan batasnya. Apa yang harus saya lakukan?
```
**Expected**: cites Pasal 1365 KUHPerdata (perbuatan melawan hukum), UU No. 5/1960 UUPA; mediasi BPN, gugatan PMH

---

### T-02 · Double certificate fraud
```
Saya beli tanah sudah 5 tahun, tapi sekarang ada orang lain yang datang dengan sertifikat berbeda untuk tanah yang sama. Siapa yang berhak?
```
**Expected**: sertifikat asli vs palsu, cek BPN, Pasal 32 PP No. 24/1997 (pendaftaran tanah); gugatan ke pengadilan negeri

---

### T-03 · Inherited land, no certificate
```
Tanah warisan dari kakek saya tidak punya sertifikat, hanya girik/letter C. Bagaimana cara saya mengurus sertifikatnya sekarang?
```
**Expected**: proses konversi girik → sertifikat di BPN, dokumen yang dibutuhkan (riwayat tanah, SK desa/kelurahan, pajak bumi), PTSL program pemerintah

---

### T-04 · Landlord-tenant dispute
```
Saya kontrak rumah 2 tahun, sudah bayar penuh di muka. Sekarang pemilik minta saya keluar sebelum kontrak habis karena katanya mau dijual. Apakah dia bisa melakukan itu?
```
**Expected**: cites Pasal 1548, 1576 KUHPerdata (sewa tidak berakhir karena jual beli); hak penyewa vs hak pembeli baru

---

### T-05 · Government land acquisition
```
Tanah saya kena proyek tol. Pemerintah mau ganti rugi tapi nilainya jauh di bawah harga pasar. Apa hak saya?
```
**Expected**: UU No. 2/2012 (pengadaan tanah), Pasal 37–40 (musyawarah penetapan ganti rugi), mekanisme keberatan ke pengadilan negeri, appraisal independen

---

## EDGE CASES

### E-01 · Vague / emotional question
```
Suami saya jahat dan saya mau cerai. Tolong bantu saya.
```
**Expected**: empathetic, asks clarifying question about specifics, mentions perceraian pathway, recommends LBH

---

### E-02 · Off-topic question
```
Apa resep nasi goreng yang enak?
```
**Expected**: polite refusal, explains LawDoc is for legal questions, suggests categories

---

### E-03 · Criminal law (out of scope)
```
Teman saya dipukul preman dan mau lapor polisi. Bagaimana prosesnya?
```
**Expected**: acknowledges it's criminal (hukum pidana), explains LawDoc covers civil law (hukum perdata), but can mention Pasal 351 KUHP (penganiayaan) and recommend lapor polisi

---

### E-04 · Multi-issue question
```
Saya mau cerai dari suami yang juga punya hutang besar atas nama berdua kami, dan ada tanah warisan dari orang tua saya yang belum dibagi. Dari mana saya harus mulai?
```
**Expected**: decomposes into 3 issues (perceraian, utang bersama, waris), prioritizes, recommends konsultasi lawyer

---

### E-05 · Already in legal process
```
Saya sudah gugat cerai dan sidang pertama minggu depan. Apa yang harus saya siapkan?
```
**Expected**: practical procedural answer — dokumen identitas, akta nikah, bukti-bukti, surat gugatan, kemungkinan mediasi wajib di sidang pertama

---

## MULTIMODAL / DOCUMENT UPLOAD TEST CASES
*(for the /ocr-explain backend endpoint)*

| File | What to test |
|---|---|
| `documents/surat_utang_informal.txt` | informal debt letter, ask AI to explain obligations |
| `documents/perjanjian_sewa_rumah.txt` | rental contract, ask AI to flag risky clauses |
| `documents/surat_somasi.txt` | debt demand letter, ask AI what this means and what to do |
| `documents/akta_jual_beli_tanah.txt` | land sale deed, ask AI to explain buyer protections |
| `documents/surat_wasiat.txt` | will/testament, ask AI to validate structure and explain shares |
| `documents/pinjol_tagihan.txt` | predatory loan statement, ask AI to identify illegal terms |

---

## HOW TO RUN

**Backend must be running:**
```bash
cd backend && bash start.sh
```

**Send a prompt via curl:**
```bash
curl -X POST http://localhost:8000/tanya \
  -H "Content-Type: application/json" \
  -d '{"message": "Ayah saya meninggal tanpa wasiat. Ada 3 anak. Bagaimana harta dibagi?"}'
```

**Send a document via curl (OCR endpoint):**
```bash
# Encode document as base64 then:
curl -X POST http://localhost:8000/ocr-explain \
  -H "Content-Type: application/json" \
  -d "{\"image_base64\": \"$(base64 -i documents/surat_utang_informal.txt)\"}"
```
