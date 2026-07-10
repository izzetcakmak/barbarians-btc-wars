# ⚔️ Barbarians BTC Wars

Canlı Bitcoin fiyatını gerçek zamanlı bir savaşa dönüştüren web oyunu.
A web game that turns the live Bitcoin price into a real-time battle.

**🎮 Canlı Demo / Live Demo: [izzetcakmak.github.io/barbarians-btc-wars](https://izzetcakmak.github.io/barbarians-btc-wars/)**

## Nasıl çalışır / How it works

- Binance WebSocket üzerinden **1 saniyelik BTC/USDT mumları** izlenir.
- 🟢 Yeşil mum → oyuncak askerler (boğalar) cepheye koşar.
- 🔴 Kırmızı mum → iskeletler (ayılar) mezardan kalkar.
- Fiyat hareketi ne kadar sertse saldırı dalgası o kadar büyük olur; tek saniyede ~%0.04+ hareket **dev birim** doğurur.
- Bağlantı yoksa oyun otomatik olarak simülasyon moduna geçer.

Every 1-second BTC/USDT candle from Binance spawns an attack wave: green candles spawn bull soldiers, red candles raise bear skeletons. Bigger moves spawn bigger waves; a ~0.04%+ move in one second spawns a giant unit. Falls back to simulation mode if the stream is unavailable.

## Çalıştırma / Run

Tek dosya, bağımlılık yok. `index.html`'i tarayıcıda aç, bitti.
Single file, zero build. Open `index.html` in a browser — that's it.

## Teknoloji / Stack

Three.js (r128) · Binance WebSocket API · Vanilla JS — tek HTML dosyası.

---
Built by [Hurrian AI](https://hurrianai.com) 🎵
