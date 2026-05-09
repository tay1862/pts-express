import { UserRole } from '@prisma/client';

export type RequestUser = {
  id: string;
  username: string;
  role: UserRole;
};
