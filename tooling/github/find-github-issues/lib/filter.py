"""Read graphql output on stdin, apply filter.jq with skipped-issue numbers
loaded from .skipped-issues.yaml in cwd, write survivors to stdout."""
import json
import pathlib
import sys

import jq
import yaml


def main():
    skipped_path = pathlib.Path(".skipped-issues.yaml")
    if skipped_path.exists():
        entries = yaml.safe_load(skipped_path.read_text()) or []
        skipped = [e["number"] for e in entries]
    else:
        skipped = []

    filter_jq = pathlib.Path(__file__).resolve().parent.parent / "filter.jq"
    program = jq.compile(filter_jq.read_text(), args={"skipped": skipped})
    data = json.load(sys.stdin)
    json.dump(program.input_value(data).first(), sys.stdout)
    sys.stdout.write("\n")
