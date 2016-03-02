#import <AudioToolbox/AudioToolbox.h>

#define SAMPLERATE 44100
#define HUMAN_MIN_FREQUENCY 20
#define HUMAN_MAX_FREQUENCY 22050

#define kDataStreamSideRight 0
#define kDataStreamSideLeft  1

typedef struct ModulatorData {
	NSInteger frequencies[4];
	BOOL frequenciesState[4];
	char *words[4];
} ModulatorData;

@protocol ToneRenderer

@property (nonatomic, assign) CGFloat transferSpeed;
@property (nonatomic, assign) NSInteger channelCount;
@property (nonatomic, assign) NSInteger channelIndex;
@property (nonatomic, assign) NSInteger centerFrequency;
@property (nonatomic, assign) NSInteger deltaFrequency;
@property (nonatomic, assign) ModulatorData *modulatorData;
@property (nonatomic, assign) CGFloat amplitude;

@end

OSStatus ToneRenderer(
	void *inRefCon,
	AudioUnitRenderActionFlags	*ioActionFlags,
	const AudioTimeStamp		*inTimeStamp,
	UInt32						inBusNumber,
	UInt32						inNumberFrames,
	AudioBufferList 			*ioData);

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState);
