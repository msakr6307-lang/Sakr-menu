#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>
#import <mach-o/dyld.h>
#import <substrate.h>

#define GOLD_COLOR [UIColor colorWithRed:1.0 green:0.84 blue:0 alpha:1.0]

// ========== Offsets ==========
#define OFFSET_GET_PROGRESS         0x23F9764
#define OFFSET_SET_PROGRESS         0x23F976C
#define OFFSET_SEND_ATTACK          0x24CC8DC
#define OFFSET_BULLET_DAMAGE        0x38
#define OFFSET_FIRE_RATE            0x44
#define OFFSET_MAGAZINE_SIZE        0x3C
#define OFFSET_SET_SPEED            0x2A6E8C8
#define OFFSET_SET_HEALTH           0x1C6A870
#define OFFSET_SET_ENERGY           0x1D881F8
#define OFFSET_FIND_TARGET          0x21A84C0
#define OFFSET_GET_CLOSEST_PLAYER   0x21A8A10
#define OFFSET_SET_TARGET           0x21A8618
#define OFFSET_LOCK_TARGET          0x21A8C40

// ========== Flags ==========
static BOOL isMagicBulletOn = NO;
static BOOL isOneHitKillOn = NO;
static BOOL isInfiniteAmmoOn = NO;
static BOOL isRapidFireOn = NO;
static BOOL isAutoMineOn = NO;
static BOOL isGodModeOn = NO;
static BOOL isEnergyOn = NO;
static BOOL isSpeedHackOn = NO;
static BOOL isAimbotOn = NO;
static BOOL isFOVOn = NO;
static BOOL isHeadshot = YES;  // YES = Head, NO = Body

// ========== FOV Circle ==========
static UIView *fovCircle = nil;
static UISlider *fovSlider = nil;

// ========== Hook Pointers ==========
static float (*orig_get_progress)(void *self);
static void (*orig_set_progress)(void *self, float value);
static void (*orig_send_attack)(void *self);
static void (*orig_set_speed)(void *self, float speed);
static void (*orig_set_health)(void *self, float health);
static void (*orig_set_energy)(void *self, float value);
static void* (*orig_find_target)(void *self);
static void* (*orig_get_closest_player)(void *self);
static void (*orig_set_target)(void *self, void *target);
static void (*orig_lock_target)(void *self, void *target);

// ========== Hook Functions ==========
float hook_get_progress(void *self) {
    if (!orig_get_progress) return 0.0f;
    return (isAutoMineOn) ? 1.0f : orig_get_progress(self);
}

void hook_set_progress(void *self, float v) {
    if (!orig_set_progress) return;
    orig_set_progress(self, (isAutoMineOn) ? 1.0f : v);
}

void hook_send_attack(void *self) {
    if (!orig_send_attack) return;
    
    if ((isMagicBulletOn || isOneHitKillOn) && self) {
        *(float *)((uintptr_t)self + OFFSET_BULLET_DAMAGE) = 15000.0f;
    }
    if ((isMagicBulletOn || isInfiniteAmmoOn) && self) {
        *(int *)((uintptr_t)self + OFFSET_MAGAZINE_SIZE) = 9999;
    }
    if ((isMagicBulletOn || isRapidFireOn) && self) {
        *(float *)((uintptr_t)self + OFFSET_FIRE_RATE) = 1500.0f;
    }
    orig_send_attack(self);
}

void* hook_find_target(void *self) {
    if (!orig_find_target) return NULL;
    if (!isAimbotOn) return orig_find_target(self);
    
    void *target = orig_find_target(self);
    return target;
}

void* hook_get_closest_player(void *self) {
    if (!orig_get_closest_player) return NULL;
    void *target = orig_get_closest_player(self);
    
    if (isAimbotOn && target) {
        if (orig_lock_target) orig_lock_target(self, target);
        if (orig_set_target) orig_set_target(self, target);
    }
    return target;
}

