# sandbox/views.py
import subprocess
import resource

def set_limits():
    # Set memory and time limits
    resource.setrlimit(resource.RLIMIT_CPU, (1, 1))  # 1 second CPU time
    resource.setrlimit(resource.RLIMIT_AS, (256 * 1024 * 1024, 256 * 1024 * 1024))  # 256 MB memory

def execute_code(code, input_data):
    try:
        process = subprocess.run(
            ["python3", "-c", code],
            input=input_data.encode(),
            capture_output=True,
            preexec_fn=set_limits,
            timeout=1  # 1 second timeout
        )
        return process.stdout.decode(), process.stderr.decode()
    except subprocess.TimeoutExpired:
        return None, "Time Limit Exceeded"
    except Exception as e:
        return None, str(e)