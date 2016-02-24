#ifndef RENDERTONE_H
#define RENDERTONE_H

#import <AudioToolbox/AudioToolbox.h>

OSStatus RenderTone(
	void *inRefCon,
	AudioUnitRenderActionFlags	*ioActionFlags,
	const AudioTimeStamp		*inTimeStamp,
	UInt32						inBusNumber,
	UInt32						inNumberFrames,
	AudioBufferList 			*ioData);

#endif /* RENDERTONE_H */
