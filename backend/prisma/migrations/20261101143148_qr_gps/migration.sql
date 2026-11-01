-- AlterTable
ALTER TABLE "customers" ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "longitude" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "visit_attachments" ADD COLUMN     "mimeType" TEXT,
ADD COLUMN     "sizeBytes" INTEGER,
ADD COLUMN     "storageKey" TEXT;

-- AlterTable
ALTER TABLE "visits" ADD COLUMN     "qrVerifiedAt" TIMESTAMP(3),
ADD COLUMN     "verifyAccuracyM" INTEGER,
ADD COLUMN     "verifyDistanceM" INTEGER,
ADD COLUMN     "verifyLatitude" DOUBLE PRECISION,
ADD COLUMN     "verifyLongitude" DOUBLE PRECISION;
