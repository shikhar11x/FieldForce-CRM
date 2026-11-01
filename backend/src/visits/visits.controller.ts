import {
  Body,
  Controller,
  Get,
  Header,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  StreamableFile,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../auth/auth.types.js';
import { CurrentUser } from '../auth/decorators.js';
import { MAX_PHOTO_BYTES, type UploadedImage } from '../storage/image-type.js';
import { CreateVisitDto, ScanQrDto, VisitNoteDto } from './visits.dto.js';
import { VisitsService } from './visits.service.js';

// Teeno roles ke liye khula hai. Kaun kya dekhe aur kare, ye service tay karta hai.
@Controller('visits')
export class VisitsController {
  constructor(private readonly visits: VisitsService) {}

  @Get()
  findAll(@CurrentUser() actor: AuthUser) {
    return this.visits.findAll(actor);
  }

  @Post('scan-qr')
  @HttpCode(200)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  scanQr(@CurrentUser() actor: AuthUser, @Body() dto: ScanQrDto) {
    return this.visits.scanQr(actor, dto);
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

  // Multipart upload. Multer file memory me rakhta hai aur size limit khud lagata hai.
  @Post(':id/photos')
  @HttpCode(200)
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @UseInterceptors(
    FileInterceptor('file', { limits: { fileSize: MAX_PHOTO_BYTES, files: 1 } }),
  )
  addPhoto(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: UploadedImage | undefined,
  ) {
    return this.visits.addPhoto(actor, id, file);
  }

  @Get(':id/photos/:photoId')
  @Header('Cache-Control', 'private, max-age=3600')
  async photo(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('photoId', ParseUUIDPipe) photoId: string,
  ) {
    const file = await this.visits.getPhoto(actor, id, photoId);
    return new StreamableFile(file.stream, {
      type: file.mime,
      length: file.size,
    });
  }
}