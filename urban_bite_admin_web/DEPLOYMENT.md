# 🚀 Deploying The Urban Bite - Admin Panel

This guide covers how to deploy the React + Vite admin web panel. Since the backend uses Firebase, the recommended and easiest method is **Firebase Hosting** (Option 1). Alternatively, you can use **Vercel** (Option 2) or **Netlify** (Option 3).

---

## 🛠️ Step 0: Build the Project Locally
Before deploying, you must compile the project to generate the production-ready code:
1. Open your terminal in the `urban_bite_admin_web` directory.
2. Run:
   ```bash
   npm run build
   ```
This will compile the app and create a static folder called **`dist`** containing all the production code.

---

## 🔹 Option 1: Deploy to Firebase Hosting (Recommended)
Since your project is already built on Firebase, you can host it directly on Firebase's global CDN for free.

### 1. Install Firebase CLI
If you don't have it already, install the Firebase command-line tools globally:
```bash
npm install -g firebase-tools
```

### 2. Log In to Firebase
Log into your Google/Firebase account in the terminal:
```bash
firebase login
```

### 3. Initialize Firebase Hosting
Run this command from the root of the `urban_bite_admin_web` directory:
```bash
firebase init hosting
```

**Answer the configuration prompts exactly as follows:**
* **Select Project**: Choose `Use an existing project` and select your project: **`zomato-clone-98044`**.
* **Public Directory**: Type **`dist`** (Vite's output folder) and press Enter.
* **Configure as Single Page App**: Type **`y`** (Yes) and press Enter (this routes all navigation URLs to `index.html`).
* **Set up automatic builds and deploys with GitHub?**: Type **`n`** (No).
* **File `dist/index.html` already exists. Overwrite?**: Type **`n`** (No) to keep your custom HTML intact.

### 4. Deploy the App
Simply build and deploy using:
```bash
npm run build
firebase deploy --only hosting
```
Once completed, Firebase will provide you with a hosting URL (e.g., `https://zomato-clone-98044.web.app`) where your panel is live!

---

## 🔹 Option 2: Deploy to Vercel (Super Fast 1-Click)
Vercel is extremely popular, fast, and deploys static frontend apps in seconds.

### 1. Install Vercel CLI
```bash
npm install -g vercel
```

### 2. Deploy
Run this in the `urban_bite_admin_web` directory:
```bash
vercel
```
**Answer the prompts:**
* Set up and deploy? **Yes**
* Project name: **urban-bite-admin**
* Link to existing project? **No**
* Directory? **`./`**
* Want to modify settings? **No** (Vercel automatically detects Vite, runs `npm run build`, and serves from the `dist` directory).

Once the initial deploy is done, push it to production with:
```bash
vercel --prod
```

---

## 🔹 Option 3: Deploy to Netlify
Netlify is another excellent option for hosting Vite applications.

### 1. Install Netlify CLI
```bash
npm install -g netlify-cli
```

### 2. Deploy
1. Build the production files:
   ```bash
   npm run build
   ```
2. Deploy the build:
   ```bash
   netlify deploy
   ```
* Select `Create & configure a new site`.
* Choose your team.
* When asked for the **Publish directory**, type **`dist`**.
3. Once satisfied, deploy it to production:
   ```bash
   netlify deploy --prod
   ```
