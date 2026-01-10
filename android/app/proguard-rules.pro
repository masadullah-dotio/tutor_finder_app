# Keep Stripe classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep push provisioning classes (optional Stripe feature)
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep Google services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
