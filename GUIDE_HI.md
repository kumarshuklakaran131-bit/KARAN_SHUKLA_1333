# Demon Modz Shop: Google लॉगिन फिक्स + अगला स्टेप गाइड

## 1. Google लॉगिन क्यों काम नहीं कर रहा था

वेबसाइट के JavaScript में यह लाइन थी:

```js
import { getAuth, GoogleAuthProvider, signInWithPopup } from ".../firebase-auth.js";
```

लेकिन `auth` नाम का वेरिएबल कभी बनाया ही नहीं गया। जब आप "LOG IN WITH GOOGLE" दबाते हैं, तो कोड `signInWithPopup(auth, ...)` चलाने की कोशिश करता है। `auth` मौजूद न होने से JavaScript एरर फेंकता है, और catch-block हर बार यही मैसेज दिखाता है: "Google login fail: Firebase Console me Google provider + domain authorize karo". यानी समस्या Firebase Console की कम, कोड की ज़्यादा थी।

**फिक्स (फ़ाइल में लागू किया गया):**

```js
const db = getDatabase(app);
const auth = getAuth(app); // FIX
```

## 2. Firebase Console में ये 2 सेटिंग्स ज़रूर करें

Firebase Console (project: `karan-panel`) खोलें:

1. **Authentication > Sign-in method** में जाएँ, **Google** को Enable करें, support email चुनें और Save करें।
2. **Authentication > Settings > Authorized domains** में वो डोमेन जोड़ें जहाँ साइट होस्ट होगी (जैसे `yourdomain.com`)। `localhost` पहले से होता है। Dramax/VPS वाला डोमेन यहाँ ज़रूर जोड़ें, वरना popup में "unauthorized domain" एरर आएगा।

## 3. इन खतरों को अभी ठीक करें (ज़रूरी)

- **Bot token सुरक्षित नहीं है।** आपने यह token चैट में भेजा है, इसलिए इसे अभी **BotFather** में जाकर `/revoke` करें और नया token लें। साथ ही, token को वेबसाइट के फ्रंटएंड या Firebase Database में न रखें। Telegram के काम (मैसेज भेजना, नोटिफिकेशन) सर्वर-साइड (VPS) से होने चाहिए।
- **पासवर्ड Database में plain text में है।** कोड में `password: crypto.randomUUID()` और लॉगिन पासवर्ड सीधे `users/` में लिखे जाते हैं। Firebase Realtime Database के rules ढीले हों तो कोई भी यूज़र्स और पासवर्ड पढ़ सकता है। Firebase Authentication और सख्त Database rules इस्तेमाल करें।
- **Admin ID सिर्फ़ सर्वर पर रहे।** Admin की पहचान Database के भरोसे पर नहीं, सर्वर पर होनी चाहिए।

## 4. होस्टिंग (Dramax / VPS) के बारे में

- यह साइट एक ही HTML फ़ाइल है जो Firebase से बात करती है। इसे किसी भी स्टेटिक होस्ट पर चलाया जा सकता है। पूरी तरह चलने के लिए VPS ज़रूरी नहीं है।
- VPS की ज़रूरत तब है जब आपको **पेमेंट वेबहुक**, **Telegram बॉट** या **यूज़र होस्टिंग (10 रुपये वाला बोर्ड)** चलाना हो।
- **"Dramax" क्या है, यह मुझे नहीं पता।** मोबाइल से VPS पर कनेक्ट करने वाला ऐप कौन सा है (जैसे Termux, JuiceSSH, Termius या Dramax खुद), यह बताएँ। उसी के हिसाब से स्टेप-बाय-स्टेप गाइड दूँगा। आपकी VPS की जानकारी (IP, OS, Nginx/Apache हो या नहीं) भी चाहिए। पासवर्ड चैट में न भेजें, SSH key का इस्तेमाल करें।

## 5. पेमेंट "ऑटो-ऐड" के बारे में

वीडियो में जो "Verified Merchant" पेज दिख रहा है, वह तभी सही है जब पेमेंट सच में वेरिफाई हो। Auto-add के लिए:

- एक असली पेमेंट गेटवे (Razorpay, Cashfree, Paytm, PhonePe PG आदि) का अकाउंट चाहिए।
- गेटवे का **webhook** आपके VPS/सर्वर पर आएगा, और तभी बैलेंस अपने-आप जुड़ेगा।
- सिर्फ़ यूज़र का "I have paid" बटन दबाना या स्क्रीनशॉट भरोसेमंद नहीं है। ऐसा सिस्टम झूठे पेमेंट से धोखा खा सकता है।

## 6. अभी क्या मिला और क्या बाकी है

**अभी हो गया:**
- Google लॉगिन का बग फिक्स।
- JavaScript की syntax जाँच पास।

**अभी बाकी (इनके लिए आपकी जानकारी चाहिए):**
- पूरा कलरफुल नियॉन रीडिज़ाइन (वीडियो जैसा)। यह बड़ा काम है, इसलिए इसे अलग पास में किया जाएगा।
- "Forgot password" और Google जैसा लॉगिन स्क्रीन।
- एडमिन पैनल: नाम और फोटो बदलना, यूज़र हिस्ट्री, बैलेंस ऐड करना, नोटिफिकेशन।
- Telegram नोटिफिकेशन (सर्वर से)।
- पेमेंट गेटवे का फुल सेटअप।
- VPS/Dramax का स्टेप-बाय-स्टेप अपलोड गाइड।

**मुझे ये जानकारी चाहिए:**
1. क्या आप पेमेंट गेटवे कौन सा रखेंगे (Razorpay/Cashfree/PhonePe PG आदि)?
2. "Dramax" ऐप का नाम और VPS का OS?
3. Firebase में यह प्रोजेक्ट आपका अपना है? Database rules कैसे हैं?
4. प्रोडक्ट्स (keys/mods) की लीगल स्थिति और बिक्री का पैमाना आप खुद सँभालेंगे, यह पुष्टि करें।

> नोट: बोट token को revoke करना न भूलें।
