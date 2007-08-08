//
//  AppDelegate.m
//  MakeRAMDisk
//
//  Created by Peter Hosey on 2007-06-05.
//  Copyright 2007 Peter Hosey. All rights reserved.
//

#import "AppDelegate.h"

#include "SetVolumeAttributes.h"

#define PREF_KEY_VOLUME_NAME @"Volume name"
#define PREF_KEY_VOLUME_SIZE @"Volume size"
#define PREF_KEY_MULTIPLIER_BASE @"Multiplier base"
#define PREF_KEY_MULTIPLIER_POWER @"Multiplier power"

@implementation AppDelegate

- init {
	if((self = [super init])) {
		[self setVolumeName:NSLocalizedString(@"RAM Disk", /*comment*/ nil)];
		[self setVolumeSize:64U];
		[self setMultiplierBase:2U];
		[self setMultiplierPower:20U]; //2 ** 20 == MiB
		[self setSaveSettings:YES];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		//Register the defaults with the values set up in -init.
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			volumeName, PREF_KEY_VOLUME_NAME,
			[NSNumber numberWithUnsignedInt:volumeSize], PREF_KEY_VOLUME_SIZE,
			[NSNumber numberWithUnsignedShort:multiplierBase], PREF_KEY_MULTIPLIER_BASE,
			[NSNumber numberWithUnsignedShort:multiplierPower], PREF_KEY_MULTIPLIER_POWER,
			nil]];

		//Now that we've registered our defaults, get the current values (in case the user had saved settings before).
		[self setVolumeName:[defaults stringForKey:PREF_KEY_VOLUME_NAME]];
		[self setVolumeSize:[[defaults objectForKey:PREF_KEY_VOLUME_SIZE] unsignedIntValue]];
		[self setMultiplierBase:[[defaults objectForKey:PREF_KEY_MULTIPLIER_BASE] unsignedIntValue]];
		[self setMultiplierPower:[[defaults objectForKey:PREF_KEY_MULTIPLIER_POWER] unsignedIntValue]];
	}
	return self;
}
- (void)dealloc {
	[volumeName release];
	[super dealloc];
}

- (void)awakeFromNib {
	if (GetCurrentEventKeyModifiers() == optionKey) {
		//The option key is down, so show the settings window.
		unsigned multiplierPacked = (multiplierBase << 16U | multiplierPower);
		[multiplierPopup selectItemWithTag:multiplierPacked];

		[settingsWindow makeKeyAndOrderFront:nil];
	} else {
		//No option key, so go directly to mounting the RAM disk. I will save you the Monopoly joke.
		NSError *error = nil;
		[self mountRAMDisk:&error];
#warning XXX Handle error
		[NSApp terminate:nil];
	}
}

