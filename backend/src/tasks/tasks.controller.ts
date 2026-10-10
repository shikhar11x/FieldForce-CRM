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
import { CreateTaskDto, UpdateTaskDto } from './tasks.dto.js';
import { TasksService } from './tasks.service.js';

// Teeno roles ke liye khula hai. Kaun kya dekhe, ye service ka scope() tay karta hai.
@Controller('tasks')
export class TasksController {
  constructor(private readonly tasks: TasksService) {}

  @Get()
  findAll(@CurrentUser() actor: AuthUser) {
    return this.tasks.findAll(actor);
  }

  // ':id' se pehle declare karna zaroori hai.
  @Get('options')
  options(@CurrentUser() actor: AuthUser) {
    return this.tasks.options(actor);
  }

  @Get(':id')
  findOne(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.tasks.findOne(actor, id);
  }

  @Post()
  create(@CurrentUser() actor: AuthUser, @Body() dto: CreateTaskDto) {
    return this.tasks.create(actor, dto);
  }

  @Patch(':id')
  update(
    @CurrentUser() actor: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTaskDto,
  ) {
    return this.tasks.update(actor, id, dto);
  }
}