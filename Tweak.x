#import <UIKit/UIKit.h>

// --- [1] تعريف مفاتيح السيطرة (Global Variables) ---
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO;
static bool aMine = NO, aDeliv = NO, aLoot = NO, pLoot = NO;
static float espDist = 150.0f;

// --- [2] واجهة المستخدم (Mustafa UI Elements) ---
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vL = nil;
static UILabel *dLab = nil;

@interface MustafaSupremeV5 : NSObject
+ (void)tSwitch:(UIButton *)s;
+ (void)fToggle:(UIButton *)b;
+ (void)sSlide:(UISlider *)s;
+ (void)sh;
+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p;
@end

@implementation MustafaSupremeV5

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
    // تفعيل المنطق البرمجي لكل ميزة
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
    // التفاعل البصري (توهج الزرار عند التشغيل)
    [UIView animateWithDuration:0.2 animations:^{
        if (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) {
            b.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.6 alpha:0.7];
            b.layer.borderColor = [UIColor cyanColor].CGColor;
        } else {
            b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
            b.layer.borderColor = [UIColor grayColor].CGColor;
        }
    }];
}

+ (void)sSlide:(UISlider *)s {
    espDist = s.value;
    dLab.text = [NSString stringWithFormat:@"ESP Distance: %.0fM", espDist];
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(10, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 8; b.layer.borderWidth = 1; b.layer.borderColor = [UIColor grayColor].CGColor;
    b.tag = tag; [b setTitle:t forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

// --- [3] الربط الفعلي مع اللعبة (THE HOOKS) ---
// هنا بنخلي الأزرار تغير في برمجة اللعبة فعلياً
%hook WeaponSystem // الكلاس المسؤول عن الأسلحة
-(float)getRecoilValue {
    if (infA) return 0.0f; // لو الميزة شغالة مفيش ارتداد
    return %orig;
}
-(int)currentAmmo {
    if (infA) return 999; // رصاص لانهائي
    return %orig;
}
%end

%hook PlayerHealth // الكلاس المسؤول عن الدمج
-(void)takeDamage:(float)dmg isHeadshot:(BOOL)isHS {
    if (hShot) {
        %orig(999.9f, YES); // لو الهيد شوت شغال، الموت فوري
    } else {
        %orig(dmg, isHS);
    }
}
%end

// --- [4] حقن المنيو في اللعبة عند التشغيل ---
__attribute__((constructor))
static void startMustafaFinal() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.96];
        mPanel.layer.cornerRadius = 20; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 2.0; mPanel.alpha = 0;
        [win addSubview:mPanel];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        title.text = @"   🦅 MUSTAFA SPECIAL | THE SUPREME ENGINE V5.0";
        title.textColor = [UIColor cyanColor]; title.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [mPanel addSubview:title];

        // إنشاء التبويبات (Tabs)
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*65+60, 130, 60);
            [tb setTitle:tabs[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[MustafaSupremeV5 class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        // إنشاء الحاويات وتوزيع الأزرار
        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vL = [[UIView alloc] initWithFrame:CGRectMake(140, 60, 380, 260)]; vL.hidden = YES; [mPanel addSubview:vL];

        [MustafaSupremeV5 addB:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vC];
        [MustafaSupremeV5 addB:@"SMART BODYSHOT 👕" y:50 tag:2 p:vC];
        [MustafaSupremeV5 addB:@"INFINITE AMMO 🔫" y:100 tag:4 p:vC];

        [MustafaSupremeV5 addB:@"ESP BOX" y:0 tag:101 p:vV];
        [MustafaSupremeV5 addB:@"ESP SKELETON" y:45 tag:102 p:vV];
        dLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 350, 25)];
        dLab.text = @"ESP Distance: 150M"; dLab.textColor = [UIColor cyanColor]; [vV addSubview:dLab];
        UISlider *sd = [[UISlider alloc] initWithFrame:CGRectMake(15, 175, 350, 30)];
        sd.minimumValue = 50; sd.maximumValue = 300; sd.value = 150;
        [sd addTarget:[MustafaSupremeV5 class] action:@selector(sSlide:) forControlEvents:UIControlEventValueChanged];
        [vV addSubview:sd];

        [MustafaSupremeV5 addB:@"AUTO MINER ⛏️" y:0 tag:301 p:vJ];
        [MustafaSupremeV5 addB:@"AUTO DELIVERY 📦" y:50 tag:302 p:vJ];

        [MustafaSupremeV5 addB:@"ARMY BASE LOOT 🎖️" y:0 tag:401 p:vL];
        [MustafaSupremeV5 addB:@"PORT CARGO LOOT 🚢" y:50 tag:402 p:vL];

        // أيقونة التحكم (Floating Icon)
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(50, 150, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.2 alpha:0.6];
        eIcon.layer.cornerRadius = 32.5; eIcon.layer.borderWidth = 2; eIcon.layer.borderColor = [UIColor cyanColor].CGColor;
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaSupremeV5 class] action:@selector(drag:)]];
        [eIcon addTarget:[MustafaSupremeV5 class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
    });
}