void hook_set_target(void *self, void *target) {
    if (!orig_set_target) return;
    orig_set_target(self, target);
}

void hook_lock_target(void *self, void *target) {
    if (!orig_lock_target) return;
    if (isAimbotOn && target) {
        orig_lock_target(self, target);
    } else {
        orig_lock_target(self, target);
    }
}

void hook_set_speed(void *self, float speed) {
    if (!orig_set_speed) return;
    orig_set_speed(self, (isSpeedHackOn) ? speed * 2.5f : speed);
}

void hook_set_health(void *self, float health) {
    if (!orig_set_health) return;
    orig_set_health(self, (isGodModeOn) ? 15000.0f : health);
}

void hook_set_energy(void *self, float value) {
    if (!orig_set_energy) return;
    orig_set_energy(self, (isEnergyOn) ? 15000.0f : value);
}

// ========== Get Real Base Address with ASLR Slide ==========
uintptr_t getBaseAddress() {
    uint32_t count = _dyld_image_count();
    const char *targetImage = "OneStateRP";
    
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, targetImage)) {
            uintptr_t header = (uintptr_t)_dyld_get_image_header(i);
            intptr_t slide = _dyld_get_image_vmaddr_slide(i);
            return header + slide;
        }
    }
    
    // Fallback: use first image with its slide
    uintptr_t header = (uintptr_t)_dyld_get_image_header(0);
    intptr_t slide = _dyld_get_image_vmaddr_slide(0);
    return header + slide;
}

// ========== Install Hooks ==========
void installHooks() {
    uintptr_t base = getBaseAddress();
    if (!base) {
        base = (uintptr_t)_dyld_get_image_header(0) + _dyld_get_image_vmaddr_slide(0);
    }
    
    MSHookFunction((void *)(base + OFFSET_GET_PROGRESS), (void *)&hook_get_progress, (void **)&orig_get_progress);
    MSHookFunction((void *)(base + OFFSET_SET_PROGRESS), (void *)&hook_set_progress, (void **)&orig_set_progress);
    MSHookFunction((void *)(base + OFFSET_SEND_ATTACK), (void *)&hook_send_attack, (void **)&orig_send_attack);
    MSHookFunction((void *)(base + OFFSET_FIND_TARGET), (void *)&hook_find_target, (void **)&orig_find_target);
    MSHookFunction((void *)(base + OFFSET_SET_SPEED), (void *)&hook_set_speed, (void **)&orig_set_speed);
    MSHookFunction((void *)(base + OFFSET_SET_HEALTH), (void *)&hook_set_health, (void **)&orig_set_health);
    MSHookFunction((void *)(base + OFFSET_SET_ENERGY), (void *)&hook_set_energy, (void **)&orig_set_energy);
    
    // Correct hook for get_closest_player using its own function
    void *closestAddr = (void *)(base + OFFSET_GET_CLOSEST_PLAYER);
    if (closestAddr) {
        MSHookFunction(closestAddr, (void *)&hook_get_closest_player, (void **)&orig_get_closest_player);
    }
    
    void *setTargetAddr = (void *)(base + OFFSET_SET_TARGET);
    if (setTargetAddr) {
        MSHookFunction(setTargetAddr, (void *)&hook_set_target, (void **)&orig_set_target);
    }
    
    void *lockTargetAddr = (void *)(base + OFFSET_LOCK_TARGET);
    if (lockTargetAddr) {
        MSHookFunction(lockTargetAddr, (void *)&hook_lock_target, (void **)&orig_lock_target);
    }
    
    NSLog(@"[MUSTAFA] All hooks installed successfully! Base: 0x%lx", base);
}

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
    UIButton *aimbotBtn;
    UIButton *fovToggleBtn;
    UISegmentedControl *hitLocationSegment;
    
    NSString *currentTab;
}

