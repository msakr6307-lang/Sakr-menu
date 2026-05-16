#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// ========== Offsets ==========
#define OFFSET_GET_PROGRESS         0x23F9764
#define OFFSET_SET_PROGRESS         0x23F976C
#define OFFSET_SEND_ATTACK          0x24CC8DC
#define OFFSET_BULLET_DAMAGE        0x38
#define OFFSET_FIRE_RATE            0x44
#define OFFSET_MAGAZINE_SIZE        0x3C
#define OFFSET_FIND_TARGET          0x24D1D54
#define OFFSET_TARGET_LOCK          0x2B291B0
#define OFFSET_SET_SPEED            0x2A6E8C8
#define OFFSET_SET_MAX_SPEED        0x31BA1AC
#define OFFSET_SET_HEALTH           0x1C6A870
#define OFFSET_GET_HEALTH           0x1C6A868
#define OFFSET_WORLD_TO_SCREEN      0x3F36970
#define OFFSET_GET_POSITION         0x2A501B4

// ========== Hook Pointers ==========
static float (*orig_get_progress)(void *self);
static void (*orig_set_progress)(void *self, float value);
static void (*orig_send_attack)(void *self);
static void* (*orig_find_target)(void *self);
static void (*orig_target_lock)(void *self);
static void (*orig_set_speed)(void *self, float speed);
static void (*orig_set_health)(void *self, float health);
static float (*orig_get_health)(void *self);

// ========== Global Flags ==========
static BOOL isAutoMineOn = NO;
static BOOL isMagicBulletOn = NO;
static BOOL isOneHitKillOn = NO;
static BOOL isInfiniteAmmoOn = NO;
static BOOL isRapidFireOn = NO;
static BOOL isAimbotOn = NO;
static BOOL isSpeedHackOn = NO;
static BOOL isGodModeOn = NO;
static BOOL isEspOn = NO;
static BOOL isFOVOn = NO;

// ========== FOV Helper ==========
static UIView *fovCircle = nil;
static UISlider *fovSlider = nil;
static UIWindow *mainWindow = nil;

BOOL IsPointInFOV(CGPoint point) {
    if (!isFOVOn || !fovCircle) return YES;
    CGFloat radius = fovCircle.frame.size.width / 2;
    CGFloat centerX = [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat centerY = [UIScreen mainScreen].bounds.size.height / 2;
    CGFloat dx = point.x - centerX;
    CGFloat dy = point.y - centerY;
    CGFloat distance = sqrt(dx*dx + dy*dy);
    return distance <= radius;
}

// ========== Hook Functions ==========
float hook_get_progress(void *self) { 
    if (isAutoMineOn) return 1.0f;
    return orig_get_progress(self);
}

void hook_set_progress(void *self, float value) { 
    if (isAutoMineOn) {
        orig_set_progress(self, 1.0f);
    } else {
        orig_set_progress(self, value);
    }
}

void hook_send_attack(void *self) {
    if ((isMagicBulletOn || isOneHitKillOn) && self) {
        *(float *)((uintptr_t)self + OFFSET_BULLET_DAMAGE) = 999999.0f;
    }
    if ((isMagicBulletOn || isInfiniteAmmoOn) && self) {
        *(int *)((uintptr_t)self + OFFSET_MAGAZINE_SIZE) = 9999;
    }
    if ((isMagicBulletOn || isRapidFireOn) && self) {
        *(float *)((uintptr_t)self + OFFSET_FIRE_RATE) = 9999.0f;
    }
    if (orig_send_attack) orig_send_attack(self);
}

void* hook_find_target(void *self) {
    if (!isAimbotOn) return orig_find_target(self);
    void *target = orig_find_target(self);
    if (target && orig_target_lock) {
        orig_target_lock(self);
    }
    return target;
}

void hook_set_speed(void *self, float speed) {
    if (isSpeedHackOn) {
        orig_set_speed(self, speed * 10.0f);
    } else {
        orig_set_speed(self, speed);
    }
}

void hook_set_health(void *self, float health) {
    if (isGodModeOn) {
        orig_set_health(self, 999999.0f);
    } else {
        orig_set_health(self, health);
    }
}

float hook_get_health(void *self) {
    if (isGodModeOn) return 999999.0f;
    return orig_get_health(self);
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
    UIButton *oneHitKillBtn;
    UIButton *infiniteAmmoBtn;
    UIButton *rapidFireBtn;
    UIButton *aimbotBtn;
    UIButton *speedHackBtn;
    UIButton *godModeBtn;
    UIButton *espBtn;
    UIButton *fovToggleBtn;
}

+ (instancetype)sharedMenu;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupFalconIcon;
- (void)setupMenu;
- (void)setupFOVCircle;
- (void)moveFalcon:(UIPanGestureRecognizer *)sender;
- (void)moveMenu:(UIPanGestureRecognizer *)sender;
- (void)toggleMenu;
- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action;
- (void)updateButton:(UIButton *)button isOn:(BOOL)isOn title:(NSString *)title;
- (void)installHooks;

- (void)toggleAutoMine;
- (void)toggleMagicBullet;
- (void)toggleOneHitKill;
- (void)toggleInfiniteAmmo;
- (void)toggleRapidFire;
- (void)toggleAimbot;
- (void)toggleSpeedHack;
- (void)toggleGodMode;
- (void)toggleESP;
- (void)toggleFOV;
- (void)changeFOV:(UISlider *)slider;

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
        mainWindow = self;
        [self setupFalconIcon];
        [self setupMenu];
        [self setupFOVCircle];
        [self installHooks];
    }
    return self;
}

