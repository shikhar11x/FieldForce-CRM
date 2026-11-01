import {
  Body,
  Controller,
  Get,
  HttpCode,
  Post,
  Query,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../auth/auth.types.js';
import { CurrentUser, Roles } from '../auth/decorators.js';
import { CheckDto, MonthQueryDto } from './attendance.dto.js';
import { AttendanceService } from './attendance.service.js';

@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendance: AttendanceService) {}

  @Roles('EMPLOYEE')
  @Get('today')
  today(@CurrentUser() actor: AuthUser) {
    return this.attendance.today(actor);
  }

  @Roles('EMPLOYEE')
  @Post('check-in')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  checkIn(@CurrentUser() actor: AuthUser, @Body() dto: CheckDto) {
    return this.attendance.checkIn(actor, dto);
  }

  @Roles('EMPLOYEE')
  @Post('check-out')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  checkOut(@CurrentUser() actor: AuthUser, @Body() dto: CheckDto) {
    return this.attendance.checkOut(actor, dto);
  }

  // Teeno roles ke liye. Kiska data dikhe, ye service tay karta hai.
  @Get('month')
  month(@CurrentUser() actor: AuthUser, @Query() query: MonthQueryDto) {
    return this.attendance.month(actor, query);
  }

  @Roles('ADMIN', 'MANAGER')
  @Get('team')
  team(@CurrentUser() actor: AuthUser) {
    return this.attendance.team(actor);
  }
}