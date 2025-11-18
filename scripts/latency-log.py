#!/usr/bin/env python3
import time
import subprocess
import sys


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: latency-log.py <target> <output-file>")
        sys.exit(1)

    target = sys.argv[1]
    outfile = sys.argv[2]

    with open(outfile, "a", encoding="utf-8") as f:
        while True:
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
            try:
                result = subprocess.run(
                    ["ping", "-c", "1", "-W", "1", target],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    check=False,
                )
                if "time=" in result.stdout:
                    latency = result.stdout.split("time=")[1].split(" ")[0]
                else:
                    latency = "timeout"
            except Exception:
                latency = "error"

            f.write(f"{timestamp}, {latency}\n")
            f.flush()
            time.sleep(1)


if __name__ == "__main__":
    main()
