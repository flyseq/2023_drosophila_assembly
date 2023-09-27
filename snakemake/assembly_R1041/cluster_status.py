#!/usr/bin/env python3
import os
import sys
import warnings
import subprocess

jobid = sys.argv[-1]
state = subprocess.run(['sacct','-j',jobid,'--format=State'],stdout=subprocess.PIPE).stdout.decode('utf-8')
state = state.split('\n')[2].strip().strip('+')

map_state={"PENDING":'running',
       "RUNNING":'running', 
       "SUSPENDED":'running', 
       "CANCELLED":'failed', 
       "COMPLETING":'running', 
       "COMPLETED":'success', 
       "CONFIGURING":'running', 
       "FAILED":'failed',
       "TIMEOUT":'failed',
       "PREEMPTED":'failed',
       "NODE_FAIL":'failed',
       "REVOKED":'failed',
       "SPECIAL_EXIT":'failed',
       "":'success'}

print(map_state[state])
