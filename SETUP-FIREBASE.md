# Firebase Kurulumu (çok oyunculu mod)

Oyun bu dosyadaki adımlar tamamlanana kadar **misafir modunda** çalışır.
Google girişi + gerçek çok oyunculu için ~5 dakikalık tek seferlik kurulum:

## 1. Proje oluştur
1. https://console.firebase.google.com → **Add project / Proje ekle**
2. İsim: `barbarians-btc-wars` (Google Analytics kapatılabilir) → oluştur.

## 2. Web uygulaması ekle
1. Proje ana sayfasında **</>** (Web) simgesine tıkla.
2. Takma ad: `btc-wars` → **Register app**.
3. Ekranda çıkan `firebaseConfig = { ... }` bloğunu kopyala — birazdan lazım.

## 3. Google girişini aç
1. Sol menü **Build → Authentication → Get started**.
2. **Sign-in method** sekmesi → **Google** → Enable → kaydet.
3. **Settings → Authorized domains** listesine şu ikisini ekle
   (`localhost` zaten ekli olur):
   - `www.barbariansbtcwars.xyz`
   - `izzetcakmak.github.io`

## 4. Firestore'u aç
1. Sol menü **Build → Firestore Database → Create database**.
2. Konum: `eur3 (europe-west)` uygun → **Production mode** ile oluştur.
3. **Rules** sekmesine bu repodaki [firestore.rules](firestore.rules) içeriğini
   yapıştır → **Publish**.

## 5. Config'i oyuna bağla
1. Bu klasördeki `firebase-config.example.js` dosyasını `firebase-config.js`
   adıyla kopyala.
2. İçindeki değerleri 2. adımda kopyaladığın config ile değiştir.
3. Commit + push — GitHub Pages yayınlanınca giriş ekranında
   **🔑 GOOGLE İLE GİRİŞ** butonu belirir.

> Not: Firebase web config'i gizli değildir (API anahtarı istemci anahtarıdır);
> public repoya konması güvenlik sorunu yaratmaz. Erişim kontrolü
> `firestore.rules` ile sağlanır.

## Veri modeli
- `players/{uid}` — name, nameLower, team, points, wins
- `usernames/{nameLower}` — uid (kullanıcı adı rezervasyonu)
- `epochs/{epochId}/preds/{uid}` — name, team, target, t
