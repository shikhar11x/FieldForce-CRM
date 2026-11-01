import { randomUUID } from 'node:crypto';
import { createReadStream } from 'node:fs';
import { mkdir, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Local disk storage. Production me isi class ka S3 version aayega, baaki
 * code (keys, save, open, remove) wahi rahega.
 */
@Injectable()
export class StorageService {
  private readonly root: string;

  constructor(config: ConfigService) {
    this.root = path.resolve(
      process.cwd(),
      config.get<string>('UPLOAD_DIR') ?? 'uploads',
    );
  }

  /** Key hamesha server banata hai, user ka koi input isme nahi jaata. */
  newKey(folder: string, ext: string): string {
    return `${folder}/${randomUUID()}.${ext}`;
  }

  private resolve(key: string): string {
    const full = path.resolve(this.root, key);
    if (!full.startsWith(this.root + path.sep)) {
      throw new Error('Invalid storage key.');
    }
    return full;
  }

  async save(key: string, data: Buffer): Promise<void> {
    const full = this.resolve(key);
    await mkdir(path.dirname(full), { recursive: true });
    // 'wx': kisi maujooda file ko kabhi overwrite nahi karta.
    await writeFile(full, data, { flag: 'wx' });
  }

  async open(key: string) {
    const full = this.resolve(key);
    try {
      const info = await stat(full);
      return { stream: createReadStream(full), size: info.size };
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
        throw new NotFoundException('Photo not found.');
      }
      throw error;
    }
  }

  async remove(key: string): Promise<void> {
    await rm(this.resolve(key), { force: true });
  }
}