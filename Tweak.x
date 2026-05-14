#import <UIKit/UIKit.h>

// --- متغيرات السيطرة الفولاذية ---
static bool hShot = NO, bShot = NO, wBang = NO, infA = NO;
static bool espB = NO, espS = NO, espL = NO, espH = NO;
static float espMaxDist = 150.0f;

static UIView *mustafaPanel = nil;
static UIButton *eagleBtn = nil;
static UIView *vCombat = nil, *vVisuals = nil, *vJobs = nil, *vLoot = nil;
static UILabel *distLabel = nil;

@interface MustafaFinalPro : NSObject
+ (void)tabSwitch:(UIButton *)s;
+ (void)toggleFeat:(UIButton *)b;
+ (void)onSlide:(UISlider *)s;
+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p;
@end

@implementation MustafaFinalPro

// تحريك الصقر بسلاسة
+ (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:eagleBtn.superview];
    eagleBtn.center = CGPointMake(eagleBtn.center.x + t.x, eagleBtn.center.y + t.y);
    [p setTranslation:CGPointZero inView:eagleBtn.superview];
}

// التبديل بين الخانات بدون تأخير
+ (void)tabSwitch:(UIButton *)s {
    vCombat.hidden = vVisuals.hidden = vJobs.hidden = vLoot.hidden = YES;
    if (s.tag == 10) vCombat.hidden = NO;
    else if (s.tag == 20) vVisuals.hidden = NO;
    else if (s.tag == 30) vJobs.hidden = NO;
    else if (s.tag == 40) vLoot.hidden = NO;
}

// التحكم الذكي وتغيير الألوان
+ (void)toggleFeat:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    else if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    else if (b.tag == 3) wBang = !wBang;
    else if (b.tag == 4) infA = !infA;
    else if (b.tag == 101) espB = !espB;

    b.backgroundColor = (b.backgroundColor == [UIColor colorWithWhite:0.1 alpha:0.8]) ? 
                        [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:0.6] : [UIColor colorWithWhite:0.1 alpha:0.8];
}

+ (void)onSlide:(UISlider *)s {
    espMaxDist = s.value;
    distStatus.text = [NSString stringWithFormat:@"ESP Limit: %.0fM", espMaxDist];
}

+ (void)showHide { [UIView animateWithDuration:0.3 animations:^{ mustafaPanel.alpha = (mustafaPanel.alpha == 0) ? 1 : 0; }]; }
@end

__attribute__((constructor))
static void buildSupremeV5() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        // القائمة الأساسية (مطابقة للصورة)
        mustafaPanel = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2-270, win.frame.size.height/2-165, 540, 330)];
        mustafaPanel.backgroundColor = [UIColor colorWithRed:0.01 green:0.04 blue:0.05 alpha:0.95];
        mustafaPanel.layer.cornerRadius = 18;
        mustafaPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mustafaPanel.layer.borderWidth = 1.8;
        mustafaPanel.alpha = 0;
        [win addSubview:mustafaPanel];

        // الاسم والهيدر
        UILabel *idL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 540, 45)];
        idL.text = @"   🦅 MUSTAFA SPECIAL | THE GHOST ENGINE V5.0";
        idL.textColor = [UIColor cyanColor];
        idL.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        idL.font = [UIFont boldSystemFontOfSize:15];
        [mustafaPanel addSubview:idL];

        // إنشاء الخانات (Tabs)
        NSArray *tabs = @[@"COMBAT", @"VISUALS", @"JOBS", @"LOOT"];
        for(int i=0; i<4; i++){
            UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
            tb.frame = CGRectMake(0, i*60+55, 130, 55);
            [tb setTitle:tabs[i] forState:UIControlStateNormal];
            tb.tag = (i+1)*10;
            [tb addTarget:[MustafaFinalPro class] action:@selector(tabSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [mustafaPanel addSubview:tb];
        }

        // إنشاء الحاويات
        vCombat = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; [mustafaPanel addSubview:vCombat];
        vVisuals = [[UIView alloc] initWithFrame:CGRectMake(140, 55, 380, 260)]; vVisuals.hidden = YES; [mustafaPanel addSubview:vVisuals];
        
        // أزرار COMBAT
        [MustafaFinalPro addB:@"SMART HEADSHOT 🎯" y:0 tag:1 p:vCombat];
        [MustafaFinalPro addB:@"SMART BODYSHOT 👕" y:50 tag:2 p:vCombat];
        [MustafaFinalPro addB:@"INFINITE AMMO 🔫" y:100 tag:4 p:vCombat];

        // محتوى VISUALS (السلايدر)
        [MustafaFinalPro addB:@"ESP BOX" y:0 tag:101 p:vVisuals];
        distLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 360, 30)];
        distLabel.text = @"ESP Distance: 150M"; distLabel.textColor = [UIColor whiteColor];
        [vVisuals addSubview:distLabel];

        UISlider *sd = [[UISlider alloc] initWithFrame:CGRectMake(10, 180, 360, 40)];
        sd.minimumValue = 50; sd.maximumValue = 250; sd.value = 150;
        sd.minimumTrackTintColor = [UIColor cyanColor];
        [sd addTarget:[MustafaFinalPro class] action:@selector(onSlide:) forControlEvents:UIControlEventValueChanged];
        [vVisuals addSubview:sd];

        // أيقونة الصقر
        eagleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleBtn.frame = CGRectMake(50, 150, 65, 65);
        [eagleBtn setTitle:@"🦅" forState:UIControlStateNormal];
        eagleBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        eagleBtn.layer.cornerRadius = 32.5; eagleBtn.layer.borderWidth = 1.5; eagleBtn.layer.borderColor = [UIColor cyanColor].CGColor;
        [eagleBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaFinalPro class] action:@selector(drag:)]];
        [eagleBtn addTarget:[MustafaFinalPro class] action:@selector(showHide) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eagleBtn];
    });
}

+ (void)addB:(NSString *)t y:(CGFloat)y tag:(int)tag p:(UIView *)p {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, y, 360, 42);
    b.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    b.layer.cornerRadius = 10; b.tag = tag;
    [b setTitle:t forState:UIControlStateNormal];
    [b addTarget:self action:@selector(toggleFeat:) forControlEvents:UIControlEventTouchUpInside];
    [p addSubview:b];
}
