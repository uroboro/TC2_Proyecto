#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ToneGenerator.h"

#import "common.h"

static AudioComponentInstance createToneUnitWithChannelsCallbackContext(int channels, AURenderCallback callback, void *context) {
	AudioComponentInstance toneUnit;
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;

	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	if (!defaultOutput) {
		NSLog(@"Can't find default output");
		return nil;
	}

	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	if (!toneUnit) {
		NSLog(@"Error creating unit: %ld", (long)err);
		return nil;
	}

	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = callback;
	input.inputProcRefCon = context;
	err = AudioUnitSetProperty(toneUnit,
		kAudioUnitProperty_SetRenderCallback,
		kAudioUnitScope_Input,
		0,
		&input,
		sizeof(input));
	if (err != noErr) {
		NSLog(@"Error setting callback: %ld", (long)err);
		return nil;
	}

	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = SAMPLERATE;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = channels;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&streamFormat,
		sizeof(AudioStreamBasicDescription));
	if (err != noErr) {
		NSLog(@"Error setting stream format: %ld", (long)err);
		return nil;
	}

	// Stop changing parameters on the unit
	err = AudioUnitInitialize(toneUnit);
	if (err != noErr) {
		NSLog(@"Error initializing unit: %ld", (long)err);
		return nil;
	}

	return toneUnit;
}

@interface ToneGenerator ()
@property (nonatomic, assign) AudioComponentInstance toneUnit;
@end

static ModulatorData md;

@implementation ToneGenerator

@synthesize transferSpeed;
@synthesize channelCount;
@synthesize channelIndex;
@synthesize centerFrequency;
@synthesize deltaFrequency;
@synthesize modulatorData;

- (id)initWithMode:(int)mode {
	if ((self = [super init])) {
		mode = (mode >= 1) ? (mode <= 2) ? mode : 2 : 1;
		modulatorData = &md;
		_toneUnit = createToneUnitWithChannelsCallbackContext(mode, ToneRenderer, self);

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
		if (result == kAudioSessionNoError) {
			UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
			AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
		}
		#pragma clang diagnostic pop
	}

	return self;
}

- (id)init {
	return [self initWithMode:1];
}

- (void)dealloc {
	[self stop];

	[super dealloc];
}

- (BOOL)togglePlay {
	return (_playing) ? [self pause] : [self play];
}

- (BOOL)play {
	if (!_toneUnit) {
		return NO;
	}

	// Start playback
	OSErr err = AudioOutputUnitStart(_toneUnit);
	if (err != noErr) {
		UIAlert(@"play", @"no tone unit");
		NSLog(@"Error starting unit: %ld", (long)err);
		return NO;
	}
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	AudioSessionSetActive(true);
	#pragma clang diagnostic pop
	_playing = YES;

	return YES;
}

- (BOOL)pause {
	if (!_toneUnit) {
		return NO;
	}

	AudioOutputUnitStop(_toneUnit);
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	AudioSessionSetActive(false);
	#pragma clang diagnostic pop
	_playing = NO;

	return YES;
}

- (BOOL)stop {
	AudioUnitUninitialize(_toneUnit);
	AudioComponentInstanceDispose(_toneUnit);
	_toneUnit = nil;

	return YES;
}

@end
