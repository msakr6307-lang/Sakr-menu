#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// ========== Hook Function Declarations ==========
static float (*orig_get_progress)(void *self);
static void (*orig_send_attack)(void *self);

float hook_get_progress(void *self) { return 1.0f; }
void hook_send_attack(void *self) { 
    if (orig_send_attack) orig_send_attack(self); 
}

// ========== UIColor Gold ==========
@interface UIColor (Gold)
+ (UIColor *)goldColor;
@end

@implementation UIColor (Gold)
+ (UIColor *)goldColor {
    return [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];
}
@end

// ========== Sakr Menu Interface ==========
@interface SakrMenu : UIWindow {
    UIView *menuView;
    UIButton *falconButton;
    UILabel *goldTitle;
    
    UIButton *autoMineBtn;
    UIButton *magicBulletBtn;
    UIButton *aimbotBtn;
    UIButton *speedHackBtn;
    UIButton *godModeBtn;
    UIButton *espBtn;
    
    UISlider *fovSlider;
    UISegmentedControl *hitLocationSegment;
    
    BOOL isAutoMineOn;
    BOOL isMagicBulletOn;
    BOOL isAimbotOn;
    BOOL isSpeedHackOn;
    BOOL isGodModeOn;
    BOOL isEspOn;
}

+ (instancetype)sharedMenu;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupFalconIcon;
- (void)setupMenu;
- (void)moveFalcon:(UIPanGestureRecognizer *)sender;
- (void)moveMenu:(UIPanGestureRecognizer *)sender;
- (void)toggleMenu;
- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action;
- (void)updateButton:(UIButton *)button isOn:(BOOL)isOn title:(NSString *)title;
- (void)toggleAutoMine;
- (void)toggleMagicBullet;
- (void)toggleAimbot;
- (void)toggleSpeedHack;
- (void)toggleGodMode;
- (void)toggleESP;
- (void)installHooks;

@end

// ========== Sakr Menu Implementation ==========
@implementation SakrMenu

+ (instancetype)sharedMenu {
    static SakrMenu *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return shared;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        [self setupFalconIcon];
        [self setupMenu];
        [self installHooks];
    }
    return self;
}

- (void)installHooks {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    uintptr_t progressOffset = base + 0x23F9764;
    uintptr_t attackOffset = base + 0x24CC8DC;
    
    MSHookFunction((void *)progressOffset, (void *)&hook_get_progress, (void **)&orig_get_progress);
    MSHookFunction((void *)attackOffset, (void *)&hook_send_attack, (void **)&orig_send_attack);
    
    NSLog(@"[SakrMenu] Hooks installed!");
}

- (void)setupFalconIcon {
    falconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    falconButton.frame = CGRectMake(20, 150, 55, 55);
    falconButton.backgroundColor = [UIColor blackColor];
    falconButton.layer.cornerRadius = 27.5;
    falconButton.layer.borderWidth = 1.5;
    falconButton.layer.borderColor = [UIColor goldColor].CGColor;
    [falconButton setTitle:@"🦅" forState:UIControlStateNormal];
    falconButton.titleLabel.font = [UIFont systemFontOfSize:28];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveFalcon:)];
    [falconButton addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [falconButton addGestureRecognizer:tap];
    
    [self addSubview:falconButton];
}

- (void)moveFalcon:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)setupMenu {
    menuView = [[UIView alloc] initWithFrame:CGRectMake(60, 100, 280, 500)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.95];
    menuView.layer.cornerRadius = 20;
    menuView.layer.borderWidth = 1.5;
    menuView.layer.borderColor = [UIColor goldColor].CGColor;
    menuView.alpha = 0;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    [menuView addGestureRecognizer:pan];
    
    goldTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 35)];
    goldTitle.text = @"✦ SAKR MENU ✦";
    goldTitle.textColor = [UIColor goldColor];
    goldTitle.textAlignment = NSTextAlignmentCenter;
    goldTitle.font = [UIFont boldSystemFontOfSize:18];
    [menuView addSubview:goldTitle];
    
    CGFloat y = 65;
    CGFloat step = 50;
    
    autoMineBtn = [self createButton:@"🤖 Auto Mine" y:y action:@selector(toggleAutoMine)];
    [menuView addSubview:autoMineBtn];
    y += step;
    
    magicBulletBtn = [self createButton:@"✨ Magic Bullet" y:y action:@selector(toggleMagicBullet)];
    [menuView addSubview:magicBulletBtn];
    y += step;
    
    aimbotBtn = [self createButton:@"🎯 Aimbot" y:y action:@selector(toggleAimbot)];
    [menuView addSubview:aimbotBtn];
    y += step;
    
    speedHackBtn = [self createButton:@"🏎️ Speed Hack" y:y action:@selector(toggleSpeedHack)];
    [menuView addSubview:speedHackBtn];
    y += step;
    
    godModeBtn = [self createButton:@"🛡️ God Mode" y:y action:@selector(toggleGodMode)];
    [menuView addSubview:godModeBtn];
    y += step;
    
    espBtn = [self createButton:@"👁️ ESP" y:y action:@selector(toggleESP)];
    [menuView addSubview:espBtn];
    
    [self addSubview:menuView];
}

- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(15, y, 250, 40);
    btn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    btn.layer.cornerRadius = 8;
    [btn setTitle:[NSString stringWithFormat:@"%@ 🔴 OFF", title] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)moveMenu:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)toggleMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self->menuView.alpha = (self->menuView.alpha == 0 ? 1 : 0);
    }];
}

- (void)updateButton:(UIButton *)button isOn:(BOOL)isOn title:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isOn) {
            [button setTitle:[NSString stringWithFormat:@"%@ 🟢 ON", title] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        } else {
            [button setTitle:[NSString stringWithFormat:@"%@ 🔴 OFF", title] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    });
}

- (void)toggleAutoMine { isAutoMineOn = !isAutoMineOn; [self updateButton:autoMineBtn isOn:isAutoMineOn title:@"🤖 Auto Mine"]; }
- (void)toggleMagicBullet { isMagicBulletOn = !isMagicBulletOn; [self updateButton:magicBulletBtn isOn:isMagicBulletOn title:@"✨ Magic Bullet"]; }
- (void)toggleAimbot { isAimbotOn = !isAimbotOn; [self updateButton:aimbotBtn isOn:isAimbotOn title:@"🎯 Aimbot"]; }
- (void)toggleSpeedHack { isSpeedHackOn = !isSpeedHackOn; [self updateButton:speedHackBtn isOn:isSpeedHackOn title:@"🏎️ Speed Hack"]; }
- (void)toggleGodMode { isGodModeOn = !isGodModeOn; [self updateButton:godModeBtn isOn:isGodModeOn title:@"🛡️ God Mode"]; }
- (void)toggleESP { isEspOn = !isEspOn; [self updateButton:espBtn isOn:isEspOn title:@"👁️ ESP"]; }

@end

// ========== Constructor ==========
__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SakrMenu sharedMenu];
    });
}
