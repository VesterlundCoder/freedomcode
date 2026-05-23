"""
freedomcode — Example 1: Python Hello World
Ask Continue.dev or Aider to extend this file.

Try in Continue chat:
  "Add a function that generates the Fibonacci sequence up to n terms"
"""

import sys
from datetime import datetime


def greet(name: str = "World") -> str:
    """Return a greeting string."""
    return f"Hello, {name}! It's {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"


def fibonacci(n: int) -> list[int]:
    """Generate the first n Fibonacci numbers."""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    seq = [0, 1]
    while len(seq) < n:
        seq.append(seq[-1] + seq[-2])
    return seq


if __name__ == "__main__":
    name = sys.argv[1] if len(sys.argv) > 1 else "World"
    print(greet(name))
    print(f"First 10 Fibonacci numbers: {fibonacci(10)}")
