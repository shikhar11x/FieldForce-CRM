import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { ROLES, type AppRole } from '../auth/auth.types.js';

const trim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const normalizeEmail = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toLowerCase() : value;

const PHONE = /^\+?[0-9\s-]{10,20}$/;
const PHONE_MESSAGE = 'phone must be a valid phone number';

export class CreateUserDto {
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @Transform(normalizeEmail)
  @IsEmail()
  @MaxLength(254)
  email: string;

  @Transform(trim)
  @Matches(PHONE, { message: PHONE_MESSAGE })
  phone: string;

  @IsIn(ROLES)
  role: AppRole;

  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  designation: string;

  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  department: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  team?: string;

  @IsOptional()
  @IsUUID()
  managerId?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateUserDto {
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @Transform(normalizeEmail)
  @IsEmail()
  @MaxLength(254)
  email?: string;

  @IsOptional()
  @Transform(trim)
  @Matches(PHONE, { message: PHONE_MESSAGE })
  phone?: string;

  @IsOptional()
  @IsIn(ROLES)
  role?: AppRole;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  designation?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  department?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  team?: string;

  @IsOptional()
  @IsUUID()
  managerId?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}