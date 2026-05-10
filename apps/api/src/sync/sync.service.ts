import { BadRequestException, Injectable } from '@nestjs/common';
import { RequestUser } from '../common/types/request-user';
import { ParcelsService } from '../parcels/parcels.service';
import {
  AdvanceParcelDto,
  ReceiveParcelDto,
} from '../parcels/dto/parcel-write.dto';
import {
  SyncOperationDto,
  SyncOperationType,
  SyncPushDto,
} from './dto/sync-push.dto';

@Injectable()
export class SyncService {
  constructor(private readonly parcels: ParcelsService) {}

  async push(dto: SyncPushDto, actor: RequestUser) {
    const results: unknown[] = [];
    for (const operation of dto.operations) {
      results.push(await this.applyOperation(operation, actor));
    }
    return { applied: results.length, results };
  }

  private async applyOperation(
    operation: SyncOperationDto,
    actor: RequestUser,
  ): Promise<Awaited<ReturnType<ParcelsService['receive']>>> {
    const common = {
      clientMutationId: operation.clientMutationId,
      deviceId: operation.deviceId,
      happenedAt: operation.happenedAt,
    };

    if (operation.type === SyncOperationType.RECEIVE) {
      const payload = operation.payload as unknown as ReceiveParcelDto;
      return await this.parcels.receive({ ...payload, ...common }, actor);
    }

    const payload = operation.payload as AdvanceParcelDto & {
      trackingCode?: string;
    };
    if (!payload.trackingCode) {
      throw new BadRequestException(
        'trackingCode is required for status sync operations',
      );
    }

    if (operation.type === SyncOperationType.ARRIVE) {
      return await this.parcels.arrive(
        payload.trackingCode,
        { ...payload, ...common },
        actor,
      );
    }

    if (operation.type === SyncOperationType.PICKUP) {
      return await this.parcels.pickup(
        payload.trackingCode,
        { ...payload, ...common },
        actor,
      );
    }

    throw new BadRequestException('Unsupported operation');
  }
}
