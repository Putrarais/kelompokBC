# LAPORAN REVISI UTS

## Hipelem: Registri Kepemilikan Karya Film Berbasis Blockchain

**Kelompok:** 5  
**Nama Proyek:** Hipelem  
**Anggota Tim:**
1. Fakhri Muhtasib
2. Muhamad Haekal Bilal
3. Putra Rais Hakim

---
## Ruang Bukti Ringkasan Video Pengujian

- **Ringkasan Bukti Eksekusi Video:**
  - [x] **Bukti 1 (Revisi 5.1):** Pendaftaran film dengan genre enum dan konfirmasi output string.  
        👉 [Tonton Video Bukti 1](vidio/Screen%20Recording%202026-11-01%20215309.mp4)
  - [x] **Bukti 2 (Revisi 5.2):** Tampilan array `listFilmBioskop` pada akun 1 dan akun 2 tidak saling tertimpa.  
        👉 [Tonton Video Bukti 2](vidio/20261101-1451-54.5173918.mp4)
  - [x] **Bukti 3 (Penguat 5.P1):** Eksekusi `hapusFilm` dan pembaruan array kepemilikan.  
        👉 [Tonton Video Bukti 3](vidio/Screen%20Recording%202026-11-01%20220501.mp4)[cite: 1]
  - [x] **Bukti 4:** Tampilan Logs Event pada terminal Remix IDE (`FilmDitambahkan`, `KepemilikanDipindah`, `FilmDihapus`).  
        👉 [Tonton Video Bukti 4](vidio/20261101-1506-28.6295336.mp4)[cite: 1]

---

## 1. Ringkasan Matriks Revisi & Perbaikan

| Kode Revisi | Deskripsi Instruksi Revisi | Status & Solusi Implementasi |
| :--- | :--- | :--- |
| **Revisi 5.1** | Konversi `uint`/`enum` ke `string` pada kolom Genre. | **Selesai.** Membuat fungsi `genreToString(Genre)` untuk mengonversi Enum ke String serta memperbarui struct tampilan (`FilmDetail` dan `FilmSaya`) agar mengembalikan nama genre berbasis teks. |
| **Revisi 5.2** | Ganti `JumlahFilmPengguna` menjadi `listFilmBioskop` dengan key tetap `address`. | **Selesai.** Mengganti mapping lama menjadi `mapping(address => uint256[]) public listFilmBioskop;`. Mengamankan pemenuhan rubrik *Address* $\rightarrow$ *Data*. |
| **Revisi 5.3** | Terapkan nama resmi `Hipelem`. | **Selesai.** Kontrak diubah dari `HipelemMovieRegistry` menjadi `contract Hipelem` dan file disimpan sebagai `Hipelem.sol`. |
| **Penguat 5.P1** | Fungsi hapus film oleh pemilik (`hapusFilm`). | **Selesai.** Implementasi fungsi `hapusFilm(uint256 _id)` khusus pembuat. Meng-emit `FilmDihapus`, mengubah status `ada = false`, dan menghapus ID dari array `listFilmBioskop` milik pembuat. |

---

## 2. Penjelasan Detail Implementasi Kode

### A. Konversi Enum Genre ke String (Revisi 5.1)
Genre film didefinisikan menggunakan Solidity `enum` untuk efisiensi penyimpanan *state*. Pada fungsi getter data tampilan (`ambilSemuaFilmDetail`, `ambilDetailFilmById`, dan `ambilFilmBerdasarkanAlamat`), enum tersebut diconvert ke `string` melalui fungsi helper `genreToString`:

```solidity
function genreToString(Genre _genre) public pure returns (string memory) {
    if (_genre == Genre.Action) return "Action";
    if (_genre == Genre.Comedy) return "Comedy";
    if (_genre == Genre.Drama) return "Drama";
    if (_genre == Genre.Horror) return "Horror";
    if (_genre == Genre.Romance) return "Romance";
    if (_genre == Genre.SciFi) return "SciFi";
    if (_genre == Genre.Thriller) return "Thriller";
    if (_genre == Genre.Documentary) return "Documentary";
    return "Unknown";
}
```

### B. Struktur Mapping Kepemilikan (Revisi 5.2)
Untuk mempertahankan kriteria penilaian *Address* $\rightarrow$ *Data* sekaligus memfasilitasi pencatatan multisepemilikan, kami menggunakan struktur data:

```solidity
mapping(address => uint256[]) public listFilmBioskop;
```

* **Saat Tambah Film:** ID film baru di-`push` ke `listFilmBioskop[msg.sender]`.
* **Saat Transfer Kepemilikan:** ID film dihapus dari `listFilmBioskop[pemilikLama]` dan ditambahkan ke `listFilmBioskop[pemilikBaru]`.

### C. Penanganan Penghapusan Film (Penguat 5.P1)
Penghapusan data dilakukan secara *soft-delete* pada `semuaFilm` dengan mengubah properti `ada = false` guna menjaga histori immutability pada blockchain. Namun, untuk menjaga keakuratan tampilan dompet pemilik, ID film tersebut secara fisik di-`pop` dari array `listFilmBioskop[_pemilik]` menggunakan fungsi bantuan internal `_hapusDariList`.


---

## 4. Panduan & Skenario Pengujian di Remix IDE

1. **Kompilasi Kontrak:**
   * Buka Remix IDE, buat file `Hipelem.sol`.
   * Pilih Compiler versi `0.8.20` atau yang lebih baru.
   * Klik **Compile Hipelem.sol**.

2. **Pengujian Pendaftaran & Tampilan Genre String (Revisi 5.1):**
   * Panggil `tambahFilm("The Matrix", "Wachowskis", 136, "Perjuangan melawan SciFi AI", 5)` *(Genre SciFi = 5)*.
   * Panggil `ambilSemuaFilmDetail()` atau `ambilDetailFilmById(1)`.
   * Pastikan output `genreStr` mengembalikan string `"SciFi"` (bukan angka `5`).

3. **Pengujian Mapping & Alamat Dompet (Revisi 5.2):**
   * Gunakan Akun 1 (`0x5B38...`), daftarkan 2 film.
   * Panggil `listFilmBioskop(0x5B38...)` $\rightarrow$ Muncul ID `[1, 2]`.
   * Ganti ke Akun 2 (`0xAb84...`), daftarkan 1 film.
   * Panggil `listFilmBioskop(0xAb84...)` $\rightarrow$ Muncul ID `[3]`. Data kedua akun terbukti terpisah dan tidak tercampur.

4. **Pengujian Transfer & Hapus Film (Penguat 5.P1):**
   * Panggil `transferKepemilikanFilm(1, 0xAb84...)` dari Akun 1.
   * Cek `listFilmBioskop(0x5B38...)` $\rightarrow$ ID 1 terhapus.
   * Cek `listFilmBioskop(0xAb84...)` $\rightarrow$ ID 1 bertambah.
   * Panggil `hapusFilm(3)` dari Akun 2. `listFilmBioskop(0xAb84...)` akan memperbarui daftar tanpa menghapus histori global.

---

