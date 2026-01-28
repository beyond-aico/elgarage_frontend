import os

output_filename = "backend_full_code.txt"

# امتدادات ملفات الباك إند الشائعة (Node.js, Python, PHP, etc)
included_extensions = [
    '.js', '.ts', '.json',           # Node.js / TypeScript
    '.py',                           # Python
    '.php',                          # PHP
    '.env', '.env.example',          # Config
    '.yml', '.yaml',                 # Docker / CI
    '.sql', '.prisma',               # Database
    '.xml', '.java'                  # Java / Spring (Just in case)
]

ignored_dirs = {
    'node_modules', 'venv', '.git', '.idea', '__pycache__', 
    'dist', 'build', 'coverage', 'tmp', 'logs'
}

def collect_files():
    with open(output_filename, 'w', encoding='utf-8') as outfile:
        for root, dirs, files in os.walk("."):
            dirs[:] = [d for d in dirs if d not in ignored_dirs]
            
            for file in files:
                if any(file.endswith(ext) for ext in included_extensions):
                    # تجاهل ملفات القفل الكبيرة
                    if 'lock' in file: continue
                    
                    file_path = os.path.join(root, file)
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as infile:
                            outfile.write(f"\n{'='*50}\nFILE: {file_path}\n{'='*50}\n\n")
                            outfile.write(infile.read())
                            outfile.write("\n")
                            print(f"Added: {file_path}")
                    except Exception as e:
                        print(f"Skipped {file_path}: {e}")

    print(f"\n✅ Done! Saved to: {output_filename}")

if __name__ == "__main__":
    collect_files()