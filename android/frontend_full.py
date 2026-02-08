import os

# ================= إعدادات السكريبت لمشروع FLUTTER المتكامل =================

# 1. اسم الملف النهائي
output_filename = 'flutter_full_code_dump.txt'

# 2. الامتدادات الشاملة لكل أجزاء مشروع فلاتر
included_extensions = [
    # Dart & Logic
    '.dart',       # كود فلاتر الأساسي
    '.env',        # ملفات المتغيرات البيئية
    
    # Configuration & Dependencies
    '.yaml',       # pubspec, analysis_options
    '.toml',       # أحياناً لبعض مكتبات الـ Rust أو الأدوات
    '.json',       # Assets config, Firebase config
    '.lock',       # (اختياري) لو عايز تشوف إصدارات المكتبات بالضبط
    
    # Android Platform
    '.gradle',     # build.gradle, settings.gradle
    '.xml',        # AndroidManifest, styles, drawable config
    '.properties', # local.properties, gradle.properties
    '.pro',        # Proguard rules
    '.kts',         # Kotlin code
    '.java',       # Java code (للمشاريع القديمة)
    
    # iOS / macOS Platform
    '.plist',      # Info.plist, GoogleService-Info
    '.swift',      # iOS logic
    '.m',          # Objective-C source
    '.h',          # Objective-C headers
    '.xcconfig',   # Xcode configurations
    '.podspec',    # CocoaPods config
    
    # Web Platform
    '.html',       # index.html
    '.js',         # web specific scripts
    '.css',        # web styling
    
    # Documentation & Git
    '.md',         # README, CHANGELOG
    '.gitignore'   # قواعد استبعاد الملفات
]

# 3. مجلدات يجب تجاهلها (الأرشيف، الكاش، والملفات الضخمة)
excluded_dirs = {
    'build', '.dart_tool', '.git', '.idea', '.vscode', 
    'Pods', '.gradle', 'flutter_assets', 'ios/Flutter', 
    'bin', 'obj', 'node_modules', 'vendor', 'dist'
}

# 4. ملفات محددة يفضل تجاهلها لأنها طويلة جداً وغير مفيدة برمجياً
excluded_files = {
    'pubspec.lock',     # طويل جداً وممل
    'package-lock.json', 
    'gradlew',          # ملفات تنفيذية
    'gradlew.bat'
}

# ================= بداية التنفيذ =================

def collect_flutter_project():
    print(f"🚀 Starting to collect code from: {os.getcwd()}")
    count = 0
    
    with open(output_filename, 'w', encoding='utf-8') as outfile:
        outfile.write(f"--- FLUTTER FULL PROJECT DUMP ---\n")
        outfile.write(f"Generated on: 2026-02-07\n")
        outfile.write("="*60 + "\n\n")

        for root, dirs, files in os.walk("."):
            # (1) تصفية المجلدات المستبعدة
            dirs[:] = [d for d in dirs if d not in excluded_dirs and not d.startswith('.')]

            for file in files:
                # (2) التحقق من الامتداد واسم الملف
                if any(file.endswith(ext) for ext in included_extensions):
                    if file in excluded_files:
                        continue

                    file_path = os.path.join(root, file)
                    
                    # تخطي الملف النهائي نفسه إذا كان في نفس المجلد
                    if file == output_filename:
                        continue

                    print(f"📦 Processing [{count+1}]: {file_path}")

                    outfile.write(f"\n{'#'*60}\n")
                    outfile.write(f"PATH: {file_path}\n")
                    outfile.write(f"{'#'*60}\n\n")

                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as infile:
                            outfile.write(infile.read())
                            count += 1
                    except Exception as e:
                        outfile.write(f"\n[⚠️ Error reading file: {e}]\n")
                    
                    outfile.write(f"\n\n{'*'*30} END OF FILE {'*'*30}\n")

    print(f"\n✅ Done! {count} files have been aggregated into: {output_filename}")

if __name__ == "__main__":
    collect_flutter_project()