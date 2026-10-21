const fs = require('fs');
const path = require('path');
const https = require('https');

// Lokasi penyimpanan aset lokal
const targetDir = path.join(__dirname, 'assets', 'js');

// Daftar CDN dan nama file lokalnya
const libraries = [
    { url: "https://cdn.webrtc-experiment.com/Translator.js", filename: "Translator.js" },
    { url: "https://cdn.jsdelivr.net/npm/artyom.js/build/artyom.min.js", filename: "artyom.min.js" },
    { url: "https://cdnjs.cloudflare.com/ajax/libs/annyang/2.6.1/annyang.min.js", filename: "annyang.min.js" },
    { url: "https://cdn.jsdelivr.net/gh/kripken/speak.js/speakClient.js", filename: "speakClient.js" },
    { url: "https://www.masswerk.at/mespeak/mespeak.js", filename: "mespeak.js" },
    { url: "https://unpkg.com/jsvoice/dist/voice-ui.umd.min.js", filename: "voice-ui.umd.min.js" },
    { url: "https://unpkg.com/easy-speech/dist/EasySpeech.iife.js", filename: "EasySpeech.iife.js" },
    { url: "https://code.responsivevoice.org/responsivevoice.js", filename: "responsivevoice.js" },
    { url: "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js", filename: "ort.min.js" },
    { url: "https://cdn.jsdelivr.net/npm/speak-tts/dist/speak-tts.min.js", filename: "speak-tts.min.js" },
    { url: "https://cdn.jsdelivr.net/npm/speechkitt/dist/speechkitt.min.js", filename: "speechkitt.min.js" },
    { url: "https://cdn.webrtc-experiment.com/RecordRTC.js", filename: "RecordRTC.js" },
    { url: "https://cdnjs.cloudflare.com/ajax/libs/Recorderjs/0.1.0/recorder.min.js", filename: "recorder.min.js" },
    { url: "https://cdn.jsdelivr.net/npm/audio-recorder-polyfill/index.js", filename: "audio-recorder-polyfill.js" }
];

// Buat folder jika belum ada
if (!fs.existsSync(targetDir)){
    fs.mkdirSync(targetDir, { recursive: true });
}

// Fungsi download
function downloadFile(url, dest) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(dest);
        https.get(url, (response) => {
            // Menangani redirect jika ada (seperti unpkg / jsdelivr)
            if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
                file.close();
                fs.unlinkSync(dest); // Hapus file kosong yang terlanjur dibuat
                return downloadFile(response.headers.location, dest).then(resolve).catch(reject);
            }

            response.pipe(file);
            file.on('finish', () => {
                file.close();
                console.log(`✅ Berhasil mengunduh: ${path.basename(dest)}`);
                resolve();
            });
        }).on('error', (err) => {
            fs.unlink(dest, () => {}); 
            console.error(`❌ Gagal mengunduh ${path.basename(dest)}: ${err.message}`);
            reject(err);
        });
    });
}

// Jalankan proses download berurutan
async function startSetup() {
    console.log("🚀 Memulai proses unduh aset CDN ke lokal...");
    for (const lib of libraries) {
        const destPath = path.join(targetDir, lib.filename);
        try {
            await downloadFile(lib.url, destPath);
        } catch (e) {
            // Lanjut ke file berikutnya jika ada error
        }
    }
    console.log("\n🎉 Selesai! Semua file tersimpan di dalam folder 'assets/js/'");
}

startSetup();