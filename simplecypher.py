#This script acts as a vigenere cipher, but I've only programmed 
#it to take an equal size string and key for higher levels of security

key = "weshiftforwardinfiresmirror"
text = "youareallgoingtoliedownhere"
#pclrzqspcotvvjkozzsihbvowva
#rorrimserifnidrawroftfihsew
key = key[::-1]
alpha = {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9, 'j': 10, 'k': 11, 'l': 12, 'm': 13, 'n': 14,
'o': 15, 'p':16, 'q':17, 'r':18, 's': 19, 't':20, 'u':21, 'v': 22, 'w': 23, 'x':24, 'y': 25, 'z':26}
count = 0
#print(alpha)
keyValues = []
iTextValues = []
fTextValues = []
ciphertext = ''
print(key)
if len(key) != len(text):
	print('Key and Text length must be the same!')
	exit()


# for i in key:
# 	for letter, digit in alpha.items():
# 		if i == letter:
# 			intValue += str(digit)

def findShift(key):
	for letter, digit in alpha.items():
		if key == letter:
			return str(digit)


print(findShift('d'))


def encode(fTextValue):
	for letter, digit in alpha.items():
		if fTextValue == digit:
			return letter



#Find Number Values for Key and Text

for i in key:
	keyValues.append(findShift(i))
	#print(findShift(i))

for i in text:
	iTextValues.append(findShift(i))
	#print(findShift(i))

#Shift the numbers forward 
for i in iTextValues:
	new = int(i) + int(keyValues[count]) - 1
	if new > 26:
		new = new - 26
	fTextValues.append(new)
	####***Tell me what's going on***####
#	print(i + ' was shifted ' + keyValues[count] + ' spaces and is now ' + str(new) + ' which is ' +  encode(new))
	count+=1

#Convert Numbers to text
for i in fTextValues:
	ciphertext += encode(i)
	#print(encode(i))



#Shift the numbers forward 






print(ciphertext)





	
