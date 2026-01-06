import importlib.util
import glob
import os
import sys


def load_module_from_path(path):
    name = os.path.splitext(os.path.basename(path))[0]
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_tests(tests_dir="tests"):
    failures = []
    sys.path.insert(0, os.path.abspath(".."))  # make backend package importable
    for path in glob.glob(os.path.join(tests_dir, "test_*.py")):
        mod = load_module_from_path(path)
        for attr in dir(mod):
            if attr.startswith("test_") and callable(getattr(mod, attr)):
                try:
                    print(f"RUN {mod.__name__}.{attr}")
                    getattr(mod, attr)()
                except AssertionError as e:
                    failures.append((mod.__name__, attr, str(e)))
                except Exception as e:
                    failures.append((mod.__name__, attr, f"ERROR: {e}"))
    if failures:
        print("\nFAILURES:")
        for m, f, msg in failures:
            print(f" - {m}.{f}: {msg}")
        sys.exit(1)
    print("\nAll tests passed")


if __name__ == "__main__":
    run_tests()
