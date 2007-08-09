//
//  AppDelegate.h
//  MakeRAMDisk
//
//  Created by Peter Hosey on 2007-06-05.
//  Copyright 2007 Peter Hosey. All rights reserved.
//

@interface AppDelegate : NSObject
{
	IBOutlet NSWindow *settingsWindow;
	IBOutlet NSPopUpButton *multiplierPopup;

	double volumeSize;
	unsigned short multiplierBase, multiplierPower;
	NSString *volumeName;
	BOOL saveSettings;
}

- (void)mountRAMDisk:(out NSError **)outError;

#pragma mark Accessors

- (double) volumeSize;
- (void) setVolumeSize:(double)newVolumeSize;

- (unsigned short) multiplierBase;
- (void) setMultiplierBase:(unsigned short)newMultiplierBase;

- (unsigned short) multiplierPower;
- (void) setMultiplierPower:(unsigned short)newMultiplierPower;

- (IBAction) takeMultiplierFrom:sender;

- (NSString *) volumeName;
- (void) setVolumeName:(NSString *)newVolumeName;

- (BOOL) saveSettings;
- (void) setSaveSettings:(BOOL)flag;

#pragma mark Actions

- (IBAction)quitWithoutMakingRAMDisk:sender;
- (IBAction)makeRAMDisk:sender;

@end
