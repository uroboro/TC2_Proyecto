#import <UIKit/UIKit.h>

@interface AppDelegate: UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navViewController;
@property (nonatomic, retain) UIViewController *rootViewController;

- (void)refreshDefaultPNG;
- (UIImage *)makeDefaultImage;

- (void)updateMediaInfoKey:(id)key withValue:(id)value;
- (void)clearMediaInfo;

@end
