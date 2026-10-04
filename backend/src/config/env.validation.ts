/** Required environment variables na hon to startup pe hi fail ho jaata hai. */
export function validateEnv(config: Record<string, unknown>) {
  const missing = ['DATABASE_URL', 'JWT_ACCESS_SECRET'].filter(
    (key) => !config[key],
  );
  if (missing.length > 0) {
    throw new Error(`Missing environment variables: ${missing.join(', ')}`);
  }

  const secret = config['JWT_ACCESS_SECRET'];
  if (typeof secret !== 'string' || secret.length < 32) {
    throw new Error('JWT_ACCESS_SECRET must be at least 32 characters.');
  }
  return config;
}