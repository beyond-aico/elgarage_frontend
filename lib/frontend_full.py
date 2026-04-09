import os

# ================= إعدادات السكريبت لمشروع FLUTTER =================

# 1. اسم الملف النهائي
output_filename = 'frontend_lib.txt'

# 2. الامتدادات المهمة في فلاتر (Dart, Config, Android Build)
included_extensions = [
    '.dart',       # كود التطبيق الأساسي
    '.yaml',       # ملفات الإعدادات (pubspec.yaml)
    '.gradle',     # إعدادات البناء للأندرويد
    '.xml',        # المانيفست (Android Manifest)
    '.plist',      # إعدادات الآيفون (Info.plist)
    '.json'        # أحياناً يستخدم للـ assets أو config
]

# 3. مجلدات يجب تجاهلها تماماً في فلاتر (عشان الملف ما يبقاش جيجا بايت!)
excluded_dirs = {
    'build',           # مجلد البناء (ضخم جداً)
    '.dart_tool',      # أدوات فلاتر المساعدة
    '.git',            # ملفات الجيت
    '.idea',           # إعدادات أندرويد ستوديو
    '.vscode',         # إعدادات VS Code
    'Pods',            # مكتبات iOS (CocoaPods)
    '.gradle',         # كاش الجرادل
    'flutter_assets',  # مجلدات مؤقتة
    'ios/Flutter'      # ملفات Generated للفريم وورك
}

# ================= بداية التنفيذ =================

def collect_flutter_code():
    with open(output_filename, 'w', encoding='utf-8') as outfile:
        
        outfile.write(f"--- FLUTTER PROJECT DUMP ---\n")
        outfile.write(f"Target Extensions: {included_extensions}\n")
        outfile.write("="*50 + "\n\n")

        for root, dirs, files in os.walk("."):
            
            # (1) تنظيف المجلدات المستبعدة
            # هذا السطر يمنع السكريبت من الدخول في المجلدات الضخمة
            dirs[:] = [d for d in dirs if d not in excluded_dirs and not d.startswith('.')]

            for file in files:
                if any(file.endswith(ext) for ext in included_extensions):
                    # استثناء إضافي: ملف pubspec.lock مش مفيد أوي في القراءة، ممكن نتجاهله لو حابب
                    if file == 'pubspec.lock':
                        continue

                    file_path = os.path.join(root, file)
                    print(f"Processing: {file_path}") 

                    outfile.write(f"\n{'='*50}\n")
                    outfile.write(f"FILE START: {file_path}\n")
                    outfile.write(f"{'='*50}\n\n")

                    try:
                        with open(file_path, 'r', encoding='utf-8') as infile:
                            outfile.write(infile.read())
                    except Exception as e:
                        outfile.write(f"\n[Error reading file: {e}]\n")
                    
                    outfile.write(f"\n\n{'='*50}\n")
                    outfile.write(f"FILE END: {file_path}\n")
                    outfile.write(f"{'='*50}\n")

    print(f"\n✅ Done! Flutter code saved to: {output_filename}")

if __name__ == "__main__":
    collect_flutter_code()