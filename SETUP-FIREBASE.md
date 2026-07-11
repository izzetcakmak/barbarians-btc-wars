# Firebase Kurulumu (Google girişi — çok oyunculu)

Oyun bu adımlar tamamlanana kadar Google girişi olmadan (🦊 cüzdan + misafir)
çalışır. Kurulum ~5 dakika, **kredi kartı gerektirmez** (Realtime Database,
Spark ücretsiz planında çalışır — Firestore kullanmıyoruz).

## 1. Proje oluştur
1. https://console.firebase.google.com → **Add project / Proje oluştur**
2. İsim: `barbarians-btc-wars` (Google Analytics kapatılabilir) → oluştur.

## 2. Web uygulaması ekle
1. Proje ana sayfasında **</>** (Web) simgesine tıkla.
2. Takma ad: `btc-wars` → **Register app** (Hosting kutusunu işaretleme).
3. Ekranda çıkan `firebaseConfig = { ... }` bloğunu kopyala — 6. adımda lazım.

## 3. Google girişini aç
1. Sol menü **Build → Authentication → Get started**.
2. **Sign-in method** sekmesi → **Google** → Enable → destek e-postanı seç → Save.

## 4. İzinli alan adlarını ekle
**Authentication → Settings → Authorized domains** listesine şu ikisini ekle
(`localhost` zaten ekli olur):
- `www.barbariansbtcwars.xyz`
- `izzetcakmak.github.io`

## 5. Realtime Database'i aç
1. Sol menü **Build → Realtime Database → Create database**.
2. Konum: **Belgium (europe-west1)** → **Locked mode** ile oluştur.
3. **Rules** sekmesine bu repodaki [database.rules.json](database.rules.json)
   içeriğini yapıştır → **Publish**.

> Not: Konum olarak Belçika dışında bir bölge seçersen, veritabanı sayfasının
> üstünde görünen `https://...firebasedatabase.app` adresini de config'le
> birlikte ilet (oyun varsayılan olarak Belçika adresini türetir).

## 6. Config'i oyuna bağla
1. Bu klasördeki `firebase-config.example.js` dosyasını `firebase-config.js`
   adıyla kopyala.
2. İçindeki değerleri 2. adımda kopyaladığın config ile değiştir.
3. Commit + push — yayınlanınca giriş ekranında **🔑 GOOGLE İLE GİRİŞ** belirir.

> Not: Firebase web config'i gizli değildir (API anahtarı istemci anahtarıdır);
> public repoya konması güvenlik sorunu yaratmaz. Erişim kontrolü
> `database.rules.json` ile sağlanır.

## Veri modeli (Realtime Database)
- `players/{uid}` — name, nameLower, team, points, wins, updatedAt
- `usernames/{nameLower}` — { uid } (kullanıcı adı rezervasyonu, transaction ile)
- `epochs/{epochId}/preds/{uid}` — name, team, target, t
  (tahminler hedef epoch'un altına yazılır; hedef = gönderim epoch'u + 1)
