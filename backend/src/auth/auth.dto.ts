import { IsEmail, IsString, Matches, MaxLength, MinLength } from 'class-validator';

export class LoginDto {
  @IsEmail()
  @MaxLength(254)
  email: string;

  @IsString()
  @MinLength(1)
  @MaxLength(128)
  password: string;
}

export class RefreshDto {
  @IsString()
  @MinLength(20)
  @MaxLength(256)
  refreshToken: string;
}
export class UpdateProfileDto {
  @IsEmail()
  @MaxLength(254)
  email: string;

  @Matches(/^\+?[0-9\s-]{10,20}$/, {
    message: 'phone must be a valid phone number',
  })
  phone: string;
}

export class ChangePasswordDto {
  @IsString()
  @MinLength(1)
  @MaxLength(128)
  currentPassword: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  @Matches(/[A-Za-z]/, { message: 'newPassword must contain a letter' })
  @Matches(/\d/, { message: 'newPassword must contain a number' })
  newPassword: string;
}