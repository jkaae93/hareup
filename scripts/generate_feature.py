#!/usr/bin/env python3
"""Generate conservative Flutter scaffolding from a feature architecture document."""
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def generate(root: Path, feature: str, dry_run: bool = False) -> list[Path]:
    if not re.fullmatch(r'[a-z][a-z0-9]*(?:_[a-z0-9]+)*', feature):
        raise ValueError('Feature must be a lower_snake_case directory name.')
    directory = root / 'lib' / 'features' / feature
    doc = directory / 'ARCHITECTURE.md'
    if not doc.is_file():
        raise ValueError(f'Architecture document not found: {doc}')
    content = doc.read_text(encoding='utf-8')
    match = re.search(r'^- 상태·계약:\s*(.+)$', content, re.MULTILINE)
    if not match:
        raise ValueError('Architecture document has no 상태·계약 entry.')
    contract = match.group(1)
    cubits = list(dict.fromkeys(re.findall(r'\b[A-Z][A-Za-z0-9]*Cubit\b', contract)))
    repositories = list(dict.fromkeys(re.findall(r'\b[A-Z][A-Za-z0-9]*Repository\b', contract)))
    if len(cubits) != 1 or len(repositories) > 1:
        raise ValueError('Expected exactly one Cubit and at most one repository in 상태·계약.')
    cubit = cubits[0]
    base = cubit[:-5]
    snake = lambda name: re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()
    stem = snake(base)
    repository = repositories[0] if repositories else None
    repo_file = f'{snake(repository)}.dart' if repository else None
    files = {}
    if repository:
        files[directory / 'domain' / repo_file] = (
            f'/// Contract to be specified from ARCHITECTURE.md before integration.\n'
            f'abstract interface class {repository} {{}}\n')
    imports = "import 'package:hareup_presentation_core/presentation_core.dart';\n"
    if repository:
        imports += f"import '../domain/{repo_file}';\n"
    constructor = (f'{cubit}(this.repository) : super(const {base}State());\n'
                   f'  final {repository} repository;' if repository else
                   f'{cubit}() : super(const {base}State());')
    files[directory / 'presentation' / f'{stem}_state.dart'] = (
        f'/// Replace with the feature state described in ARCHITECTURE.md.\n'
        f'class {base}State {{\n  const {base}State();\n}}\n')
    imports += f"import '{stem}_state.dart';\n"
    files[directory / 'presentation' / f'{stem}_cubit.dart'] = (
        f'{imports}\n/// Implement the feature operations and state described in ARCHITECTURE.md.\n'
        f'class {cubit} extends BaseCubit<{base}State> {{\n  {constructor}\n}}\n')
    files[directory / 'presentation' / f'{stem}_page.dart'] = (
        "import 'package:flutter/material.dart';\n\n"
        f'/// Replace this placeholder with the flow described in ARCHITECTURE.md.\n'
        f'class {base}Page extends StatelessWidget {{\n'
        f'  const {base}Page({{super.key}});\n\n'
        '  @override\n  Widget build(BuildContext context) => const Scaffold(\n'
        "    body: Center(child: Text('구현 예정')),\n  );\n}\n")
    conflicts = [path for path in files if path.exists()]
    if conflicts:
        raise ValueError('Refusing to overwrite existing files: ' + ', '.join(str(p) for p in conflicts))
    if not dry_run:
        for path, text in files.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding='utf-8')
    return list(files)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('feature', help='Existing feature folder, e.g. photo_analysis')
    parser.add_argument('--dry-run', action='store_true', help='Show paths without writing files')
    args = parser.parse_args()
    try:
        paths = generate(ROOT, args.feature, args.dry_run)
    except ValueError as error:
        print(f'Error: {error}', file=sys.stderr)
        return 1
    for path in paths:
        print(path.relative_to(ROOT))
    return 0


if __name__ == '__main__':
    sys.exit(main())
