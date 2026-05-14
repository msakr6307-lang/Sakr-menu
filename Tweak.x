#import <UIKit/UIKit.h>

// --- تعريف المتغيرات الأساسية ---
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO;
static float espDist = 150.0f;

static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static UIView *vC = nil, *vV = nil, *vJ = nil, *vR = nil;
static UILabel *dLab = nil;

@interface MustafaFinalFix : NSObject
+ (void)tSwitch:(UIButton *)s;
+ (void)fToggle:(UIButton *)b;
+ (void)sSlide:(UISlider *)s;
@end

@implementation MustafaFinalFix

+ (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eIcon.superview];
    eIcon.center = CGPointMake(eIcon.center.x + t.x, eIcon.center.y + t.y);
    [p setTranslation:CGPointZero inView:eIcon.superview];
}

+ (void)tSwitch:(UIButton *)s {
    vC.hidden = vV.hidden = vJ.hidden = vR.hidden = YES;
    if (s.tag == 10) vC.hidden = NO;
    else if (s.tag == 20) vV.hidden = NO;
    else if (s.tag == 30) vJ.hidden = NO;
    else if (s.tag == 40) vR.hidden = NO;
}

+ (void)fToggle:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 3) wBang = !wBang;
    else if (b.tag == 4) infA = !infA;
    else if (b.tag == 101) espB = !espB;

    b.backgroundColor = (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) ? 
                        [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.6] : [UIColor colorWithWhite:0.1 alpha:0.8];
}

+ (void)sSlide:(UISlider *)s {
    espDist = s.value;
    dLab.text = [NSString stringWithFormat:@"ESP Distance: %.0fM", espDist];
}

+ (void)sh { [UIView animateWithDuration:0.3 animations:^{ mPanel.alpha = (mPanel.alpha == 0) ? 1 : 0; }]; }

// دالة مساعدة لبناء الأزرار لتجنب تكرار الكود والأخطاء
+ (void)btnW:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 10; b.tag = tag;
    [b setTitle:t forState:UIControlStateNormal];
    [b addTarget:self action:@selector(fToggle:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
@end

__attribute__((constructor))
static void startEngine() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        mPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.95];
        mPanel.layer.cornerRadius = 18; mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.layer.borderWidth = 1.8; mPanel.alpha = 0;
        [win addSubview:mPanel];

        UILabel *idL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        idL.text = @"   🦅 MUSTAFA SPECIAL | SUPREME V5.0";
        idL.textColor = [UIColor cyanColor]; idL.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        [mPanel addSubview:idL];

        NSArray *ts = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*60+55, 130, 55);
            [tb setTitle:ts[i] forState:UIControlStateNormal]; tb.tag = (i+1)*10;
            [tb addTarget:[MustafaFinalFix class] action:@selector(tSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:tb];
        }

        vC = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; [mPanel addSubview:vC];
        vV = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; vV.hidden = YES; [mPanel addSubview:vV];
        vJ = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; vJ.hidden = YES; [mPanel addSubview:vJ];
        vR = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; vR.hidden = YES; [mPanel addSubview:vR];

        [MustafaFinalFix btnW:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vC];
        [MustafaFinalFix btnW:@"SMART BODYSHOT 👕" y:50 tag:2 p:vC];
        [MustafaFinalFix btnW:@"INFINITE AMMO 🔫" y:100 tag:4 p:vC];

        [MustafaFinalFix btnW:@"ESP BOX" y:0 tag:101 p:vV];
        dLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 360, 30)];
        dLab.text = @"ESP Distance: 150M"; dLab.textColor = [UIColor whiteColor]; [vV addSubview:dLab];

        UISlider *sd = [[UISlider alloc] initWithFrame:CGRectMake(10, 180, 360, 40)];
        sd.minimumValue = 50; sd.maximumValue = 250; sd.value = 150;
        sd.minimumTrackTintColor = [UIColor cyanColor];
        [sd addTarget:[MustafaFinalFix class] action:@selector(sSlide:) forControlEvents:UIControlEventValueChanged];
        [vV addSubview:sd];

        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(50, 150, 65, 65);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        eIcon.layer.cornerRadius = 32.5; eIcon.layer.borderWidth = 1.5; eIcon.layer.borderColor = [UIColor cyanColor].CGColor;
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalFix class] action:@selector(drag:)]];
        [eIcon addTarget:[MustafaFinalFix class] action:@selector(sh) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eIcon];
    });
}
