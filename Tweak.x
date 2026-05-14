#import <UIKit/UIKit.h>

// --- التفعيلات ---
static BOOL infAmmo = NO;
static BOOL fastJob = NO;
static BOOL portStealth = NO;
static BOOL milUnlock = NO;

static UIView *mMenu = nil;
static UIButton *mIcon = nil;
static UIView *vCombat = nil;
static UIView *vJobs = nil;
static UIView *vPort = nil;
static UIView *vMil = nil;

@interface MustafaFinal : NSObject
@end

@implementation MustafaFinal
+ (void)onDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
+ (void)showHide {
    [UIView animateWithDuration:0.3 animations:^{ mMenu.alpha = (mMenu.alpha == 0) ? 1.0 : 0; }];
}
+ (void)goTab:(UIButton *)b {
    vCombat.hidden = (b.tag != 100);
    vJobs.hidden = (b.tag != 10);
    vPort.hidden = (b.tag != 20);
    vMil.hidden = (b.tag != 30);
}
+ (void)toggle:(UIButton *)b {
    if (b.tag == 7) infAmmo = !infAmmo;
    if (b.tag == 1) fastJob = !fastJob;
    if (b.tag == 4) portStealth = !portStealth;
    if (b.tag == 5) milUnlock = !milUnlock;
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.6] : [UIColor clearColor];
}
@end

// --- الهوكات (Hooks) ---
%hook WeaponController
-(void)consumeAmmo:(int)a { if (!infAmmo) %orig; } // طلق لانهاية
%end

%hook JobSystem
-(float)cooldownTime { return fastJob ? 0.0f : %orig; } // وظائف سريعة
%end

%hook PortSystem
-(BOOL)isAlarmOn { return portStealth ? NO : %orig; } // سرقة الميناء هادئة
%end

%hook MilitaryBase
-(BOOL)isGateLocked:(int)g { return milUnlock ? NO : %orig; } // بوابات الجيش
%end

// --- بناء الواجهة ---
__attribute__((constructor))
static void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // حل مشكلة الويندو (تجنب Error 1 & 2)
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) win = [[UIApplication sharedApplication].windows firstObject];
        if (!win) return;

        // الأيقونة
        mIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        mIcon.frame = CGRectMake(50, 150, 50, 50);
        [mIcon setTitle:@"🦅" forState:UIControlStateNormal];
        mIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        mIcon.layer.cornerRadius = 25;
        mIcon.layer.borderColor = [UIColor greenColor].CGColor; mIcon.layer.borderWidth = 1;
        [mIcon addTarget:[MustafaFinal class] action:@selector(showHide) forControlEvents:UIControlEventTouchUpInside];
        [mIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinal class] action:@selector(onDrag:)]];
        [win addSubview:mIcon];

        // المنيو
        mMenu = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-140, win.frame.size.height/2-120, 280, 240)];
        mMenu.backgroundColor = [UIColor colorWithRed:0 green:0.05 blue:0 alpha:0.95];
        mMenu.layer.cornerRadius = 15; mMenu.layer.borderColor = [UIColor greenColor].CGColor; mMenu.layer.borderWidth = 2;
        mMenu.alpha = 0; [win addSubview:mMenu];

        // التابات
        NSArray *ts = @[@"COMBAT", @"JOBS", @"PORT", @"MIL"];
        for(int i=0; i<4; i++){
            UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
            t.frame = CGRectMake(5+(i*68), 40, 65, 30);
            t.backgroundColor = [UIColor darkGrayColor]; t.layer.cornerRadius = 5;
            t.titleLabel.font = [UIFont systemFontOfSize:9 boldSystemFontOfSize:9];
            [t setTitle:ts[i] forState:UIControlStateNormal];
            t.tag = (i==0)?100:i*10;
            [t addTarget:[MustafaFinal class] action:@selector(goTab:) forControlEvents:UIControlEventTouchUpInside];
            [mMenu addSubview:t];
        }

        // الخانات
        vCombat = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)];
        vJobs = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; vJobs.hidden = YES;
        vPort = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; vPort.hidden = YES;
        vMil = [[UIView alloc] initWithFrame:CGRectMake(10, 80, 260, 150)]; vMil.hidden = YES;
        [mMenu addSubview:vCombat]; [mMenu addSubview:vJobs]; [mMenu addSubview:vPort]; [mMenu addSubview:vMil];

        // الأزرار
        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom]; b1.frame = CGRectMake(0, 30, 260, 45); b1.tag = 7;
        [b1 setTitle:@"INF AMMO ♾️" forState:UIControlStateNormal]; [b1 addTarget:[MustafaFinal class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        b1.layer.borderWidth = 1; b1.layer.borderColor = [UIColor greenColor].CGColor; [vCombat addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom]; b2.frame = CGRectMake(0, 30, 260, 45); b2.tag = 1;
        [b2 setTitle:@"FAST JOBS 💼" forState:UIControlStateNormal]; [b2 addTarget:[MustafaFinal class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        b2.layer.borderWidth = 1; b2.layer.borderColor = [UIColor greenColor].CGColor; [vJobs addSubview:b2];

        UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom]; b3.frame = CGRectMake(0, 30, 260, 45); b3.tag = 4;
        [b3 setTitle:@"PORT STEALTH 🚢" forState:UIControlStateNormal]; [b3 addTarget:[MustafaFinal class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        b3.layer.borderWidth = 1; b3.layer.borderColor = [UIColor greenColor].CGColor; [vPort addSubview:b3];

        UIButton *b4 = [UIButton buttonWithType:UIButtonTypeCustom]; b4.frame = CGRectMake(0, 30, 260, 45); b4.tag = 5;
        [b4 setTitle:@"MILITARY UNLOCK 🪖" forState:UIControlStateNormal]; [b4 addTarget:[MustafaFinal class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        b4.layer.borderWidth = 1; b4.layer.borderColor = [UIColor greenColor].CGColor; [vMil addSubview:b4];
    });
}
