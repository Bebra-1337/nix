#!/usr/bin/env python3
import json
import sys
import os

def convert_scheme(input_path, output_path):
    with open(input_path, 'r') as f:
        src = json.load(f)

    # Base mapping from user's keys to Matugen keys
    key_mapping = {
        "primary": "mPrimary",
        "on_primary": "mOnPrimary",
        "primary_container": "mPrimary",
        "on_primary_container": "mOnPrimary",
        "secondary": "mSecondary",
        "on_secondary": "mOnSecondary",
        "secondary_container": "mSecondary",
        "on_secondary_container": "mOnSecondary",
        "tertiary": "mTertiary",
        "on_tertiary": "mOnTertiary",
        "tertiary_container": "mTertiary",
        "on_tertiary_container": "mOnTertiary",
        "error": "mError",
        "on_error": "mOnError",
        "error_container": "mError",
        "on_error_container": "mOnError",
        "background": "mSurface",
        "on_background": "mOnSurface",
        "surface": "mSurface",
        "on_surface": "mOnSurface",
        "surface_variant": "mSurfaceVariant",
        "on_surface_variant": "mOnSurfaceVariant",
        "outline": "mOutline",
        "outline_variant": "mOutline",
        "shadow": "mShadow",
        "scrim": "mShadow",
        "inverse_surface": "mOnSurface",
        "inverse_on_surface": "mSurface",
        "inverse_primary": "mPrimary",
        "primary_fixed": "mPrimary",
        "primary_fixed_dim": "mPrimary",
        "on_primary_fixed": "mOnPrimary",
        "on_primary_fixed_variant": "mOnPrimary",
        "secondary_fixed": "mSecondary",
        "secondary_fixed_dim": "mSecondary",
        "on_secondary_fixed": "mOnSecondary",
        "on_secondary_fixed_variant": "mOnSecondary",
        "tertiary_fixed": "mTertiary",
        "tertiary_fixed_dim": "mTertiary",
        "on_tertiary_fixed": "mOnTertiary",
        "on_tertiary_fixed_variant": "mOnTertiary",
        "surface_dim": "mSurface",
        "surface_bright": "mSurfaceVariant",
        "surface_container_lowest": "mSurface",
        "surface_container_low": "mSurface",
        "surface_container": "mSurfaceVariant",
        "surface_container_high": "mSurfaceVariant",
        "surface_container_highest": "mSurfaceVariant",
        "surface_tint": "mPrimary",
        "source_color": "mPrimary"
    }

    dst = {
        "colors": {},
        "image": None,
        "is_dark_mode": True,
        "mode": "dark",
        "palettes": {}
    }

    # Populate colors object
    for matugen_key, user_key in key_mapping.items():
        dark_val = src["dark"].get(user_key, "#000000")
        light_val = src["light"].get(user_key, "#ffffff")
        dst["colors"][matugen_key] = {
            "dark": { "color": dark_val },
            "light": { "color": light_val },
            "default": { "color": dark_val }
        }

    # Populate base16 object
    base16_mapping = {
        "base00": "mSurface",
        "base01": "mSurfaceVariant",
        "base02": "mSurfaceVariant",
        "base03": "mOnSurfaceVariant",
        "base04": "mOnSurface",
        "base05": "mOnSurface",
        "base06": "mOnSurface",
        "base07": "mOnSurface",
        "base08": "mError",
        "base09": "mSecondary",
        "base0a": "mPrimary",
        "base0b": "mTertiary",
        "base0c": "mTertiary",
        "base0d": "mSecondary",
        "base0e": "mError",
        "base0f": "mTertiary"
    }

    dst["base16"] = {}
    for b16_key, user_key in base16_mapping.items():
        dark_val = src["dark"].get(user_key, "#000000")
        light_val = src["light"].get(user_key, "#ffffff")
        dst["base16"][b16_key] = {
            "dark": { "color": dark_val },
            "light": { "color": light_val },
            "default": { "color": dark_val }
        }

    with open(output_path, 'w') as f:
        json.dump(dst, f, indent=2)
    print(f"Successfully converted and saved to {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 import_scheme.py <input_scheme.json> <output_matugen_import.json>")
        sys.exit(1)
    convert_scheme(sys.argv[1], sys.argv[2])
