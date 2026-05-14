#import <UIKit/UIKit.h>

static BOOL infA = NO; static BOOL mineH = NO;
static BOOL portH = NO; static BOOL milH = NO;
static UIView *mainV = nil;

@interface M_Logic : NSObject @end
@implementation M_Logic
+ (void)pan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view; CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
+ (void)sw:(UIButton *)b {
    if(b.tag==1) infA=!infA; if(b.tag==2) mineH=!mineH;
    if(b.tag==3) portH=!portH; if(b.tag==4) milH=!milH;
    b.backgroundColor = (b.backgroundColor == [UIColor clearColor]) ? [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.5] : [UIColor clearColor];
}
@end

// --- الهوكات (اللى بتشغل المميزات فعلياً) ---
%hook Weapon
-(int)GetAmmoCount { return infA ? 999 : %orig; }
%end

%hook MiningAction
-(float)GetProgressSpeed { return mineH ? 20.0f : %orig; }
%end

%hook PortSecuritySystem
-(void)TriggerAlarm { if(!portH) %orig; }
%end

%hook MilitaryBaseManager
-(BOOL)IsZoneRestricted { return milH ? NO : %orig; }
%end

// --- بناء القائمة ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if(!w) w = [[UIApplication sharedApplication].windows firstObject];
        if(!w) return;

        UIButton *icon = [UIButton buttonWithType:UIButtonTypeCustom];
        icon.frame = CGRectMake(100, 100, 50, 50); [icon setTitle:@"🦅" forState:UIControlStateNormal];
        icon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7]; icon.layer.cornerRadius = 25;
        [icon addTarget:[M_Logic class] action:@selector(pan:) forControlEvents:UIControlEventTouchDown]; // للتجربة فقط
        [icon addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[M_Logic class] action:@selector(pan:)]];
        [w addSubview:icon];

        mainV = [[UIView alloc] initWithFrame:CGRectMake(50, 160, 200, 250)];
        mainV.backgroundColor = [UIColor blackColor]; mainV.layer.borderColor = [UIColor greenColor].CGColor; mainV.layer.borderWidth = 2;
        [w addSubview:mainV];

        NSArray *btns = @[@"INF AMMO", @"MINE JOB", @"PORT HACK", @"MILITARY"];
        for(int i=0; i<4; i++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(10, 20+(i*55), 180, 45); b.tag = i+1;
            [b setTitle:btns[i] forState:UIControlStateNormal]; b.layer.borderWidth = 1; b.layer.borderColor = [UIColor greenColor].CGColor;
            [b addTarget:[M_Logic class] action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
            [mainV addSubview:b];
        }
    });
}
