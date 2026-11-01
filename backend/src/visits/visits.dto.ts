import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export const VISIT_TYPES = [
  'SALES',
  'SERVICE',
  'FOLLOW_UP',
  'DELIVERY',
  'DEMO',
] as const;

const trim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class CreateVisitDto {
  @IsUUID()
  customerId: string;

  @IsOptional()
  @IsUUID()
  assigneeId?: string;

  @IsDateString()
  scheduledAt: string;

  @IsIn(VISIT_TYPES)
  type: (typeof VISIT_TYPES)[number];

  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(250)
  purpose: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(250)
  location?: string;
}

export class VisitNoteDto {
  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  text: string;
}

/** QR scan + device ki location. Doori server khud nikalta hai. */
export class ScanQrDto {
  @IsString()
  @MinLength(10)
  @MaxLength(300)
  qrPayload: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  /** GPS reading ki accuracy (meters). */
  @IsNumber()
  @Min(0)
  @Max(100000)
  accuracyMeters: number;
}