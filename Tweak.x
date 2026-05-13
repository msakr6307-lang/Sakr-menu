#import "ArchitectMenu.h"

@implementation ArchitectMenu

static ArchitectMenu *_sharedInstance;

+ (instancetype)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[ArchitectMenu alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    }
    return _sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.zPosition = 10000; // لضمان ظهورها فوق اللعبة
        
        // زر الأيقونة العائمة
        self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.menuButton.frame = CGRectMake(0, 0, 60, 60);
        self.menuButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
        self.menuButton.layer.cornerRadius = 30;
        self.menuButton.layer.borderWidth = 2;
        self.menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
        [self.menuButton setTitle:@"2099" forState:UIControlStateNormal];
        [self.menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.menuButton];
        
        // إضافة خاصية السحب (Drag) للأيقونة
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
}

- (void)showMenu {
    // إنشاء تنبيه بسيط (Menu) عند الضغط
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Architect 2099" 
                                                                   message:@"One State RP Menu" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Enable ESP (ON/OFF)" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Magic Bullet (Active)" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

// كود الحقن عند تشغيل اللعبة
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ArchitectMenu sharedInstance] setHidden:NO];
        [[[UIApplication sharedApplication] keyWindow] addSubview:[ArchitectMenu sharedInstance]];
        NSLog(@"[Architect] Menu Injected Successfully!");
    });
}
