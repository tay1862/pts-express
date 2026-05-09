import { IsIn, IsString } from 'class-validator';

export class PresignUploadDto {
  @IsString()
  fileName!: string;

  @IsString()
  @IsIn(['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
  contentType!: string;
}
