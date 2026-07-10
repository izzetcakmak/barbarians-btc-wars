// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Barbarians BTC Wars — on-chain oyuncu kaydı ve epoch tahminleri
/// @notice Oyun 2 dakikalık epoch'larla döner. Oyuncular kullanıcı adı + takım
///         kaydeder ve her epoch için hedef BTC fiyatı tahminini zincire yazar.
///         Puanlama istemci tarafında, zincirdeki Prediction event'leri ve
///         Binance kapanış fiyatlarından deterministik olarak hesaplanır.
contract BarbariansBtcWars {
    uint256 public constant EPOCH_SECONDS = 120;
    uint8 public constant TEAM_BULL = 1;
    uint8 public constant TEAM_BEAR = 2;

    struct Player {
        string name;      // 3-20 bayt, benzersiz
        uint8 team;       // 1 = boğa, 2 = ayı
        uint64 joinedAt;
    }

    address public immutable owner;
    mapping(address => Player) public players;
    mapping(bytes32 => address) public nameOwner; // keccak256(name) -> adres

    event Registered(address indexed player, string name, uint8 team);
    event TeamChanged(address indexed player, uint8 team);
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

    constructor() {
        owner = msg.sender;
    }

    function currentEpoch() public view returns (uint256) {
        return block.timestamp / EPOCH_SECONDS;
    }

    function register(string calldata name_, uint8 team_) external {
        bytes memory b = bytes(name_);
        if (b.length < 3 || b.length > 20) revert InvalidName();
        if (team_ != TEAM_BULL && team_ != TEAM_BEAR) revert InvalidTeam();

        bytes32 key = keccak256(b);
        address holder = nameOwner[key];
        if (holder != address(0) && holder != msg.sender) revert NameTaken();

        // eski adı serbest bırak
        bytes memory old = bytes(players[msg.sender].name);
        if (old.length > 0) delete nameOwner[keccak256(old)];

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

    /// @notice Aktif epoch için hedef fiyat tahmini yayınlar.
    ///         Aynı epoch'ta birden fazla çağrı serbesttir; istemciler son
    ///         event'i geçerli sayar.
    function predict(uint64 targetPrice) external {
        Player memory p = players[msg.sender];
        if (bytes(p.name).length == 0) revert NotRegistered();
        if (targetPrice == 0) revert InvalidPrice();
        emit Prediction(msg.sender, currentEpoch(), p.team, targetPrice, p.name);
    }
}
