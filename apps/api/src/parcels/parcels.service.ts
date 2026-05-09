import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ParcelCodeKind,
  ParcelEventType,
  ParcelPhotoType,
  ParcelStatus,
  Prisma,
  UserRole,
  WarehouseCode,
} from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { RequestUser } from '../common/types/request-user';
import { StorageService } from '../storage/storage.service';
import {
  AddParcelPhotoDto,
  AdminOverrideDto,
  AdvanceParcelDto,
  ParcelAttachmentDto,
  ReceiveParcelDto,
} from './dto/parcel-write.dto';
import { SearchParcelsDto } from './dto/search-parcels.dto';
import {
  extractTrackingCandidate,
  normalizeCode,
  phoneSearchValue,
} from './parcel-code.util';

const statusOrder = [
  ParcelStatus.RECEIVED_IN_THAILAND,
  ParcelStatus.ARRIVED_IN_LAOS,
  ParcelStatus.PICKED_UP,
];

@Injectable()
export class ParcelsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async search(query: SearchParcelsDto) {
    const search = query.q?.trim();
    return this.prisma.parcel.findMany({
      where: {
        status: query.status,
        OR: search
          ? [
              { trackingCode: { contains: search, mode: 'insensitive' } },
              { customerName: { contains: search, mode: 'insensitive' } },
              { customerPhone: { contains: search, mode: 'insensitive' } },
              { codes: { some: { normalizedCode: normalizeCode(search) } } },
            ]
          : undefined,
      },
      include: this.parcelInclude(),
      orderBy: { updatedAt: 'desc' },
      take: 100,
    });
  }

  async findById(id: string) {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id },
      include: this.parcelInclude(),
    });
    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }
    return parcel;
  }

  async publicTrack(rawTrackingCode: string) {
    const parcel = await this.findByAnyCode(rawTrackingCode);
    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }

    const events = await this.prisma.parcelEvent.findMany({
      where: {
        parcelId: parcel.id,
        toStatus: { not: null },
      },
      orderBy: { happenedAt: 'asc' },
      select: {
        eventType: true,
        toStatus: true,
        happenedAt: true,
      },
    });

    return {
      trackingCode: parcel.trackingCode,
      status: parcel.status,
      history: events.map((event) => ({
        toStatus: event.toStatus,
        eventType: event.eventType,
        happenedAt: event.happenedAt,
      })),
    };
  }

  async receive(dto: ReceiveParcelDto, actor: RequestUser) {
    if (dto.clientMutationId) {
      const existingEvent = await this.findEventByMutation(
        dto.clientMutationId,
      );
      if (existingEvent) {
        return this.findById(existingEvent.parcelId);
      }
    }

    const baseCode =
      dto.trackingCode?.trim() ||
      dto.rawCodes?.find((code) => code.isPrimary)?.rawCode;
    const trackingCode = baseCode
      ? extractTrackingCandidate(baseCode)
      : await this.generateFallbackTrackingCode('PTS-TH');

    const existing = await this.findByAnyCode(trackingCode);
    if (existing) {
      await this.audit(
        'parcel.duplicate_receive',
        'parcel',
        existing.id,
        actor,
        {
          trackingCode,
          clientMutationId: dto.clientMutationId,
        },
      );
      return this.findById(existing.id);
    }

    const thWarehouse = await this.requiredWarehouse(WarehouseCode.TH);
    const customerPhone = phoneSearchValue(dto.customerPhone);
    const created = await this.prisma.$transaction(async (tx) => {
      const parcel = await tx.parcel.create({
        data: {
          trackingCode: trackingCode.trim(),
          status: ParcelStatus.RECEIVED_IN_THAILAND,
          customerName: dto.customerName.trim(),
          customerPhone,
          labelName: dto.labelName?.trim(),
          note: dto.note?.trim(),
          currentWarehouseId: thWarehouse.id,
          createdById: actor.id,
        },
      });

      await this.createCodes(tx, parcel.id, trackingCode, dto.rawCodes);
      const event = await tx.parcelEvent.create({
        data: {
          parcelId: parcel.id,
          eventType: ParcelEventType.RECEIVED_IN_THAILAND,
          toStatus: ParcelStatus.RECEIVED_IN_THAILAND,
          note: dto.note,
          happenedAt: this.happenedAt(dto.happenedAt),
          actorId: actor.id,
          warehouseId: thWarehouse.id,
          clientMutationId: dto.clientMutationId,
          deviceId: dto.deviceId,
        },
      });
      await tx.auditLog.create({
        data: this.auditData('parcel.receive', 'parcel', parcel.id, actor, {
          trackingCode,
          clientMutationId: dto.clientMutationId,
        }),
      });
      return { parcelId: parcel.id, eventId: event.id };
    });
    await this.saveAttachments(
      created.parcelId,
      created.eventId,
      dto.attachments,
      actor,
    );
    return this.findById(created.parcelId);
  }

  async arrive(rawCode: string, dto: AdvanceParcelDto, actor: RequestUser) {
    return this.advance(rawCode, ParcelStatus.ARRIVED_IN_LAOS, dto, actor);
  }

  async pickup(rawCode: string, dto: AdvanceParcelDto, actor: RequestUser) {
    return this.advance(rawCode, ParcelStatus.PICKED_UP, dto, actor);
  }

  async override(id: string, dto: AdminOverrideDto, actor: RequestUser) {
    const parcel = await this.findById(id);
    const warehouse = await this.warehouseForStatus(dto.status);
    const updated = await this.prisma.$transaction(async (tx) => {
      const next = await tx.parcel.update({
        where: { id },
        data: {
          status: dto.status,
          currentWarehouseId: warehouse?.id,
        },
      });
      await tx.parcelEvent.create({
        data: {
          parcelId: id,
          eventType: ParcelEventType.ADMIN_OVERRIDE,
          fromStatus: parcel.status,
          toStatus: dto.status,
          note: dto.reason,
          happenedAt: new Date(),
          actorId: actor.id,
          warehouseId: warehouse?.id,
        },
      });
      await tx.auditLog.create({
        data: this.auditData('parcel.admin_override', 'parcel', id, actor, {
          fromStatus: parcel.status,
          toStatus: dto.status,
          reason: dto.reason,
        }),
      });
      return next;
    });
    return this.findById(updated.id);
  }

  async addPhoto(id: string, dto: AddParcelPhotoDto, actor: RequestUser) {
    await this.findById(id);
    const photo = await this.prisma.parcelPhoto.create({
      data: {
        parcelId: id,
        eventId: dto.eventId,
        type: dto.type ?? ParcelPhotoType.PHOTO,
        url: dto.url,
        key: dto.key,
        note: dto.note,
        capturedAt: this.optionalDate(dto.capturedAt),
        latitude: dto.latitude,
        longitude: dto.longitude,
        accuracyMeters: dto.accuracyMeters,
        addressText: dto.addressText,
        uploadedBy: actor.id,
      },
    });
    await this.prisma.parcelEvent.create({
      data: {
        parcelId: id,
        eventType: ParcelEventType.PHOTO_ADDED,
        note: dto.note,
        happenedAt: new Date(),
        actorId: actor.id,
        photos: dto.eventId ? undefined : { connect: { id: photo.id } },
      },
    });
    await this.audit('parcel.photo_added', 'parcel', id, actor, {
      photoId: photo.id,
    });
    return photo;
  }

  private async advance(
    rawCode: string,
    targetStatus: ParcelStatus,
    dto: AdvanceParcelDto,
    actor: RequestUser,
  ) {
    if (dto.clientMutationId) {
      const existingEvent = await this.findEventByMutation(
        dto.clientMutationId,
      );
      if (existingEvent) {
        return this.findById(existingEvent.parcelId);
      }
    }

    const parcel = await this.findByAnyCode(rawCode);
    if (!parcel) {
      return this.createMissingParcel(rawCode, targetStatus, dto, actor);
    }

    const allowed =
      this.nextStatus(parcel.status) === targetStatus ||
      actor.role !== UserRole.STAFF;
    if (!allowed) {
      throw new BadRequestException(
        `Invalid transition ${parcel.status} -> ${targetStatus}`,
      );
    }

    return this.writeStatusEvent(
      parcel.id,
      parcel.status,
      targetStatus,
      dto,
      actor,
    );
  }

  private async createMissingParcel(
    rawCode: string,
    targetStatus: ParcelStatus,
    dto: AdvanceParcelDto,
    actor: RequestUser,
  ) {
    if (!dto.customerName?.trim()) {
      throw new BadRequestException(
        'customerName is required for unknown scans',
      );
    }

    const trackingCode = extractTrackingCandidate(rawCode);
    const firstWarehouse = await this.requiredWarehouse(WarehouseCode.TH);
    const parcel = await this.prisma.parcel.create({
      data: {
        trackingCode,
        status: ParcelStatus.RECEIVED_IN_THAILAND,
        customerName: dto.customerName.trim(),
        labelName: dto.customerName.trim(),
        note: `Created from unknown scan: ${dto.note ?? ''}`.trim(),
        currentWarehouseId: firstWarehouse.id,
        createdById: actor.id,
        codes: {
          create: {
            rawCode,
            normalizedCode: normalizeCode(trackingCode),
            kind: ParcelCodeKind.MANUAL,
            isPrimary: true,
          },
        },
      },
    });

    let current: ParcelStatus | null = null;
    const statuses = statusOrder.slice(
      0,
      statusOrder.indexOf(targetStatus) + 1,
    );
    for (const [index, next] of statuses.entries()) {
      await this.writeStatusEvent(
        parcel.id,
        current,
        next,
        {
          ...dto,
          clientMutationId:
            index === statuses.length - 1 ? dto.clientMutationId : undefined,
          attachments:
            index === statuses.length - 1 ? dto.attachments : undefined,
          note:
            index === 0
              ? `Created from unknown scan. ${dto.note ?? ''}`.trim()
              : dto.note,
        },
        actor,
      );
      current = next;
    }
    await this.audit(
      'parcel.missing_scan_created',
      'parcel',
      parcel.id,
      actor,
      {
        rawCode,
        targetStatus,
        clientMutationId: dto.clientMutationId,
      },
    );
    return this.findById(parcel.id);
  }

  private async writeStatusEvent(
    parcelId: string,
    fromStatus: ParcelStatus | null,
    toStatus: ParcelStatus,
    dto: AdvanceParcelDto,
    actor: RequestUser,
  ) {
    const warehouse = await this.warehouseForStatus(toStatus);
    const eventId = await this.prisma.$transaction(async (tx) => {
      await tx.parcel.update({
        where: { id: parcelId },
        data: {
          status: toStatus,
          currentWarehouseId: warehouse?.id,
        },
      });
      const event = await tx.parcelEvent.create({
        data: {
          parcelId,
          eventType: toStatus,
          fromStatus,
          toStatus,
          note: dto.note,
          happenedAt: this.happenedAt(dto.happenedAt),
          actorId: actor.id,
          warehouseId: warehouse?.id,
          clientMutationId: dto.clientMutationId,
          deviceId: dto.deviceId,
        },
      });
      await tx.auditLog.create({
        data: this.auditData(
          'parcel.status_change',
          'parcel',
          parcelId,
          actor,
          {
            fromStatus,
            toStatus,
            clientMutationId: dto.clientMutationId,
          },
        ),
      });
      return event.id;
    });
    await this.saveAttachments(parcelId, eventId, dto.attachments, actor);
    return this.findById(parcelId);
  }

  private async saveAttachments(
    parcelId: string,
    eventId: string,
    attachments: ParcelAttachmentDto[] | undefined,
    actor: RequestUser,
  ) {
    if (!attachments?.length) {
      return;
    }

    for (const attachment of attachments) {
      const stored = await this.storage.storeBase64Attachment(attachment);
      const photo = await this.prisma.parcelPhoto.create({
        data: {
          parcelId,
          eventId,
          type: attachment.type,
          url: stored.publicUrl,
          key: stored.key,
          note: attachment.note,
          capturedAt: this.optionalDate(attachment.capturedAt),
          latitude: attachment.latitude,
          longitude: attachment.longitude,
          accuracyMeters: attachment.accuracyMeters,
          addressText: attachment.addressText,
          uploadedBy: actor.id,
        },
      });
      await this.audit(
        attachment.type === ParcelPhotoType.SIGNATURE
          ? 'parcel.signature_added'
          : 'parcel.photo_added',
        'parcel',
        parcelId,
        actor,
        {
          photoId: photo.id,
          eventId,
          type: attachment.type,
        },
      );
    }
  }

  private async generateFallbackTrackingCode(prefix: string) {
    const date = new Date().toISOString().slice(0, 10).replaceAll('-', '');
    const sequence = await this.prisma.barcodeSequence.upsert({
      where: { prefix_date: { prefix, date } },
      create: { prefix, date, value: 1 },
      update: { value: { increment: 1 } },
    });
    return `${prefix}-${date}-${String(sequence.value).padStart(4, '0')}`;
  }

  private async findByAnyCode(rawCode: string) {
    const normalizedCode = normalizeCode(extractTrackingCandidate(rawCode));
    return this.prisma.parcel.findFirst({
      where: {
        OR: [
          { trackingCode: rawCode.trim() },
          { codes: { some: { normalizedCode } } },
        ],
      },
    });
  }

  private async findEventByMutation(clientMutationId: string) {
    return this.prisma.parcelEvent.findUnique({ where: { clientMutationId } });
  }

  private async createCodes(
    tx: Prisma.TransactionClient,
    parcelId: string,
    trackingCode: string,
    rawCodes?: {
      rawCode: string;
      kind?: ParcelCodeKind;
      isPrimary?: boolean;
    }[],
  ) {
    const codes = [
      { rawCode: trackingCode, kind: ParcelCodeKind.MANUAL, isPrimary: true },
      ...(rawCodes ?? []),
    ];
    const seen = new Set<string>();
    for (const code of codes) {
      const candidate = extractTrackingCandidate(code.rawCode);
      const normalizedCode = normalizeCode(candidate);
      if (!normalizedCode || seen.has(normalizedCode)) {
        continue;
      }
      seen.add(normalizedCode);
      await tx.parcelCode.create({
        data: {
          parcelId,
          rawCode: code.rawCode,
          normalizedCode,
          kind: code.kind ?? ParcelCodeKind.MANUAL,
          isPrimary: !!code.isPrimary,
        },
      });
    }
  }

  private nextStatus(status: ParcelStatus) {
    return statusOrder[statusOrder.indexOf(status) + 1];
  }

  private async warehouseForStatus(status: ParcelStatus) {
    if (status === ParcelStatus.RECEIVED_IN_THAILAND) {
      return this.requiredWarehouse(WarehouseCode.TH);
    }
    return this.requiredWarehouse(WarehouseCode.LA);
  }

  private async requiredWarehouse(code: WarehouseCode) {
    return this.prisma.warehouse.findUniqueOrThrow({ where: { code } });
  }

  private happenedAt(value?: string) {
    return value ? new Date(value) : new Date();
  }

  private optionalDate(value?: string) {
    return value ? new Date(value) : undefined;
  }

  private parcelInclude() {
    return {
      codes: true,
      events: { orderBy: { happenedAt: 'asc' as const } },
      photos: true,
      currentWarehouse: true,
    };
  }

  private auditData(
    action: string,
    entityType: string,
    entityId: string | undefined,
    actor: RequestUser,
    metadata?: Prisma.InputJsonValue,
  ) {
    return {
      action,
      entityType,
      entityId,
      actorId: actor.id,
      metadata,
    };
  }

  private async audit(
    action: string,
    entityType: string,
    entityId: string | undefined,
    actor: RequestUser,
    metadata?: Prisma.InputJsonValue,
  ) {
    await this.prisma.auditLog.create({
      data: this.auditData(action, entityType, entityId, actor, metadata),
    });
  }
}
