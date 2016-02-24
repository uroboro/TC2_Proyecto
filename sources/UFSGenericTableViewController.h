#import <UIKit/UIKit.h>

@interface UFSGenericTableViewController : UITableViewController

@property (nonatomic, retain) id dataSource;
@property (nonatomic, retain) id delegate;
@property (nonatomic, copy) void (^callback)();

@property (nonatomic, retain) NSString *saveFilePath;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)loadState;
- (void)saveState;

@end
