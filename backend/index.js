const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { GoogleGenerativeAI } = require('@google/generative-ai');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

if (!GEMINI_API_KEY || GEMINI_API_KEY === 'YOUR_GEMINI_API_KEY_HERE') {
  console.warn("⚠️ PERINGATAN: GEMINI_API_KEY belum dikonfigurasi di file .env!");
}

// Inisialisasi Google Generative AI
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY || "");

// System Prompt untuk Pembuatan Kuis
const systemPromptQuiz = `
Anda adalah PrepMaster AI, sebuah AI pembuat kuis pintar.
Tugas Anda adalah memproses topik belajar yang diberikan pengguna dan menghasilkan kuis pilihan ganda yang terstruktur.

Langkah-langkah pemrosesan:
1. Validasi Input:
   Periksa apakah topik belajar yang dimasukkan pengguna valid dan masuk akal untuk dipelajari.
   Jika topiknya kosong, terlalu pendek (kurang dari 3 karakter), berupa ketukan acak keyboard/gibberish (misalnya "asdfgh", "qwertyuiop", "xxxxx"), atau tidak memiliki arti edukatif yang jelas, Anda harus menganggap input ini TIDAK VALID.
   Jika tidak valid, kembalikan JSON dengan format:
   {
     "is_valid": false,
     "error_message": "Topik tidak jelas atau terlalu acak. Silakan masukkan topik belajar yang valid (contoh: \\"Flutter\\", \\"Sains\\", \\"Tata Surya\\", \\"Sejarah\\")."
   }

2. Pembuatan Pertanyaan (jika topik VALID):
   Buatlah tepat N pertanyaan pilihan ganda mengenai topik tersebut dengan tingkat kesulitan D (Mudah, Sedang, atau Sulit).
   Ketentuan pertanyaan:
   - Harus dalam Bahasa Indonesia yang baik dan benar.
   - Setiap pertanyaan harus memiliki tepat 4 opsi pilihan ganda.
   - Tentukan indeks jawaban benar (correct_answer_index) dari 0 sampai 3 (0=opsi ke-1, 1=opsi ke-2, dll).
   - Tulis petunjuk singkat (hint) yang membantu pengguna memikirkan jawaban tanpa membocorkannya langsung.
   - Tulis penjelasan (explanation) detail yang menjelaskan mengapa jawaban tersebut benar dan konsep di baliknya.
   Kembalikan JSON dengan format:
   {
     "is_valid": true,
     "topic": "Nama topik yang dirapikan (kapitalisasi yang benar)",
     "questions": [
       {
         "question": "Teks pertanyaan",
         "options": ["Opsi A", "Opsi B", "Opsi C", "Opsi D"],
         "correct_answer_index": 0,
         "hint": "Petunjuk singkat",
         "explanation": "Penjelasan detail"
       }
     ]
   }

Kembalikan HANYA data JSON di atas tanpa markdown wrapper, tanpa tag \`\`\`json, dan tanpa teks tambahan lainnya.
`;

// System Prompt untuk Panduan Belajar (Study Guide)
const systemPromptStudyGuide = `
Anda adalah PrepMaster AI, sebuah asisten belajar personal berbasis AI.
Tugas Anda adalah meracik Panduan Belajar personalisasi (Study Guide) berformat Markdown dalam Bahasa Indonesia yang berfokus pada perbaikan pemahaman konsep dari pertanyaan-pertanyaan kuis yang salah dijawab oleh pengguna.

Format keluaran harus menggunakan Markdown yang bersih dan indah.
Struktur Markdown yang wajib diikuti:

# 📚 Panduan Belajar AI Personalisasi: [Nama Topik]
Diulas berdasarkan hasil evaluasi kuis Anda di sesi ini.

## 💡 Ulasan Konsep yang Meleset
Ulaslah setiap pertanyaan yang salah dijawab oleh pengguna secara terperinci. Jelaskan konsep teoritis di balik pertanyaan tersebut dengan bahasa yang mudah dipahami, ramah, dan mendidik.
Untuk setiap pertanyaan:
### [Nomor]. [Teks Pertanyaan]
* **Jawaban Benar yang Seharusnya:** [Teks opsi jawaban yang benar]
* **Penjelasan Detail:**
  [Penjelasan detail, mendalam, dan terstruktur tentang mengapa jawaban tersebut benar dan apa konsep utamanya.]

## 📖 Kamus Istilah Pintar (Glossary)
Berikan daftar istilah/kosakata kunci yang relevan dengan topik ini (minimal 3-5 istilah) berserta definisinya agar pemahaman pengguna lebih matang. Gunakan format list bullet:
* **[Istilah]**: [Definisi istilah]

Berikan teks keluaran langsung dalam format Markdown. Jangan bungkus dengan tag \`\`\`markdown atau teks pembuka/penutup lainnya.
`;

