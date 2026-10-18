# Dokumentasi Lengkap & Bedah Kode Smart Contract: `HipelemMovieRegistry.sol`

### kelompok 3 ###
1. muhammad haekal bilal
2. fakhri muhtasib
3. putra rais hakim

## I. Glosarium & Istilah Teknis Solidity

Sebelum membedah kode baris demi baris, berikut adalah penjelasan istilah dan tipe data utama yang digunakan dalam kode ini:

 1. **`pragma solidity ^0.8.0;`**

    * **Fungsi:** Menentukan versi kompiler Solidity yang digunakan. `^0.8.0` berarti kode dapat dikompilasi menggunakan versi `0.8.0` hingga versi di bawah `0.9.0`.

 2. **`contract`**

    * **Fungsi:** Blok utama tempat penulisan logika program di Solidity (serupa dengan `class` pada bahasa pemrograman berorientasi objek seperti Java atau C++).

 3. **`uint256` (*Unsigned Integer 256-bit*)**

    * **Fungsi:** Tipe data angka bulat positif (tanpa tanda minus) dengan kapasitas ukuran 256 bit. Sangat umum digunakan di Ethereum untuk merepresentasikan ID, jumlah token, atau durasi.

 4. **`address`**

    * **Fungsi:** Tipe data khusus Solidity untuk menyimpan alamat akun/dompet kripto Ethereum (berformat string 42 karakter yang diawali dengan `0x...`).

 5. **`string`**

    * **Fungsi:** Tipe data untuk menyimpan karakter teks (seperti nama, judul, atau deskripsi sinopsis).

 6. **`bool` (*Boolean*)**

    * **Fungsi:** Tipe data logika yang hanya memiliki dua kemungkinan nilai: `true` (benar) atau `false` (salah). Digunakan sebagai penanda (*flag*) keberadaan data.

 7. **`enum` (*Enumeration*)**

    * **Fungsi:** Tipe data buatan yang membatasi pilihan variabel pada opsi yang sudah ditentukan saja. Di balik layar, Solidity menyimpan *enum* sebagai indeks angka yang dimulai dari `0`.

 8. **`struct` (*Structure*)**

    * **Fungsi:** Tipe data kustom yang memungkinkan kita menggabungkan beberapa variabel berbeda tipe ke dalam satu wadah/objek (misal: objek `Film` terdiri dari ID, judul, durasi, dll).

 9. **`mapping`**

    * **Fungsi:** Struktur data tabel pencarian (*hash table*) berbentuk pasangan Kunci-Nilai (*Key-Value pair*). Digunakan untuk menyimpan dan mencari data secara cepat.

10. **`public` / `external` / `internal` / `private` (*Visibility Specifiers*)**

    * **`public`:** Variabel/fungsi dapat diakses dari luar maupun dalam *smart contract*. Solidity otomatis membuatkan fungsi *getter* (pembaca data) untuk variabel `public`.

    * **`external`:** Fungsi hanya bisa dipanggil dari luar *smart contract* (misal oleh transaksi user atau aplikasi front-end).

11. **`view` & `pure`**

    * **`view`:** Menandakan fungsi hanya membaca data dari state blockchain tanpa mengubah data apapun (tidak memerlukan biaya *gas fee* jika dipanggil secara *read-only*).

12. **`modifier`**

    * **Fungsi:** Blok logika pengaman yang dijalankan **sebelum** sebuah fungsi dieksekusi. Digunakan untuk memeriksa syarat otorisasi/hak akses.

13. **`require`**

    * **Fungsi:** Pernyataan kondisional untuk validasi. Jika kondisi bernilai `true`, eksekusi berlanjut. Jika `false`, transaksi akan **dibatalkan (*revert*)**, semua perubahan state dibatalkan, dan sisa *gas* dikembalikan.

14. **`event` & `emit`**

    * **`event`:** Deklarasi sinyal/log yang dicatat di jaringan blockchain.

    * **`emit`:** Perintah untuk memicu atau memancarkan *event* tersebut ke log transaksi agar bisa dibaca oleh aplikasi luar (seperti Streamlit/Ethers.js).

15. **`msg.sender`**

    * **Fungsi:** Variabel bawaan Solidity yang menyimpan alamat dompet (*address*) akun yang sedang menandatangani dan mengirimkan transaksi tersebut.

## II. Bedah Kode Baris demi Baris (`HipelemMovieRegistry.sol`)

Berikut adalah analisis dan bedah logika pada kode smart contract:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

