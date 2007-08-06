/*
 *  SetVolumeAttributes.h
 *  MakeRAMDisk
 *
 *  Created by Peter Hosey on 2007-08-06.
 *  Copyright 2007 Peter Hosey. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

extern bool setHFSPlusVolumeAttributesWithDevicePath(const char *pathToDevice, uint32_t setThese, uint32_t clearThese);
