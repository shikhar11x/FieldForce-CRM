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

export const CUSTOMER_STATUSES = ['ACTIVE', 'INACTIVE', 'NEW'] as const;

const trim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const normalizeEmail = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toLowerCase() : value;

const PHONE = /^\+?[0-9\s-]{10,20}$/;
const PHONE_MESSAGE = 'phone must be a valid phone number';

export class CreateCustomerDto {
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  company: string;

  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  contactName: string;

  @Transform(trim)
  @Matches(PHONE, { message: PHONE_MESSAGE })
  phone: string;

  @Transform(normalizeEmail)
  @IsEmail()
  @MaxLength(254)
  email: string;

  @Transform(trim)
  @IsString()
  @MinLength(5)
  @MaxLength(250)
  address: string;

  @IsOptional()
  @IsIn(CUSTOMER_STATUSES)
  status?: (typeof CUSTOMER_STATUSES)[number];

  @IsOptional()
  @IsBoolean()
  highPriority?: boolean;

  @IsOptional()
  @IsUUID()
  assignedToId?: string;
}

export class UpdateCustomerDto {
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  company?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  contactName?: string;

  @IsOptional()
  @Transform(trim)
  @Matches(PHONE, { message: PHONE_MESSAGE })
  phone?: string;

  @IsOptional()
  @Transform(normalizeEmail)
  @IsEmail()
  @MaxLength(254)
  email?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MinLength(5)
  @MaxLength(250)
  address?: string;

  @IsOptional()
  @IsIn(CUSTOMER_STATUSES)
  status?: (typeof CUSTOMER_STATUSES)[number];

  @IsOptional()
  @IsBoolean()
  highPriority?: boolean;

  @IsOptional()
  @IsUUID()
  assignedToId?: string;
}

export class CreateNoteDto {
  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  text: string;
}