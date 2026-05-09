import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';

export enum SyncOperationType {
  RECEIVE = 'RECEIVE',
  ARRIVE = 'ARRIVE',
  PICKUP = 'PICKUP',
}

export class SyncOperationDto {
  @IsString()
  @IsNotEmpty()
  clientMutationId!: string;

  @IsEnum(SyncOperationType)
  type!: SyncOperationType;

  @IsOptional()
  @IsString()
  deviceId?: string;

  @IsDateString()
  happenedAt!: string;

  @IsObject()
  payload!: Record<string, unknown>;
}

export class SyncPushDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncOperationDto)
  operations!: SyncOperationDto[];
}
