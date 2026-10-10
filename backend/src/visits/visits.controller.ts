import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../auth/auth.types.js';
import { CurrentUser } from '../auth/decorators.js';
import { CreateVisitDto, VerifyQrDto, VisitNoteDto } from './visits.dto.js';
import { VisitsService } from './visits.service.js';

// Teeno roles ke liye khula hai. Kaun kya dekhe aur kare, ye service tay karta hai.
@Controller('visits')
export class VisitsController {
  constructor(private readonly visits: VisitsService) {}

  @Get()
  findAll(@CurrentUser() actor: AuthUser) {
    return this.visits.findAll(actor);
  }

  @Get(':id')
  findOne(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.visits.findOne(actor, id);
  }

  @Post()
  create(@CurrentUser() actor: AuthUser, @Body() dto: CreateVisitDto) {
    return this.visits.create(actor, dto);
  }

  @Post(':id/start')
  @HttpCode(200)
  start(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.visits.start(actor, id);
  }

  @Post(':id/complete')
  @HttpCode(200)
  complete(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.visits.complete(actor, id);
  }

  @Post(':id/cancel')
  @HttpCode(200)
  cancel(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.visits.cancel(actor, id);
  }

  @Post(':id/notes')
  @HttpCode(200)
  addNote(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: VisitNoteDto,
  ) {
    return this.visits.addNote(actor, id, dto.text);
  }

  @Post(':id/photos')
  @HttpCode(200)
  addPhoto(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.visits.addPhoto(actor, id);
  }

  @Post(':id/verify-qr')
  @HttpCode(200)
  verifyQr(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: VerifyQrDto,
  ) {
    return this.visits.verifyQr(actor, id, dto.distanceMeters);
  }
}