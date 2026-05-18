import shutil
from pathlib import Path

import bpy


ROOT = Path(r"C:\Users\rainr\Documents\Blender\Monero Coin\MONERO COIN")
BACKUP = ROOT / "_backup_before_recolor_angle_text"


def main() -> None:
    blend_files = sorted(ROOT.glob("*.blend"))
    BACKUP.mkdir(exist_ok=True)

    for path in blend_files:
        png_path = path.with_suffix(".png")
        backup_png = BACKUP / png_path.name
        if png_path.exists() and not backup_png.exists():
            shutil.copy2(png_path, backup_png)

        bpy.ops.wm.open_mainfile(filepath=str(path))
        bpy.context.scene.render.filepath = str(png_path)
        bpy.ops.render.render(write_still=True)
        print(f"RENDERED {png_path.name}")

    print(f"DONE {len(blend_files)} previews. Backups: {BACKUP}")


if __name__ == "__main__":
    main()
