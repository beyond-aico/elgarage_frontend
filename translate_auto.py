import os
import re

# خريطة الترجمة الشاملة لجميع الملفات المرفقة
translation_map = {
    # Fleet Dashboard
    "HOLD ON, SYNCING DATA...": "fleet.syncing",
    "Search fleet...": "fleet.search_hint",
    "FROM": "fleet.from",
    "TO": "fleet.to",
    "ANALYTICS": "fleet.analytics_tab",
    "LIST VIEW": "fleet.list_view_tab",
    "Fleet Dashboard": "fleet.dashboard_title",
    "Odometer synced with server": "fleet.sync_success",
    "Sync failed, try again": "fleet.sync_failed",

    # Analytics Dashboard
    "TOTAL KMS": "fleet.total_kms",
    "AVG COST/KM": "fleet.avg_cost_km",
    "TOTAL COST": "fleet.total_cost",
    "FUEL": "fleet.fuel",
    "MAINTENANCE": "fleet.maintenance",
    "DISTANCE": "fleet.distance",
    "EFFICIENCY": "fleet.efficiency",
    "FUEL USAGE": "fleet.chart_fuel_usage_tab",
    "FUEL COST": "fleet.chart_fuel_cost_tab",
    "MAINTENANCE COST (EGP)": "fleet.chart_maint_cost",
    "DISTANCE DRIVEN (KM)": "fleet.chart_distance",
    "EFFICIENCY (KM/L)": "fleet.chart_efficiency",
    "FUEL USAGE (LITERS)": "fleet.chart_fuel_usage",
    "FUEL COST (EGP)": "fleet.chart_fuel_cost",
    "BRAND & MODEL": "fleet.table_brand",
    "PLATE": "fleet.table_plate",
    "CURRENT KM": "fleet.table_current_km",
    "STATUS": "fleet.table_status",
    "NEXT MAINT.": "fleet.table_next_maint",
    "URGENT: Maintenance needed": "fleet.status_urgent",
    "Healthy": "fleet.status_healthy",

    # Driver Screen (عربي وإنجليزي)
    "تسجيل وقود": "driver.fuel_tab",
    "حالة الصيانة": "driver.maint_tab",
    "Current KM": "driver.current_km_label",
    "Status": "driver.status_label",
    "Remaining": "driver.remaining_label",
    "✅ تم تحديث العداد وجدولة الصيانة بنجاح": "driver.success_msg",
    "حفظ وإرسال التقرير": "driver.submit_btn",
    "لم يتم العثور على سيارة مربوطة بحسابك.": "driver.no_car_error",
    "قراءة العداد الحالية (كم)": "driver.odometer_label",
    "كمية الوقود (لتر)": "driver.fuel_liters_label",
    "التكلفة الإجمالية (EGP)": "driver.total_cost_label",

    # Driver QR Scanner
    "Scan Vehicle Barcode": "driver.scan_title",
    "Place barcode inside box": "driver.scan_hint",
    "Invalid Code": "driver.invalid_code",
}

IMPORT_LINE = "import 'package:easy_localization/easy_localization.dart';"

def apply_smart_translation(content):
    modified = False
    for raw_text, key in translation_map.items():
        #Regex يبحث عن النص محاطاً بـ ' أو " ويتجاهل ما تم ترجمته مسبقاً (.tr())
        pattern = r'(?<!\.tr\(\))([\'"])\s*' + re.escape(raw_text) + r'\s*\1'
        replacement = f'"{key}".tr()'
        
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            modified = True
    return content, modified

def run_localization(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart") and file != "smart_translate.py":
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()

                    new_content, is_modified = apply_smart_translation(content)

                    if is_modified:
                        if IMPORT_LINE not in new_content:
                            new_content = f"{IMPORT_LINE}\n{new_content}"
                        
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"✅ تم تحديث: {file}")
                except Exception as e:
                    print(f"❌ خطأ في {file}: {e}")

if __name__ == "__main__":
    # تأكد من وضع السكريبت في lib/app_screens/fleet أو تغيير المسار لـ "."
    process_files_path = "." 
    print(f"🚀 جاري تعريب كافة النصوص في المجلد الحالي...")
    run_localization(process_files_path)
    print("\n✨ مبروك! الأسطول الآن يدعم العربية والإنجليزية بالكامل.")