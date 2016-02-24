#import <Foundation/NSObject.h>
#import <AudioUnit/AudioUnit.h>
#import "ToneRenderer.h"

@interface ToneGenerator : NSObject <ToneRenderer>

- (id)initWithMode:(int)mode;

@property (nonatomic, assign) BOOL playing;
- (BOOL)togglePlay;
- (BOOL)play;
- (BOOL)pause;

@end
