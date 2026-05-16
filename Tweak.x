#import <UIKit/UIKit.h>

@interface MUSTAFA_Menu : UIWindow
+ (instancetype)sharedMenu;
@end

@implementation MUSTAFA_Menu

+ (instancetype)sharedMenu {
    static MUSTAFA_Menu *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return shared;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelNormal + 1;
        self.hidden = NO;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(20, 100, 160, 50);
        button.backgroundColor = [UIColor blackColor];
        button.layer.cornerRadius = 10;
        [button setTitle:@"MUSTAFA VIP" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showMessage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)showMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MUSTAFA VIP" message:@"Tweak Loaded Successfully!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:alert animated:YES completion:nil];
}

@end

__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MUSTAFA_Menu sharedMenu];
    });
}
