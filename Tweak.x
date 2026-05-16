#import <UIKit/UIKit.h>
#import <substrate.h>

@interface MUSTAFA_Menu : UIWindow
+ (instancetype)sharedMenu;
- (void)showAlert;
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
        self.windowLevel = UIWindowLevelNormal + 1;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = NO;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 100, 150, 50);
        btn.backgroundColor = [UIColor blackColor];
        btn.layer.cornerRadius = 10;
        [btn setTitle:@"MUSTAFA VIP" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MUSTAFA VIP" 
                                                                   message:@"Tweak Loaded Successfully!" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
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
