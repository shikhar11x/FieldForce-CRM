import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../auth/auth.types.js';
import { CurrentUser } from '../auth/decorators.js';
import {
  CreateCustomerDto,
  CreateNoteDto,
  UpdateCustomerDto,
} from './customers.dto.js';
import { CustomersService } from './customers.service.js';

// Teeno roles ke liye khula hai. Kaun kya dekhe, ye service ka scope() tay karta hai.
@Controller('customers')
export class CustomersController {
  constructor(private readonly customers: CustomersService) {}

  @Get()
  findAll(@CurrentUser() actor: AuthUser) {
    return this.customers.findAll(actor);
  }

  @Get(':id')
  findOne(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.customers.findOne(actor, id);
  }

  @Post()
  create(@CurrentUser() actor: AuthUser, @Body() dto: CreateCustomerDto) {
    return this.customers.create(actor, dto);
  }

  @Patch(':id')
  update(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCustomerDto,
  ) {
    return this.customers.update(actor, id, dto);
  }

  @Post(':id/notes')
  addNote(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateNoteDto,
  ) {
    return this.customers.addNote(actor, id, dto.text);
  }
}