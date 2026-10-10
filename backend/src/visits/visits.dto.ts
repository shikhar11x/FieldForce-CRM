import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsInt,
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

export class VerifyQrDto {
  /** Abhi app se aati hai. Step 22 me server khud GPS se nikalega. */
  @IsInt()
  @Min(0)
  @Max(100000)
  distanceMeters: number;
}