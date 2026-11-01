import { createHmac, timingSafeEqual } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

const PREFIX = 'fieldforce://customer/';
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Customer QR codes: `<prefix><customerId>.<HMAC signature>`. */
@Injectable()
export class QrService {
  private readonly secret: string;

  constructor(config: ConfigService) {
    this.secret = config.getOrThrow<string>('QR_SIGNING_SECRET');
  }

  private sign(customerId: string): string {
    return createHmac('sha256', this.secret)
      .update(`customer:${customerId}`)
      .digest('base64url');
  }

  payloadFor(customerId: string): string {
    return `${PREFIX}${customerId}.${this.sign(customerId)}`;
  }

  /** Valid code ho to customer id, warna null. */
  parse(payload: string): string | null {
    if (!payload.startsWith(PREFIX)) return null;

    const parts = payload.slice(PREFIX.length).split('.');
    if (parts.length !== 2) return null;
    const [customerId, signature] = parts;
    if (!UUID.test(customerId)) return null;

    const expected = Buffer.from(this.sign(customerId));
    const given = Buffer.from(signature);
    if (expected.length !== given.length) return null;
    return timingSafeEqual(expected, given) ? customerId : null;
  }
}