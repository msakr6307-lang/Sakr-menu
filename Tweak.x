#import <UIKit/UIKit.h>

// --- [1] مخزن حالات الهكر ---
static bool hShot = NO, infA = NO, aMine = NO;

// --- [2] واجهة المستخدم ---
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vJ = nil; 

@interface FinalSupreme : NSObject
+ (void)fToggle:(UIButton *)b;
+ (void)tSwitch:(UIButton *)s;
+ (void)sh;
@end

@implementation FinalSupreme

// --- [3] محرك التفاعل (الإصلاح الجذري) ---
+ (void)fToggle:(UIButton *)b {
    // تفعيل المنطق
    if (b.tag == 1) hShot = !hShot;
    else if (b.tag == 4) infA = !infA;
    else if (b.tag == 301) aMine = !aMine;

    // تغيير اللون فوراً (إجبار النظام على التحديث)
    [UIView animateWithDuration:0.2 animations:^{
        if (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) {
            b.backgroundColor = [UIColor colorWithRed:0 green:0.8 blue:0.8 alpha:0.9];
            b.layer.borderColor = [UIColor whiteColor].CGColor;
        } else {
            b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
            b.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];
}

+ (void)tSwitch:(UIButton *)s {
    vC.hidden = YES; vJ.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 45);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 10; b.layer.borderWidth = 1.5; b.layer.borderColor = [UIColor clearColor].CGColor;
    b.tag = tag; [b setTitle:t forState:UIControlStateNormal];
    b.userInteractionEnabled = YES; // التأكد من تفعيل اللمس
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// --- [4] الـ Hooks الفعلية (تشغيل الهكر في اللعبة) ---
%hook WeaponSystem 
-(int)getAmmo {
    if (infA) return 999; 
    return %orig;
}
%end

%hook PlayerController
-(void)applyDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else %orig(d, h);
}
%end

// --- [5] بناء المنيو عند التشغيل ---
__attribute__((constructor))
static void startSystem() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.05 alpha:0.98];
        mPanel.layer.cornerRadius = 15; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 2; mPanel.alpha = 0;
        mPanel.userInteractionEnabled = YES; // أهم سطر للتفاعل
        [win addSubview:mPanel];

        // قسم Combat
        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)];
        vC.userInteractionEnabled = YES;
        [mPanel addSubview:vC];

        // قسم Jobs
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)];
        vJ.userInteractionEnabled = YES; vJ.hidden = YES;
        [mPanel addSubview:vJ];

        // إضافة الأزرار
        [FinalSupreme addB:@"SMART HEADSHOT 🎯" y:10 tag:1 p:vC];
        [FinalSupreme addB:@"INFINITE AMMO 🔫" y:65 tag:4 p:vC];
        [FinalSupreme addB:@"AUTO MINER ⛏️" y:10 tag:301 p:vJ];

        // أيقونة الفتح
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(100, 100, 60, 60);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.7];
        eIcon.layer.cornerRadius = 30;
        [eIcon addTarget:[FinalSupreme class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
        
        // أزرار التبديل (Tabs)
        NSArray *tabs = @[@"COMBAT", @"JOBS"];
        for(int i=0; i<2; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(10, i*60+60, 120, 50);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i==0)?10:30;
            [tb addTarget:[FinalSupreme class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }
    });
}
