import colorsys
import shutil
from pathlib import Path

import bpy


ROOT = Path(r"C:\Users\rainr\Documents\Blender\Symbol")
BACKUP = ROOT / "_backup_before_symbol_recolor"


def rgba_from_hsv(hue: float, saturation: float, value: float) -> tuple[float, float, float, float]:
    r, g, b = colorsys.hsv_to_rgb(hue % 1.0, saturation, value)
    return (r, g, b, 1.0)


def palette_for_file(file_index: int) -> dict[str, tuple[float, float, float, float]]:
    hue = (0.56 + file_index * 0.083) % 1.0
    companion = (hue + 0.12) % 1.0
    contrast = (hue + 0.5) % 1.0

    return {
        "BASE": rgba_from_hsv(hue, 0.74, 0.88),
        "BASE.001": rgba_from_hsv(companion, 0.66, 0.96),
        "BASE.002": rgba_from_hsv(hue, 0.58, 0.58),
        "BASE.003": rgba_from_hsv(contrast, 0.70, 0.92),
        "BASE.004": rgba_from_hsv((hue + 0.04) % 1.0, 0.34, 0.98),
        "Dots Stroke": (0.18, 0.18, 0.22, 1.0),
    }


def set_material_color(material: bpy.types.Material, rgba: tuple[float, float, float, float]) -> None:
    material.diffuse_color = rgba
    material.use_nodes = True

    principled = next(
        (node for node in material.node_tree.nodes if node.type == "BSDF_PRINCIPLED"),
        None,
    )
    if not principled:
        return

    if "Base Color" in principled.inputs:
        principled.inputs["Base Color"].default_value = rgba
    if "Alpha" in principled.inputs:
        principled.inputs["Alpha"].default_value = rgba[3]
    if "Roughness" in principled.inputs:
        principled.inputs["Roughness"].default_value = 0.44
    if "Metallic" in principled.inputs:
        principled.inputs["Metallic"].default_value = 0.08


def update_file(path: Path, file_index: int) -> None:
    bpy.ops.wm.open_mainfile(filepath=str(path))

    palette = palette_for_file(file_index)
    fallback = list(palette.values())
    for mat_index, material in enumerate(sorted(bpy.data.materials, key=lambda m: m.name.lower())):
        rgba = palette.get(material.name, fallback[mat_index % len(fallback)])
        set_material_color(material, rgba)

    for obj in bpy.data.objects:
        if obj.type == "FONT":
            obj.data.align_x = "CENTER"

    bpy.ops.wm.save_as_mainfile(filepath=str(path))

    png_path = path.with_suffix(".png")
    bpy.context.scene.render.filepath = str(png_path)
    bpy.ops.render.render(write_still=True)


def main() -> None:
    blend_files = sorted(ROOT.glob("*.blend"))
    BACKUP.mkdir(exist_ok=True)

    for blend_path in blend_files:
        backup_blend = BACKUP / blend_path.name
        if not backup_blend.exists():
            shutil.copy2(blend_path, backup_blend)

        png_path = blend_path.with_suffix(".png")
        if png_path.exists():
            backup_png = BACKUP / png_path.name
            if not backup_png.exists():
                shutil.copy2(png_path, backup_png)

    for file_index, blend_path in enumerate(blend_files):
        update_file(blend_path, file_index)
        print(f"UPDATED {blend_path.name} and {blend_path.with_suffix('.png').name}")

    print(f"DONE {len(blend_files)} files. Backups: {BACKUP}")


if __name__ == "__main__":
    main()
