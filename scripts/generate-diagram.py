#!/usr/bin/env python3
"""Generate a stylized hero banner using Amazon Nova Canvas."""
import json, base64, random, sys, boto3

PROMPTS = {
    "banner": """
A sleek modern technology infographic banner image. Dark navy blue gradient background.
On the left side, show a glowing terminal window with code lines.
In the center, a bright orange hexagonal hub icon radiating connection lines.
On the right side, show a monitoring dashboard with charts and graphs in green.
Below, show cloud infrastructure icons in orange.
Flowing gradient lines connect all elements in a smooth arc pattern.
Style: flat vector illustration, tech startup aesthetic, neon glow effects on dark background,
AWS orange and Dynatrace green accent colors. No text, no words, no labels, no letters.
Ultra clean, minimal, professional. Wide cinematic composition.
""",
    "ecosystem": """
A beautiful modern technology ecosystem map illustration on dark background.
Show 4 glowing device silhouettes on the left (laptop, tablet, phone, desktop monitor) 
connected by bright flowing energy lines to a central glowing orb.
From the central orb, lines flow right to two cloud shapes - one green, one orange.
The green cloud has monitoring/chart symbols. The orange cloud has infrastructure symbols.
Style: abstract, futuristic, dark navy background, neon orange and green glowing lines,
particle effects along the connection paths, no text whatsoever, no words, no labels.
Clean vector art meets sci-fi aesthetic. Wide 16:9 cinematic.
""",
}

def main():
    style = sys.argv[1] if len(sys.argv) > 1 else "ecosystem"
    output = sys.argv[2] if len(sys.argv) > 2 else "docs/assets/kiro-dt-banner.png"

    if style not in PROMPTS:
        print(f"Usage: {sys.argv[0]} [{'/'.join(PROMPTS.keys())}] [output.png]")
        sys.exit(1)

    client = boto3.client("bedrock-runtime", region_name="us-east-1")
    body = json.dumps({
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": PROMPTS[style].strip()},
        "imageGenerationConfig": {
            "seed": random.randint(0, 858993459),
            "quality": "premium",
            "width": 1280,
            "height": 720,
            "numberOfImages": 1,
        },
    })

    print(f"Generating '{style}' image...")
    resp = client.invoke_model(
        modelId="amazon.nova-canvas-v1:0", body=body,
        contentType="application/json", accept="application/json",
    )
    result = json.loads(resp["body"].read())
    if result.get("error"):
        print(f"Error: {result['error']}"); sys.exit(1)

    data = base64.b64decode(result["images"][0])
    with open(output, "wb") as f:
        f.write(data)
    print(f"✅ Saved to {output} ({len(data)//1024}KB)")

if __name__ == "__main__":
    main()
