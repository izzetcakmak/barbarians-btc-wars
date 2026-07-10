# Barbarians BTC Wars — Proje Bağlamı

Bu dosya claude.ai sohbetinden devir notudur. Claude Code bu dosyayı otomatik okur.

## Proje nedir
Canlı Bitcoin fiyatını gerçek zamanlı 3D savaşa dönüştüren tek dosyalık web oyunu.
Sahibi: İzzet (Hurrian AI — hurrianai.com). İletişim dili: Türkçe.

## Teknik özet
- Tek dosya: `index.html` (Three.js r128 CDN + vanilla JS, build yok, bağımlılık yok)
- Veri: Binance WebSocket `wss://stream.binance.com:9443/ws/btcusdt@kline_1s`
- Kapanan her 1sn mum bir saldırı dalgası doğurur:
  - Yeşil mum → boğa askerleri (uzaktan ateş eder), kırmızı mum → ayı iskeletleri (yakın dövüş)
  - Dalga büyüklüğü fiyat hareketiyle orantılı (1–14 birim); 1sn'de ~%0.04+ hareket → dev birim + banner
- Bağlantı kurulamazsa 5 sn sonra otomatik simülasyon modu (sağ üst rozet)
- Kamera: savaşın ağırlık merkezini takip eder, tüm birimler sığacak şekilde otomatik zoom yapar,
  dikey/mobil ekranda FOV 62°'ye çıkar
- Düşman kalmayınca galip taraf cephe hattına (x=±7) toplanır, devriye gezer, zafer zıplaması yapar;
  arena sınırı ±52 x / ±26 z (birimler ekran dışına çıkamaz)
- HUD: canlı fiyat, günlük %, ordu sayaçları, öldürme sayıları, güç çubuğu, kill feed (Türkçe)
- Birim tavanı: taraf başına 110

## Yapılacak ilk iş (kullanıcının talebi)
1. Bu klasörü `barbarians-btc-wars` adıyla **public** GitHub reposu olarak yayınla
   (git init → commit → gh repo create → push).
2. GitHub Pages'ı main branch'ten aktif et.
3. Canlı URL'yi kullanıcıya ver ve README.md'ye "Canlı Demo / Live Demo" linki olarak ekleyip
   tekrar push'la.

## Olası sonraki adımlar (kullanıcı isterse)
- Ses efektleri, gece/gündüz döngüsü
- cirbet.xyz (Arc Network prediction market) temasıyla renk uyumu
- ETH/SOL gibi ek pariteler, parite seçici
- OBS/YouTube yayın overlay modu (@HurrianAI kanalı için)

## Üslup notları
- Kullanıcıyla Türkçe konuş, İngilizce çıktıları (README, commit mesajı) sen üstlen.
- GUI-öncelikli, az sürtünmeli akışları tercih eder; komutların "neden"ini kısaca açıkla.
