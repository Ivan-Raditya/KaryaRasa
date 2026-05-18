import colorsys
import math
import os
import shutil
from pathlib import Path

import bpy


ROOT = Path(r"C:\Users\rainr\Documents\Blender\Monero Coin\MONERO COIN")
BACKUP = ROOT / "_backup_before_recolor_angle_text"

NEW_TEXT = {
    "ADD": "MINT",
    "AIRDROP": "CLAIM",
    "APP": "VAULT",
    "BEAR": "DIP",
    "BID": "OFFER",
    "BLOCK": "CHAIN",
    "BLOCKCHAIN": "PRIVACY",
    "BULL": "PUMP",
    "COIN": "XMR",
    "DAPP": "NODE",
    "FEE": "GAS",
    "HASH": "PROOF",
    "HODL": "HOLD",
    "KEY": "SEED",
    "LEDGER": "RECORD",
    "MIN": "DIG",
    "MINING": "HASHRATE",
    "P2P": "PEER",
    "POOL": "MINERS",
    "RATE": "PRICE",
    "STAKING": "LOCK",
    "TOKEN": "ASSET",
    "TXID": "TRACE",
    "WAL": "SAFE",
    "WALLET": "COLD",
}


def make_color(file_index: int, mat_index: int) -> tuple[float, float, float, float]:
    hue = ((file_index * 0.071) + (mat_index * 0.137) + 0.44) % 1.0
    saturation = 0.54 + ((file_index + mat_index) % 4) * 0.08
    value = 0.58 + ((file_index * 2 + mat_index) % 3) * 0.1
    r, g, b = colorsys.hsv_to_rgb(hue, min(saturation, 0.82), min(value, 0.86))
    return (r, g, b, 1.0)


def set_material_color(material: bpy.types.Material, rgba: tuple[float, float, float, float]) -> None:
    material.diffuse_color = rgba
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    if principled:
        if "Base Color" in principled.inputs:
            principled.inputs["Base Color"].default_value = rgba
        if "Alpha" in principled.inputs:
            principled.inputs["Alpha"].default_value = rgba[3]
        if "Roughness" in principled.inputs:
            principled.inputs["Roughness"].default_value = 0.42
        if "Metallic" in principled.inputs:
            principled.inputs["Metallic"].default_value = 0.18


def update_file(path: Path, file_index: int) -> None:
    bpy.ops.wm.open_mainfile(filepath=str(path))

    stem = path.stem.upper()
    replacement = NEW_TEXT.get(stem, f"XMR {file_index + 1:02d}")
    for obj in bpy.data.objects:
        if obj.type == "FONT":
            obj.data.body = replacement
            obj.data.align_x = "CENTER"

    for mat_index, material in enumerate(sorted(bpy.data.materials, key=lambda m: m.name.lower())):
        set_material_color(material, make_color(file_index, mat_index))

    angle_z = math.radians(12 + (file_index % 6) * 5)
    angle_x = math.radians(-7 + (file_index % 5) * 2.5)
    for obj in bpy.data.objects:
        if obj.type in {"MESH", "FONT"} and obj.name.lower() != "backlight":
            obj.rotation_euler.rotate_axis("Z", angle_z)
            obj.rotation_euler.rotate_axis("X", angle_x)

    camera = next((obj for obj in bpy.data.objects if obj.type == "CAMERA"), None)
    if camera:
        camera.location.x += 0.28 + (file_index % 4) * 0.06
        camera.location.z += 0.16 + (file_index % 3) * 0.05
        camera.rotation_euler.rotate_axis("Z", math.radians(4 + file_index % 5))
        camera.rotation_euler.rotate_axis("X", math.radians(-2.5))

    bpy.ops.wm.save_as_mainfile(filepath=str(path))


def main() -> None:
    blend_files = sorted(ROOT.glob("*.blend"))
    BACKUP.mkdir(exist_ok=True)

    for path in blend_files:
        backup_path = BACKUP / path.name
        if not backup_path.exists():
            shutil.copy2(path, backup_path)

    for file_index, path in enumerate(blend_files):
        update_file(path, file_index)
        print(f"UPDATED {path.name} -> {NEW_TEXT.get(path.stem.upper(), 'XMR')}")

    print(f"DONE {len(blend_files)} files. Backups: {BACKUP}")


if __name__ == "__main__":
    main()
