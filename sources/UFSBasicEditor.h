#import <UIKit/UIKit.h>

NSString *wwword;

@interface UFSBasicEditor : UIViewController <UITextViewDelegate>

@property (nonatomic, copy) NSString *word;
@property (nonatomic, assign) NSUInteger frequency;
@property (nonatomic, copy) void (^callback)(NSString *word, NSInteger frequency);

@end