// Endpoint 1: Membuat Kuis (POST /api/generate-quiz)
app.post('/api/generate-quiz', async (req, res) => {
  try {
    const { topic, count, difficulty, modelVersion } = req.body;
    
    if (!topic || topic.trim().length === 0) {
      return res.json({
        is_valid: false,
        error_message: 'Topik belajar tidak boleh kosong.'
      });
    }

    const questionCount = parseInt(count) || 10;
    const level = difficulty || 'Sedang';
    const isPro = modelVersion === 'Pro';
    
    // Pilih model: Standard -> gemini-2.5-flash, Pro -> gemini-2.5-pro
    const modelName = isPro ? 'gemini-2.5-pro' : 'gemini-2.5-flash';
    console.log(`[PrepMaster API] Generating ${questionCount} questions on "${topic}" (${level}) using model ${modelName}...`);

    const model = genAI.getGenerativeModel({ 
      model: modelName,
      systemInstruction: systemPromptQuiz
    });

    const promptText = `Buatkan kuis mengenai topik: "${topic}" sebanyak ${questionCount} soal dengan tingkat kesulitan: "${level}".`;

    const result = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: promptText }] }],
      generationConfig: {
        responseMimeType: "application/json",
      }
    });

    const responseText = result.response.text();
    let sanitizedText = responseText.trim();
    
    // Fallback pembersihan tag markdown jika ada
    if (sanitizedText.startsWith("```json")) {
      sanitizedText = sanitizedText.substring(7);
    }
    if (sanitizedText.endsWith("```")) {
      sanitizedText = sanitizedText.substring(0, sanitizedText.length - 3);
    }

    const quizData = JSON.parse(sanitizedText.trim());
    return res.json(quizData);
  } catch (error) {
    console.error('[PrepMaster API] Error generating quiz:', error);
    return res.json({
      is_valid: false,
      error_message: `Gagal membuat kuis karena kesalahan server: ${error.message || error}`
    });
  }
});

// Endpoint 2: Membuat Panduan Belajar (POST /api/generate-study-guide)
app.post('/api/generate-study-guide', async (req, res) => {
  try {
    const { topic, incorrectQuestions } = req.body;

    if (!topic) {
      return res.status(400).send("Parameter 'topic' diperlukan.");
    }

    if (!incorrectQuestions || !Array.isArray(incorrectQuestions) || incorrectQuestions.length === 0) {
      const emptyGuide = `# 📚 Panduan Belajar AI Personalisasi: ${topic}
Diulas berdasarkan hasil evaluasi kuis Anda di sesi ini.

### 🎉 Luar Biasa! Nilai Sempurna!
Anda telah menjawab semua pertanyaan dengan benar. Tidak ada materi kesalahan yang perlu diulas.
Pertahankan performa Anda atau coba tingkatkan kesulitan kuis Anda ke level berikutnya!`;
      return res.send(emptyGuide);
    }

    console.log(`[PrepMaster API] Generating study guide for "${topic}" with ${incorrectQuestions.length} missed questions...`);

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.5-flash',
      systemInstruction: systemPromptStudyGuide
    });

    const promptText = `Topik: "${topic}"
Pertanyaan yang salah dijawab oleh pengguna:
${JSON.stringify(incorrectQuestions, null, 2)}`;

    const result = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: promptText }] }]
    });

    let markdown = result.response.text().trim();
    
    // Pembersihan markdown wrapper jika ada
    if (markdown.startsWith("```markdown")) {
      markdown = markdown.substring(11);
    } else if (markdown.startsWith("```")) {
      markdown = markdown.substring(3);
    }
    if (markdown.endsWith("```")) {
      markdown = markdown.substring(0, markdown.length - 3);
    }

    return res.send(markdown.trim());
  } catch (error) {
    console.error('[PrepMaster API] Error generating study guide:', error);
    return res.status(500).send(`Gagal meracik panduan belajar karena kesalahan sistem: ${error.message || error}`);
  }
});

// Jalankan Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
});
