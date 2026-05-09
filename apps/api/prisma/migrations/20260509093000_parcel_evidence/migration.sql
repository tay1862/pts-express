-- CreateEnum
CREATE TYPE "ParcelPhotoType" AS ENUM ('PHOTO', 'SIGNATURE');

-- AlterTable
ALTER TABLE "ParcelPhoto"
ADD COLUMN "type" "ParcelPhotoType" NOT NULL DEFAULT 'PHOTO',
ADD COLUMN "capturedAt" TIMESTAMP(3),
ADD COLUMN "latitude" DOUBLE PRECISION,
ADD COLUMN "longitude" DOUBLE PRECISION,
ADD COLUMN "accuracyMeters" DOUBLE PRECISION,
ADD COLUMN "addressText" TEXT;

-- CreateIndex
CREATE INDEX "ParcelPhoto_parcelId_createdAt_idx" ON "ParcelPhoto"("parcelId", "createdAt");

-- CreateIndex
CREATE INDEX "ParcelPhoto_eventId_idx" ON "ParcelPhoto"("eventId");
