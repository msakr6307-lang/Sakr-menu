#import <UIKit/UIKit.h>

// التفعيلات
static BOOL infAmmo = NO;
static BOOL fastJob = NO;

static UIView *menuBg = nil;
static UIButton *menuIcon = nil;

@interface MustafaFinalBoss : NSObject
@end

@implementation MustafaFinalBoss
+ (void)onPan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
+ (void)open { menuBg.hidden = !menuBg.hidden; }
+ (void)toggle:(UIButton *)b {
    if (b.tag == 7) infAmmo = !infAmmo;
    if (b.tag == 1) fastJob = !fastJob;
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.6] : [UIColor clearColor];
}
@end

// --- الهوكات الشغالة ---
%hook WeaponController
-(void)consumeAmmo:(int)a { if (!infAmmo) %orig; }
%end

%hook JobSystem
-(float)cooldownTime { return fastJob ? 0.0f : %orig; }
%end

// --- تشغيل المنيو ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win && [UIApplication sharedApplication].windows.count > 0)
            win = [UIApplication sharedApplication].windows.firstObject;
        if (!win) return;

        menuIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        menuIcon.frame = CGRectMake(100, 100, 50, 50);
        [menuIcon setTitle:@"🦅" forState:UIControlStateNormal];
        menuIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        menuIcon.layer.cornerRadius = 25;
        [menuIcon addTarget:[MustafaFinalBoss class] action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
        [menuIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalBoss class] action:@selector(onPan:)]];
        [win addSubview:menuIcon];

        menuBg = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-130, win.frame.size.height/2-100, 260, 200)];
        menuBg.backgroundColor = [UIColor blackColor];
        menuBg.layer.cornerRadius = 15; menuBg.layer.borderWidth = 2; menuBg.layer.borderColor = [UIColor greenColor].CGColor;
        menuBg.hidden = YES; [win addSubview:menuBg];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
        b1.frame = CGRectMake(10, 50, 240, 50); b1.tag = 7;
        [b1 setTitle:@"INFINITE AMMO ♾️" forState:UIControlStateNormal];
        b1.layer.borderWidth = 1; b1.layer.borderColor = [UIColor greenColor].CGColor;
        [b1 addTarget:[MustafaFinalBoss class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        [menuBg addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
        b2.frame = CGRectMake(10, 120, 240, 50); b2.tag = 1;
        [b2 setTitle:@"FAST JOB 💼" forState:UIControlStateNormal];
        b2.layer.borderWidth = 1; b2.layer.borderColor = [UIColor greenColor].CGColor;
        [b2 addTarget:[MustafaFinalBoss class] action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        [menuBg addSubview:b2];
    });
}
