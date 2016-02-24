#import <UIKit/UIKit.h>

@interface UFSGenericTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, retain) NSMutableDictionary *data;

- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithContentsOfURL:(NSURL *)aURL;
- (id)initWithDictionary:(NSDictionary *)aDictionary;

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
- (BOOL)writeToURL:(NSString *)path atomically:(BOOL)flag;

- (void)saveState;
- (void)restoreState;

- (id)objectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (NSInteger)numberOfSections;
- (NSDictionary *)sectionForIndex:(NSInteger)sectionIndex;
- (void)addSection:(NSDictionary *)section;
- (void)removeSectionAtIndex:(NSInteger)sectionIndex;
- (NSArray *)sectionIndexTitles;

- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex;
- (NSDictionary *)rowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addRow:(NSDictionary *)row toSection:(NSInteger)sectionIndex;
- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

- (id)inheritedObjectForKey:(id)key atIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCellStyle)cellStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)setText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setDetailText:(NSString *)detailText forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)detailTextForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
