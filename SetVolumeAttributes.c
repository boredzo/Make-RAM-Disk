/*
 *  SetVolumeAttributes.c
 *  MakeRAMDisk
 *
 *  Created by Peter Hosey on 2007-08-06.
 *  Copyright 2007 Peter Hosey. All rights reserved.
 *
 */

#include "SetVolumeAttributes.h"

#include <hfs/hfs_format.h>
#include <libkern/OSByteOrder.h>
#include <fcntl.h>
#include <unistd.h>

bool setHFSPlusVolumeAttributesWithDevicePath(const char *pathToDevice, uint32_t setThese, uint32_t clearThese) {
	int fd = open(pathToDevice, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "%s: open failed: %s\n", __PRETTY_FUNCTION__, strerror(errno));
		return false;
	}

	struct HFSPlusVolumeHeader header;
	ssize_t amt = pread(fd, &header, sizeof(header), 1024);
	if (amt < 0) {
		fprintf(stderr, "%s: pread of %zu bytes failed: %s\n", __PRETTY_FUNCTION__, sizeof(header), strerror(errno));
		return false;
	}
	if (amt != sizeof(header)) {
		fprintf(stderr, "%s: pread of %zu bytes actually read %zi bytes, which is surprising\n", __PRETTY_FUNCTION__, sizeof(header), amt);
		return false;
	}

	//This only works on HFS+ and HFSX file-systems. If it's anything else, bail out without messing with it.
	u_int16_t signatureSwapped = OSSwapBigToHostInt16(header.signature);
	if ((signatureSwapped != kHFSPlusSigWord)
	&&  (signatureSwapped != kHFSXSigWord)
	) {
		fprintf(stderr, "%s: header.signature is 0x%x, which is not HFS+ (0x%x) or HFSX (0x%x)\n", __PRETTY_FUNCTION__, signatureSwapped, kHFSPlusSigWord, kHFSXSigWord);
		return false;
	}

	header.attributes  = OSSwapBigToHostInt32(header.attributes);
	header.attributes |= setThese;
	header.attributes &= ~clearThese;
	header.attributes  = OSSwapHostToBigInt32(header.attributes);

	//Since we're modifying the volume header, we should sign our work. (TN1150 says so.)
	header.lastMountedVersion = OSSwapHostToBigInt32('MkRD');

	//Put our shiny new header back in the device.
	amt = pwrite(fd, &header, sizeof(header), 1024);
	if (amt < 0) {
		fprintf(stderr, "%s: pwrite of %zu bytes failed: %s\n", __PRETTY_FUNCTION__, sizeof(header), strerror(errno));
		return false;
	}
	if (amt != sizeof(header)) {
		fprintf(stderr, "%s: pwrite of %zu bytes actually read %zi bytes, which is surprising\n", __PRETTY_FUNCTION__, sizeof(header), amt);
		return false;
	}

	close(fd);

	return true;
}