- (void)installHooks {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    MSHookFunction((void *)(base + OFFSET_GET_PROGRESS), (void *)&hook_get_progress, (void **)&orig_get_progress);
    MSHookFunction((void *)(base + OFFSET_SET_PROGRESS), (void *)&hook_set_progress, (void **)&orig_set_progress);
    MSHookFunction((void *)(base + OFFSET_SEND_ATTACK), (void *)&hook_send_attack, (void **)&orig_send_attack);
    MSHookFunction((void *)(base + OFFSET_FIND_TARGET), (void *)&hook_find_target, (void **)&orig_find_target);
    MSHookFunction((void *)(base + OFFSET_SET_SPEED), (void *)&hook_set_speed, (void **)&orig_set_speed);
    MSHookFunction((void *)(base + OFFSET_SET_HEALTH), (void *)&hook_set_health, (void **)&orig_set_health);
    MSHookFunction((void *)(base + OFFSET_GET_HEALTH), (void *)&hook_get_health, (void **)&orig_get_health);
    
    NSLog(@"[SakrMenu] All hooks installed!");
}

- (void)setupFOVCircle {
    fovCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    fovCircle.center = self.center;
    fovCircle.backgroundColor = [UIColor clearColor];
    fovCircle.layer.borderColor = [UIColor cyanColor].CGColor;
    fovCircle.layer.borderWidth = 2;
    fovCircle.layer.cornerRadius = 50;
    fovCircle.hidden = YES;
    [self addSubview:fovCircle];
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
    menuView = [[UIView alloc] initWithFrame:CGRectMake(60, 100, 280, 620)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.95];
    menuView.layer.cornerRadius = 20;
    menuView.layer.borderWidth = 1.5;
    menuView.layer.borderColor = [UIColor goldColor].CGColor;
    menuView.alpha = 0;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    [menuView addGestureRecognizer:pan];
    
    goldTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 35)];
    goldTitle.text = @"✦ SAKR MENU VIP ✦";
    goldTitle.textColor = [UIColor goldColor];
    goldTitle.textAlignment = NSTextAlignmentCenter;
    goldTitle.font = [UIFont boldSystemFontOfSize:18];
    [menuView addSubview:goldTitle];
    
    CGFloat y = 65;
    CGFloat step = 48;
    
    // ========== MINING ==========
    UILabel *miningTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    miningTitle.text = @"⛏️ MINING";
    miningTitle.textColor = [UIColor goldColor];
    miningTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:miningTitle];
    y += 28;
    
    autoMineBtn = [self createButton:@"🤖 Auto Mine" y:y action:@selector(toggleAutoMine)];
    [menuView addSubview:autoMineBtn];
    y += step;
    
    // ========== WEAPON ==========
    UILabel *weaponTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    weaponTitle.text = @"🔫 WEAPON";
    weaponTitle.textColor = [UIColor goldColor];
    weaponTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:weaponTitle];
    y += 28;
    
    magicBulletBtn = [self createButton:@"✨ Magic Bullet" y:y action:@selector(toggleMagicBullet)];
    [menuView addSubview:magicBulletBtn];
    y += step;
    
    oneHitKillBtn = [self createButton:@"💀 1 Hit Kill" y:y action:@selector(toggleOneHitKill)];
    [menuView addSubview:oneHitKillBtn];
    y += step;
    
    infiniteAmmoBtn = [self createButton:@"🔫 Infinite Ammo" y:y action:@selector(toggleInfiniteAmmo)];
    [menuView addSubview:infiniteAmmoBtn];
    y += step;
    
    rapidFireBtn = [self createButton:@"⚡ Rapid Fire" y:y action:@selector(toggleRapidFire)];
    [menuView addSubview:rapidFireBtn];
    y += step;
    
    // ========== COMBAT (Aimbot + FOV together) ==========
    UILabel *combatTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    combatTitle.text = @"⚔️ COMBAT";
    combatTitle.textColor = [UIColor goldColor];
    combatTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:combatTitle];
    y += 28;
    
    aimbotBtn = [self createButton:@"🎯 Aimbot" y:y action:@selector(toggleAimbot)];
    [menuView addSubview:aimbotBtn];
    y += 45;
    
    fovToggleBtn = [self createButton:@"🔘 FOV Circle" y:y action:@selector(toggleFOV)];
    [menuView addSubview:fovToggleBtn];
    y += 40;
    
    UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 80, 25)];
    fovLabel.text = @"FOV Size";
    fovLabel.textColor = [UIColor lightGrayColor];
    fovLabel.font = [UIFont systemFontOfSize:12];
    [menuView addSubview:fovLabel];
    
    fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(95, y, 170, 25)];
    fovSlider.minimumValue = 40;
    fovSlider.maximumValue = 200;
    fovSlider.value = 100;
    fovSlider.tintColor = [UIColor goldColor];
    [fovSlider addTarget:self action:@selector(changeFOV:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:fovSlider];
    y += step;
    
    // ========== VEHICLE ==========
    UILabel *vehicleTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    vehicleTitle.text = @"🏎️ VEHICLE";
    vehicleTitle.textColor = [UIColor goldColor];
    vehicleTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:vehicleTitle];
    y += 28;
    
    speedHackBtn = [self createButton:@"🚗 Speed Hack" y:y action:@selector(toggleSpeedHack)];
    [menuView addSubview:speedHackBtn];
    y += step;
    
    // ========== PLAYER ==========
    UILabel *playerTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    playerTitle.text = @"🛡️ PLAYER";
    playerTitle.textColor = [UIColor goldColor];
    playerTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:playerTitle];
    y += 28;
    
    godModeBtn = [self createButton:@"💚 God Mode" y:y action:@selector(toggleGodMode)];
    [menuView addSubview:godModeBtn];
    y += step;
    
    // ========== ESP ==========
    UILabel *espTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
    espTitle.text = @"👁️ ESP";
    espTitle.textColor = [UIColor goldColor];
    espTitle.font = [UIFont boldSystemFontOfSize:15];
    [menuView addSubview:espTitle];
    y += 28;
    
    espBtn = [self createButton:@"📡 ESP" y:y action:@selector(toggleESP)];
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
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
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

