import subprocess

cmd = "py.test --cov=fixedpoint --cov-report html tests/"

with subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) as p:
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
