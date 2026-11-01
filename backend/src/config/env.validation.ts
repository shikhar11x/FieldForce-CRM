/** Required environment variables na hon to startup pe hi fail ho jaata hai. */
export function validateEnv(config: Record<string, unknown>) {
  const missing = [
    'DATABASE_URL',
    'JWT_ACCESS_SECRET',
    'QR_SIGNING_SECRET',
  ].filter((key) => !config[key]);
  if (missing.length > 0) {
    throw new Error(`Missing environment variables: ${missing.join(', ')}`);
  }

  for (const key of ['JWT_ACCESS_SECRET', 'QR_SIGNING_SECRET']) {
    const value = config[key];
    if (typeof value !== 'string' || value.length < 32) {
      throw new Error(`${key} must be at least 32 characters.`);
    }
  }
  return config;
}