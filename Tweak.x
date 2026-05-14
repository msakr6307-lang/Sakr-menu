#import <UIKit/UIKit.h>

// --- متغيرات التفعيلات ---
static BOOL infAmmo = NO;      // طلق لانهاية
static BOOL fastJob = NO;      // وظائف سريعة
static BOOL stealthPort = NO;  // سرقة الميناء بدون إنذار
static BOOL bypassMil = NO;    // بوابات الجيش

// واجهة المستخدم
static UIView *mainMenu = nil;
static UIButton *floatingBtn = nil;
static UIView *combatView = nil;
static UIView *jobsView = nil;
static UIView *portView = nil;
static UIView *milView = nil;

@interface MustafaFinalBoss : NSObject
@end

@implementation MustafaFinalBoss

+ (void)drag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

+ (void)toggleMenu {
    [UIView animateWithDuration:0.3 animations:^{
        mainMenu.alpha = (mainMenu.alpha == 0) ? 1.0 : 0;
    }];
}

+ (void)switchTab:(UIButton *)b {
    combatView.hidden = YES; jobsView.hidden = YES; portView.hidden = YES; milView.hidden = YES;
    if (b.tag == 100) combatView.hidden = NO;
    if (b.tag == 10) jobsView.hidden = NO;
    if (b.tag == 20) portView.hidden = NO;
    if (b.tag == 30) milView.hidden = NO;
}

+ (void)toggleFeat:(UIButton *)b {
    if (b.tag == 7) infAmmo = !infAmmo;
    if (b.tag == 1) fastJob = !fastJob;
    if (b.tag == 4) stealthPort = !stealthPort;
    if (b.tag == 5) bypassMil = !bypassMil;

    [UIView animateWithDuration:0.2 animations:^{
        b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? 
        [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.7] : [UIColor clearColor];
    }];
}
@end

// --- الهوكات (العمل الميداني) ---

// 1. ميزة الطلق اللانهاية
%hook WeaponController
-(void)consumeAmmo:(int)amount {
    if (infAmmo) return; // لا تستهلك الطلق
    %orig;
}
%end

// 2. ميزة الوظائف (تقليل وقت الانتظار)
%hook JobSystem
-(float)cooldownTime {
    return fastJob ? 0.0f : %orig;
}
%end

// 3. ميزة الميناء (سرقة هادئة)
%hook PortSystem
-(BOOL)shouldTriggerAlarm {
    return stealthPort ? NO : %orig;
}
%end

// 4. ميزة الجيش (تخطى البوابات)
%hook MilitaryBase
-(BOOL)isGateLocked:(int)gateID {
    return bypassMil ? NO : %orig;
}
%end

// --- بناء المنيو الاحترافي ---
__attribute__((constructor))
static void setupMustafaVIP() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *win = nil;
        // أضمن طريقة للوصول للويندو في iOS الحديث لتجنب Error 1
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                win = scene.windows.firstObject;
                break;
            }
        }
        if (!win) win = [UIApplication sharedApplication].windows.firstObject;
        if (!win) return;

        // الأيقونة
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(50, 150, 55, 55);
        [floatingBtn setTitle:@"🛡️" forState:UIControlStateNormal];
        floatingBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        floatingBtn.layer.cornerRadius = 27.5;
        floatingBtn.layer.borderWidth = 1.5;
        floatingBtn.layer.borderColor = [UIColor greenColor].CGColor;
        [floatingBtn addTarget:[MustafaFinalBoss class] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [floatingBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalBoss class] action:@selector(drag:)]];
        [win addSubview:floatingBtn];

        // اللوحة
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-150, win.frame.size.height/2-130, 300, 260)];
        mainMenu.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95];
        mainMenu.layer.cornerRadius = 20;
        mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor greenColor].CGColor;
        mainMenu.alpha = 0;
        [win addSubview:mainMenu];

        // التابات (Tabs)
        NSArray *tabs = @[@"COMBAT", @"JOBS", @"PORT", @"MIL"];
        for (int i=0; i<4; i++) {
            UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
            t.frame = CGRectMake(5 + (i*73), 40, 70, 30);
            t.backgroundColor = [UIColor darkGrayColor];
            t.layer.cornerRadius = 5;
            t.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
            [t setTitle:tabs[i] forState:UIControlStateNormal];
            t.tag = (i == 0) ? 100 : i*10; // 100, 10, 20, 30
            [t addTarget:[MustafaFinalBoss class] action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
            [mainMenu addSubview:t];
        }

        // إنشاء الخانات
        combatView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 280, 160)];
        jobsView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 280, 160)]; jobsView.hidden = YES;
        portView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 280, 160)]; portView.hidden = YES;
        milView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 280, 160)]; milView.hidden = YES;
        
        [mainMenu addSubview:combatView]; [mainMenu addSubview:jobsView]; 
        [mainMenu addSubview:portView]; [mainMenu addSubview:milView];

        // زر الطلق (Combat Tab)
        UIButton *bInf = [UIButton buttonWithType:UIButtonTypeCustom];
        bInf.frame = CGRectMake(0, 40, 280, 50); bInf.tag = 7;
        [bInf setTitle:@"INFINITE AMMO ♾️" forState:UIControlStateNormal];
        bInf.layer.borderWidth = 1; bInf.layer.borderColor = [UIColor greenColor].CGColor;
        [bInf addTarget:[MustafaFinalBoss class] action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
        [combatView addSubview:bInf];

        // زر الوظائف (Jobs Tab)
        UIButton *bJob = [UIButton buttonWithType:UIButtonTypeCustom];
        bJob.frame = CGRectMake(0, 40, 280, 50); bJob.tag = 1;
        [bJob setTitle:@"NO JOB COOLDOWN" forState:UIControlStateNormal];
        bJob.layer.borderWidth = 1; bJob.layer.borderColor = [UIColor greenColor].CGColor;
        [bJob addTarget:[MustafaFinalBoss class] action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
        [jobsView addSubview:bJob];

        // زر الميناء (Port Tab)
        UIButton *bPort = [UIButton buttonWithType:UIButtonTypeCustom];
        bPort.frame = CGRectMake(0, 40, 280, 50); bPort.tag = 4;
        [bPort setTitle:@"STEALTH ROBBERY" forState:UIControlStateNormal];
        bPort.layer.borderWidth = 1; bPort.layer.borderColor = [UIColor greenColor].CGColor;
        [bPort addTarget:[MustafaFinalBoss class] action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
        [portView addSubview:bPort];

        // زر الجيش (Mil Tab)
        UIButton *bMil = [UIButton buttonWithType:UIButtonTypeCustom];
        bMil.frame = CGRectMake(0, 40, 280, 50); bMil.tag = 5;
        [bMil setTitle:@"UNLOCK MIL GATES" forState:UIControlStateNormal];
        bMil.layer.borderWidth = 1; bMil.layer.borderColor = [UIColor greenColor].CGColor;
        [bMil addTarget:[MustafaFinalBoss class] action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
        [milView addSubview:bMil];
    });
}