+ (instancetype)sharedMenu;
- (void)setupFalconIcon;
- (void)setupMenu;
- (void)setupFOV;
- (void)showTab:(NSString *)tab;
- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action;
- (void)updateButton:(UIButton *)btn isOn:(BOOL)isOn title:(NSString *)title;
- (void)clearContentView;
- (void)changeHitLocation:(UISegmentedControl *)segment;
- (void)toggleMagicBullet;
- (void)toggleOneHitKill;
- (void)toggleInfiniteAmmo;
- (void)toggleRapidFire;
- (void)toggleAutoMine;
- (void)toggleGodMode;
- (void)toggleEnergy;
- (void)toggleSpeedHack;
- (void)toggleAimbot;
- (void)toggleFOV;
- (void)changeFOV:(UISlider *)slider;

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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self || view == nil) {
        return nil;
    }
    
    if ([view isDescendantOfView:menuView] || view == falconButton || [view isDescendantOfView:falconButton]) {
        return view;
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        self.hidden = NO;
        
        UIViewController *dummyVC = [[UIViewController alloc] init];
        dummyVC.view.backgroundColor = [UIColor clearColor];
        self.rootViewController = dummyVC;
        
        [self setHidden:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self setupFalconIcon];
            [self setupMenu];
            [self setupFOV];
            [self showTab:@"WEAPON"];
        });
        
        installHooks();
    }
    return self;
}

- (void)setupFOV {
    fovCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    fovCircle.center = self.center;
    fovCircle.backgroundColor = [UIColor clearColor];
    fovCircle.layer.borderColor = [UIColor cyanColor].CGColor;
    fovCircle.layer.borderWidth = 2;
    fovCircle.layer.cornerRadius = 50;
    fovCircle.hidden = YES;
    fovCircle.userInteractionEnabled = NO;
    [self addSubview:fovCircle];
}

- (void)setupFalconIcon {
    falconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    falconButton.frame = CGRectMake(20, 150, 55, 55);
    falconButton.backgroundColor = [UIColor blackColor];
    falconButton.layer.cornerRadius = 27.5;
    falconButton.layer.borderWidth = 1.5;
    falconButton.layer.borderColor = GOLD_COLOR.CGColor;
    falconButton.layer.shouldRasterize = YES;
    falconButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [falconButton setTitle:@"🦅" forState:UIControlStateNormal];
    falconButton.titleLabel.font = [UIFont systemFontOfSize:28];
    falconButton.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveFalcon:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;
    [falconButton addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    tap.cancelsTouchesInView = NO;
    [tap requireGestureRecognizerToFail:pan];
    [falconButton addGestureRecognizer:tap];
    
    [self addSubview:falconButton];
    [self bringSubviewToFront:falconButton];
}

- (void)moveFalcon:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self];
        sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
        [sender setTranslation:CGPointZero inView:self];
    }
}

- (void)toggleMenu {
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self->menuView.alpha = (self->menuView.alpha == 0 ? 1 : 0);
        [self bringSubviewToFront:self->menuView];
    } completion:nil];
}

- (void)setupMenu {
    menuView = [[UIView alloc] initWithFrame:CGRectMake(40, 100, 300, 520)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    menuView.layer.cornerRadius = 20;
    menuView.clipsToBounds = YES;
    menuView.layer.borderWidth = 1;
    menuView.layer.borderColor = GOLD_COLOR.CGColor;
    menuView.layer.shouldRasterize = YES;
    menuView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    menuView.alpha = 0;
    menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;
    [menuView addGestureRecognizer:pan];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 35)];
    title.text = @"✦ MUSTAFA VIP ✦";
    title.textColor = GOLD_COLOR;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    title.userInteractionEnabled = NO;
    [menuView addSubview:title];
    
    NSArray *tabs = @[@"⚔️ WEAPON", @"⛏️ MINING", @"🛡️ PLAYER", @"🎯 AIMBOT"];
    for (int i = 0; i < tabs.count; i++) {
        UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        tabBtn.frame = CGRectMake(10 + (i * 70), 50, 65, 35);
        tabBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [tabBtn setTitle:tabs[i] forState:UIControlStateNormal];
        [tabBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        tabBtn.backgroundColor = [UIColor darkGrayColor];
        tabBtn.layer.cornerRadius = 5;
        tabBtn.tag = i;
        tabBtn.userInteractionEnabled = YES;
        [tabBtn addTarget:self action:@selector(onTabClick:) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:tabBtn];
    }
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 280, 400)];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.userInteractionEnabled = YES;
    [menuView addSubview:contentView];
    
    [self addSubview:menuView];
}

