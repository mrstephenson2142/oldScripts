import csv
from datetime import datetime


# This script will look through a specifically formatted firewall output and attempt to match a list of time stamps to the firewall output. 
# If a pattern can be found the NAT public and private addresses will be printed. 
# This was used to try to identify the private address from a public NAT in response to complaints from 3rd parties 
# that reported the address. 

#Reference Variables
times = ["2019/01/02 10:20:55","2019/01/02 10:24:13","2019/01/02 10:13:38","2019/01/02 10:20:50","2019/01/02 10:20:52","2019/01/02 10:20:53"]
time2 = ["2019/01/01 10:11:38","2019/01/01 10:13:38","2019/01/01 10:20:50","2019/01/01 10:20:53","2019/01/01 10:20:55","2019/01/01 10:24:13","2019/01/02 10:13:38","2019/01/02 10:20:50","2019/01/02 10:20:52","2019/01/02 10:20:53","2019/01/02 10:20:55","2019/01/02 10:24:13"]
fTimes = []
timeDiff = []
timeDiff2 = []
#Firewall Export Varialbes
csvName = 'firewall_test_test.csv'
finalDict = {}


### Functions
## Format Dates
def format_time(times):
	fTimes = []
	for i in times:
		adding = datetime.strptime(i, '%Y/%m/%d %H:%M:%S')
		fTimes.append(adding)
	return fTimes



## Calc Differences

def calc_difference(fTimes):
	timeDiff = []
	fTimes = sorted(list(dict.fromkeys(fTimes)))
	i=0
	while i < (len(fTimes)-1):
		timeDiff.append(fTimes[i+1] - fTimes[i])
		i=i+1
	return timeDiff

## Compare all Libraries against reference times

def compare_against_ref(k, m, timebiff, timebiff2):
	counter = 0
	for i in timebiff2:
		
		#print(str(counter) + ': ' + str(i) + ' ' + str(timeDiff[counter]) )	
		if i == timebiff[0]:
			innerWCount = 0
			innerCounter = counter
			print('++ Found Possible Match ' + k + ' -> ' + m + ' ++')
			
			while innerWCount < len(timebiff):
				# if (len(timeDiff2) - counter) < len(timeDiff):
				# 	print('Not enough entries in series to continue.')
				# 	break
				#print('Attempt:' + str(innerWCount) + str(timeDiff2[innerCounter]) + ' ' + str(timeDiff[innerWCount]))
				try: 
					if timebiff2[innerCounter] == timebiff[innerWCount]:
						print('Attempt:' + str(innerWCount) + ' Pass '+ str(timebiff2[innerCounter]) + ' ' + str(timebiff[innerWCount]))
					else: 
						print('Attempt:' + str(innerWCount) + ' Fail')
						break
				except IndexError: 
					print('Attempt:' + str(innerWCount) + ' Not enough entries in target to continue...')
				finally:
					innerCounter = innerCounter + 1 
					innerWCount = innerWCount + 1
		counter = counter + 1
	

## Calc Reference times
fTimes = format_time(times)		
timeDiff = calc_difference(fTimes)
timeDiff2 = calc_difference(format_time(time2))

## Import CSV 
with open(csvName, newline='') as csvfile:
	reader = csv.reader(csvfile)
infile = csv.DictReader(open(csvName))

## Load Firewall Data into Final Dict 
#loop through the dictionaries
for row in infile:
	#print(row['client_ip'])
#if client_ip doest not exist create client_ip key in dictionary
	if row['client_ip'] not in finalDict:
		finalDict[row['client_ip']] = {}
#check for dest ip
	if row['dest_ip'] not in finalDict[row['client_ip']]:
		finalDict[row['client_ip']][row['dest_ip']] = {'dtimes': [], 'timeDiff': []}
	finalDict[row['client_ip']][row['dest_ip']]['dtimes'].append(row['start_time'])

for k, v in finalDict.items():
	#print(k, v)
	for m, p in v.items():
		#print(m, p)
		fwTime = []
		fwTime = calc_difference(format_time(p['dtimes']))
		p['timeDiff'] = fwTime
		
		compare_against_ref(k, m, timeDiff, p['timeDiff'])	
