#import <UIKit/UIKit.h>

// --- متغيرات التحكم بالقيم (المفاتيح) ---
static BOOL infAmmo = NO;
static BOOL fastMining = NO;
static BOOL stealthPort = NO;
static BOOL unlockMilitary = NO;

static UIView *mainMenu = nil;
static UIButton *menuIcon = nil;

@interface MustafaSupremeVIP : NSObject
@end

@implementation MustafaSupremeVIP

// --- نظام تحريك الأيقونة بسلاسة ---
+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

// --- إظهار وإخفاء القائمة بأنيميشن احترافي ---
+ (void)toggle {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        if (mainMenu.alpha == 0) {
            mainMenu.alpha = 1;
            mainMenu.transform = CGAffineTransformIdentity;
        } else {
            mainMenu.alpha = 0;
            mainMenu.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }
    } completion:nil];
}

// --- معالج أزرار المميزات ---
+ (void)btnAction:(UIButton *)b {
    if (b.tag == 1) infAmmo = !infAmmo;
    if (b.tag == 2) fastMining = !fastMining;
    if (b.tag == 3) stealthPort = !stealthPort;
    if (b.tag == 4) unlockMilitary = !unlockMilitary;

    // تغيير اللون للتوضيح (أخضر عند التفعيل)
    if (b.backgroundColor == [UIColor clearColor]) {
        [b setBackgroundColor:[UIColor colorWithRed:0.0 green:0.8 blue:0.4 alpha:0.7]];
        b.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        [b setBackgroundColor:[UIColor clearColor]];
        b.layer.borderColor = [UIColor greenColor].CGColor;
    }
}
@end

// ==========================================
// --- هوكات ليفل الوحش (البرمجة العميقة) ---
// ==========================================

// 1. الطلق اللانهائي (Infinite Ammo)
%hook PlayerCombatComponent
-(int)get_currentAmmo { return infAmmo ? 999 : %orig; }
-(void)set_currentAmmo:(int)value { %orig(infAmmo ? 999 : value); }
-(BOOL)get_hasInfiniteAmmo { return infAmmo ? YES : %orig; }
%end

// 2. عامل المنجم الخارق (Fast Mining)
%hook MiningJobAction
-(float)get_miningDuration { return fastMining ? 0.05f : %orig; } // تجميع فوري
-(void)SetProgress(float p) { %orig(fastMining ? 1.0f : p); }
%end

// 3. المدى الخارق (السرقة عن بُعد - Range Hack)
// دي الميزة اللي طلبتها: بتخليك تلم الحاجات وأنت بعيد عنها
%hook InteractionSystem
-(float)get_InteractionDistance { 
    return (stealthPort || unlockMilitary) ? 500.0f : %orig; 
}
%end

%hook PlayerInteractionComponent
-(BOOL)CanInteractWithObject:(id)obj {
    if (stealthPort || unlockMilitary) return YES; 
    return %orig;
}
%end

// 4. حماية الشبح (الجيش والميناء ومنع النجوم)
%hook ZoneManager
-(BOOL)IsPlayerInRestrictedArea { 
    if (stealthPort || unlockMilitary) return NO; 
    return %orig; 
}
%end

%hook CrimeSystem
-(void)AddWantedStars:(int)count {
    if (stealthPort || unlockMilitary) return; // لا يوجد بلاغات أو نجوم
    %orig;
}
%end


// ==========================================
// --- بناء واجهة المستخدم (UI) ---
// ==========================================

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if(!win) win = [[UIApplication sharedApplication] windows].firstObject;

        // --- إنشاء أيقونة الصقر ---
        menuIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        menuIcon.frame = CGRectMake(50, 150, 60, 60);
        [menuIcon setTitle:@"🦅" forState:UIControlStateNormal];
        menuIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        menuIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        menuIcon.layer.cornerRadius = 30;
        menuIcon.layer.borderWidth = 2;
        menuIcon.layer.borderColor = [UIColor greenColor].CGColor;
        [menuIcon addTarget:[MustafaSupremeVIP class] action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [menuIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaSupremeVIP class] action:@selector(handlePan:)]];
        [win addSubview:menuIcon];

        // --- إنشاء القائمة الرئيسية ---
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-130, win.frame.size.height/2-150, 260, 310)];
        mainMenu.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:0.98];
        mainMenu.layer.cornerRadius = 20;
        mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor greenColor].CGColor;
        mainMenu.alpha = 0;
        mainMenu.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [win addSubview:mainMenu];

        // عنوان القائمة
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 30)];
        title.text = @"MUSTAFA SUPREME VIP";
        title.textColor = [UIColor greenColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:16];
        [mainMenu addSubview:title];

        // أسماء المميزات
        NSArray *fNames = @[@"INFINITE AMMO ♾️", @"INSTANT MINING ⛏️", @"REMOTE PORT 🚢", @"MILITARY BYPASS 🪖"];
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(15, 60 + (i * 58), 230, 48);
            btn.tag = i + 1;
            [btn setTitle:fNames[i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            btn.layer.cornerRadius = 12;
            btn.layer.borderWidth = 1.5;
            btn.layer.borderColor = [UIColor greenColor].CGColor;
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:[MustafaSupremeVIP class] action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [mainMenu addSubview:btn];
        }
        
        UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, 260, 20)];
        footer.text = @"E-Sign Ready - No Jailbreak";
        footer.textColor = [UIColor darkGrayColor];
        footer.textAlignment = NSTextAlignmentCenter;
        footer.font = [UIFont systemFontOfSize:10];
        [mainMenu addSubview:footer];
    });
}