```

* **Penjelasan:**

  * `SPDX-License-Identifier`: Deklarasi lisensi perangkat lunak terbuka (MIT).

  * `pragma solidity`: Menginstruksikan kompiler untuk menggunakan Solidity versi 0.8.0 ke atas.

### 1. Deklarasi Kontrak & Enum Genre

```
contract HipelemMovieRegistry {
    enum Genre {
        Action,      // Nilai 0
        Comedy,      // Nilai 1
        Drama,       // Nilai 2
        Horror,      // Nilai 3
        Romance,     // Nilai 4
        SciFi,       // Nilai 5
        Thriller,    // Nilai 6
        Documentary  // Nilai 7
    }

```

* **Penjelasan:**

  * Membuka blok `contract` bernama `HipelemMovieRegistry`.

  * Membuat `enum Genre` yang mengelompokkan kategori film ke dalam 8 opsi standar. Dalam eksekusi Remix IDE atau Web3, genre dipilih dengan menginput angka indeksnya (`0` s/d `7`).

### 2. Definisi Struct `Film`

```
    struct Film {
        uint256 id;
        string judul;
        string sutradara;
        uint256 durasiMenit;
        string sinopsis;
        Genre genre;
        address pembuat;
        bool ada;
    }

```

* **Penjelasan:** Membentuk struktur data objek `Film` dengan properti:

  * `id`: Nomor identitas unik film.

  * `judul`: Nama film.

  * `sutradara`: Nama sutradara film.

  * `durasiMenit`: Panjang durasi film dalam hitungan menit.

  * `sinopsis`: Deskripsi singkat alur cerita.

  * `genre`: Tipe data enum yang telah dibuat sebelumnya.

  * `pembuat`: Alamat dompet peng-input film (`address`).

  * `bool ada`: Penanda (*flag*) apakah record film tersebut valid dan sudah terdaftar di blockchain (`true`/`false`).

### 3. State Variables & Storage

```
    uint256 public totalFilm;
    mapping(uint256 => Film) public daftarFilm;
    mapping(address => uint256) public jumlahFilmPengguna;

```

* **Penjelasan:**

  * `totalFilm`: Variabel global untuk menghitung jumlah **keseluruhan film** yang ada di jaringan.

  * `daftarFilm`: Penyimpanan utama berbasis mapping dari `ID (uint256)` ke objek `Film`. Memungkinkan pencarian data film secara instan berdasarkan ID.

  * `jumlahFilmPengguna`: Mapping dari `Address Pengguna` ke `Angka (uint256)`. Berfungsi menghitung berapa banyak film yang pernah dibuat oleh dompet tertentu.

### 4. Deklarasi Event Log

```
    event FilmDitambahkan(
        uint256 indexed id,
        string judul,
        address indexed pembuat
    );

    event FilmDiperbarui(
        uint256 indexed id,
        string sinopsisBaru
    );

    event KepemilikanDipindah(
        uint256 indexed id,
        address indexed pemilikLama,
        address indexed pemilikBaru
    );

```

* **Penjelasan:**

  * Mendaftarkan 3 jenis log transaksi. Kata kunci `indexed` memungkinkan aplikasi luar melakukan filter pencarian riwayat berdasarkan `id` atau `address` secara efisien.

### 5. Modifier Keamanan Access Control

```
    modifier hanyaPembuat(uint256 _id) {
        require(daftarFilm[_id].ada, "Error: Film tidak ditemukan.");
        require(
            daftarFilm[_id].pembuat == msg.sender,
            "Error: Akses ditolak! Hanya pembuat film yang dapat mengubah data."
        );
        _;
    }

```

* **Penjelasan:**

  * Modifier `hanyaPembuat` menerima parameter `_id`.

  * Syarat 1 (`require` pertama): Memastikan data film terdaftar (`ada == true`).

  * Syarat 2 (`require` kedua): Memastikan pengirim transaksi (`msg.sender`) adalah alamat dompet pembuat film asli yang tersimpan di `daftarFilm[_id].pembuat`.

  * Simbol `_;`: Menginstruksikan Solidity untuk melanjutkan ke kode fungsi utama jika semua syarat `require` terpenuhi.

### 6. Fungsi Pendaftaran Film (`tambahFilm`)

```
    function tambahFilm(
        string memory _judul,
        string memory _sutradara,
        uint256 _durasiMenit,
        string memory _sinopsis,
        Genre _genre
    ) external {
        require(bytes(_judul).length > 0, "Error: Judul tidak boleh kosong.");
        require(_durasiMenit > 0, "Error: Durasi film harus lebih dari 0 menit.");

        totalFilm++;
        uint256 idBaru = totalFilm;

        daftarFilm[idBaru] = Film({
            id: idBaru,
            judul: _judul,
            sutradara: _sutradara,
            durasiMenit: _durasiMenit,
            sinopsis: _sinopsis,
            genre: _genre,
            pembuat: msg.sender,
            ada: true
        });

        jumlahFilmPengguna[msg.sender]++;

        emit FilmDitambahkan(idBaru, _judul, msg.sender);
    }

```

* **Penjelasan:**

  * Fungsi berjenis `external` (dipanggil oleh pengguna dari luar).

  * `bytes(_judul).length > 0`: Memastikan string judul tidak dikirim kosong.

  * `totalFilm++`: Menambahkan variabel penghitung global sebesar 1 (sehingga film pertama bernilai ID `1`).

  * `daftarFilm[idBaru] = Film(...)`: Memasukkan struct data film baru ke dalam mapping dengan ID tersebut. `pembuat` otomatis diisi dengan `msg.sender`.

  * `jumlahFilmPengguna[msg.sender]++`: Menambahkan jumlah total karya khusus untuk dompet pengirim.

  * `emit FilmDitambahkan(...)`: Memancarkan event pencatatan sukses.

### 7. Fungsi Pembaruan Sinopsis (`perbaruiSinopsisFilm`)

```
    function perbaruiSinopsisFilm(uint256 _id, string memory _sinopsisBaru)
        external
        hanyaPembuat(_id)
    {
        require(bytes(_sinopsisBaru).length > 0, "Error: Sinopsis baru tidak boleh kosong.");
        
        daftarFilm[_id].sinopsis = _sinopsisBaru;

        emit FilmDiperbarui(_id, _sinopsisBaru);
    }

```

* **Penjelasan:**

  * Fungsi untuk mengubah deskripsi sinopsis.

  * Dilindungi oleh modifier `hanyaPembuat(_id)`. Jika dipanggil oleh akun yang bukan pembuat film, transaksi akan langsung gagal/ditolak.

  * `daftarFilm[_id].sinopsis = _sinopsisBaru`: Mengupdate properti sinopsis pada ID film terkait.

### 8. Fungsi Transfer Kepemilikan (`transferKepemilikanFilm`)

```
    function transferKepemilikanFilm(uint256 _id, address _pemilikBaru)
        external
        hanyaPembuat(_id)
    {
        require(_pemilikBaru != address(0), "Error: Alamat pemilik baru tidak valid.");
        require(_pemilikBaru != msg.sender, "Error: Anda sudah menjadi pemilik film ini.");

        address pemilikLama = msg.sender;
        
        // Update data pemilik
        daftarFilm[_id].pembuat = _pemilikBaru;
        
        // Adjust statistik jumlah film per pengguna
        jumlahFilmPengguna[pemilikLama]--;
        jumlahFilmPengguna[_pemilikBaru]++;

        emit KepemilikanDipindah(_id, pemilikLama, _pemilikBaru);
    }

```

* **Penjelasan:**

  * Memindahkan hak kedaulatan data film ke alamat dompet lain.

  * `_pemilikBaru != address(0)`: Mencegah pemindahan ke alamat kosong (*burn address*).

  * `daftarFilm[_id].pembuat = _pemilikBaru`: Mengganti entitas pembuat di database blockchain.

  * Menyesuaikan statistik jumlah film dengan mengurangi angka pada `pemilikLama` dan menambahkan angka pada `pemilikBaru`.

### 9. Fungsi Getter Kustom (`ambilDetailFilm`)

```
    function ambilDetailFilm(uint256 _id)
        external
        view
        returns (
            uint256 id,
            string memory judul,
            string memory sutradara,
            uint256 durasiMenit,
            string memory sinopsis,
            Genre genre,
            address pembuat
        )
    {
        require(daftarFilm[_id].ada, "Error: Film tidak ditemukan.");
        Film memory f = daftarFilm[_id];

        return (
            f.id,
            f.judul,
            f.sutradara,
            f.durasiMenit,
            f.sinopsis,
            f.genre,
            f.pembuat
        );
    }
}

```

* **Penjelasan:**

  * Fungsi berjenis `view` (bebas *gas fee* / hanya membaca data).

  * Menerima input ID film (`_id`) dan mengembalikan seluruh properti film dalam bentuk *tuple* variabel terpisah yang mudah dibaca oleh antarmuka aplikasi.