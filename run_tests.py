import subprocess
import sys
import os

def run_tests():
    # Change to the project directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # Run the service tests
    result = subprocess.run([
        sys.executable, "-m", "pytest", 
        "tests/test_services.py", 
        "-v", 
        "--tb=short",
        "--override-ini=addopts="
    ], capture_output=True, text=True)
    
    # Write results to a file
    with open("test_results.txt", "w") as f:
        f.write("STDOUT:\n")
        f.write(result.stdout)
        f.write("\nSTDERR:\n")
        f.write(result.stderr)
        f.write(f"\nReturn code: {result.returncode}\n")
    
    print(f"Tests completed with return code: {result.returncode}")
    print(f"Results written to test_results.txt")
    
    return result.returncode

if __name__ == "__main__":
    run_tests()