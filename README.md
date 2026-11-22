# Demon Modz Shop

Ye ek single-page website hai (`index.html`). GitHub Pages par seedha chalti hai.

## Files
- `index.html` : Pura website (login, Google login, hosting request tab, sab kuch)
- `.nojekyll` : GitHub Pages ko saadi HTML ki tarah chalane ke liye (zaroori, hatana nahi)
- `docs/` : Setup aur VPS guides (Hindi)
- `vps/deploy.sh` : Admin ke liye VPS par repo deploy karne ka script

## GitHub Pages par live kaise karein
1. Repository → Settings → Pages
2. Source: "Deploy from a branch", Branch: `main`, folder: `/ (root)`, Save
3. Kuch minute baad link aayega: `https://USERNAME.github.io/REPO-NAME/`

## Update kaise karein
- GitHub par `index.html` kholo → pencil (Edit) ya "Add file → Upload files" se naya `index.html` daalo → Commit changes.
- Commit ke 1-2 minute baad naya version live hoga.

## Zaroori
- Firebase Console → Authentication → Settings → Authorized domains mein `USERNAME.github.io` jodo, warna Google login nahi chalega.
- Bot token ya koi password is repo mein mat daalo.