- (void)moveMenu:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self];
        sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
        [sender setTranslation:CGPointZero inView:self];
    }
}

- (void)onTabClick:(UIButton *)sender {
    NSArray *tabs = @[@"WEAPON", @"MINING", @"PLAYER", @"AIMBOT"];
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
    else if ([tab isEqualToString:@"AIMBOT"]) {
        aimbotBtn = [self createButton:@"🎯 Aimbot" y:y action:@selector(toggleAimbot)]; y += 50;
        fovToggleBtn = [self createButton:@"🔘 FOV Circle" y:y action:@selector(toggleFOV)]; y += 50;
        
        UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 80, 25)];
        fovLabel.text = @"FOV Size";
        fovLabel.textColor = [UIColor lightGrayColor];
        fovLabel.font = [UIFont systemFontOfSize:12];
        fovLabel.userInteractionEnabled = NO;
        [contentView addSubview:fovLabel];
        
        fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(95, y, 170, 25)];
        fovSlider.minimumValue = 40;
        fovSlider.maximumValue = 200;
        fovSlider.value = 100;
        fovSlider.tintColor = GOLD_COLOR;
        fovSlider.userInteractionEnabled = YES;
        [fovSlider addTarget:self action:@selector(changeFOV:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:fovSlider];
        y += 50;
        
        // Hit Location Segment (Head / Body)
        UILabel *hitLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
        hitLabel.text = @"🎯 Hit Location";
        hitLabel.textColor = [UIColor lightGrayColor];
        hitLabel.font = [UIFont systemFontOfSize:13];
        hitLabel.userInteractionEnabled = NO;
        [contentView addSubview:hitLabel];
        
        hitLocationSegment = [[UISegmentedControl alloc] initWithItems:@[@"Head", @"Body"]];
        hitLocationSegment.frame = CGRectMake(120, y, 145, 30);
        hitLocationSegment.selectedSegmentIndex = 0;
        hitLocationSegment.selectedSegmentTintColor = GOLD_COLOR;
        hitLocationSegment.userInteractionEnabled = YES;
        [hitLocationSegment addTarget:self action:@selector(changeHitLocation:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:hitLocationSegment];
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
    btn.userInteractionEnabled = YES;
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

- (void)changeHitLocation:(UISegmentedControl *)segment {
    isHeadshot = (segment.selectedSegmentIndex == 0);
    NSLog(@"[MUSTAFA] Hit location changed to: %@", isHeadshot ? @"HEAD" : @"BODY");
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
- (void)toggleAimbot { isAimbotOn = !isAimbotOn; [self updateButton:aimbotBtn isOn:isAimbotOn title:@"🎯 Aimbot"]; }
- (void)toggleFOV { isFOVOn = !isFOVOn; fovCircle.hidden = !isFOVOn; [self updateButton:fovToggleBtn isOn:isFOVOn title:@"🔘 FOV Circle"]; }
- (void)changeFOV:(UISlider *)slider { CGFloat r = slider.value; fovCircle.frame = CGRectMake(0, 0, r, r); fovCircle.center = self.center; fovCircle.layer.cornerRadius = r / 2; }

@end

// ========== Constructor ==========
__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MUSTAFA_Menu sharedMenu];
    });
}
