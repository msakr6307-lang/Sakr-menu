#import <UIKit/UIKit.h>

// تعريف المتغيرات عالمياً
static BOOL infAmmo = NO;
static BOOL fastMining = NO;
static BOOL stealthPort = NO;
static BOOL unlockMilitary = NO;

static UIView *mainMenu = nil;
static UIButton *menuIcon = nil;

@interface MustafaSupremeVIP : NSObject
@end

@implementation MustafaSupremeVIP
// تحريك الأيقونة
+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
// إظهار وإخفاء القائمة
+ (void)toggle {
    [UIView animateWithDuration:0.4 animations:^{
        mainMenu.alpha = (mainMenu.alpha == 0) ? 1 : 0;
    }];
}
// تفاعل الأزرار
+ (void)btnAction:(UIButton *)b {
    if (b.tag == 1) infAmmo = !infAmmo;
    if (b.tag == 2) fastMining = !fastMining;
    if (b.tag == 3) stealthPort = !stealthPort;
    if (b.tag == 4) unlockMilitary = !unlockMilitary;
    
    if (b.backgroundColor == [UIColor clearColor]) {
        b.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:0.7];
    } else {
        b.backgroundColor = [UIColor clearColor];
    }
}
@end

// ================== الهوكات المصححة بدقة ==================

%hook PlayerCombatComponent
- (int)get_currentAmmo { return infAmmo ? 999 : %orig; }
- (void)set_currentAmmo:(int)value { %orig(infAmmo ? 999 : value); }
- (BOOL)get_hasInfiniteAmmo { return infAmmo ? YES : %orig; }
%end

%hook MiningJobAction
- (float)get_miningDuration { return fastMining ? 0.05f : %orig; }
- (void)SetProgress:(float)p { %orig(fastMining ? 1.0f : p); }
%end

%hook InteractionSystem
- (float)get_InteractionDistance { 
    if (stealthPort || unlockMilitary) return 500.0f;
    return %orig; 
}
%end

%hook PlayerInteractionComponent
- (BOOL)CanInteractWithObject:(id)obj { 
    if (stealthPort || unlockMilitary) return YES; 
    return %orig; 
}
%end

%hook ZoneManager
- (BOOL)IsPlayerInRestrictedArea { 
    if (stealthPort || unlockMilitary) return NO; 
    return %orig; 
}
%end

%hook CrimeSystem
- (void)AddWantedStars:(int)count { 
    if (stealthPort || unlockMilitary) return; 
    %orig; 
}
%end

// ================== بناء الواجهة ==================

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    win = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!win) win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        menuIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        menuIcon.frame = CGRectMake(50, 150, 60, 60);
        [menuIcon setTitle:@"🦅" forState:UIControlStateNormal];
        menuIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        menuIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        menuIcon.layer.cornerRadius = 30;
        [menuIcon addTarget:[MustafaSupremeVIP class] action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [menuIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaSupremeVIP class] action:@selector(handlePan:)]];
        [win addSubview:menuIcon];

        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-130, win.frame.size.height/2-150, 260, 310)];
        mainMenu.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        mainMenu.layer.borderColor = [UIColor greenColor].CGColor;
        mainMenu.layer.borderWidth = 2;
        mainMenu.layer.cornerRadius = 15;
        mainMenu.alpha = 0;
        [win addSubview:mainMenu];

        NSArray *fNames = @[@"INF AMMO ♾️", @"FAST MINE ⛏️", @"REMOTE PORT 🚢", @"MILITARY 🪖"];
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(15, 60 + (i * 58), 230, 48);
            btn.tag = i + 1;
            [btn setTitle:fNames[i] forState:UIControlStateNormal];
            btn.layer.borderWidth = 1.0;
            btn.layer.borderColor = [UIColor greenColor].CGColor;
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:[MustafaSupremeVIP class] action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [mainMenu addSubview:btn];
        }
    });
}
