// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Hipelem {

    // Enum untuk Pilihan Dropdown di Remix
    enum Genre { Action, Comedy, Drama, Horror, Romance, SciFi, Thriller, Documentary }

    // Struct Internal Penyimpanan Data Film
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

    // Struct Tampilan untuk Daftar Keseluruhan
    struct FilmDetail {
        uint256 id;
        string judul;
        string sutradara;
        uint256 durasiMenit;
        string sinopsis;
        string genreStr;
        address pembuat;
        bool ada;
    }

    // Struct Tampilan Film Milik Dompet Aktif (satu film = satu blok)
    struct FilmSaya {
        uint256 id;
        string judul;
        string sutradara;
        uint256 durasiMenit;
        string sinopsis;
        string genreStr;
    }

    // Array disimpan secara internal
    Film[] internal semuaFilm;

    // Mapping ID film => posisi (index) di array, supaya pencarian langsung
    mapping(uint256 => uint256) internal idKeIndex;

    // Daftar ID film aktif per dompet/pengguna (key tetap address)
    mapping(address => uint256[]) public listFilmBioskop;

    uint256 public totalFilm;

    // Events
    event FilmDitambahkan(
        uint256 indexed id,
        string judul,
        string sutradara,
        uint256 durasiMenit,
        string sinopsis,
        string genreStr,
        address indexed pembuat
    );
    event FilmDiubah(
        uint256 indexed id,
        string judul,
        string sutradara,
        uint256 durasiMenit,
        string sinopsis,
        string genreStr
    );
    event FilmDiperbarui(uint256 indexed id, string sinopsisBaru);
    event KepemilikanDipindah(uint256 indexed id, address indexed pemilikLama, address indexed pemilikBaru);
    event FilmDihapus(uint256 indexed id, address indexed pembuat);

    // Modifier Keamanan (berdasarkan ID film)
    modifier hanyaPembuat(uint256 _id) {
        require(_id > 0 && _id <= totalFilm, "Error: ID film tidak ditemukan.");
        Film storage f = semuaFilm[idKeIndex[_id]];
        require(f.ada, "Error: Film tidak ditemukan atau sudah dihapus.");
        require(f.pembuat == msg.sender, "Error: Akses ditolak! Hanya pembuat film yang dapat mengubah data.");
        _;
    }

    // Fungsi Pendukung: Konversi Enum ke String
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

    // Fungsi Pendukung: Hapus ID film dari listFilmBioskop milik sebuah dompet (urutan dijaga)
    function _hapusDariList(address _pemilik, uint256 _id) internal {
        uint256[] storage daftar = listFilmBioskop[_pemilik];
        for (uint256 i = 0; i < daftar.length; i++) {
            if (daftar[i] == _id) {
                for (uint256 k = i; k < daftar.length - 1; k++) {
                    daftar[k] = daftar[k + 1];
                }
                daftar.pop();
                break;
            }
        }
    }

    // Fungsi Pendukung: Validasi input teks & durasi (dipakai tambah & ubah film)
    function _validasiInput(
        string memory _judul,
        string memory _sutradara,
        uint256 _durasiMenit,
        string memory _sinopsis
    ) internal pure {
        require(bytes(_judul).length > 0, "Error: Judul film wajib diisi.");
        require(bytes(_sutradara).length > 0, "Error: Sutradara wajib diisi.");
        require(_durasiMenit > 0, "Error: Durasi film harus lebih dari 0 menit.");
        require(bytes(_sinopsis).length > 0, "Error: Sinopsis wajib diisi.");
    }

    // 1. Tambah Film (Create)
    function tambahFilm(
        string memory _judul,
        string memory _sutradara,
        uint256 _durasiMenit,
        string memory _sinopsis,
        Genre _genre
    ) public {
        _validasiInput(_judul, _sutradara, _durasiMenit, _sinopsis);

        totalFilm++;
        uint256 idBaru = totalFilm;

        semuaFilm.push(Film({
            id: idBaru,
            judul: _judul,
            sutradara: _sutradara,
            durasiMenit: _durasiMenit,
            sinopsis: _sinopsis,
            genre: _genre,
            pembuat: msg.sender,
            ada: true
        }));
        idKeIndex[idBaru] = semuaFilm.length - 1;
        listFilmBioskop[msg.sender].push(idBaru);

        emit FilmDitambahkan(
            idBaru,
            _judul,
            _sutradara,
            _durasiMenit,
            _sinopsis,
            genreToString(_genre),
            msg.sender
        );
    }

    // 2. Perbarui Sinopsis (Update) - pakai ID film
    function perbaruiSinopsisFilm(uint256 _id, string memory _sinopsisBaru) public hanyaPembuat(_id) {
        require(bytes(_sinopsisBaru).length > 0, "Error: Sinopsis baru tidak boleh kosong.");
        semuaFilm[idKeIndex[_id]].sinopsis = _sinopsisBaru;
        emit FilmDiperbarui(_id, _sinopsisBaru);
    }

    // 3. Perbarui Seluruh Data Film (Update lengkap) - pakai ID film
    function perbaruiFilm(
        uint256 _id,
        string memory _judul,
        string memory _sutradara,
        uint256 _durasiMenit,
        string memory _sinopsis,
        Genre _genre
    ) public hanyaPembuat(_id) {
        _validasiInput(_judul, _sutradara, _durasiMenit, _sinopsis);

        Film storage f = semuaFilm[idKeIndex[_id]];
        f.judul = _judul;
        f.sutradara = _sutradara;
        f.durasiMenit = _durasiMenit;
        f.sinopsis = _sinopsis;
        f.genre = _genre;

        emit FilmDiubah(_id, _judul, _sutradara, _durasiMenit, _sinopsis, genreToString(_genre));
    }

    // 4. Transfer Kepemilikan (Action) - pakai ID film
    function transferKepemilikanFilm(uint256 _id, address _pemilikBaru) public hanyaPembuat(_id) {
        require(_pemilikBaru != address(0), "Error: Alamat dompet penerima tidak valid.");
        require(_pemilikBaru != msg.sender, "Error: Anda sudah menjadi pemilik film ini.");

        Film storage f = semuaFilm[idKeIndex[_id]];
        address pemilikLama = f.pembuat;
        f.pembuat = _pemilikBaru;

        _hapusDariList(pemilikLama, _id);
        listFilmBioskop[_pemilikBaru].push(_id);

        emit KepemilikanDipindah(_id, pemilikLama, _pemilikBaru);
    }

    // 5. Hapus Film (Penguat) - pakai ID film
    function hapusFilm(uint256 _id) public hanyaPembuat(_id) {
        semuaFilm[idKeIndex[_id]].ada = false;
        _hapusDariList(msg.sender, _id);
        emit FilmDihapus(_id, msg.sender);
    }

    // 6. Tampilkan Seluruh Detail Film
    function ambilSemuaFilmDetail() public view returns (FilmDetail[] memory) {
        FilmDetail[] memory hasil = new FilmDetail[](semuaFilm.length);
        for (uint256 i = 0; i < semuaFilm.length; i++) {
            Film memory f = semuaFilm[i];
            hasil[i] = FilmDetail({
                id: f.id,
                judul: f.judul,
                sutradara: f.sutradara,
                durasiMenit: f.durasiMenit,
                sinopsis: f.sinopsis,
                genreStr: genreToString(f.genre),
                pembuat: f.pembuat,
                ada: f.ada
            });
        }
        return hasil;
    }

    // 7. Ambil Detail Film Berdasarkan ID (Output Terpisah seperti Tambah Film)
    function ambilDetailFilmById(uint256 _id) public view returns (
        uint256 id,
        string memory judul,
        string memory sutradara,
        uint256 durasiMenit,
        string memory sinopsis,
        string memory genreStr,
        address pembuat
    ) {
        require(_id > 0 && _id <= totalFilm, "Error: ID film tidak ditemukan.");
        Film storage f = semuaFilm[idKeIndex[_id]];
        require(f.ada, "Error: Film dengan ID tersebut sudah dihapus.");

        return (
            f.id,
            f.judul,
            f.sutradara,
            f.durasiMenit,
            f.sinopsis,
            genreToString(f.genre),
            f.pembuat
        );
    }

    // 8. Tampilkan Detail Lengkap Film Milik Dompet Aktif (dari listFilmBioskop)
    //    Output per film: id, judul, sutradara, durasiMenit, sinopsis, genreStr
    function tampilkanFilmDanDurasiSaya() public view returns (FilmSaya[] memory) {
        uint256[] storage daftar = listFilmBioskop[msg.sender];
        FilmSaya[] memory hasil = new FilmSaya[](daftar.length);

        for (uint256 i = 0; i < daftar.length; i++) {
            Film storage f = semuaFilm[idKeIndex[daftar[i]]];
            hasil[i] = FilmSaya({
                id: f.id,
                judul: f.judul,
                sutradara: f.sutradara,
                durasiMenit: f.durasiMenit,
                sinopsis: f.sinopsis,
                genreStr: genreToString(f.genre)
            });
        }
        return hasil;
    }
}
