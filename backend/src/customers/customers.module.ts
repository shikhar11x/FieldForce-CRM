import { Module } from '@nestjs/common';
import { QrModule } from '../qr/qr.module.js';
import { CustomersController } from './customers.controller.js';
import { CustomersService } from './customers.service.js';

@Module({
  imports: [QrModule],
  controllers: [CustomersController],
  providers: [CustomersService],
})
export class CustomersModule {}