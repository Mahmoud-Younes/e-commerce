#!/usr/bin/env node
/**
 * scripts/seed.mjs — `npm run seed`
 *
 * Seeds a bilingual demo catalog into Firestore and Supabase Storage:
 *   1. Generates 30 placeholder product images (6 categories x 5) as valid
 *      PNGs in pure JS (no ffmpeg/ImageMagick needed) — 512x512 two-tone
 *      vertical gradients, one color pair per category.
 *   2. Uploads them to the Supabase public bucket `product-images` as
 *      `seed/<slug>.png` and keeps the public URLs.
 *   3. Upserts 30 products into Firestore `products` with deterministic doc
 *      ids `seed_<slug>` (set + merge, so re-running is idempotent).
 *
 * Firebase project is derived from the service account JSON's `project_id`
 * (never hardcoded) — see scripts/service-account.mjs.
 *
 * Frozen document contract (the Flutter app is built against it):
 *   name, nameAr, description, descriptionAr, category, categoryAr,
 *   price (number, EGP), imageUrl, stock (int), isAvailable (true)
 */

import zlib from 'node:zlib';
import { pathToFileURL } from 'node:url';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { createClient } from '@supabase/supabase-js';
import { loadServiceAccount, log } from './service-account.mjs';
import {
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY,
  SUPABASE_BUCKET,
  SEED_ID_PREFIX,
  SEED_IMAGE_PREFIX,
} from './config.mjs';

const TAG = 'seed';

// ============================== PNG ENCODER ================================
// Minimal PNG writer: 8-bit truecolor (color type 2), one filter-0 byte per
// scanline, IDAT compressed with zlib. Enough for placeholder images and
// needs no native tools.

const CRC_TABLE = (() => {
  const table = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c;
  }
  return table;
})();

function crc32(buf) {
  let crc = -1;
  for (let i = 0; i < buf.length; i++) crc = CRC_TABLE[(crc ^ buf[i]) & 0xff] ^ (crc >>> 8);
  return (crc ^ -1) >>> 0;
}

function pngChunk(type, data) {
  const out = Buffer.alloc(data.length + 12);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, 'ascii');
  data.copy(out, 8);
  out.writeUInt32BE(crc32(out.subarray(4, 8 + data.length)), 8 + data.length);
  return out;
}

/**
 * Encodes a PNG from a per-pixel callback.
 * @param {number} width
 * @param {number} height
 * @param {(x: number, y: number) => [number, number, number]} colorAt
 * @returns {Buffer} complete PNG file bytes
 */
