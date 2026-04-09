import os
import re

# القاموس: النص الإنجليزي في الكود -> الـ Key في ملف الترجمة
replacements = {
    # Auth
    "'WELCOME TO EL GARAGE'": " 'auth.welcome_title'.tr()",
    "'PLEASE LOGIN TO HANDLE YOUR GARAGE'": " 'auth.login_subtitle'.tr()",
    '"PHONE NUMBER OR EMAIL"': " 'auth.identifier_label'.tr()",
    '"PASSWORD"': " 'auth.password_label'.tr()",
    "'LOGIN'": " 'auth.login_btn'.tr()",
    "'Don\\'t have an account? '": " 'auth.no_account'.tr()",
    "'Register'": " 'auth.register_link'.tr()",
    '"QUICK LOGIN WITH PHONE"': " 'auth.quick_phone_login'.tr()",
    '"SIGN IN WITH PHONE"': " 'auth.phone_auth_title'.tr()",
    '"SEND CODE"': " 'auth.send_code_btn'.tr()",
    '"VERIFICATION CODE"': " 'auth.otp_title'.tr()",
    '"RESEND CODE"': " 'auth.resend_btn'.tr()",
    
    # Register
    "'Complete Profile'": " 'auth.complete_profile_title'.tr()",
    "'Verify your details to get started'": " 'auth.complete_profile_desc'.tr()",
    "'Full Name'": " 'auth.full_name_label'.tr()",
    "'Email Address'": " 'auth.email_label'.tr()",
    "'Verified Phone'": " 'auth.verified_phone_label'.tr()",
    "'Confirm Password'": " 'auth.confirm_password_label'.tr()",
    "'CREATE ACCOUNT'": " 'auth.create_account_btn'.tr()",

    # Profile
    '"USER PROFILE"': " 'profile.title'.tr()",
    '"FULL NAME"': " 'profile.full_name_field'.tr()",
    '"EMAIL ADDRESS"': " 'profile.email_field'.tr()",
    '"PHONE NUMBER"': " 'profile.phone_field'.tr()",
    '"ACCOUNT TYPE"': " 'profile.account_type_field'.tr()",
    '"VERIFY NOW"': " 'profile.verify_now_btn'.tr()",
    '"CHANGE PASSWORD"': " 'profile.change_password_btn'.tr()",
    '"DELETE ACCOUNT"': " 'profile.delete_account_btn'.tr()",
    '"Delete Account?"': " 'profile.delete_confirm_title'.tr()",
}

IMPORT_LINE = "import 'package:easy_localization/easy_localization.dart';\n"

def process_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                original_content = content
                
                # تنفيذ الاستبدال
                for eng_text, tr_key in replacements.items():
                    content = content.replace(eng_text, tr_key)

                # إضافة الـ Import لو حصل تغيير ومكنش موجود
                if content != original_content and IMPORT_LINE not in content:
                    content = IMPORT_LINE + content

                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                if content != original_content:
                    print(f"✅ Updated: {file}")

if __name__ == "__main__":
    process_files("./lib")
    print("\n🚀 All done! Your lib folder is now localized.")