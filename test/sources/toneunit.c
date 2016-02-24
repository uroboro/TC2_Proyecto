#include "toneunit.h"
#include "rendertone.h"

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState) {
	AudioComponentInstance *toneUnit = (AudioComponentInstance *)inClientData;
	stopAudio(toneUnit);
}

#pragma mark - AudioUnit creation

char createToneUnit(AudioComponentInstance *toneUnit) {
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
SC; AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;

	// Get the default playback output unit
SC; AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	if (!defaultOutput) {
		printf("E: Can't find default output");
		return 1;
	}

	// Create a new unit based on this that we'll use for output
SC; OSErr err = AudioComponentInstanceNew(defaultOutput, toneUnit);
	if (!*toneUnit) {
		printf("E: creating unit: %ld", (long)err);
		return 1;
	}

	// Set our tone rendering function on the unit
SC; AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = *toneUnit;
SC; err = AudioUnitSetProperty(*toneUnit,
		kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
		0, &input, sizeof(input));
	if (err != noErr) {
		printf("E: setting callback: %ld", (long)err);
		return 1;
	}

	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
SC; AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = SAMPLERATE;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 2;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
SC; err = AudioUnitSetProperty(*toneUnit,
		kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
		0, &streamFormat, sizeof(AudioStreamBasicDescription));
	if (err != noErr) {
		printf("E: setting stream format: %ld", (long)err);
		return 1;
	}

	// Stop changing parameters on the unit
SC; err = AudioUnitInitialize(*toneUnit);
	if (err != noErr) {
		printf("E: initializing unit: %ld", (long)err);
		return 1;
	}

	return 0;
}

char freeAudio(AudioComponentInstance *toneUnit) {
	if (!toneUnit) {
		return 1;
	}

	AudioUnitUninitialize(*toneUnit);
	AudioComponentInstanceDispose(*toneUnit);
	*toneUnit = nil;

	return 0;
}


char startAudio(AudioComponentInstance *toneUnit) {
	if (!toneUnit) {
		return 1;
	}

	// Start playback
	OSErr err = AudioOutputUnitStart(*toneUnit);
	if (err != noErr) {
		printf("E: starting unit: %ld", (long)err);
		return 1;
	}

	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, toneUnit);
	if (result == kAudioSessionNoError) {
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	} else {
		printf("E: starting session: %ld", (long)err);
		return 1;
	}

	AudioSessionSetActive(true);

	return 0;
}

char stopAudio(AudioComponentInstance *toneUnit) {
	if (!toneUnit) {
		return 1;
	}

	AudioSessionSetActive(false);

	AudioOutputUnitStop(*toneUnit);

	return 0;
}