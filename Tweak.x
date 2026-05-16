#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>
#import <mach-o/dyld.h>
#import <substrate.h>

#define GOLD_COLOR [UIColor colorWithRed:1.0 green:0.84 blue:0 alpha:1.0]

// ========== Flags ==========
static BOOL isMagicBulletOn = NO;
static BOOL isOneHitKillOn = NO;
static BOOL isInfiniteAmmoOn = NO;
static BOOL isRapidFireOn = NO;
static BOOL isAutoMineOn = NO;
static BOOL isGodModeOn = NO;
static BOOL isEnergyOn = NO;
static BOOL isSpeedHackOn = NO;
static BOOL isEspBoxOn = NO;
static BOOL isEspNameOn = NO;
static BOOL isEspHealthOn = NO;
static BOOL isEspDistanceOn = NO;

// ========== UI Interface ==========
@interface MUSTAFA_Menu : UIWindow {
    UIView *menuView;
    UIView *contentView;
    UIButton *falconButton;
    
    UIButton *magicBulletBtn;
    UIButton *oneHitKillBtn;
    UIButton *infiniteAmmoBtn;
    UIButton *rapidFireBtn;
    UIButton *autoMineBtn;
    UIButton *godModeBtn;
    UIButton *energyBtn;
    UIButton *speedHackBtn;
    UIButton *espBoxBtn;
    UIButton *espNameBtn;
    UIButton *espHealthBtn;
    UIButton *espDistanceBtn;
    
    NSString *currentTab;
}

+ (instancetype)sharedMenu;
- (void)setupFalconIcon;
- (void)setupMenu;
- (void)showTab:(NSString *)tab;
- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action;
- (void)updateButton:(UIButton *)btn isOn:(BOOL)isOn title:(NSString *)title;
- (void)clearContentView;
- (void)toggleMagicBullet;
- (void)toggleOneHitKill;
- (void)toggleInfiniteAmmo;
- (void)toggleRapidFire;
- (void)toggleAutoMine;
- (void)toggleGodMode;
- (void)toggleEnergy;
- (void)toggleSpeedHack;
- (void)toggleEspBox;
- (void)toggleEspName;
- (void)toggleEspHealth;
- (void)toggleEspDistance;

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
        self.userInteractionEnabled = YES;
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        
        [self setupFalconIcon];
        [self setupMenu];
        [self showTab:@"WEAPON"];
    }
    return self;
}

- (void)setupFalconIcon {
    falconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    falconButton.frame = CGRectMake(20, 150, 55, 55);
    falconButton.backgroundColor = [UIColor blackColor];
    falconButton.layer.cornerRadius = 27.5;
    falconButton.layer.borderWidth = 1.5;
    falconButton.layer.borderColor = GOLD_COLOR.CGColor;
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

- (void)toggleMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self->menuView.alpha = (self->menuView.alpha == 0 ? 1 : 0);
    }];
}

- (void)setupMenu {
    menuView = [[UIView alloc] initWithFrame:CGRectMake(40, 100, 300, 480)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    menuView.layer.cornerRadius = 20;
    menuView.layer.borderWidth = 1;
    menuView.layer.borderColor = GOLD_COLOR.CGColor;
    menuView.alpha = 0;
    menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    [menuView addGestureRecognizer:pan];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 35)];
    title.text = @"✦ MUSTAFA VIP ✦";
    title.textColor = GOLD_COLOR;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [menuView addSubview:title];
    
    NSArray *tabs = @[@"⚔️ WEAPON", @"⛏️ MINING", @"🛡️ PLAYER", @"👁️ ESP"];
    for (int i = 0; i < tabs.count; i++) {
        UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        tabBtn.frame = CGRectMake(10 + (i * 70), 50, 65, 35);
        [tabBtn setTitle:tabs[i] forState:UIControlStateNormal];
        [tabBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        tabBtn.backgroundColor = [UIColor darkGrayColor];
        tabBtn.layer.cornerRadius = 5;
        tabBtn.tag = i;
        [tabBtn addTarget:self action:@selector(onTabClick:) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:tabBtn];
    }
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 280, 370)];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.userInteractionEnabled = YES;
    [menuView addSubview:contentView];
    
    [self addSubview:menuView];
}

- (void)moveMenu:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)onTabClick:(UIButton *)sender {
    NSArray *tabs = @[@"WEAPON", @"MINING", @"PLAYER", @"ESP"];
    if (sender.tag < tabs.count) {
        [self showTab:tabs[sender.tag]];
    }
}

- (void)clearContentView {
    for (UIView *sub in contentView.subviews) {
        [sub removeFromSuperview];
    }
}

