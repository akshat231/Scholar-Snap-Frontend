# 📚 Scholar Snap Frontend

Scholar Snap is a modern Flutter application that helps users **upload, summarize, cite, and query academic documents** — all powered by **OpenAI’s API** and **Retrieval-Augmented Generation (RAG)**.  
It integrates **Google Sign-In** for authentication and supports both **dark** and **light** themes for a comfortable reading experience.

---

## ✨ Features

- 🔐 **Google Sign-In** – Secure authentication via Google.
- 📤 **Document Upload** – Upload PDFs or other supported file types.
- 🧠 **Automatic Summarization** – Generate concise summaries using OpenAI.
- 📚 **Citation Generator** – Automatically extract and format citations.
- 💬 **Smart Q&A (RAG)** – Ask questions and get context-aware answers from your uploaded documents.
- 🌗 **Dark & Light Modes** – Seamless theme switching for user comfort.
- ⚡ **Fast & Responsive** – Built with Flutter for cross-platform performance.

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | [Flutter](https://flutter.dev/) |
| Authentication | Google Sign-In |
| AI/ML | OpenAI API (ChatGPT, Embeddings) |
| Data Handling | RAG (Retrieval-Augmented Generation) |
| State Management | Riverpod / Provider (update as appropriate) |
| Backend (optional) | Node.js / Firebase / Supabase (depending on your setup) |

---

## 🚀 Getting Started

### 1. Prerequisites
Make sure you have:
- Flutter SDK installed ([Install Guide](https://flutter.dev/docs/get-started/install))
- A Google Cloud project with **OAuth client credentials**
- Any backend endpoint (if applicable) for document processing and embeddings

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/scholar-snap-frontend.git
cd scholar-snap-frontend
```

### 3. Install Dependencies
```bash
flutter pub get
```
### 4. Configure Environment Variables
Create a .env file in the root directory (or use Flutter flavors depending on your setup).

```bash
BACKEND_HOST=10.0.2.2
BACKEND_PORT=7000
BACKEND_PROTOCOL=http
GOOGLE_CLIENT_ID=2341242353456345633465345.apps.googleusercontent.com
```

### 5. Run App
```bash
flutter run -d <device id>
```

## 🤝 Contributing

Contributions are welcome!
Feel free to open issues or submit pull requests to improve features, fix bugs, or enhance documentation.

## 📜 License

This project is licensed under the MIT License.
You’re free to use, modify, and distribute it with attribution.

