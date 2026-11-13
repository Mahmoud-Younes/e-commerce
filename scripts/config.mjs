/**
 * scripts/config.mjs — shared constants for the local ops scripts.
 *
 * Supabase hosts the product images (public bucket) because Firebase Storage
 * requires the Blaze plan. The publishable key is safe to expose in a client
 * context; writes to the bucket are gated by storage.objects SQL policies
 * (see scripts/README.md).
 */

export const SUPABASE_URL = 'https://qshiwfcssobenpjijjxo.supabase.co';

/** Publishable (anon) key — NOT the service_role secret. */
export const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_cdo7buZrUWExB_gqWmejCA_RnVyRc0Z';

/** Public storage bucket holding product images under `seed/<slug>.png`. */
export const SUPABASE_BUCKET = 'product-images';

/** Prefix for every seeded Firestore product doc id (`seed_<slug>`). */
export const SEED_ID_PREFIX = 'seed_';

/** Prefix for seeded image objects inside the bucket. */
export const SEED_IMAGE_PREFIX = 'seed/';