// ========== Actions ==========
- (void)toggleAutoMine { isAutoMineOn = !isAutoMineOn; [self updateButton:autoMineBtn isOn:isAutoMineOn title:@"🤖 Auto Mine"]; }
- (void)toggleMagicBullet { isMagicBulletOn = !isMagicBulletOn; [self updateButton:magicBulletBtn isOn:isMagicBulletOn title:@"✨ Magic Bullet"]; }
- (void)toggleOneHitKill { isOneHitKillOn = !isOneHitKillOn; [self updateButton:oneHitKillBtn isOn:isOneHitKillOn title:@"💀 1 Hit Kill"]; }
- (void)toggleInfiniteAmmo { isInfiniteAmmoOn = !isInfiniteAmmoOn; [self updateButton:infiniteAmmoBtn isOn:isInfiniteAmmoOn title:@"🔫 Infinite Ammo"]; }
- (void)toggleRapidFire { isRapidFireOn = !isRapidFireOn; [self updateButton:rapidFireBtn isOn:isRapidFireOn title:@"⚡ Rapid Fire"]; }
- (void)toggleAimbot { isAimbotOn = !isAimbotOn; [self updateButton:aimbotBtn isOn:isAimbotOn title:@"🎯 Aimbot"]; }
- (void)toggleSpeedHack { isSpeedHackOn = !isSpeedHackOn; [self updateButton:speedHackBtn isOn:isSpeedHackOn title:@"🚗 Speed Hack"]; }
- (void)toggleGodMode { isGodModeOn = !isGodModeOn; [self updateButton:godModeBtn isOn:isGodModeOn title:@"💚 God Mode"]; }
- (void)toggleESP { isEspOn = !isEspOn; [self updateButton:espBtn isOn:isEspOn title:@"📡 ESP"]; }
- (void)toggleFOV { 
    isFOVOn = !isFOVOn; 
    fovCircle.hidden = !isFOVOn;
}
- (void)changeFOV:(UISlider *)slider {
    CGFloat radius = slider.value;
    fovCircle.frame = CGRectMake(0, 0, radius, radius);
    fovCircle.center = self.center;
    fovCircle.layer.cornerRadius = radius / 2;
}

@end

// ========== Constructor ==========
__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SakrMenu sharedMenu];
    });
}
