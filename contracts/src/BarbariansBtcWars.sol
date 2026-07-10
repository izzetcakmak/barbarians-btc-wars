// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Barbarians BTC Wars — on-chain oyuncu kaydı ve epoch tahminleri
/// @notice Oyun 2 dakikalık epoch'larla döner. Oyuncular kullanıcı adı + takım
///         kaydeder ve BİR SONRAKİ epoch'un hedef BTC fiyatını zincire yazar:
///         epoch N içinde gönderilen tahmin N+1'in mumuna karşı puanlanır, yani
///         sonuç gönderim anında bilinemez (son-saniye avcılığı imkânsız).
///         Puanlama istemci tarafında, Prediction event'leri ve Binance kapanış
///         fiyatlarından deterministik olarak hesaplanır.
contract BarbariansBtcWars {
    uint256 public constant EPOCH_SECONDS = 120;
    uint8 public constant TEAM_BULL = 1;
    uint8 public constant TEAM_BEAR = 2;
    uint64 public constant MAX_PRICE = 1e13; // $100 milyar (cent) — saçma değerlere sınır

    struct Player {
        string name;      // 3-32 bayt; izinli karakterler: a-z A-Z 0-9 _ çğıöşü (TR)
        uint8 team;       // 1 = boğa, 2 = ayı
        uint64 joinedAt;
    }

    /// @notice Deploy eden owner cüzdanı (bilgi amaçlı; kontratta yönetici yetkisi yoktur)
    address public immutable owner;
    mapping(address => Player) public players;
    /// @dev Benzersizlik anahtarı büyük/küçük harf katlanmış ada göredir:
    ///      "İzzet", "izzet" ve "IZZET" aynı adı işgal eder (taklit koruması).
    mapping(bytes32 => address) public nameOwner;

    event Registered(address indexed player, string name, uint8 team);
    event NameReleased(address indexed player, string oldName);
    event TeamChanged(address indexed player, uint8 team);
    /// @param epoch tahminin HEDEF epoch'u (gönderim epoch'u + 1)
    /// @param targetPrice USD cinsinden fiyat * 100 (cent hassasiyeti)
    event Prediction(
        address indexed player,
        uint256 indexed epoch,
        uint8 team,
        uint64 targetPrice,
        string name
    );

    error InvalidName();
    error NameTaken();
    error InvalidTeam();
    error NotRegistered();
    error InvalidPrice();
    error WrongEpoch();

    constructor() {
        owner = msg.sender;
    }

    function currentEpoch() public view returns (uint256) {
        return block.timestamp / EPOCH_SECONDS;
    }

    /// @dev Karakter beyaz listesi + büyük/küçük harf katlama. İzinli: ASCII
    ///      a-z 0-9 _ (A-Z küçüğe katlanır) ve Türkçe çğıöşü (büyükleri katlanır;
    ///      İ ve ı aynı anahtara düşer). Diğer her bayt — görünmez karakterler,
    ///      Kiril benzerleri, kontrol baytları — InvalidName ile reddedilir.
    function _foldedKey(bytes memory b) private pure returns (bytes32) {
        bytes memory f = new bytes(b.length);
        uint256 i;
        while (i < b.length) {
            uint8 c = uint8(b[i]);
            if (c < 0x80) {
                if (c >= 0x41 && c <= 0x5A) c += 0x20; // A-Z -> a-z
                bool ok = (c >= 0x30 && c <= 0x39) || (c >= 0x61 && c <= 0x7A) || c == 0x5F;
                if (!ok) revert InvalidName();
                f[i] = bytes1(c);
                i += 1;
            } else {
                if (i + 1 >= b.length) revert InvalidName();
                uint16 pair = (uint16(c) << 8) | uint8(b[i + 1]);
                if (pair == 0xC387) pair = 0xC3A7;      // Ç -> ç
                else if (pair == 0xC396) pair = 0xC3B6; // Ö -> ö
                else if (pair == 0xC39C) pair = 0xC3BC; // Ü -> ü
                else if (pair == 0xC49E) pair = 0xC49F; // Ğ -> ğ
                else if (pair == 0xC4B0) pair = 0xC4B1; // İ -> ı (tek anahtar)
                else if (pair == 0xC59E) pair = 0xC59F; // Ş -> ş
                if (pair != 0xC3A7 && pair != 0xC3B6 && pair != 0xC3BC &&
                    pair != 0xC49F && pair != 0xC4B1 && pair != 0xC59F) revert InvalidName();
                f[i] = bytes1(uint8(pair >> 8));
                f[i + 1] = bytes1(uint8(pair));
                i += 2;
            }
        }
        return keccak256(f);
    }

    function register(string calldata name_, uint8 team_) external {
        bytes memory b = bytes(name_);
        if (b.length < 3 || b.length > 32) revert InvalidName();
        if (team_ != TEAM_BULL && team_ != TEAM_BEAR) revert InvalidTeam();

        bytes32 key = _foldedKey(b);
        address holder = nameOwner[key];
        if (holder != address(0) && holder != msg.sender) revert NameTaken();

        // eski adı serbest bırak (istemciler NameReleased ile eski görünümü düşürür)
        bytes memory old = bytes(players[msg.sender].name);
        if (old.length > 0) {
            delete nameOwner[_foldedKey(old)];
            emit NameReleased(msg.sender, players[msg.sender].name);
        }

        nameOwner[key] = msg.sender;
        players[msg.sender] = Player(name_, team_, uint64(block.timestamp));
        emit Registered(msg.sender, name_, team_);
    }

    function setTeam(uint8 team_) external {
        if (team_ != TEAM_BULL && team_ != TEAM_BEAR) revert InvalidTeam();
        Player storage p = players[msg.sender];
        if (bytes(p.name).length == 0) revert NotRegistered();
        p.team = team_;
        emit TeamChanged(msg.sender, team_);
    }

    /// @notice Bir SONRAKİ epoch için hedef fiyat tahmini yayınlar.
    /// @param targetPrice hedef fiyat, cent (USD * 100)
    /// @param epoch_ hedef epoch; tam olarak currentEpoch() + 1 olmalı. Gecikip
    ///        sınırı kaçıran tx sessizce yanlış epoch'a sayılmak yerine revert eder.
    /// @dev Aynı hedef epoch için birden çok çağrı serbesttir; istemciler son
    ///      event'i geçerli sayar (sonuç zaten gönderim anında bilinemez).
    function predict(uint64 targetPrice, uint256 epoch_) external {
        Player memory p = players[msg.sender];
        if (bytes(p.name).length == 0) revert NotRegistered();
        if (targetPrice == 0 || targetPrice >= MAX_PRICE) revert InvalidPrice();
        if (epoch_ != currentEpoch() + 1) revert WrongEpoch();
        emit Prediction(msg.sender, epoch_, p.team, targetPrice, p.name);
    }
}
