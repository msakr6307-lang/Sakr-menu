#import <UIKit/UIKit.h>

// تعريف المتغيرات اللي هنحكم فيها من المنيو
bool autoMine = false;
bool magicBullet = false;
float bulletRadius = 100.0f;

// --- [ 1. ميزة الطلقة السحرية ] ---
// تعديل مسار الطلقة (كود مبسط)
void (*old_Shoot)(void *instance);
void new_Shoot(void *instance) {
    if (magicBullet) {
        // هنا بيتم توجيه الطلقة تلقائياً
        NSLog(@"[Sakr] Magic Bullet Active");
    }
    old_Shoot(instance);
}

// --- [ 2. ميزة البوت (المنجم) ] ---
void setupAutoMine() {
    if (autoMine) {
        // منطق العمل التلقائي
        NSLog(@"[Sakr] Mining Bot Working...");
    }
}

// --- [ 3. تشغيل المنيو عند فتح اللعبة ] ---
__attribute__((constructor))
static void initialize() {
    NSLog(@"[Sakr] OneState Mod Loaded Successfully!");
    
    // إظهار تنبيه عند دخول اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sakr Menu" message:@"الهاك اشتغل بنجاح يا مصطفى" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"تمام" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
