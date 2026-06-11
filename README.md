# 🎵 MW Play

Africa's Music Platform — built with React + Vite + Supabase.

---

## 🚀 Quick Start (Local)

```bash
# 1. Install dependencies
npm install

# 2. Copy env file
cp .env.example .env

# 3. Fill in your Supabase keys in .env (or leave blank to use localStorage only)

# 4. Start dev server
npm run dev
```

Open http://localhost:5173

---

## 🗄️ Supabase Setup (Real Backend)

### Step 1 — Create a free project
1. Go to https://supabase.com and sign up free
2. Click **New Project**, pick a name and region close to Malawi (e.g. EU West)
3. Wait ~2 minutes for it to provision

### Step 2 — Run the schema
1. In Supabase dashboard → **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase_schema.sql`
3. Click **Run**

### Step 3 — Create Storage buckets
1. Go to **Storage** → **New Bucket**
2. Create three buckets (all set to **Public**):
   - `covers` — for song cover art
   - `audio` — for audio files
   - `avatars` — for profile photos

### Step 4 — Get your API keys
1. Go to **Settings** → **API**
2. Copy **Project URL** and **anon/public key**
3. Paste them into your `.env`:
```
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGci...
```

### Step 5 — Run again
```bash
npm run dev
```

---

## 🌐 Deploy Free

### Vercel (Recommended — fastest)
```bash
npm install -g vercel
vercel
```
Then add your env vars in Vercel Dashboard → Project → Settings → Environment Variables.

### Netlify
```bash
npm run build
# Drag the 'dist' folder to https://app.netlify.com/drop
```
Or connect your GitHub repo for auto-deploy.

**Add env vars:** Netlify Dashboard → Site → Environment Variables

---

## 🔑 Demo Credentials

| Role     | Access                          |
|----------|---------------------------------|
| Admin    | Profile → Admin Panel → `admin123` |
| Verify   | Email OTP → `947182`            |

---

## 📁 Project Structure

```
mwplay/
├── src/
│   ├── main.jsx          # React entry point
│   ├── MWPlay.jsx        # Main app (all components)
│   └── supabase.js       # Supabase client + DB helpers
├── public/
│   └── favicon.svg
├── index.html
├── vite.config.js
├── package.json
├── netlify.toml          # Netlify config
├── vercel.json           # Vercel config
├── supabase_schema.sql   # Full DB schema (run in Supabase)
├── .env.example          # Copy to .env and fill in keys
└── .gitignore
```

---

## 📱 Features

- 🎵 Stream music with real HTML5 audio player
- 🎤 Artist accounts with upload flow
- 💳 TNM Mpamba payment simulation (MWK 2,500 per upload)
- 📊 Artist dashboard with analytics
- ⚙️ Admin panel (approve/reject tracks, mark trending)
- 🔍 Search tracks and artists
- ♥ Like songs, follow artists
- 💬 Comments per track
- 🔀 Shuffle & repeat
- 📧 Email verification (OTP)
- 💾 localStorage fallback when Supabase not configured

---

## 🔒 Without Supabase

The app works fully offline with `localStorage` only.
Every user on the same device/browser shares data.
This is fine for testing — add Supabase when ready to go live.