- (void)showTab:(NSString *)tab {
    [self clearContentView];
    currentTab = tab;
    int y = 10;
    
    if ([tab isEqualToString:@"WEAPON"]) {
        magicBulletBtn = [self createButton:@"✨ Magic Bullet" y:y action:@selector(toggleMagicBullet)]; y += 50;
        oneHitKillBtn = [self createButton:@"💀 1 Hit Kill" y:y action:@selector(toggleOneHitKill)]; y += 50;
        infiniteAmmoBtn = [self createButton:@"🔫 Infinite Ammo" y:y action:@selector(toggleInfiniteAmmo)]; y += 50;
        rapidFireBtn = [self createButton:@"⚡ Rapid Fire" y:y action:@selector(toggleRapidFire)];
    }
    else if ([tab isEqualToString:@"MINING"]) {
        autoMineBtn = [self createButton:@"🤖 Auto Mine" y:y action:@selector(toggleAutoMine)];
    }
    else if ([tab isEqualToString:@"PLAYER"]) {
        godModeBtn = [self createButton:@"🛡️ God Mode" y:y action:@selector(toggleGodMode)]; y += 50;
        energyBtn = [self createButton:@"⚡ Energy" y:y action:@selector(toggleEnergy)]; y += 50;
        speedHackBtn = [self createButton:@"🏎️ Speed Hack" y:y action:@selector(toggleSpeedHack)];
    }
    else if ([tab isEqualToString:@"ESP"]) {
        espBoxBtn = [self createButton:@"📦 Player Box" y:y action:@selector(toggleEspBox)]; y += 50;
        espNameBtn = [self createButton:@"🏷️ Player Name" y:y action:@selector(toggleEspName)]; y += 50;
        espHealthBtn = [self createButton:@"❤️ Player Health" y:y action:@selector(toggleEspHealth)]; y += 50;
        espDistanceBtn = [self createButton:@"📏 Distance" y:y action:@selector(toggleEspDistance)];
    }
}

- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(15, y, 250, 42);
    btn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    btn.layer.cornerRadius = 8;
    [btn setTitle:[NSString stringWithFormat:@"%@ 🔴 OFF", title] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn];
    return btn;
}

- (void)updateButton:(UIButton *)btn isOn:(BOOL)isOn title:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *newTitle = [NSString stringWithFormat:@"%@ %@", title, (isOn ? @"🟢 ON" : @"🔴 OFF")];
        [btn setTitle:newTitle forState:UIControlStateNormal];
        [btn setTitleColor:(isOn ? [UIColor greenColor] : [UIColor redColor]) forState:UIControlStateNormal];
    });
}

// ========== Toggles ==========
- (void)toggleMagicBullet { isMagicBulletOn = !isMagicBulletOn; [self updateButton:magicBulletBtn isOn:isMagicBulletOn title:@"✨ Magic Bullet"]; }
- (void)toggleOneHitKill { isOneHitKillOn = !isOneHitKillOn; [self updateButton:oneHitKillBtn isOn:isOneHitKillOn title:@"💀 1 Hit Kill"]; }
- (void)toggleInfiniteAmmo { isInfiniteAmmoOn = !isInfiniteAmmoOn; [self updateButton:infiniteAmmoBtn isOn:isInfiniteAmmoOn title:@"🔫 Infinite Ammo"]; }
- (void)toggleRapidFire { isRapidFireOn = !isRapidFireOn; [self updateButton:rapidFireBtn isOn:isRapidFireOn title:@"⚡ Rapid Fire"]; }
- (void)toggleAutoMine { isAutoMineOn = !isAutoMineOn; [self updateButton:autoMineBtn isOn:isAutoMineOn title:@"🤖 Auto Mine"]; }
- (void)toggleGodMode { isGodModeOn = !isGodModeOn; [self updateButton:godModeBtn isOn:isGodModeOn title:@"🛡️ God Mode"]; }
- (void)toggleEnergy { isEnergyOn = !isEnergyOn; [self updateButton:energyBtn isOn:isEnergyOn title:@"⚡ Energy"]; }
- (void)toggleSpeedHack { isSpeedHackOn = !isSpeedHackOn; [self updateButton:speedHackBtn isOn:isSpeedHackOn title:@"🏎️ Speed Hack"]; }
- (void)toggleEspBox { isEspBoxOn = !isEspBoxOn; [self updateButton:espBoxBtn isOn:isEspBoxOn title:@"📦 Player Box"]; }
- (void)toggleEspName { isEspNameOn = !isEspNameOn; [self updateButton:espNameBtn isOn:isEspNameOn title:@"🏷️ Player Name"]; }
- (void)toggleEspHealth { isEspHealthOn = !isEspHealthOn; [self updateButton:espHealthBtn isOn:isEspHealthOn title:@"❤️ Player Health"]; }
- (void)toggleEspDistance { isEspDistanceOn = !isEspDistanceOn; [self updateButton:espDistanceBtn isOn:isEspDistanceOn title:@"📏 Distance"]; }

@end

// ========== Constructor ==========
__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MUSTAFA_Menu sharedMenu];
    });
}
