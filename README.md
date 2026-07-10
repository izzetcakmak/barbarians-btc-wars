# ⚔️ Barbarians BTC Wars

Canlı Bitcoin fiyatını gerçek zamanlı bir savaş oyununa dönüştüren web dApp'i.
A web game that turns the live Bitcoin price into a real-time battle arena.

**🎮 Canlı Demo / Live Demo: [izzetcakmak.github.io/barbarians-btc-wars](https://izzetcakmak.github.io/barbarians-btc-wars/)**

## Nasıl oynanır / How to play

1. **Giriş yap** — Google hesabınla (çok oyunculu) ya da misafir olarak.
2. **Kullanıcı adını seç** ve 🟢 **Boğa Ordusu** veya 💀 **Ayı İskeletleri** takımına katıl.
3. Her **2 dakikalık epoch** başında **hedef BTC fiyatını** yaz — adın ve hedefin,
   sahadaki kahraman askerinin üzerinde dolaşır.
4. Epoch bitiminde fiyat **yükseldiyse boğalar, düştüyse ayılar** turu kazanır:
   kazanan takımın oyuncuları **+10 puan**, fiyatı %0.05 içinde bilen **+5 isabet bonusu** alır.
5. Oyun 2 dakikalık epoch'larla sonsuza dek döner; puanlar liderlik tablosunda birikir.

Sign in with Google (multiplayer) or play as guest, pick a username and join the
bull or bear army. Each 2-minute epoch you submit a target BTC price — your name
and target float above your hero soldier on the battlefield. When the epoch ends,
bulls win if price went up, bears win if it went down: winners earn +10 points,
plus a +5 accuracy bonus for targets within 0.05% of the closing price.

## Savaş motoru / Battle engine

- Binance WebSocket üzerinden **1 saniyelik BTC/USDT mumları** izlenir.
- 🟢 Yeşil mum → oyuncak askerler (boğalar) cepheye koşar.
- 🔴 Kırmızı mum → iskeletler (ayılar) mezardan kalkar.
- Tek saniyede ~%0.04+ hareket **dev birim** doğurur.
- Bağlantı yoksa oyun otomatik olarak simülasyon moduna geçer.
- Epoch sonuçları canlı modda Binance 1dk mumlarından çözülür (her istemci için aynı kaynak).

## Çalıştırma / Run

Statik dosyalar, build yok. `index.html`'i tarayıcıda aç — misafir modu hemen çalışır.
Static files, zero build. Open `index.html` in a browser — guest mode just works.

Çok oyunculu mod (Google girişi + ortak savaş alanı + liderlik tablosu) için
[SETUP-FIREBASE.md](SETUP-FIREBASE.md) adımlarını izle.
For multiplayer (Google sign-in, shared battlefield, leaderboard) follow
[SETUP-FIREBASE.md](SETUP-FIREBASE.md).

## Robinhood Chain (on-chain mod)

Oyun [Robinhood Chain](https://chainlist.org/chain/4663) mainnet üzerinde çalışır
(chainId 4663): kullanıcı adı + takım kaydı ve her epoch'un hedef fiyat tahmini
zincire yazılır (`contracts/src/BarbariansBtcWars.sol`). Puanlar, zincirdeki
`Prediction` event'leri ve Binance kapanış fiyatlarından istemcide deterministik
olarak hesaplanır — sunucu/keeper yoktur.

Player registration and per-epoch price predictions live on Robinhood Chain
mainnet (chain id 4663). Scores are computed client-side from on-chain
`Prediction` events plus Binance closing prices — fully serverless.

```bash
# kontrat testleri / contract tests
forge test --root contracts
# deploy (owner cüzdanı, contracts/.env içinde PRIVATE_KEY)
forge script contracts/script/Deploy.s.sol --root contracts \
  --rpc-url https://rpc.mainnet.chain.robinhood.com --broadcast
```

## Teknoloji / Stack

Three.js (r128) · Binance WebSocket API · Robinhood Chain (Solidity + Foundry, ethers.js) · Firebase Auth + Firestore · Vanilla JS

---
Built by [Hurrian AI](https://hurrianai.com) 🎵
