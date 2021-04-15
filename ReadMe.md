# Make RAM Disk
## by Peter Hosey

Make RAM Disk is an application that provides an easy way to create, format, and mount a RAM disk in one shot.

It **requires Mac OS X version 10.4 or later.** It will not work on 10.3 or earlier.

### What's a RAM disk?
Most disks (more accurately, volumes) are backed by some sort of permanent storage, such as an optical disc (as in CD and DVD), magnetic hard disk, or flash memory. In all of these cases, the data on the volume will persist after the computer is shut down, because it's been written to permanent storage. (Sometimes that isn't true, but it's very very rare.)

A RAM disk, on the other hand, has no permanent storage behind it. The data on the RAM “disk” is stored only in RAM (memory), and will be forgotten at shutdown.

### Why would I want this?
A RAM disk is very, very fast—in fact, it's the fastest disk you can possibly have (without buying an expensive RAID). On my Mac Pro (manufactured October 2006), I can write data to a RAM disk at more than half a gigabyte per second.

It's great for things that you need to read or write quickly, especially if you don't need to keep them around. A RAM disk is great for iShowU temp files (see the Storage tab of its preferences). You can also put your Downloads folder (in Safari, Mail, Adium, etc.) on a RAM disk, since you won't always want to keep things you download.

### But isn't it possible to lose data if it's only in RAM?
Yes. Don't leave anything on your RAM disk that you want to keep. As soon as you decide to keep something, copy it to some kind of permanent storage, such as your hard disk (especially if you're on a desktop Mac, since you never know when the power will go out).

The danger is less on a laptop, since a power failure isn't as likely to cause the machine to shut down (it will probably just switch to battery power), but there are still circumstances that can lose the contents of the RAM disk. These include kernel panics, depleted batteries, and accidentally clicking the Eject button in the Finder.

### How do I use it?
Just run it. By default, it creates a 64-MiB RAM disk named “RAM Disk”.

### Can I have it create a RAM disk on startup/login?
Yes. Add it to your Login Items in the Accounts pane of System Preferences.

### How do I get rid of the RAM disk?
Click on the Eject (⏏) button next to its name in the Finder's sidebar. Alternatively, use Disk Utility (in /Applications/Utilities) to eject it.

### I want to create a bigger or smaller RAM disk or to create it with a different name. How do I do that?
Hold down the Option key while launching Make RAM Disk; it will present a window wherein you can change the size or name of the volume. If the “Save settings for next time” checkbox is checked, the settings you enter here will be saved (obviously); if not, they are forgotten just before quitting.

Remember: the Option key for the Options window.

### Can I change the options without actually creating a RAM disk?
Yes. As long as the box is checked, the options will be saved, whether you create a RAM disk or not.

### Can I change the size an existing RAM disk?
No.

### Can I rename an existing RAM disk?

Yes, you can get info on it in the Finder and change its name there.

If you have anything referencing the RAM disk by pathname (e.g., `/Volumes/RAM Disk/…`), you'll need to tell it the new pathname, as the old pathname will no longer work.

### Can I have a custom icon on the RAM disk?
(or)
### Can I have it install some things on the RAM disk for me?
Maybe in a future version. Both of these are really the same question, by the way (custom icons work by putting a file on the volume and setting a flag).

### Can I have the RAM disk's contents saved at shutdown?
Not that I know of.

### My RAM disk went away when I put the computer to sleep!
Yeah, desktop Macs do that. I don't know why, or how to prevent it.

Laptops don't, though. Again, I don't know why. Maybe it's something to do with the “safe sleep” feature on recent Macs (enabled by default on laptops).

### What's the largest RAM disk I can create?
Probably somewhere less than 4 GiB, owing to the natural limit of 32-bit counting. With 32-bit numbers, you can only count up to 232, which is 4,294,967,296. That's the number of bytes in 4 GiB; there's some overhead to subtract, so the amount actually available for storage of data is a bit less.

I expect that the limit will go up in Leopard, as that will be a fully 64-bit operating system.

### How do I change the volume format from HFS+ to something else?
Use Disk Utility to reformat the RAM disk. Remember that this will blow away anything already stored on the RAM disk.

You can't change this in Make RAM Disk itself—it's hard-coded. I figure that if you actually need to repeatedly create a RAM disk in some exotic format, you have enough Terminal-fu that you can write a shell script of your own to do it (and maybe make it into a pseudo-GUI app using Platypus).

### How is it implemented?
The facility to host a RAM disk is built into Mac OS X, but it's well-hidden. It's actually provided by the Disk Images framework. Make RAM Disk invokes hdiutil to create the RAM disk, then invokes newfs_hfs to format it as HFS+, then disables caching on the RAM disk (what would be the point?), then invokes diskutil mount to mount the volume on the Desktop.

### So Make RAM Disk doesn't implement the RAM disk itself, then?
Heck no.

### Does Make RAM Disk run continuously in the background?
No, it doesn't come with any background processes of its own. You will have a diskimages-helper process in the background, but that's part of Mac OS X, since Make RAM Disk simply uses Mac OS X's own disk-image machinery to create the RAM disk. That process should go away once you eject the RAM disk.

### My amount of free memory went way down!
(or)
### I have a diskimages-helper process using lots of memory!
Well, yeah. ☺ RAM disks, by definition, use RAM (memory) to store their contents. Fortunately, diskimages-helper seems pretty lazy about allocating memory for itself, so you can actually create fairly huge RAM disks and only pay the RAM penalty for it when you start putting huge amounts of data on them.

----

### Copyright
Make RAM Disk and this ReadMe are copyright 2007 Peter Hosey. See the LICENSE.txt file, which you should have received with both this application and this ReadMe, for license terms and redistribution information.

https://boredzo.org/make-ram-disk