- (void)mountRAMDisk:(out NSError **)outError {
	unsigned long long multiplier = pow(multiplierBase, multiplierPower);
	unsigned long long bytes = volumeSize * multiplier;
	unsigned long long sectors = (bytes / 512ULL);

	//Used by log messages.
	enum { OPEN_QUOTE = 0x201C, CLOSE_QUOTE = 0x201D };

	//Create device
	NSTask *hdidTask = [[[NSTask alloc] init] autorelease];
	[hdidTask setLaunchPath:@"/usr/bin/hdiutil"];
	[hdidTask setArguments:[NSArray arrayWithObjects:@"attach", @"-nomount", [NSString stringWithFormat:@"ram://%llu", sectors], nil]];
	NSPipe *hdidPipe = [NSPipe pipe];
	[hdidTask setStandardOutput:hdidPipe];

	//Slurp the device name from the hdid pipe
	[hdidTask launch];
	NSFileHandle *hdidFH = [hdidPipe fileHandleForReading];
	NSData *deviceNameData = [hdidFH readDataToEndOfFile];
	NSString *deviceName = [[[[NSString alloc] initWithData:deviceNameData encoding:NSASCIIStringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	[hdidTask waitUntilExit];
	if ([hdidTask terminationStatus] != 0) {
		NSLog(@"hdid exited abnormally with status %u", [hdidTask terminationStatus]);
		goto eject;
	}

	//Format it
	NSTask *newfsTask = [[[NSTask alloc] init] autorelease];
	[newfsTask setLaunchPath:@"/sbin/newfs_hfs"];
	[newfsTask setArguments:[NSArray arrayWithObjects:@"-v", volumeName, deviceName, nil]];
	[newfsTask launch];
	[newfsTask waitUntilExit];
	if ([newfsTask terminationStatus] != 0) {
		NSLog(@"newfs_hfs exited abnormally with status %u", [newfsTask terminationStatus]);
		goto eject;
	}

	/*Turn off caching. This is a RAM disk; we don't need a cache.
	 *This gains us 1–2 fps when recording in iShowU (settings: 1280×1024; uncompressed; 40 fps).
	 *This isn't essential, but failure here may portend other bad signs, since this does read and write the volume header.
	 */
	if(!setHFSPlusVolumeAttributesWithDevicePath([deviceName fileSystemRepresentation], kHFSVolumeNoCacheRequiredMask, 0U)) {
		NSLog(@"Couldn't set %@ as no-cache-required; bailing", deviceName);
		goto eject;
	}

	NSTask *diskutilTask = [[[NSTask alloc] init] autorelease];
	[diskutilTask setLaunchPath:@"/usr/sbin/diskutil"];
	[diskutilTask setArguments:[NSArray arrayWithObjects:@"mount", deviceName, nil]];
	[diskutilTask launch];
	[diskutilTask waitUntilExit];
	if ([diskutilTask terminationStatus] != 0) {
		NSLog(@"diskutil mount of device %C%@%C exited abnormally with status %u", OPEN_QUOTE, deviceName, CLOSE_QUOTE, [diskutilTask terminationStatus]);
		goto eject;
	}

	//We're done! Everything after this point is error-handling.
	return;

eject:;
	NSTask *diskutilEjectTask = [[[NSTask alloc] init] autorelease];
	[diskutilEjectTask setLaunchPath:@"/usr/sbin/diskutil"];
	[diskutilEjectTask setArguments:[NSArray arrayWithObjects:@"eject", deviceName, nil]];
	[diskutilEjectTask launch];
	[diskutilEjectTask waitUntilExit];
	NSAssert4([diskutilEjectTask terminationStatus] == 0, @"diskutil eject of device %C%@%C exited abnormally with status %u", OPEN_QUOTE, deviceName, CLOSE_QUOTE, [diskutilEjectTask terminationStatus]);
}

#pragma mark Accessors

- (unsigned) volumeSize {
	return volumeSize;
}
- (void) setVolumeSize:(unsigned)newVolumeSize {
	volumeSize = newVolumeSize;
}

- (unsigned short) multiplierBase {
	return multiplierBase;
}
- (void) setMultiplierBase:(unsigned short)newMultiplierBase {
	multiplierBase = newMultiplierBase;
}

- (unsigned short) multiplierPower {
	return multiplierPower;
}
- (void) setMultiplierPower:(unsigned short)newMultiplierPower {
	multiplierPower = newMultiplierPower;
}

- (IBAction) takeMultiplierFrom:sender {
	unsigned multiplierPacked = [[sender selectedItem] tag];
	unsigned short newBase = multiplierPacked >> 16U;
	unsigned short newPower = multiplierPacked & 0xFFFF;
	[self setMultiplierBase:newBase];
	[self setMultiplierPower:newPower];
}

- (NSString *) volumeName {
	return volumeName;
}
- (void) setVolumeName:(NSString *)newVolumeName {
	if(volumeName != newVolumeName) {
		[volumeName release];
		volumeName = [newVolumeName copy];
	}
}

- (BOOL) saveSettings {
	return saveSettings;
}
- (void) setSaveSettings:(BOOL)flag {
	saveSettings = flag;
}

#pragma mark Actions

- (IBAction)endSettingsWindow:sender {
	if (saveSettings) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		[defaults setInteger:volumeSize forKey:PREF_KEY_VOLUME_SIZE];
		[defaults setInteger:multiplierBase forKey:PREF_KEY_MULTIPLIER_BASE];
		[defaults setInteger:multiplierPower forKey:PREF_KEY_MULTIPLIER_POWER];
		[defaults setObject:volumeName forKey:PREF_KEY_VOLUME_NAME];

		[defaults synchronize];
	}

	NSError *error = nil;
	[self mountRAMDisk:&error];
#warning XXX Handle error
	[NSApp terminate:nil];
}

@end
