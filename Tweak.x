#import <UIKit/UIKit.h>

// تعريف النافذة والزرار
static UIWindow *overlayWindow = nil;
static UIButton *flyingButton = nil;

// دالة إظهار الرسالة والمنيو
void showSakrMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SAKR MENU" 
                                message:@"الطلق اللانهائي شغال ✅\nقريباً باقي المميزات" 
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

// تشغيل الهاك عند فتح اللعبة
__attribute__((constructor))
static void startSakr() {
    // استنى 10 ثواني عشان اللعبة تحمل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // إنشاء زرار الصقر
        flyingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        flyingButton.frame = CGRectMake(20, 150, 50, 50);
        flyingButton.backgroundColor = [UIColor blackColor];
        flyingButton.layer.cornerRadius = 25;
        [flyingButton setTitle:@"🦅" forState:UIControlStateNormal];
        flyingButton.alpha = 0.7;
        
        // ربط الزرار بالمنيو
        [flyingButton addTarget:[[UIApplication sharedApplication] delegate] action:@selector(showSakrMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // إضافة الزرار للشاشة
        [[[UIApplication sharedApplication] keyWindow] addSubview:flyingButton];
        
        // تنبيه التفعيل
        showSakrMenu();
    });
}

// كود الطلق اللانهائي - الطريقة الأبسط
int ammo_hack() {
    return 999;
}
