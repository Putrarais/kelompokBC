// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract HipelemMovieRegistry {

    // 1. Enum: Memodelkan Genre Film
    enum Genre { Action, Comedy, Drama, Horror, Romance, SciFi, Thriller, Documentary }

    // 1. Struct: Memodelkan Objek Nyata (Film)
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

    // 2. Mapping: Menghubungkan ID Film dengan Struct Data Film
    mapping(uint256 => Film) public daftarFilm;

    // Mapping tambahan untuk melacak jumlah film yang dibuat oleh suatu alamat dompet
    mapping(address => uint256) public jumlahFilmPengguna;

    // Variabel untuk melacak total film
    uint256 public totalFilm;

    // 5. Events: Memancarkan riwayat transaksi untuk efisiensi gas
    event FilmDitambahkan(uint256 indexed id, string judul, address indexed pembuat);
    event FilmDiperbarui(uint256 indexed id, string sinopsisBaru);
    event KepemilikanDipindah(uint256 indexed id, address indexed pemilikLama, address indexed pemilikBaru);

    // Modifier untuk keamanan (hanya pembuat film yang bisa mengubah)
    modifier hanyaPembuat(uint256 _id) {
        require(daftarFilm[_id].ada, "Error: Film dengan ID tersebut tidak ditemukan. Tambah film terlebih dahulu!");
        require(daftarFilm[_id].pembuat == msg.sender, "Error: Akses ditolak! Hanya pembuat film yang dapat mengubah data.");
        _;
    }

    // ==========================================
    // FUNGSI INTI 1: TAMBAH FILM (CREATE)
    // *Harus dijalankan paling pertama*
    // ==========================================
    function tambahFilm(
        string memory _judul,
        string memory _sutradara,
        uint256 _durasiMenit,
        string memory _sinopsis,
        Genre _genre
    ) public {
        // 4. Keamanan (Error Handling): Memastikan input tidak kosong
        require(bytes(_judul).length > 0, "Error: Judul film wajib diisi.");
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

        // 5. Emit Event saat data berhasil dibuat
        emit FilmDitambahkan(idBaru, _judul, msg.sender);
    }

    // ==========================================
    // FUNGSI INTI 2: PERBARUI SINOPSIS (UPDATE)
    // ==========================================
    function perbaruiSinopsisFilm(uint256 _id, string memory _sinopsisBaru) public hanyaPembuat(_id) {
        require(bytes(_sinopsisBaru).length > 0, "Error: Sinopsis baru tidak boleh kosong.");

        daftarFilm[_id].sinopsis = _sinopsisBaru;

        // 5. Emit Event saat data diperbarui
        emit FilmDiperbarui(_id, _sinopsisBaru);
    }

    // ==========================================
    // FUNGSI INTI 3: TRANSFER KEPEMILIKAN (ACTION)
    // ==========================================
    function transferKepemilikanFilm(uint256 _id, address _pemilikBaru) public hanyaPembuat(_id) {
        require(_pemilikBaru != address(0), "Error: Alamat dompet penerima tidak valid.");
        require(_pemilikBaru != msg.sender, "Error: Anda sudah menjadi pemilik film ini.");

        address pemilikLama = daftarFilm[_id].pembuat;
        daftarFilm[_id].pembuat = _pemilikBaru;

        jumlahFilmPengguna[pemilikLama]--;
        jumlahFilmPengguna[_pemilikBaru]++;

        // 5. Emit Event saat kepemilikan ditransfer
        emit KepemilikanDipindah(_id, pemilikLama, _pemilikBaru);
    }

    // ==========================================
    // FUNGSI PENDUKUNG: LIHAT DETAIL FILM (READ)
    // ==========================================
    function ambilDetailFilm(uint256 _id) public view returns (
        string memory judul,
        string memory sutradara,
        uint256 durasiMenit,
        string memory sinopsis,
        Genre genre,
        address pembuat
    ) {
        require(daftarFilm[_id].ada, "Error: Film tidak ditemukan.");
        Film memory f = daftarFilm[_id];
        return (f.judul, f.sutradara, f.durasiMenit, f.sinopsis, f.genre, f.pembuat);
    }
}