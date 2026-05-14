#import <UIKit/UIKit.h>

// 1. تعريف المتغيرات (المفاتيح)
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO;
static bool aMine = NO, aDeliv = NO, aLoot = NO, pLoot = NO;
static float espDist = 150.0f;

// 2. واجهة المستخدم (UI)
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vL = nil;
static UILabel *dLab = nil;

@interface MustafaFinalClean : NSObject
+ (void)tSwitch:(UIButton *)s;
+ (void)fToggle:(UIButton *)b;
+ (void)sSlide:(UISlider *)s;
+ (void)sh;
+ (void)addBtn:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p;
@end

@implementation MustafaFinalClean

+ (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eIcon.superview];
    eIcon.center = CGPointMake(eIcon.center.x + t.x, eIcon.center.y + t.y);
    [p setTranslation:CGPointZero inView:eIcon.superview];
}

+ (void)tSwitch:(UIButton *)s {
    vC.hidden = vV.hidden = vJ.hidden = vL.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 20) vV.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
    else if (s.tag == 40) vL.hidden = NO;
}

+ (void)fToggle:(UIButton *)b {
    switch (b.tag) {
        case 1: hShot = !hShot; bShot = NO; break;
        case 2: bShot = !bShot; hShot = NO; break;
        case 3: wBang = !wBang; break;
        case 4: infA = !infA; break;
        case 101: espB = !espB; break;
        case 102: espS = !espS; break;
        case 103: espL = !espL; break;
        case 301: aMine = !aMine; break;
        case 302: aDeliv = !aDeliv; break;
        case 401: aLoot = !aLoot; break;
        case 402: pLoot = !pLoot; break;
    }
    // تأثير اللون السيان عند التفعيل
    b.backgroundColor = (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) ? 
                        [UIColor colorWithRed:0 green:0.6 blue:0.6 alpha:0.8] : [UIColor colorWithWhite:0.1 alpha:0.8];
}

+ (void)sSlide:(UISlider *)s {
    espDist = s.value;
    dLab.text = [NSString stringWithFormat:@"ESP Distance: %.0fM", espDist];
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

+ (void)addBtn:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.tag = tag;
    [b setTitle:t forState:UIControlStateNormal];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// 3. الربط الفعلي مع محرك اللعبة (THE HOOKS)
// ملاحظة: استبدل WeaponSystem و PlayerHealth بالأسماء الصحيحة من الـ Dump بتاعك
%hook WeaponSystem
-(float)getRecoil {
    if (infA) return 0.0f; // لو الميزة شغالة مفيش ارتداد
    return %orig;
}
-(int)getAmmo {
    if (infA) return 999; // رصاص لانهائي
    return %orig;
}
%end

%hook PlayerHealth
-(void)applyDamage:(float)dmg isHead:(BOOL)isH {
    if (hShot) { 
        %orig(500.0f, YES); // لو الهيد شوت شغال، خلي الدمج قاتل
    } else {
        %orig(dmg, isH);
    }
}
%end

// 4. تشغيل المنيو عند فتح اللعبة
__attribute__((constructor))
static void initializeMustafaV5() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.96];
        mPanel.layer.cornerRadius = 20; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 2.0; mPanel.alpha = 0;
        [win addSubview:mPanel];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        title.text = @"   🦅 MUSTAFA SPECIAL | SUPREME V5.0";
        title.textColor = [UIColor cyanColor]; title.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [mPanel addSubview:title];

        // التبويبات
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*65+60, 130, 60);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[MustafaFinalClean class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vL = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vL.hidden = YES; [mPanel addSubview:vL];

        [MustafaFinalClean addBtn:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vC];
        [MustafaFinalClean addBtn:@"SMART BODYSHOT 👕" y:50 tag:2 p:vC];
        [MustafaFinalClean addBtn:@"INFINITE AMMO 🔫" y:100 tag:4 p:vC];

        [MustafaFinalClean addBtn:@"ESP BOX" y:0 tag:101 p:vV];
        dLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 350, 25)];
        dLab.text = @"ESP Distance: 150M"; dLab.textColor = [UIColor cyanColor]; [vV addSubview:dLab];
        
        [MustafaFinalClean addBtn:@"AUTO MINER ⛏️" y:0 tag:301 p:vJ];
        [MustafaFinalClean addBtn:@"ARMY BASE LOOT 🎖️" y:0 tag:401 p:vL];

        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(50, 150, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.2 alpha:0.6];
        eIcon.layer.cornerRadius = 32.5; eIcon.layer.borderWidth = 2; eIcon.layer.borderColor = [UIColor cyanColor].CGColor;
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalClean class] action:@selector(drag:)]];
        [eIcon addTarget:[MustafaFinalClean class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
    });
}
