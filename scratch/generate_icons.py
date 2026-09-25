import os
from PIL import Image

SRC_IMAGE = "/Users/paulo/.gemini/antigravity-ide/brain/a5611b7a-5a84-4b29-b5f4-1b88331447c4/tensortimer_app_icon_1790281687109.jpg"
IOS_APPICON_DIR = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES_DIR = "android/app/src/main/res"
ASSETS_ICON_DIR = "assets/icon"

os.makedirs(ASSETS_ICON_DIR, exist_ok=True)
os.makedirs(IOS_APPICON_DIR, exist_ok=True)

img = Image.open(SRC_IMAGE).convert("RGBA")

# 1. Master 1024x1024 PNG
master_1024 = img.resize((1024, 1024), Image.Resampling.LANCZOS)
master_1024.save(os.path.join(ASSETS_ICON_DIR, "app_icon_1024.png"), format="PNG")
master_1024.save(os.path.join(IOS_APPICON_DIR, "Icon-App-1024x1024@1x.png"), format="PNG")

# 2. iOS Sizes
ios_sizes = {
    "Icon-App-20x20@1x.png": (20, 20),
    "Icon-App-20x20@2x.png": (40, 40),
    "Icon-App-20x20@3x.png": (60, 60),
    "Icon-App-29x29@1x.png": (29, 29),
    "Icon-App-29x29@2x.png": (58, 58),
    "Icon-App-29x29@3x.png": (87, 87),
    "Icon-App-40x40@1x.png": (40, 40),
    "Icon-App-40x40@2x.png": (80, 80),
    "Icon-App-40x40@3x.png": (120, 120),
    "Icon-App-60x60@2x.png": (120, 120),
    "Icon-App-60x60@3x.png": (180, 180),
    "Icon-App-76x76@1x.png": (76, 76),
    "Icon-App-76x76@2x.png": (152, 152),
    "Icon-App-83.5x83.5@2x.png": (167, 167),
}

for name, size in ios_sizes.items():
    resized = img.resize(size, Image.Resampling.LANCZOS)
    resized.save(os.path.join(IOS_APPICON_DIR, name), format="PNG")
    print(f"Generated iOS icon: {name} ({size[0]}x{size[1]})")

# 3. Android Sizes
android_sizes = {
    "mipmap-mdpi": (48, 48),
    "mipmap-hdpi": (72, 72),
    "mipmap-xhdpi": (96, 96),
    "mipmap-xxhdpi": (144, 144),
    "mipmap-xxxhdpi": (192, 192),
}

for folder, size in android_sizes.items():
    folder_path = os.path.join(ANDROID_RES_DIR, folder)
    os.makedirs(folder_path, exist_ok=True)
    resized = img.resize(size, Image.Resampling.LANCZOS)
    target_path = os.path.join(folder_path, "ic_launcher.png")
    resized.save(target_path, format="PNG")
    print(f"Generated Android icon: {target_path} ({size[0]}x{size[1]})")

print("All TensionTimer icons generated successfully!")
