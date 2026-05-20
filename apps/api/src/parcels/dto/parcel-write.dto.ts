import { ParcelCodeKind, ParcelPhotoType, ParcelStatus } from '@prisma/client';
import {
  ArrayMaxSize,
  IsArray,
  IsBase64,
  IsDateString,
  IsEnum,
  MaxLength,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

const MAX_ATTACHMENT_BYTES = 2 * 1024 * 1024;
const MAX_ATTACHMENT_BASE64_LENGTH = Math.ceil((MAX_ATTACHMENT_BYTES * 4) / 3);

export class RawParcelCodeDto {
  @IsString()
  @IsNotEmpty()
  rawCode!: string;

  @IsOptional()
  @IsEnum(ParcelCodeKind)
  kind?: ParcelCodeKind;

  @IsOptional()
  isPrimary?: boolean;
}

export class ParcelAttachmentDto {
  @IsEnum(ParcelPhotoType)
  type!: ParcelPhotoType;

  @IsString()
  @IsNotEmpty()
  fileName!: string;

  @IsString()
  @IsNotEmpty()
  contentType!: string;

  @IsBase64()
  @MaxLength(MAX_ATTACHMENT_BASE64_LENGTH)
  dataBase64!: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsDateString()
  capturedAt?: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsNumber()
  accuracyMeters?: number;

  @IsOptional()
  @IsString()
  addressText?: string;
}

export class ReceiveParcelDto {
  @IsOptional()
  @IsString()
  trackingCode?: string;

  @IsString()
  @IsNotEmpty()
  customerName!: string;

  @IsOptional()
  @IsString()
  customerPhone?: string;

  @IsOptional()
  @IsString()
  labelName?: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => RawParcelCodeDto)
  rawCodes?: RawParcelCodeDto[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(5)
  @ValidateNested({ each: true })
  @Type(() => ParcelAttachmentDto)
  attachments?: ParcelAttachmentDto[];

  @IsOptional()
  @IsString()
  clientMutationId?: string;

  @IsOptional()
  @IsString()
  deviceId?: string;

  @IsOptional()
  @IsDateString()
  happenedAt?: string;
}

export class AdvanceParcelDto {
  @IsOptional()
  @IsString()
  customerName?: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsString()
  clientMutationId?: string;

  @IsOptional()
  @IsString()
  deviceId?: string;

  @IsOptional()
  @IsDateString()
  happenedAt?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(5)
  @ValidateNested({ each: true })
  @Type(() => ParcelAttachmentDto)
  attachments?: ParcelAttachmentDto[];
}

export class AdminOverrideDto {
  @IsEnum(ParcelStatus)
  status!: ParcelStatus;

  @IsOptional()
  @IsString()
  reason?: string;
}

export class AddParcelPhotoDto {
  @IsOptional()
  @IsEnum(ParcelPhotoType)
  type?: ParcelPhotoType;

  @IsString()
  @IsNotEmpty()
  url!: string;

  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsString()
  eventId?: string;

  @IsOptional()
  @IsDateString()
  capturedAt?: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsNumber()
  accuracyMeters?: number;

  @IsOptional()
  @IsString()
  addressText?: string;
}
