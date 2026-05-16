#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// ========== الأوفستات ==========
#define OFFSET_GET_PROGRESS         0x23F9764
#define OFFSET_SET_PROGRESS         0x23F976C
#define OFFSET_SEND_ATTACK          0x24CC8DC
#define OFFSET_BULLET_DAMAGE        0x38
#define OFFSET_FIRE_RATE            0x44
#define OFFSET_MAGAZINE_SIZE        0x3C
#define OFFSET_FIND_TARGET          0x24D1D54
#define OFFSET_TARGET_LOCK          0x2B291B0
#define OFFSET_SET_SPEED            0x2A6E8C8
#define OFFSET_SET_HEALTH           0x1C6A870

// ========== UIColor Gold ==========
@interface UIColor (Gold)
+ (UIColor *)goldColor;
@end

@implementation UIColor (Gold)
+ (UIColor *)goldColor {
    return [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];
}
@end

// ========== MUSTAFA VIP Menu ==========
@interface MUSTAFA_Menu : UIWindow {
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
@end

// ========== Hook Pointers ==========
typedef float (*_GetProgress)(void *self);
typedef void (*_SetProgress)(void *self, float value);
typedef void (*_SendAttack)(void *self);
typedef void* (*_FindTarget)(void *self);
typedef void (*_TargetLock)(void *self);
typedef void (*_SetSpeed)(void *self, float speed);
typedef void (*_SetHealth)(void *self, float health);

_GetProgress orig_get_progress = NULL;
_SetProgress orig_set_progress = NULL;
_SendAttack orig_send_attack = NULL;
_FindTarget orig_find_target = NULL;
_TargetLock orig_target_lock = NULL;
_SetSpeed orig_set_speed = NULL;
_SetHealth orig_set_health = NULL;

// ========== Hook Functions ==========
float hook_get_progress(void *self) { return 1.0f; }
void hook_set_progress(void *self, float value) { orig_set_progress(self, 1.0f); }

void hook_send_attack(void *self) {
    if (isMagicBulletOn && self) {
        *(float *)((uintptr_t)self + OFFSET_BULLET_DAMAGE) = 999999.0f;
        *(float *)((uintptr_t)self + OFFSET_FIRE_RATE) = 9999.0f;
        *(int *)((uintptr_t)self + OFFSET_MAGAZINE_SIZE) = 9999;
    }
    orig_send_attack(self);
}

void* hook_find_target(void *self) {
    if (!isAimbotOn) return orig_find_target(self);
    void *target = orig_find_target(self);
    if (target && orig_target_lock) orig_target_lock(self);
    return target;
}

void hook_set_speed(void *self, float speed) {
    if (isSpeedHackOn) orig_set_speed(self, speed * 10.0f);
    else orig_set_speed(self, speed);
}

void hook_set_health(void *self, float health) {
    if (isGodModeOn) orig_set_health(self, 999999.0f);
    else orig_set_health(self, health);
}

// ========== Install Hooks ==========
void installHooks() {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    MSHookFunction((void *)(base + OFFSET_GET_PROGRESS), (void *)&hook_get_progress, (void **)&orig_get_progress);
    MSHookFunction((void *)(base + OFFSET_SET_PROGRESS), (void *)&hook_set_progress, (void **)&orig_set_progress);
    MSHookFunction((void *)(base + OFFSET_SEND_ATTACK), (void *)&hook_send_attack, (void **)&orig_send_attack);
    MSHookFunction((void *)(base + OFFSET_FIND_TARGET), (void *)&hook_find_target, (void **)&orig_find_target);
    MSHookFunction((void *)(base + OFFSET_SET_SPEED), (void *)&hook_set_speed, (void **)&orig_set_speed);
    MSHookFunction((void *)(base + OFFSET_SET_HEALTH), (void *)&hook_set_health, (void **)&orig_set_health);
    
    NSLog(@"[MUSTAFA VIP] Hooks installed!");
}

// ========== Menu Implementation ==========
@implementation MUSTAFA_Menu

+ (instancetype)sharedMenu {
    static MUSTAFA_Menu *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        [self setupFalconIcon];
        [self setupMenu];
        installHooks();
    }
    return self;
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
    pan.cancelsTouchesInView = NO;
    [falconButton addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    tap.cancelsTouchesInView = NO;
    [falconButton addGestureRecognizer:tap];
    
    [self addSubview:falconButton];
}

- (void)moveFalcon:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)setupMenu {
    menuView = [[UIView alloc] initWithFrame:CGRectMake(80, 100, 280, 520)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    menuView.layer.cornerRadius = 20;
    menuView.layer.borderWidth = 1.5;
    menuView.layer.borderColor = [UIColor goldColor].CGColor;
    menuView.alpha = 0;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    pan.cancelsTouchesInView = NO;
    [menuView addGestureRecognizer:pan];
    
    goldTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 35)];
    goldTitle.text = @"✦ MUSTAFA VIP ✦";
    goldTitle.textColor = [UIColor goldColor];
    goldTitle.textAlignment = NSTextAlignmentCenter;
    goldTitle.font = [UIFont boldSystemFontOfSize:20];
    [menuView addSubview:goldTitle];
    
    CGFloat y = 65;
    CGFloat step = 55;
    
    autoMineBtn = [self createButton:@"⛏️ Auto Mine" y:y action:@selector(toggleAutoMine)];
    magicBulletBtn = [self createButton:@"🔮 Magic Bullet" y:y+step action:@selector(toggleMagicBullet)];
    aimbotBtn = [self createButton:@"🎯 Aimbot" y:y+step*2 action:@selector(toggleAimbot)];
    
    [menuView addSubview:autoMineBtn];
    [menuView addSubview:magicBulletBtn];
    [menuView addSubview:aimbotBtn];
    
    fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, y+step*3, 250, 30)];
    fovSlider.minimumValue = 40;
    fovSlider.maximumValue = 200;
    fovSlider.value = 100;
    fovSlider.tintColor = [UIColor goldColor];
    [menuView addSubview:fovSlider];
    
    hitLocationSegment = [[UISegmentedControl alloc] initWithItems:@[@"Head", @"Body"]];
    hitLocationSegment.frame = CGRectMake(15, y+step*3.8, 250, 30);
    hitLocationSegment.selectedSegmentIndex = 0;
    [menuView addSubview:hitLocationSegment];
    
    speedHackBtn = [self createButton:@"🏎️ Speed Hack" y:y+step*4.6 action:@selector(toggleSpeedHack)];
    godModeBtn = [self createButton:@"🛡️ God Mode" y:y+step*5.3 action:@selector(toggleGodMode)];
    espBtn = [self createButton:@"👁️ ESP" y:y+step*6 action:@selector(toggleESP)];
    
    [menuView addSubview:speedHackBtn];
    [menuView addSubview:godModeBtn];
    [menuView addSubview:espBtn];
    
    [self addSubview:menuView];
}

