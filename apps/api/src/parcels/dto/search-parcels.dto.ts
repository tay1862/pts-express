import { ParcelStatus } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';

export class SearchParcelsDto {
  @IsOptional()
  @IsString()
  q?: string;

  @IsOptional()
  @IsEnum(ParcelStatus)
  status?: ParcelStatus;
}
