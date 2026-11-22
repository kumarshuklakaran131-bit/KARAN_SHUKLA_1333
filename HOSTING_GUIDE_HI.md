# VPS से Demon Modz Shop चलाने की गाइड (Termux से)

## 0. पहले समझें
- Termux एक मोबाइल टर्मिनल है। इसमें साइट "चलती" नहीं रहती। साइट VPS पर चलेगी।
- Termux सिर्फ़ VPS से **SSH** के ज़रिए कनेक्ट होकर कमांड देने के काम आएगा।
- "Dramax" नाम का ऐप मुझे नहीं पता। अगर आप उसी ऐप में SSH करते हैं तो भी नीचे के कमांड वही रहेंगे।
- बॉट token अभी BotFather में `/revoke` करके बदलें। चैट में पुराना token मत रखें।

## 1. Termux में SSH सेटअप
```bash
pkg update -y && pkg upgrade -y
pkg install -y openssh git
ssh-keygen -t ed25519 -C "termux"        # Enter दबाते रहें
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@VPS_IP   # एक बार पासवर्ड पूछेगा
ssh root@VPS_IP                          # अब बिना पासवर्ड के लॉगिन
```
(`root` की जगह अपना VPS यूज़रनेम लिखें, `VPS_IP` की जगह IP।)

## 2. VPS पर ज़रूरी चीज़ें (एक बार)
```bash
sudo apt update && sudo apt install -y nginx git curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

## 3. मुख्य साइट (index.html) अपलोड करें
Termux से:
```bash
scp ~/storage/downloads/index.html root@VPS_IP:/var/www/demonmodz/index.html
```
(पहले `ssh root@VPS_IP "mkdir -p /var/www/demonmodz"` चलाएँ। फ़ाइल का रास्ता आपके फ़ोन में जहाँ है वहीं लिखें।)

## 4. Nginx से हमेशा ऑनलाइन रखें
VPS पर `/etc/nginx/sites-available/demonmodz` बनाएँ:
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/demonmodz;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
```
```bash
sudo ln -s /etc/nginx/sites-available/demonmodz /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```
HTTPS होने के बाद Firebase Console → Authorized domains में **yourdomain.com** ज़रूर जोड़ें, वरना Google लॉगिन नहीं चलेगा।

## 5. Hosting requests (GitHub repo) deploy करना
1. यूज़र साइट के "Website Hosting" टैब में public GitHub URL भेजता है।
2. आप Firebase में `users/{uid}/hosting` देखकर repo चेक करें।
3. VPS पर deploy:
```bash
scp /home/claude/vps/deploy.sh root@VPS_IP:/root/
ssh root@VPS_IP "chmod +x /root/deploy.sh && /root/deploy.sh my-bot https://github.com/user/repo main 3000 'npm start'"
```
4. चलने की जाँच: `pm2 list` और `pm2 logs my-bot`।

**ज़रूरी चेतावनी:** deploy का मतलब है कि GitHub का कोड आपके VPS पर चलेगा। इसलिए सिर्फ़ वही repo deploy करें जिसे आपने खुद पढ़ा हो। कई यूज़र्स को एक ही VPS पर चलाना हो तो हर प्रोजेक्ट को Docker container में अलग रखें। Plain pm2 में एक प्रोजेक्ट दूसरे को प्रभावित कर सकता है।

## 6. Telegram बॉट और पेमेंट
- बॉट token और पेमेंट गेटवे की secret keys सिर्फ़ VPS पर `.env` फ़ाइल में रखें, साइट के HTML में नहीं।
- पेमेंट वेबहुक के लिए VPS पर एक छोटा Node सर्वर चाहिए। इसका सेटअप अगले स्टेप में होगा, गेटवे का नाम बताने के बाद।

## 7. रोज़ की कमांड (Termux से)
```bash
ssh root@VPS_IP "pm2 list"          # सब चल रहे प्रोजेक्ट
ssh root@VPS_IP "pm2 restart my-bot"
ssh root@VPS_IP "pm2 logs my-bot --lines 50"
```

## 8. अगर एरर आए
- `nginx -t` फेल हो: फ़ाइल में `;` या `}` की गलती देखें।
- Google login "unauthorized domain": Firebase में डोमेन जोड़ें।
- `pm2` नहीं मिला: `sudo npm install -g pm2` दोबारा चलाएँ।
- Port पहले से इस्तेमाल: `sudo lsof -i :3000` से देखें कौन चल रहा है।
