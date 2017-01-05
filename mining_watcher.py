#!/usr/bin/env python
import subprocess
import shemutils
import time
import gevent

log = shemutils.Logger("Ethereum Watcher")


class Profile(object):
	def __init__(self, user, ip):
		self.user = user
		self.ip = ip
		

def check_profile(p, process="ethminer.exe"):
	proc = subprocess.Popen("ssh {0}@{1} 'tasklist | findstr {2}'".format(p.user, p.ip, process), shell=True, stdout=subprocess.PIPE)
	stdout, stderr = proc.communicate()
	if process in stdout:
		k = True
	else:
		k = None
	return k

def send_notification(message, title="Your miner is idle!"):
	proc = subprocess.Popen('push -t "{0}" -m "{1}"'.format(title, message), shell=True, stdout=subprocess.PIPE)
	return proc.communicate()


def check_routine(profile):
	status = check_profile(profile)
	if not status:
		log.warning("Profile {0} is not mining!".format(profile.user))
		error_message = "RIG {0} is not mining!".format(profile.user)
		send_notification(error_message)

	return 0

def main():
	p1 = Profile("ANDRE", "192.168.1.125")
	p2 = Profile("Itslikehim", "192.168.1.203")
	lp = [p1,p2]	
	log.info("Program started with {0} miners.".format(len(lp)))
	try:
		x = 1
		while True:
			for p in lp:
				check_routine(p) 
			log.info("Checking procedure #{0}".format(x))
			time.sleep(60 * 30)
			x += 1
			
	except KeyboardInterrupt:
		log.critical("Interrupt detected.")
		
	return 0

if __name__ == "__main__":
	main()
