#import <UIKit/UIKit.h>

// متغيرات التحكم
static bool hShot = NO;
static bool bShot = NO;
static bool showRadar = NO;
static UIView *mPanel = nil;
static UIButton *eIcon = nil;
static CAShapeLayer *radarCircle = nil;

@interface MustafaMenu : NSObject
@end

@implementation MustafaMenu

// تحريك الأيقونة
+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

// إظهار وإخفاء القائمة
+ (void)toggleMenu {
    if (mPanel) {
        [UIView animateWithDuration:0.3 animations:^{
            mPanel.alpha = (mPanel.alpha == 0) ? 1.0 : 0;
        }];
    }
}

// تفعيل المميزات
+ (void)btnAction:(UIButton *)b {
    if (b.tag == 1) { hShot = !hShot; bShot = NO; }
    if (b.tag == 2) { bShot = !bShot; hShot = NO; }
    if (b.tag == 3) { 
        showRadar = !showRadar; 
        if (radarCircle) radarCircle.opacity = showRadar ? 1.0 : 0; 
    }
    
    // تغيير اللون للتأكيد
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? 
    [UIColor colorWithRed:0 green:0.8 blue:0.8 alpha:0.6] : [UIColor clearColor];
}
@end

// هكر القتل
%hook PlayerController
-(void)takeDamage:(float)d isHead:(BOOL)h {
    if (hShot) %orig(999, YES); 
    else if (bShot) %orig(999, NO);
    else %orig(d, h);
}
%end

// تشغيل المنيو بأمان (الحل النهائي لـ Error 1)
__attribute__((constructor))
static void initializeMustafa() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        // الطريقة القانونية للوصول للشاشة في iOS الحديث
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
        
        if (!window) return;

        // 1. الدائرة (الرادار)
        radarCircle = [CAShapeLayer layer];
        radarCircle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(window.frame.size.width/2, window.frame.size.height/2) radius:140 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        radarCircle.strokeColor = [UIColor cyanColor].CGColor;
        radarCircle.fillColor = [UIColor clearColor].CGColor;
        radarCircle.lineWidth = 1.5;
        radarCircle.opacity = 0;
        [window.layer addSublayer:radarCircle];

        // 2. أيقونة النسر
        eIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eIcon.frame = CGRectMake(100, 100, 55, 55);
        [eIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eIcon.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
        eIcon.layer.cornerRadius = 27.5;
        [eIcon addTarget:[MustafaMenu class] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [eIcon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MustafaMenu class] action:@selector(handlePan:)]];
        [window addSubview:eIcon];

        // 3. القائمة (Panel)
        mPanel = [[UIView alloc] initWithFrame:CGRectMake(window.frame.size.width/2-140, window.frame.size.height/2-100, 280, 200)];
        mPanel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.9];
        mPanel.layer.cornerRadius = 12;
        mPanel.layer.borderWidth = 1.5;
        mPanel.layer.borderColor = [UIColor cyanColor].CGColor;
        mPanel.alpha = 0;
        [window addSubview:mPanel];

        // عنوان المنيو
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 25)];
        title.text = @"MUSTAFA VIP";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:16];
        [mPanel addSubview:title];

        // أزرار المميزات
        NSArray *names = @[@"AUTO HEADSHOT 🎯", @"BODY DAMAGE 👕", @"SHOW RADAR ⭕"];
        for (int i=0; i<3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10, 40 + (i*50), 260, 40);
            btn.layer.cornerRadius = 8;
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor cyanColor].CGColor;
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitle:names[i] forState:UIControlStateNormal];
            btn.tag = i + 1;
            [btn addTarget:[MustafaMenu class] action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [mPanel addSubview:btn];
        }
    });
}
