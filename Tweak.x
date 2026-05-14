#import <UIKit/UIKit.h>

// تفعيلات المميزات
static BOOL infAmmo = NO;
static BOOL fastJob = NO;
static BOOL portStealth = NO;
static BOOL milUnlock = NO;

// عناصر الواجهة
static UIView *mainM = nil;
static UIButton *mIco = nil;
static UIView *tab1 = nil; static UIView *tab2 = nil;
static UIView *tab3 = nil; static UIView *tab4 = nil;

@interface MustafaManager : NSObject
@end

@implementation MustafaManager
+ (void)pan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
+ (void)toggle { [UIView animateWithDuration:0.2 animations:^{ mainM.alpha = (mainM.alpha == 0) ? 1 : 0; }]; }
+ (void)swTab:(UIButton *)b {
    tab1.hidden = (b.tag != 100); tab2.hidden = (b.tag != 10);
    tab3.hidden = (b.tag != 20); tab4.hidden = (b.tag != 30);
}
+ (void)act:(UIButton *)b {
    if (b.tag == 7) infAmmo = !infAmmo;
    if (b.tag == 1) fastJob = !fastJob;
    if (b.tag == 4) portStealth = !portStealth;
    if (b.tag == 5) milUnlock = !milUnlock;
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.6] : [UIColor clearColor];
}
@end

// --- الهوكات (اللى بتجيب من الآخر) ---
%hook WeaponController
-(void)consumeAmmo:(int)a { if (!infAmmo) %orig; }
%end

%hook JobSystem
-(float)cooldownTime { return fastJob ? 0.0f : %orig; }
%end

%hook PortSystem
-(BOOL)isAlarmActive { return portStealth ? NO : %orig; }
%end

%hook MilitaryBase
-(BOOL)isLocked { return milUnlock ? NO : %orig; }
%end

// --- بناء المنيو ---
__attribute__((constructor))
static void start() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
        if (!w) return;

        mIco = [UIButton buttonWithType:UIButtonTypeCustom];
        mIco.frame = CGRectMake(80, 80, 45, 45);
        [mIco setTitle:@"🦅" forState:UIControlStateNormal];
        mIco.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        mIco.layer.cornerRadius = 22.5; mIco.layer.borderWidth = 1; mIco.layer.borderColor = [UIColor greenColor].CGColor;
        [mIco addTarget:[MustafaManager class] action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [mIco addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaManager class] action:@selector(pan:)]];
        [w addSubview:mIco];

        mainM = [[UIView alloc] initWithFrame:CGRectMake(w.frame.size.width/2-135, w.frame.size.height/2-110, 270, 220)];
        mainM.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        mainM.layer.cornerRadius = 12; mainM.layer.borderWidth = 1.5; mainM.layer.borderColor = [UIColor greenColor].CGColor;
        mainM.alpha = 0; [w addSubview:mainM];

        NSArray *tabs = @[@"WAR", @"JOB", @"PRT", @"MIL"];
        for(int i=0; i<4; i++) {
            UIButton *t = [UIButton buttonWithType:UIButtonTypeCustom];
            t.frame = CGRectMake(5+(i*66), 35, 62, 28);
            t.backgroundColor = [UIColor darkGrayColor]; t.layer.cornerRadius = 4;
            t.titleLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
            [t setTitle:tabs[i] forState:UIControlStateNormal];
            t.tag = (i==0)?100:i*10;
            [t addTarget:[MustafaManager class] action:@selector(swTab:) forControlEvents:UIControlEventTouchUpInside];
            [mainM addSubview:t];
        }

        tab1 = [[UIView alloc] initWithFrame:CGRectMake(5, 75, 260, 140)];
        tab2 = [[UIView alloc] initWithFrame:CGRectMake(5, 75, 260, 140)]; tab2.hidden = YES;
        tab3 = [[UIView alloc] initWithFrame:CGRectMake(5, 75, 260, 140)]; tab3.hidden = YES;
        tab4 = [[UIView alloc] initWithFrame:CGRectMake(5, 75, 260, 140)]; tab4.hidden = YES;
        [mainM addSubview:tab1]; [mainM addSubview:tab2]; [mainM addSubview:tab3]; [mainM addSubview:tab4];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom]; b1.frame = CGRectMake(0, 20, 260, 45); b1.tag = 7;
        [b1 setTitle:@"INF AMMO ♾️" forState:UIControlStateNormal]; b1.layer.borderWidth = 1; b1.layer.borderColor = [UIColor greenColor].CGColor;
        [b1 addTarget:[MustafaManager class] action:@selector(act:) forControlEvents:UIControlEventTouchUpInside]; [tab1 addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom]; b2.frame = CGRectMake(0, 20, 260, 45); b2.tag = 1;
        [b2 setTitle:@"FAST JOB" forState:UIControlStateNormal]; b2.layer.borderWidth = 1; b2.layer.borderColor = [UIColor greenColor].CGColor;
        [b2 addTarget:[MustafaManager class] action:@selector(act:) forControlEvents:UIControlEventTouchUpInside]; [tab2 addSubview:b2];

        UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom]; b3.frame = CGRectMake(0, 20, 260, 45); b3.tag = 4;
        [b3 setTitle:@"PORT NO ALARM" forState:UIControlStateNormal]; b3.layer.borderWidth = 1; b3.layer.borderColor = [UIColor greenColor].CGColor;
        [b3 addTarget:[MustafaManager class] action:@selector(act:) forControlEvents:UIControlEventTouchUpInside]; [tab3 addSubview:b3];

        UIButton *b4 = [UIButton buttonWithType:UIButtonTypeCustom]; b4.frame = CGRectMake(0, 20, 260, 45); b4.tag = 5;
        [b4 setTitle:@"MILITARY UNLOCK" forState:UIControlStateNormal]; b4.layer.borderWidth = 1; b4.layer.borderColor = [UIColor greenColor].CGColor;
        [b4 addTarget:[MustafaManager class] action:@selector(act:) forControlEvents:UIControlEventTouchUpInside]; [tab4 addSubview:b4];
    });
}
