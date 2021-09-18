import subprocess

cmd = "py.test --cov=fixedpoint --cov-report html tests/"

p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for line in p.stdout.readlines():
    print(line)
retval = p.wait()
