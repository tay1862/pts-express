-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('OWNER', 'ADMIN', 'STAFF');

-- CreateEnum
CREATE TYPE "WarehouseCode" AS ENUM ('TH', 'LA');

-- CreateEnum
CREATE TYPE "ParcelStatus" AS ENUM ('RECEIVED_IN_THAILAND', 'ARRIVED_IN_LAOS', 'PICKED_UP');

-- CreateEnum
CREATE TYPE "ParcelCodeKind" AS ENUM ('BARCODE', 'QR', 'MANUAL', 'GENERATED');

-- CreateEnum
CREATE TYPE "ParcelEventType" AS ENUM ('RECEIVED_IN_THAILAND', 'ARRIVED_IN_LAOS', 'PICKED_UP', 'ADMIN_OVERRIDE', 'PHOTO_ADDED', 'NOTE_ADDED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'STAFF',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Warehouse" (
    "id" TEXT NOT NULL,
    "code" "WarehouseCode" NOT NULL,
    "name" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Warehouse_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Parcel" (
    "id" TEXT NOT NULL,
    "trackingCode" TEXT NOT NULL,
    "status" "ParcelStatus" NOT NULL DEFAULT 'RECEIVED_IN_THAILAND',
    "customerName" TEXT NOT NULL,
    "customerPhone" TEXT,
    "labelName" TEXT,
    "note" TEXT,
    "currentWarehouseId" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Parcel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ParcelCode" (
    "id" TEXT NOT NULL,
    "parcelId" TEXT NOT NULL,
    "rawCode" TEXT NOT NULL,
    "normalizedCode" TEXT NOT NULL,
    "kind" "ParcelCodeKind" NOT NULL DEFAULT 'MANUAL',
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ParcelCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ParcelEvent" (
    "id" TEXT NOT NULL,
    "parcelId" TEXT NOT NULL,
    "eventType" "ParcelEventType" NOT NULL,
    "fromStatus" "ParcelStatus",
    "toStatus" "ParcelStatus",
    "note" TEXT,
    "happenedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actorId" TEXT,
    "warehouseId" TEXT,
    "clientMutationId" TEXT,
    "deviceId" TEXT,

    CONSTRAINT "ParcelEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ParcelPhoto" (
    "id" TEXT NOT NULL,
    "parcelId" TEXT NOT NULL,
    "eventId" TEXT,
    "url" TEXT NOT NULL,
    "key" TEXT,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "uploadedBy" TEXT,

    CONSTRAINT "ParcelPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BarcodeSequence" (
    "id" TEXT NOT NULL,
    "prefix" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "value" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BarcodeSequence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT,
    "actorId" TEXT,
    "metadata" JSONB,
    "clientMutationId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE UNIQUE INDEX "Warehouse_code_key" ON "Warehouse"("code");

-- CreateIndex
CREATE UNIQUE INDEX "Parcel_trackingCode_key" ON "Parcel"("trackingCode");

-- CreateIndex
CREATE INDEX "Parcel_status_idx" ON "Parcel"("status");

-- CreateIndex
CREATE INDEX "Parcel_customerName_idx" ON "Parcel"("customerName");

-- CreateIndex
CREATE INDEX "Parcel_customerPhone_idx" ON "Parcel"("customerPhone");

-- CreateIndex
CREATE UNIQUE INDEX "ParcelCode_normalizedCode_key" ON "ParcelCode"("normalizedCode");

-- CreateIndex
CREATE INDEX "ParcelCode_parcelId_idx" ON "ParcelCode"("parcelId");

-- CreateIndex
CREATE UNIQUE INDEX "ParcelEvent_clientMutationId_key" ON "ParcelEvent"("clientMutationId");

-- CreateIndex
CREATE INDEX "ParcelEvent_parcelId_happenedAt_idx" ON "ParcelEvent"("parcelId", "happenedAt");

-- CreateIndex
CREATE INDEX "ParcelEvent_eventType_idx" ON "ParcelEvent"("eventType");

-- CreateIndex
CREATE UNIQUE INDEX "BarcodeSequence_prefix_date_key" ON "BarcodeSequence"("prefix", "date");

-- CreateIndex
CREATE INDEX "AuditLog_action_idx" ON "AuditLog"("action");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");

-- AddForeignKey
ALTER TABLE "Parcel" ADD CONSTRAINT "Parcel_currentWarehouseId_fkey" FOREIGN KEY ("currentWarehouseId") REFERENCES "Warehouse"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Parcel" ADD CONSTRAINT "Parcel_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelCode" ADD CONSTRAINT "ParcelCode_parcelId_fkey" FOREIGN KEY ("parcelId") REFERENCES "Parcel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelEvent" ADD CONSTRAINT "ParcelEvent_parcelId_fkey" FOREIGN KEY ("parcelId") REFERENCES "Parcel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelEvent" ADD CONSTRAINT "ParcelEvent_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelEvent" ADD CONSTRAINT "ParcelEvent_warehouseId_fkey" FOREIGN KEY ("warehouseId") REFERENCES "Warehouse"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelPhoto" ADD CONSTRAINT "ParcelPhoto_parcelId_fkey" FOREIGN KEY ("parcelId") REFERENCES "Parcel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParcelPhoto" ADD CONSTRAINT "ParcelPhoto_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "ParcelEvent"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
