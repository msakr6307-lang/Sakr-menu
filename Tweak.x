#import <UIKit/UIKit.h>

// --- تعريف العناصر الثابتة ---
static UIView *mainContainer = nil;
static UIButton *actionBtn = nil;

@interface SakrFinal : NSObject
+ (void)switchMenu;
@end

@implementation SakrFinal
+ (void)switchMenu {
    if (mainContainer) {
        [UIView animateWithDuration:0.3 animations:^{
            mainContainer.alpha = (mainContainer.alpha == 0) ? 1 : 0;
        }];
    }
}
@end

__attribute__((constructor))
static void startHack() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) return;

        // 1. حاوية المنيو
        mainContainer = [[UIView alloc] initWithFrame:CGRectMake(win.frame.size.width/2 - 120, 70, 240, 320)];
        mainContainer.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.02 alpha:0.98];
        mainContainer.layer.cornerRadius = 15;
        mainContainer.layer.borderColor = [UIColor redColor].CGColor;
        mainContainer.layer.borderWidth = 1.2;
        mainContainer.alpha = 0;
        [win addSubview:mainContainer];

        // العناوين
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 240, 30)];
        header.text = @"🦅 SAKR MOD V1.1";
        header.textColor = [UIColor redColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont boldSystemFontOfSize:18];
        [mainContainer addSubview:header];

        // --- خانة العمليات الخاصة ---
        UILabel *subHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 220, 25)];
        subHeader.text = @"[ قسم سرقة الموارد ]";
        subHeader.textColor = [UIColor yellowColor];
        subHeader.font = [UIFont boldSystemFontOfSize:14];
        [mainContainer addSubview:subHeader];

        UILabel *features = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 210, 200)];
        features.text = @"• سرقة مواد الجيش: ✅\n• سرقة الميناء: ✅\n• طلق لانهائي: ✅\n• عامل المنجم: 🔜\n• توصيل الطلبات: 🔜";
        features.textColor = [UIColor whiteColor];
        features.numberOfLines = 0;
        features.font = [UIFont systemFontOfSize:14];
        [mainContainer addSubview:features];

        // 2. زرار الصقر
        actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.frame = CGRectMake(30, 180, 55, 55);
        actionBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        actionBtn.layer.cornerRadius = 27.5;
        actionBtn.layer.borderWidth = 1;
        actionBtn.layer.borderColor = [UIColor redColor].CGColor;
        [actionBtn setTitle:@"🦅" forState:UIControlStateNormal];
        
        [actionBtn addTarget:[SakrFinal class] action:@selector(switchMenu) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:actionBtn];
    });
}

// كود تعديل الموارد والطلق
int (*old_res)(void *instance);
int new_res(void *instance) {
    return 1; // تفعيل فوري لجمع الموارد
}

int (*old_a)(void *instance);
int new_a(void *instance) {
    return 999;
}
