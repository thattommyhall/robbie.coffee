numCPUs = require('os').cpus().length
child_process = require('child_process')
for i in [1..numCPUs]
  child_process.fork 'commandline'