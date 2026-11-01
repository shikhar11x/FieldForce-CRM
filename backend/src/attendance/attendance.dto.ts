import { Type } from 'class-transformer';
import {
  IsInt,
  IsNumber,
  IsOptional,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

/** Check-in / check-out ke saath device ki location. */
export class CheckDto {
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsNumber()
  @Min(0)
  @Max(100000)
  accuracyMeters: number;
}

export class MonthQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(2020)
  @Max(2100)
  year: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month: number;

  /** Employee ke liye nahi chahiye (wo apna dekhta hai). Manager / admin ke liye zaroori. */
  @IsOptional()
  @IsUUID()
  employeeId?: string;
}