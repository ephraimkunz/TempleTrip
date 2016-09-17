# Objective: Get all the temple dedicatory prayers in a nice output format by scraping ldschurchtemples.com

from bs4 import BeautifulSoup
import urllib2
import json


#1 Get the list of temple links we need to go through. Return list of strings
def getTempleShortNames():

	response = urllib2.urlopen('http://www.ldschurchtemples.com/temples/')
	html = response.read()
	soup = BeautifulSoup(html, 'html.parser')
	parent = soup.find_all('table', 'list')[0]

	print 'Begin fetching dedicatory prayers for', len(parent.find_all('a')), 'temples'

	results = []
	for anchor in parent.find_all('a'):
		results.append(anchor.get('href')[2:]) #Remove .. before each item. Now they are in the format '/bosto/''
	return results

#2 Get the dedicatory prayer for a given url, if one exists. Returns string with <p> tags marking paragraphs.
def getDedicatoryPrayer(url):
	response = urllib2.urlopen(url
		)
	html = response.read()
	soup = BeautifulSoup(html, 'html.parser')	
	
	result = []
	for match in soup.find_all('p'):
		result.append(str(match))

	return ''.join(result)

#3 Get all dedicatory prayers for the temples, and return a {tempName: prayer} dictionary
numFetched = 0

def getAllDedicatoryPrayers():
	names = getTempleShortNames()
	results = {}
	global numFetched

	for name in names:
		url = 'http://www.ldschurchtemples.com' + name + 'prayer'
		results[name[1:-1]] = getDedicatoryPrayer(url)
		numFetched += 1
		if numFetched % 10 == 0:
			print 'Fetched', numFetched, '...'
	return results


#4 Write to file


outfile = open('prayers.json', 'w')
outfile.write(json.dumps(getAllDedicatoryPrayers(), indent=4, sort_keys=True))