/**
 * scripts/.demo-seed-emulator.mjs — LOCAL-ONLY demo seeder for the LOCAL
 * Firestore emulator (127.0.0.1:8080), not committed.
 *
 * Pairs with the DEMO_EMULATOR dart-define (lib/main.dart): the app talks to
 * the local emulator while auth stays on the real project — the known
 * accounts (admin@sahety.app, demo.shopper@shop.test) resolve by their real
 * uids, and every screen reads stable dummy data that NO other session can
 * touch. The emulator runs with open rules, so no auth header is needed.
 */
const BASE = 'http://127.0.0.1:8080/v1/projects/sahety-ba784/databases/(default)';

// Real prod-auth uids (accounts created via the public signup REST API).
const ADMIN_UID = 'wwcVnxJmRiasb2pvBU70w3F2Nj02';
const CUSTOMER_UID = '9mTk0p6H0RgDkL60KR9WYkbTxv12';

const get = (url) => fetch(url).then(r => r.json());
const post = (url, body) => fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).then(r => r.json());
const patchDoc = (url, body) => fetch(url, { method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).then(r => r.json());
const del = (url) => fetch(url, { method: 'DELETE' }).then(r => r.status);

const s = (v) => ({ stringValue: v });
const n = (v) => ({ doubleValue: v });
const i = (v) => ({ integerValue: String(v) });
const b = (v) => ({ booleanValue: v });
const ts = (ms) => ({ timestampValue: new Date(ms).toISOString() });
const arr = (values) => ({ arrayValue: { values } });
const map = (fields) => ({ mapValue: { fields } });

const PRODUCTS = [
  { slug: 'wireless-headphones', name: 'Wireless Headphones', nameAr: 'سماعات رأس لاسلكية', description: 'Over-ear Bluetooth headphones with noise cancellation and 30-hour battery life.', descriptionAr: 'سماعات بلوتوث فوق الأذن مع إلغاء الضوضاء وبطارية ٣٠ ساعة.', category: 'electronics', price: 2450, stock: 14 },
  { slug: 'smart-watch', name: 'Smart Watch', nameAr: 'ساعة ذكية', description: 'Fitness tracking, heart-rate monitor and notifications on your wrist.', descriptionAr: 'تتبع اللياقة وقياس النبض والإشعارات على معصمك.', category: 'electronics', price: 3200, stock: 9 },
  { slug: 'cotton-t-shirt', name: 'Cotton T-Shirt', nameAr: 'تيشيرت قطن', description: 'Soft 100% cotton tee, breathable and pre-shrunk.', descriptionAr: 'تيشيرت قطن ١٠٠٪ ناعم وجيد التهوية.', category: 'fashion', price: 320, stock: 40 },
  { slug: 'running-sneakers', name: 'Running Sneakers', nameAr: 'حذاء رياضي للجري', description: 'Lightweight running shoes with cushioned soles for daily training.', descriptionAr: 'حذاء جري خفيف بنعل ممتص للصدمات.', category: 'fashion', price: 1450, stock: 22 },
  { slug: 'led-desk-lamp', name: 'LED Desk Lamp', nameAr: 'مصباح مكتب LED', description: 'Dimmable LED desk lamp with USB charging port.', descriptionAr: 'مصباح مكتب LED قابل للتعتيم مع منفذ شحن USB.', category: 'home', price: 480, stock: 31 },
  { slug: 'air-fryer', name: 'Air Fryer', nameAr: 'قلاية هوائية', description: '5.5L air fryer with 8 presets and rapid-air technology.', descriptionAr: 'قلاية هوائية ٥٫٥ لتر بـ ٨ برامج وتقنية الهواء السريع.', category: 'home', price: 3900, stock: 7 },
  { slug: 'vitamin-c-serum', name: 'Vitamin C Face Serum', nameAr: 'سيروم فيتامين سي للوجه', description: 'Brightening vitamin C serum for a more even skin tone.', descriptionAr: 'سيروم فيتامين سي لتوحيد لون البشرة وإشراقتها.', category: 'beauty', price: 480, stock: 25 },
  { slug: 'yoga-mat', name: 'Yoga Mat', nameAr: 'سجادة يوغا', description: 'Non-slip 6mm yoga mat with carrying strap.', descriptionAr: 'سجادة يوغا غير قابلة للانزلاق بسماكة ٦ مم.', category: 'sports', price: 420, stock: 18 },
  { slug: 'arabic-coffee', name: 'Arabic Coffee 250g', nameAr: 'قهوة عربية ٢٥٠ جرام', description: 'Traditional Arabic coffee with cardamom, freshly roasted.', descriptionAr: 'قهوة عربية بالهيل محمصة طازجة.', category: 'groceries', price: 120, stock: 50 },
  { slug: 'green-tea', name: 'Green Tea 100 Bags', nameAr: 'شاي أخضر ١٠٠ كيس', description: 'Natural green tea, 100 individually wrapped bags.', descriptionAr: 'شاي أخضر طبيعي ١٠٠ كيس مغلف فردياً.', category: 'groceries', price: 85, stock: 60 },
];

const image = (slug) => `https://picsum.photos/seed/${slug}/600/600`;

(async () => {
  // 1) user documents with roles (auth accounts live in the real project)
  await patchDoc(`${BASE}/documents/users/${ADMIN_UID}`, {
    fields: { name: s('Store Admin'), email: s('admin@sahety.app'), phone: s(''), address: s(''), role: s('admin') },
  });
  await patchDoc(`${BASE}/documents/users/${CUSTOMER_UID}`, {
    fields: { name: s('Demo Shopper'), email: s('demo.shopper@shop.test'), phone: s('+201000000000'), address: s('12 Tahrir Square, Cairo'), role: s('customer') },
  });
  console.log('user docs seeded');

  // 2) wipe + create products
  const list = await get(`${BASE}/documents/products`);
  for (const d of list.documents || []) await del(`${BASE}/${d.name}`);
  for (const p of PRODUCTS) {
    const r = await patchDoc(`${BASE}/documents/products/seed_${p.slug}`, {
      fields: {
        name: s(p.name), nameAr: s(p.nameAr),
        description: s(p.description), descriptionAr: s(p.descriptionAr),
        category: s(p.category), price: n(p.price), imageUrl: s(image(p.slug)),
        stock: i(p.stock), isAvailable: b(true),
      },
    });
    if (r.error) throw new Error(`create ${p.slug}: ${JSON.stringify(r.error)}`);
  }
  console.log('products seeded:', PRODUCTS.length);

  // 3) three orders with varied statuses (status seeded AT CREATION — a
  // REST PATCH here would REPLACE the whole document, dropping fields)
  const now = Date.now();
  const order = (lines, daysAgo, status) => ({
    fields: {
      userId: s(CUSTOMER_UID),
      items: arr(lines.map(l => map({
        productId: s(`seed_${l.slug}`), name: s(PRODUCTS.find(p => p.slug === l.slug).name),
        price: n(PRODUCTS.find(p => p.slug === l.slug).price), quantity: i(l.qty),
      }))),
      totalPrice: n(lines.reduce((t, l) => {
        const p = PRODUCTS.find(p => p.slug === l.slug);
        return t + p.price * l.qty;
      }, 0)),
      shippingAddress: s('12 Tahrir Square, Cairo'), phone: s('+201000000000'),
      status: s(status), createdAt: ts(now - daysAgo * 86400000),
    },
  });
  // wipe previous orders/notifications (the local emulator keeps them between runs)
  const oldOrders = await get(`${BASE}/documents/orders`);
  for (const d of oldOrders.documents || []) await del(`${BASE}/${d.name}`);
  const oldNotes = await get(`${BASE}/documents/notifications`);
  for (const d of oldNotes.documents || []) await del(`${BASE}/${d.name}`);
  const specs = [
    { key: 'groceries', doc: order([{ slug: 'green-tea', qty: 2 }, { slug: 'arabic-coffee', qty: 1 }], 6, 'delivered') },
    { key: 'headphones', doc: order([{ slug: 'wireless-headphones', qty: 1 }], 3, 'confirmed') },
    { key: 'home', doc: order([{ slug: 'yoga-mat', qty: 1 }, { slug: 'led-desk-lamp', qty: 1 }], 0, 'pending') },
  ];
  const orderIds = {};
  for (const sp of specs) {
    const r = await post(`${BASE}/documents/orders`, sp.doc);
    if (r.error) throw new Error(`create order: ${JSON.stringify(r.error)}`);
    orderIds[sp.key] = r.name.split('/').pop();
  }
  console.log('orders seeded:', JSON.stringify(orderIds));

  // 4) notifications for the in-app center (PRD §6)
  const notes = [
    { title: 'Order Update · تحديث الطلب', body: 'Your order was confirmed and is being prepared. · تم تأكيد طلبك وجارٍ تجهيزه.', orderId: orderIds['headphones'], daysAgo: 3 },
    { title: 'Order Update · تحديث الطلب', body: 'Your order was delivered. Thank you for shopping! · تم توصيل طلبك، شكراً لتسوقك!', orderId: orderIds['groceries'], daysAgo: 5 },
    { title: 'Welcome · أهلاً بك', body: 'Welcome to the store — enjoy 10% off your next order. · أهلاً بك في المتجر، استمتع بخصم ١٠٪ على طلبك القادم.', orderId: '', daysAgo: 7 },
  ];
  for (const note of notes) {
    const r = await post(`${BASE}/documents/notifications`, {
      fields: {
        userId: s(CUSTOMER_UID), title: s(note.title), body: s(note.body),
        orderId: s(note.orderId), isRead: b(false), createdAt: ts(now - note.daysAgo * 86400000),
      },
    });
    if (r.error) throw new Error(`create notification: ${JSON.stringify(r.error)}`);
  }
  console.log('notifications seeded:', notes.length);

  const check = await get(`${BASE}/documents/products`);
  console.log('read-back products:', (check.documents || []).length);
  console.log('EMULATOR SEED OK');
})().catch(e => { console.log('SEED FAILED:', e.message); process.exit(1); });

