import os
import re
import base64
import hashlib
import urllib.request
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("compiler")

def compile_mermaid_blocks(content, assets_dir):
    pattern = re.compile(r"```mermaid\n(.*?)\n```", re.DOTALL)
    
    def replace_block(match):
        mermaid_code = match.group(1).strip()
        
        # Hash code to create unique filename
        code_hash = hashlib.sha256(mermaid_code.encode("utf-8")).hexdigest()[:12]
        img_name = f"mermaid_{code_hash}.jpg"
        img_path = os.path.join(assets_dir, img_name)
        
        # Ensure image is generated
        if not os.path.exists(img_path):
            logger.info(f"Generating Mermaid diagram: {img_name}")
            try:
                encoded = base64.b64encode(mermaid_code.encode("utf-8")).decode("utf-8")
                url = f"https://mermaid.ink/img/{encoded}"
                req = urllib.request.Request(
                    url, 
                    headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
                )
                with urllib.request.urlopen(req) as response:
                    data = response.read()
                    
                with open(img_path, "wb") as f:
                    f.write(data)
                logger.info(f"Successfully cached Mermaid diagram to {img_path}")
            except Exception as e:
                logger.error(f"Failed to fetch Mermaid diagram from API: {e}")
                # Return code block back as fallback if API call fails
                return match.group(0)
                
        # Return empty string to strip from markdown text
        return ""

    return pattern.sub(replace_block, content)

def generate():
    content_dir = "/usr/local/google/home/sanchitalekh/Code/dnc/content/sections"
    assets_dir = "/usr/local/google/home/sanchitalekh/Code/dnc/web/assets/illustrations"
    output_file = "/usr/local/google/home/sanchitalekh/Code/dnc/web/lib/content/sections.g.dart"
    
    os.makedirs(assets_dir, exist_ok=True)
    
    sections = []
    files = sorted([f for f in os.listdir(content_dir) if f.endswith(".md")])
    
    for filename in files:
        path = os.path.join(content_dir, filename)
        with open(path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        if not lines:
            continue
            
        first_line = lines[0].strip()
        match = re.match(r"^#\s*§(\d+):\s*(.*)$", first_line)
        if not match:
            print(f"Warning: First line of {filename} does not match section pattern: '{first_line}'")
            continue
            
        index = int(match.group(1))
        title = match.group(2)
        
        # Parse body content and compile any Mermaid codeblocks to images
        body = "".join(lines[1:])
        body_compiled = compile_mermaid_blocks(body, assets_dir)
        
        sections.append({
            "index": index,
            "title": title,
            "content": body_compiled
        })
        
    # Now generate the Dart file
    with open(output_file, "w", encoding="utf-8") as out:
        out.write("// Generated file. Do not edit manually.\n")
        out.write("import 'section.dart';\n\n")
        out.write("const List<Section> sections = [\n")
        
        for sec in sections:
            out.write("  Section(\n")
            out.write(f"    index: {sec['index']},\n")
            title_escaped = sec['title'].replace('"', '\\"')
            out.write(f"    title: \"{title_escaped}\",\n")
            # Using Dart raw string literal with triple single quotes
            content_escaped = sec['content'].replace("'''", "' ' '")
            out.write(f"    content: r'''{content_escaped}''',\n")
            out.write("  ),\n")
            
        out.write("];\n")
        
    print(f"Successfully generated {output_file} with {len(sections)} sections.")

if __name__ == "__main__":
    generate()
