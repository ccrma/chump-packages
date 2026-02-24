#!/usr/bin/env python3

import os
import json
import hashlib
import urllib.request
import concurrent.futures
import sys
import traceback
import tempfile
import platform

from pathlib import Path


def sha256_file(path):
    """Compute sha256 of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def download_and_verify(entry, base_dir):
    url = entry["url"]
    expected_checksum = entry["checksum"]
    local_dir = entry.get("local_dir", "./")

    filename = os.path.basename(url)
    tmpdir = tempdir = Path("/tmp" if platform.system() == "Darwin" else tempfile.gettempdir())
    output_dir = os.path.abspath(os.path.join(tmpdir, base_dir, local_dir))
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, filename)

    try:
        urllib.request.urlretrieve(url, output_path)
    except Exception as e:
        return (False, f"Download failed: {url} → {e}")

    try:
        actual_checksum = sha256_file(output_path)
    except Exception as e:
        return (False, f"Checksum calculation failed: {output_path} → {e}")

    if actual_checksum != expected_checksum:
        return (
            False,
            f"Checksum mismatch for {url}\n"
            f"  Expected: {expected_checksum}\n"
            f"  Actual:   {actual_checksum}",
        )

    return (True, f"Verified: {url}")


def process_json_file(json_path):
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        return [], f"Failed to read JSON {json_path}: {e}"

    if "files" not in data:
        return [], None

    opsys = data["os"]
    arch = data["arch"]
    base_dir = os.path.join(os.path.dirname(json_path), opsys, arch)
    return [(entry, base_dir) for entry in data["files"]], None


def find_all_json_files(root_dir):
    # todo: remove all paths that contain "TestPackage" in path
        # we don't care about TestPackage
    paths = list(Path(root_dir).rglob("*.json"))

    blacklist = ["TestPackage", "TestPackageDir"]
    for item in blacklist:
        paths = [path for path in paths if item not in path.parts]
    return paths


def main(root_dir, max_workers=8):
    json_files = find_all_json_files(root_dir)

    tasks = []
    errors = []

    for json_file in json_files:
        entries, err = process_json_file(json_file)
        if err:
            errors.append(err)
        tasks.extend(entries)

    if not tasks:
        print("No downloadable entries found.")

    successes = 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(download_and_verify, entry, base_dir)
            for entry, base_dir in tasks
        ]

        for future in concurrent.futures.as_completed(futures):
            try:
                ok, message = future.result()
                if ok:
                    print(f"[OK] {message}")
                    successes += 1
                else:
                    print(f"[ERROR] {message}")
                    errors.append(message)
            except Exception:
                err_msg = traceback.format_exc()
                print(f"[ERROR] Unexpected failure:\n{err_msg}")
                errors.append(err_msg)

    print("\n--- Summary ---")
    print(f"Successful: {successes}")
    print(f"Errors:     {len(errors)}")

    if errors:
        print("\nErrors encountered:")
        for e in errors:
            print("-", e)
        sys.exit(1) # needs to fail if there are errors


if __name__ == "__main__":
    root = "./packages"
    workers = None

    main(root, workers)