- (UIButton *)createButton:(NSString *)title y:(CGFloat)y action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(15, y, 250, 42);
    btn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    btn.layer.cornerRadius = 10;
    [btn setTitle:[NSString stringWithFormat:@"%@ 🔴 OFF", title] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)moveMenu:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
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

- (void)toggleAutoMine { isAutoMineOn = !isAutoMineOn; [self updateButton:autoMineBtn isOn:isAutoMineOn title:@"⛏️ Auto Mine"]; }
- (void)toggleMagicBullet { isMagicBulletOn = !isMagicBulletOn; [self updateButton:magicBulletBtn isOn:isMagicBulletOn title:@"🔮 Magic Bullet"]; }
- (void)toggleAimbot { isAimbotOn = !isAimbotOn; [self updateButton:aimbotBtn isOn:isAimbotOn title:@"🎯 Aimbot"]; }
- (void)toggleSpeedHack { isSpeedHackOn = !isSpeedHackOn; [self updateButton:speedHackBtn isOn:isSpeedHackOn title:@"🏎️ Speed Hack"]; }
- (void)toggleGodMode { isGodModeOn = !isGodModeOn; [self updateButton:godModeBtn isOn:isGodModeOn title:@"🛡️ God Mode"]; }
- (void)toggleESP { isEspOn = !isEspOn; [self updateButton:espBtn isOn:isEspOn title:@"👁️ ESP"]; }

@end

// ========== Constructor ==========
__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MUSTAFA_Menu sharedMenu];
    });
}
