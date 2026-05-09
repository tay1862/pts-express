import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  health() {
    return {
      ok: true,
      service: 'pts-express-api',
      timestamp: new Date().toISOString(),
    };
  }
}