export function encodePng(width, height, colorAt) {
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 2; // color type: truecolor RGB
  ihdr[10] = 0; // compression: deflate
  ihdr[11] = 0; // filter: adaptive (per-scanline bytes below)
  ihdr[12] = 0; // interlace: none

  const raw = Buffer.alloc(height * (1 + width * 3));
  let offset = 0;
  for (let y = 0; y < height; y++) {
    raw[offset++] = 0; // filter type 0 (None) for this scanline
    for (let x = 0; x < width; x++) {
      const [r, g, b] = colorAt(x, y);
      raw[offset++] = r;
      raw[offset++] = g;
      raw[offset++] = b;
    }
  }

  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    signature,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', idat),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

// ============================== CATALOG DATA ===============================

/** One color pair (RGB) per category so seeded images are visually grouped. */
const CATEGORY_COLORS = {
  electronics: [[30, 58, 138], [96, 165, 250]], // deep blue -> sky blue
  fashion: [[124, 58, 237], [240, 171, 252]], // purple -> pink
  home: [[234, 88, 12], [252, 211, 77]], // orange -> warm sand
  beauty: [[190, 24, 93], [253, 164, 175]], // rose -> blush
  sports: [[22, 101, 52], [134, 239, 172]], // forest -> lime
  groceries: [[180, 83, 9], [253, 224, 71]], // brown -> amber
};

/** Canonical category key -> Arabic label (frozen contract). */
const CATEGORY_AR = {
  electronics: 'إلكترونيات',
  fashion: 'أزياء',
  home: 'منزل ومطبخ',
  beauty: 'جمال وعناية',
  sports: 'رياضة',
  groceries: 'بقالة',
};

const PRODUCTS = [
  // ---------------- electronics (5) ----------------
  {
    category: 'electronics', name: 'Wireless Headphones', nameAr: 'سماعات رأس لاسلكية', price: 2450,
    description: 'Over-ear wireless headphones with active noise cancellation, deep bass and up to 30 hours of battery life.',
    descriptionAr: 'سماعات رأس لاسلكية تغطي الأذن بالكامل مع تقنية إلغاء الضوضاء النشط وصوت جهير عميق وبطارية تدوم حتى ٣٠ ساعة.',
  },
  {
    category: 'electronics', name: 'Smart Watch', nameAr: 'ساعة ذكية', price: 3200,
    description: 'Fitness smart watch with heart-rate monitor, sleep tracking and a bright AMOLED display, water resistant to 5 ATM.',
    descriptionAr: 'ساعة ذكية للياقة مع قياس معدل نبضات القلب وتتبع النوم وشاشة AMOLED ساطعة، ومقاومة للماء حتى ٥ جو.',
  },
  {
    category: 'electronics', name: 'Bluetooth Speaker', nameAr: 'مكبر صوت بلوتوث', price: 890,
    description: 'Portable Bluetooth speaker with 360-degree sound, 12-hour playtime and a built-in microphone for calls.',
    descriptionAr: 'مكبر صوت بلوتوث محمول بصوت محيطي ٣٦٠ درجة ومدة تشغيل تصل إلى ١٢ ساعة وميكروفون مدمج للمكالمات.',
  },
  {
    category: 'electronics', name: '65W Fast Charger', nameAr: 'شاحن سريع ٦٥ واط', price: 450,
    description: 'GaN fast charger with three USB-C/USB-A ports that can power a laptop and two phones at the same time.',
    descriptionAr: 'شاحن سريع بتقنية GaN بثلاثة مخارج USB-C و USB-A يشحن حاسوبًا محمولًا وهاتفين في الوقت نفسه.',
  },
  {
    category: 'electronics', name: '4K Action Camera', nameAr: 'كاميرا أكشن بدقة 4K', price: 5400,
    description: 'Rugged 4K action camera with image stabilization, waterproof case and a wide-angle lens for sports and travel.',
    descriptionAr: 'كاميرا أكشن متينة بدقة 4K مع مثبّت صور وعلبة مقاومة للماء وعدسة واسعة الزاوية مثالية للرياضة والسفر.',
  },

  // ---------------- fashion (5) ----------------
  {
    category: 'fashion', name: 'Cotton T-Shirt', nameAr: 'تيشيرت قطن', price: 320,
    description: 'Soft 100% Egyptian cotton T-shirt with a classic cut that keeps its shape after every wash.',
    descriptionAr: 'تيشيرت من القطن المصري الخالص بقصة كلاسيكية مريحة يحتفظ بشكله بعد كل غسلة.',
  },
  {
    category: 'fashion', name: 'Denim Jacket', nameAr: 'جاكيت جينز', price: 1250,
    description: 'Timeless mid-wash denim jacket with brass buttons and two chest pockets — goes with everything.',
    descriptionAr: 'جاكيت جينز كلاسيكي بلون غسلة متوسطة وأزرار نحاسية وجيبين أماميين يناسب كل الإطلالات.',
  },
  {
    category: 'fashion', name: 'Leather Handbag', nameAr: 'حقيبة يد جلدية', price: 1850,
    description: 'Genuine leather handbag with an adjustable strap, lined interior and a zip pocket for essentials.',
    descriptionAr: 'حقيبة يد من الجلد الطبيعي بحزام قابل للتعديل وبطانة داخلية وجيب بسحاب للأغراض الأساسية.',
  },
  {
    category: 'fashion', name: 'Running Sneakers', nameAr: 'حذاء رياضي للجري', price: 1450,
    description: 'Lightweight running sneakers with a breathable mesh upper and cushioned sole for daily training.',
    descriptionAr: 'حذاء جري خفيف الوزن بشبكة تهوية علوية ونعل ممتص للصدمات مناسب للتمارين اليومية.',
  },
  {
    category: 'fashion', name: 'Wool Scarf', nameAr: 'وش صوفي', price: 280,
    description: 'Warm woven wool scarf in a unisex design — soft on the skin and perfect for cool evenings.',
    descriptionAr: 'وش صوفي منسوج دافئ بتصميم يناسب الجميع، ناعم على البشرة ومثالي للأمسيات الباردة.',
  },

  // ---------------- home (5) ----------------
  {
    category: 'home', name: 'Non-Stick Cookware Set', nameAr: 'طقم أواني طهي غير لاصق', price: 2400,
    description: 'Five-piece granite non-stick cookware set that works on gas and electric stoves and cleans in seconds.',
    descriptionAr: 'طقم أواني طهي جرانيت غير لاصق من خمس قطع يعمل على البوتاجاس الغاز والكهرباء وينظف في ثوانٍ.',
  },
  {
    category: 'home', name: 'LED Desk Lamp', nameAr: 'مصباح مكتب LED', price: 480,
    description: 'Rechargeable LED desk lamp with three brightness levels and a foldable arm for study and work.',
    descriptionAr: 'مصباح مكتب LED قابل للشحن بثلاث درجات إضاءة وذراع قابل للطي مثالي للمذاكرة والعمل.',
  },
  {
    category: 'home', name: 'Stainless Steel Thermos', nameAr: 'ترمس ستانلس ستيل', price: 350,
    description: '1-liter stainless steel vacuum flask that keeps drinks hot for 12 hours and cold for 24.',
    descriptionAr: 'ترمس ستانلس ستيل بسعة لتر واحد يحفظ المشروبات ساخنة ١٢ ساعة وباردة ٢٤ ساعة.',
  },
  {
    category: 'home', name: 'Memory Foam Pillow', nameAr: 'وسادة ميموري فوم', price: 620,
    description: 'Ergonomic memory foam pillow that supports the neck and comes with a washable breathable cover.',
    descriptionAr: 'وسادة طبية من ميموري فوم ترتاح الرقبة مع غطاء قطني قابل للغسل ومسامات تسمح بمرور الهواء.',
  },
  {
    category: 'home', name: 'Air Fryer', nameAr: 'قلاية هوائية', price: 3900,
    description: '5.5-liter digital air fryer with 8 preset programs — crispy food with up to 85% less oil.',
    descriptionAr: 'قلاية هوائية رقمية بسعة ٥٫٥ لتر مع ٨ برامج جاهزة تحضّر أطعمة مقرمشة بزيت أقل بنسبة ٨٥٪.',
  },

  // ---------------- beauty (5) ----------------
  {
    category: 'beauty', name: 'Vitamin C Face Serum', nameAr: 'سيروم فيتامين سي للوجه', price: 480,
    description: 'Concentrated vitamin C serum that brightens the skin and fades dark spots with daily use.',
    descriptionAr: 'سيروم مركّز بفيتامين سي يوحّد لون البشرة ويخفف البقع الداكنة مع الاستخدام اليومي.',
  },
  {
    category: 'beauty', name: 'Argan Oil Shampoo', nameAr: 'شامبو زيت الأرغان', price: 260,
    description: 'Sulfate-free shampoo enriched with argan oil that repairs dry hair and adds natural shine.',
    descriptionAr: 'شامبو خالٍ من السلفات مدعّم بزيت الأرغان يعالج الشعر الجاف ويمنحه لمعانًا طبيعيًا.',
  },
  {
    category: 'beauty', name: 'Electric Toothbrush', nameAr: 'فرشاة أسنان كهربائية', price: 950,
    description: 'Sonic electric toothbrush with 5 cleaning modes, a 2-minute timer and a 30-day battery.',
    descriptionAr: 'فرشاة أسنان كهربائية صوتية بخمسة أوضاع تنظيف ومؤقت لمدة دقيقتين وبطارية تدوم ٣٠ يومًا.',
  },
  {
    category: 'beauty', name: 'Sunscreen SPF 50', nameAr: 'واقي شمس بعامل حماية ٥٠', price: 310,
    description: 'Lightweight SPF 50 sunscreen that absorbs quickly and leaves no white cast — for all skin types.',
    descriptionAr: 'واقي شمس خفيف بعامل حماية ٥٠ يمتص سريعًا ولا يترك أثرًا أبيض، مناسب لجميع أنواع البشرة.',
  },
  {
    category: 'beauty', name: 'Eau de Parfum', nameAr: 'عطر شرقي فاخر', price: 2200,
    description: 'Long-lasting eau de parfum with woody oriental notes — a signature scent for day and night.',
    descriptionAr: 'عطر يدوم طويلاً بنفحات خشبية شرقية، رائحة مميزة تناسب النهار والسهرة.',
  },

  // ---------------- sports (5) ----------------
  {
    category: 'sports', name: 'Yoga Mat', nameAr: 'سجادة يوغا', price: 420,
    description: '6 mm anti-slip yoga mat with alignment lines and a carry strap for home and studio workouts.',
    descriptionAr: 'سجادة يوغا مضادة للانزلاق بسماكة ٦ مم مع خطوط إرشادية وحزام حمل للتمارين المنزلية والنوادي.',
  },
  {
    category: 'sports', name: 'Adjustable Dumbbell Set', nameAr: 'طقم دمبل قابل للتعديل', price: 2800,
    description: 'Adjustable dumbbell set from 5 to 25 kg with quick-lock plates for a full home gym.',
    descriptionAr: 'طقم دمبل قابل للتعديل من ٥ إلى ٢٥ كجم مع أطباق تُثبَّت بسرعة لصالة رياضية منزلية كاملة.',
  },
  {
    category: 'sports', name: 'Football', nameAr: 'كرة قدم', price: 550,
    description: 'Machine-stitched size-5 football with a butyl bladder that keeps its pressure match after match.',
    descriptionAr: 'كرة قدم مقاس ٥ مخيطة آليًا بمثانة بوتيل تحافظ على ضغطها مباراة بعد مباراة.',
  },
  {
    category: 'sports', name: 'Resistance Bands Set', nameAr: 'طقم أحزمة المقاومة', price: 290,
    description: 'Set of five latex resistance bands with handles and door anchor for strength training anywhere.',
    descriptionAr: 'طقم من خمسة أحزمة مقاومة مطاطية بمقابض ومرساة باب لتدريب القوة في أي مكان.',
  },
  {
    category: 'sports', name: 'Bicycle Helmet', nameAr: 'خوذة دراجة', price: 890,
    description: 'Lightweight bicycle helmet with 18 air vents and an adjustable dial fit for adults.',
    descriptionAr: 'خوذة دراجة خفيفة الوزن بـ١٨ فتحة تهوية وحزام خلفي قابل للضبط ليناسب البالغين.',
  },

  // ---------------- groceries (5) ----------------
  {
    category: 'groceries', name: 'Extra Virgin Olive Oil 1L', nameAr: 'زيت زيتون بكر ممتاز ١ لتر', price: 380,
    description: 'Cold-pressed extra virgin olive oil from Egyptian groves — fruity aroma, ideal for salads and dipping.',
    descriptionAr: 'زيت زيتون بكر ممتاز معصور على البارد من مزارع مصرية برائحة فاكهية مثالي للسلطات والأكل بالتغميس.',
  },
  {
    category: 'groceries', name: 'Natural Bee Honey 500g', nameAr: 'عسل نحل طبيعي ٥٠٠ جرام', price: 240,
    description: 'Pure raw bee honey harvested from Upper Egypt, unheated and without any additives.',
    descriptionAr: 'عسل نحل خالص غير مسخّن ودون أي إضافات، يُجمع من مناحل صعيد مصر.',
  },
  {
    category: 'groceries', name: 'Arabic Coffee 250g', nameAr: 'قهوة عربية ٢٥٠ جرام', price: 120,
    description: 'Freshly roasted and ground Arabic coffee with cardamom — the taste of every Egyptian gathering.',
    descriptionAr: 'قهوة عربية محمصة ومطحونة طازجة بالهيل بطعم يجمع العائلة على كل موعد.',
  },
  {
    category: 'groceries', name: 'Mixed Nuts 400g', nameAr: 'مكسرات مشكلة ٤٠٠ جرام', price: 320,
    description: 'Roasted mix of almonds, cashews and pistachios, lightly salted — the perfect guest bowl.',
    descriptionAr: 'خليط محمص من اللوز والكاجو والفستق بتملح خفيف، الطبق الأجمل لاستقبال الضيوف.',
  },
  {
    category: 'groceries', name: 'Green Tea 100 Bags', nameAr: 'شاي أخضر ١٠٠ كيس', price: 85,
    description: 'Natural green tea in 100 sealed bags — a light daily detox with lemon or mint.',
    descriptionAr: 'شاي أخضر طبيعي في ١٠٠ كيس محكم الإغلاق، مشروب خفيف للتنقية اليومية بالليمون أو النعناع.',
  },
];

// =============================== HELPERS ===================================

const slugify = (name) =>
  name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

const IMAGE_SIZE = 512;

/** Deterministic stock in [10, 50] from the product's position in the list. */
const stockFor = (index) => 10 + ((index * 7) % 41);

/**
 * Builds a 512x512 two-tone vertical gradient PNG for a product.
 * The same category color pair is reused; the gradient curve (gamma-ish
 * exponent) shifts per product index so the 5 images in a category are
 * visibly different but deterministic.
 */
function generateProductImage(product, indexInCategory) {
  const [from, to] = CATEGORY_COLORS[product.category];
  const curve = 1 + indexInCategory * 0.35;
  return encodePng(IMAGE_SIZE, IMAGE_SIZE, (_x, y) => {
    const t = Math.pow(y / (IMAGE_SIZE - 1), curve);
    return [
      Math.round(from[0] + (to[0] - from[0]) * t),
      Math.round(from[1] + (to[1] - from[1]) * t),
      Math.round(from[2] + (to[2] - from[2]) * t),
    ];
  });
}

const BUCKET_SETUP_INSTRUCTIONS = `
============================================================
 Supabase bucket "${SUPABASE_BUCKET}" is missing or not writable.
============================================================

1. Supabase Dashboard -> Storage -> "New bucket"
     Name:          ${SUPABASE_BUCKET}
     Public bucket: ON  (public read access)

2. Supabase Dashboard -> SQL Editor -> run:

   create policy "public upload to product-images"
   on storage.objects for insert to anon, authenticated
   with check (bucket_id = '${SUPABASE_BUCKET}');

3. Re-run: npm run seed

Notes:
  - A public bucket serves reads via /object/public/ with no extra policy.
  - Re-running the seed over existing objects (upsert) or "npm run reset --images"
    additionally needs update/delete policies, e.g.:

   create policy "public update to product-images"
   on storage.objects for update to anon, authenticated
   with check (bucket_id = '${SUPABASE_BUCKET}');

   create policy "public delete from product-images"
   on storage.objects for delete to anon, authenticated
   using (bucket_id = '${SUPABASE_BUCKET}');
============================================================
`;

function classifyStorageError(error) {
  const message = String(error?.message ?? error ?? '');
  if (/not found|does not exist/i.test(message)) return 'bucket-missing';
  if (/duplicate|already exists/i.test(message)) return 'already-exists';
  if (/row-level security|rls|unauthorized|forbidden|403|permission/i.test(message)) return 'permission';
  return 'other';
}

// ================================ MAIN =====================================

async function main() {
  console.log(`\n=== e-commerce demo seed ===\n`);

  // ---- 1. Firebase (project comes from the service account file) ----
  const account = loadServiceAccount();
  log(TAG, `Using service account: ${account.path}`);
  log(TAG, `Firebase project (from project_id): ${account.projectId}`);
  initializeApp({ credential: cert(account.credentials) });
  const db = getFirestore();

  // ---- 2. Supabase client + bucket health check ----
  const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    auth: { persistSession: false },
  });
  log(TAG, `Supabase: ${SUPABASE_URL} (bucket: ${SUPABASE_BUCKET})`);

  const { error: bucketError } = await supabase.storage.getBucket(SUPABASE_BUCKET);
  if (bucketError) {
    const kind = classifyStorageError(bucketError);
    if (kind === 'bucket-missing') {
      console.error(BUCKET_SETUP_INSTRUCTIONS);
      process.exit(1);
    }
    // The publishable key may be blocked from bucket *management* endpoints
    // even when the bucket exists — warn and let the upload attempt decide.
    log(TAG, `WARNING: could not verify bucket (getBucket: ${bucketError.message}). Trying uploads anyway...`);
  } else {
    log(TAG, `Bucket "${SUPABASE_BUCKET}" found.`);
  }

  // ---- 3. Generate + upload images, collect public URLs ----
  const failedImages = [];
  const publicUrls = new Map(); // slug -> url

  const perCategoryIndex = new Map();
  for (let i = 0; i < PRODUCTS.length; i++) {
    const product = PRODUCTS[i];
    const slug = slugify(product.name);
    const idx = perCategoryIndex.get(product.category) ?? 0;
    perCategoryIndex.set(product.category, idx + 1);
    const objectPath = `${SEED_IMAGE_PREFIX}${slug}.png`;

    process.stdout.write(`[${i + 1}/${PRODUCTS.length}] ${objectPath} ... `);

    let pngBuffer;
    try {
      pngBuffer = generateProductImage(product, idx);
    } catch (err) {
      process.stdout.write(`GENERATE FAILED (${err.message})\n`);
      failedImages.push({ objectPath, error: err.message });
      continue;
    }

    const { error: uploadError } = await supabase.storage
      .from(SUPABASE_BUCKET)
      .upload(objectPath, pngBuffer, { contentType: 'image/png', upsert: true });

    if (uploadError) {
      const kind = classifyStorageError(uploadError);
      if (kind === 'already-exists') {
        process.stdout.write(`kept existing object\n`);
      } else if (kind === 'bucket-missing') {
        process.stdout.write(`BUCKET MISSING\n`);
        console.error(BUCKET_SETUP_INSTRUCTIONS);
        process.exit(1);
      } else if (kind === 'permission') {
        process.stdout.write(`PERMISSION DENIED\n`);
        console.error(BUCKET_SETUP_INSTRUCTIONS);
        process.exit(1);
      } else {
        process.stdout.write(`UPLOAD FAILED (${uploadError.message})\n`);
        failedImages.push({ objectPath, error: uploadError.message });
        continue;
      }
    } else {
      process.stdout.write(`uploaded (${(pngBuffer.length / 1024).toFixed(1)} KB)\n`);
    }

    const { data } = supabase.storage.from(SUPABASE_BUCKET).getPublicUrl(objectPath);
    publicUrls.set(slug, data?.publicUrl ?? '');
    if (!publicUrls.get(slug)) {
      failedImages.push({ objectPath, error: 'could not resolve public URL' });
    }
  }

  // ---- 4. Upsert Firestore products (deterministic ids, merge = idempotent) ----
  const failedDocs = [];
  let written = 0;

  for (let i = 0; i < PRODUCTS.length; i++) {
    const product = PRODUCTS[i];
    const slug = slugify(product.name);
    const docId = `${SEED_ID_PREFIX}${slug}`;
    const imageUrl = publicUrls.get(slug);

    if (!imageUrl) {
      // Do not write a product with a broken image link.
      log(TAG, `SKIP ${docId}: no uploaded image URL (upload failed earlier)`);
      continue;
    }

    try {
      await db.collection('products').doc(docId).set(
        {
          name: product.name,
          nameAr: product.nameAr,
          description: product.description,
          descriptionAr: product.descriptionAr,
          category: product.category,
          categoryAr: CATEGORY_AR[product.category],
          price: product.price,
          imageUrl,
          stock: stockFor(i),
          isAvailable: true,
        },
        { merge: true },
      );
      written++;
      log(TAG, `wrote products/${docId} (${product.category} · EGP ${product.price})`);
    } catch (err) {
      log(TAG, `FAILED products/${docId}: ${err.message}`);
      failedDocs.push({ docId, error: err.message });
    }
  }

  // ---- 5. Summary ----
  console.log(`\n=== seed summary ===`);
  console.log(`products written : ${written}/${PRODUCTS.length}`);
  console.log(`images uploaded  : ${publicUrls.size}/${PRODUCTS.length}`);
  if (failedImages.length) {
    console.log(`image failures   : ${failedImages.length}`);
    for (const f of failedImages) console.log(`  - ${f.objectPath}: ${f.error}`);
  }
  if (failedDocs.length) {
    console.log(`doc failures     : ${failedDocs.length}`);
    for (const f of failedDocs) console.log(`  - ${f.docId}: ${f.error}`);
  }

  if (failedImages.length || failedDocs.length || written !== PRODUCTS.length) {
    console.error(`\nseed finished WITH FAILURES (exit 1)\n`);
    process.exit(1);
  }
  console.log(`\nseed complete: 30 products across 6 categories ready.\n`);
}

// Only run when executed directly (`node seed.mjs` / `npm run seed`), so the
// PNG encoder can be unit-sanity-tested via `node -e "import('./seed.mjs')..."`.
const isDirectRun =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isDirectRun) {
  main().catch((err) => {
    console.error(`[${TAG}] fatal: ${err?.stack ?? err}`);
    process.exit(1);
  });
}
