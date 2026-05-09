import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { randomUUID } from 'crypto';
import { PresignUploadDto } from './dto/presign-upload.dto';

export interface StoredAttachment {
  key: string;
  publicUrl: string;
}

export interface Base64AttachmentUpload {
  fileName: string;
  contentType: string;
  dataBase64: string;
}

@Injectable()
export class StorageService {
  private readonly client: S3Client;

  constructor(private readonly config: ConfigService) {
    this.client = new S3Client({
      region: 'auto',
      endpoint: this.config.get<string>('R2_ENDPOINT'),
      credentials: {
        accessKeyId: this.config.get<string>('R2_ACCESS_KEY_ID') ?? '',
        secretAccessKey: this.config.get<string>('R2_SECRET_ACCESS_KEY') ?? '',
      },
    });
  }

  async presignUpload(dto: PresignUploadDto) {
    this.assertR2Ready();
    const bucket = this.config.getOrThrow<string>('R2_BUCKET');
    const publicBaseUrl = this.config.getOrThrow<string>('R2_PUBLIC_BASE_URL');
    const key = this.objectKey(dto.fileName);
    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      ContentType: dto.contentType,
    });
    const uploadUrl = await getSignedUrl(this.client, command, {
      expiresIn: 300,
    });
    return {
      key,
      uploadUrl,
      publicUrl: `${publicBaseUrl.replace(/\/$/, '')}/${key}`,
    };
  }

  async storeBase64Attachment(
    attachment: Base64AttachmentUpload,
  ): Promise<StoredAttachment> {
    const key = this.objectKey(attachment.fileName);
    const publicBaseUrl = this.config.get<string>('R2_PUBLIC_BASE_URL');
    const bucket = this.config.get<string>('R2_BUCKET');

    if (!publicBaseUrl || !bucket || !this.hasUsableR2Endpoint()) {
      this.assertR2Ready();
      return { key, publicUrl: `local://${key}` };
    }

    await this.client.send(
      new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        ContentType: attachment.contentType,
        Body: Buffer.from(attachment.dataBase64, 'base64'),
      }),
    );
    return {
      key,
      publicUrl: `${publicBaseUrl.replace(/\/$/, '')}/${key}`,
    };
  }

  private objectKey(fileName: string) {
    const extension = fileName.split('.').pop()?.toLowerCase() ?? 'bin';
    return `pts/${new Date().toISOString().slice(0, 10)}/${randomUUID()}.${extension}`;
  }

  private hasUsableR2Endpoint() {
    const endpoint = this.config.get<string>('R2_ENDPOINT');
    if (!endpoint || endpoint.includes('<') || endpoint.includes('>')) {
      return false;
    }
    try {
      new URL(endpoint);
      return true;
    } catch {
      return false;
    }
  }

  private assertR2Ready() {
    const required =
      this.config.get<string>('REQUIRE_R2') === 'true' ||
      this.config.get<string>('NODE_ENV') === 'production';
    if (!required) {
      return;
    }
    const missing = [
      'R2_ENDPOINT',
      'R2_ACCESS_KEY_ID',
      'R2_SECRET_ACCESS_KEY',
      'R2_BUCKET',
      'R2_PUBLIC_BASE_URL',
    ].filter((key) => !this.config.get<string>(key));
    if (missing.length > 0 || !this.hasUsableR2Endpoint()) {
      throw new Error(
        `R2 is required in production. Missing or invalid: ${missing.join(', ') || 'R2_ENDPOINT'}`,
      );
    }
  }
}
