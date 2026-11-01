import { Module } from '@nestjs/common';
import { QrModule } from '../qr/qr.module.js';
import { StorageModule } from '../storage/storage.module.js';
import { VisitsController } from './visits.controller.js';
import { VisitsService } from './visits.service.js';

@Module({
  imports: [StorageModule, QrModule],
  controllers: [VisitsController],
  providers: [VisitsService],
})
export class VisitsModule {}