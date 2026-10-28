"""Bundle only the iOS Maps key from Flutter's Dart defines; never log keys."""

import base64
import os
import pathlib
import plistlib


def maps_key(encoded_defines):
    for item in encoded_defines.split(","):
        if not item:
            continue
        decoded = base64.b64decode(item, validate=True).decode("utf-8")
        name, separator, value = decoded.partition("=")
        if separator and name == "GOOGLE_MAPS_IOS_API_KEY":
            return value.strip()
    return ""


def main():
    destination = (
        pathlib.Path(os.environ["TARGET_BUILD_DIR"])
        / os.environ["UNLOCALIZED_RESOURCES_FOLDER_PATH"]
        / "GoogleMapsConfig.plist"
    )
    destination.parent.mkdir(parents=True, exist_ok=True)
    # Always overwrite, so a build without keys cannot reuse a previous key.
    with destination.open("wb") as file:
        plistlib.dump({"APIKey": maps_key(os.environ.get("DART_DEFINES", ""))}, file)


if __name__ == "__main__":
    main()
