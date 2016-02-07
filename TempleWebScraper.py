#-------------------------------------------------------------------------------
# Name: Python Temple Web Scraper
# Purpose: Scrapes first church temples listing website, then all links on it,
# to obtain necessary temple data.
#
# Author: Ephraim Kunz
#
# Created:     26/06/2015
# Copyright:   (c) Ephraim Kunz 2015
#-------------------------------------------------------------------------------
import urllib.request as urlRequest
import html.parser
import datetime
import time
import json
import uuid

#-------------Constants-----------------------

templesIndex = "https://www.lds.org/church/temples/find-a-temple?lang=eng"
outfile = "results2.txt"




#---------Utility Functions-------------

def writeTemplesToFile(filename, temples):
    """ Writes an AllTemples object to file in json format."""
    serialized = json.dumps(temples.templeList, cls=AllTemplesEncoder, sort_keys= True, indent=4)
    with open(filename, 'w') as f:
        f.write(serialized)

##def writeTempleToFile(filename, temple):
##    """Appends single passed in Temple to file in json format, no pretty print."""
##    serialized = json.dumps(temple, cls=AllTemplesEncoder, sort_keys = True, ensure_ascii=False)
##    with open(filename, 'a') as f:
##        f.write(serialized)



def populateTempleListing(indexUrl):
    """Creates and returns a new AllTemples object populated with basic data from indexUrl parameter."""
    result = AllTemples()
    templeStatsParser = TempleStatsParser()
    templeSimpleParser = TempleSimpleParser()

    htmlObject = urlRequest.urlopen(indexUrl)

    for line in htmlObject.readlines():
        decodedLine = line.decode('utf-8').strip()

        if decodedLine.startswith("<div class=\"temple-stats\">"): # Found the temple statistics
            templeStatsParser.feed(decodedLine)
            statsResult = templeStatsParser.getResult()
            result.setStats(statsResult[0], statsResult[1], statsResult[2], statsResult[3])

        if decodedLine.startswith("<tbody id=\"temple-list-sortable\">"): # Found all the temple simple info
            templeSimpleParser.feed(decodedLine)
            simpleData = templeSimpleParser.getSimpleData()
            links = templeSimpleParser.getLinks()

            assert len(simpleData) == len(links), "Mismatch link and simple data count"

            for index in range(len(simpleData)):
                newTemple = Temple()
                newTemple.setWithShortData(simpleData[index][0], simpleData[index][1], simpleData[index][2])
                newTemple.setLink(links[index])
                result.setTemple(newTemple)

    return result

def populateTempleDetail(temple):
    """Given a temple object, fills it with data recieved in response to following temple.detailLink."""
    htmlObject = urlRequest.urlopen(temple.detailLink)
    detailParser = TempleDetailParser()
    scheduleParser = TempleScheduleParser()

    for line in htmlObject.readlines():
        decodedLine = line.decode('utf-8', "ignore").strip()

        if decodedLine.startswith("</ul></li></ul><ul class=\"tabs\"><li id=\"address\" class=\"active\"><a href=\"#tab=address\">"):
            detailParser.feed(decodedLine)
            results = detailParser.getResult()

            #Find where our keepers begin and end
            addressStarts = results.index("Physical Address")
            addressEnds = results.index("Driving directions")
            phoneBegins = results.index("Telephone") # No need for end, just one list element long

            temple.address = ', '.join(results[addressStarts + 1 : addressEnds])
            temple.telephone = results[phoneBegins + 1]

        elif decodedLine.startswith("<tbody><tr><td colspan=\"1\""): #Endowment schedule
            scheduleParser.feed(decodedLine)
            data = scheduleParser.getResult()
            temple.setSchedule(data)

        elif decodedLine.startswith("<a href=\"#tab=info\" onclick=\"activateAdditionalInfoTab()"):
            detailParser.clearOldResult()
            detailParser.feed(decodedLine)
            rawClosureList = detailParser.getResult()

            closureList = [element.strip() for element in rawClosureList]


            maintenanceIndex = closureList.index("Maintenance Dates")
            otherIndex = closureList.index("Other Dates")
            specialOpeningsIndex = closureList.index("Special Openings")
            closureDict = {}
            closureDict["Maintenance Dates"] = closureList[maintenanceIndex + 1 : otherIndex]
            closureDict["Other Dates"] = closureList[otherIndex + 1 : specialOpeningsIndex]
            closureDict["Special Openings"] = closureList[specialOpeningsIndex + 1 : -1]
            temple.setClosures(closureDict)

        elif decodedLine.startswith("</div></li><li><div class=\"one-column\"><h3>Services Available</h3><ul class=\"list-decor wide\"><li>"):
            detailParser.clearOldResult()
            detailParser.feed(decodedLine)
            servicesAvailableList = detailParser.getResult()
            services = dict()
            services["Cafeteria"] = servicesAvailableList[1]
            services["Clothing"] = servicesAvailableList[2]
            temple.setServicesAvailable(services)

        elif decodedLine.startswith("<div class=\"photo-main-tabs\">"):
            detailParser.feed(decodedLine)
            temple.setPhotoLink(detailParser.getPictureLink())

#Not a good way to do this baptistry stuff, many don't have data entered and lines are inconsistent.
##        elif decodedLine.startswith("</td><td colspan=\"1\">Â </td></tr><tr><td colspan=\"1\"><strong>"):
##            decodedLine = decodedLine.replace('\xa0', "") # Replace stupid Unicode non-breaking space
##            detailParser.clearOldResult()
##            detailParser.feed(decodedLine)
##            baptistryList = detailParser.getResult()
##            baptistryDictionary = {}
##
##            if "Family Priority Baptistry Schedule:" in baptistryList: # Calgary Canada temple doesn't list this
##
##                famPrioritySchedIndex = baptistryList.index("Family Priority Baptistry Schedule:")
##            else:
##                famPrioritySchedIndex = len(baptistryList) #Set to last index
##
##            if "Baptistry Hours:" in baptistryList:
##
##                bapHoursIndex = baptistryList.index("Baptistry Hours:")
##            else:
##                bapHoursIndex = 0
##
##            baptistryDictionary["Family Priority Baptistry Schedule"] = baptistryList[famPrioritySchedIndex + 1 : -1]
##            baptistryDictionary["Baptistry Hours"] = baptistryList[bapHoursIndex + 1 : famPrioritySchedIndex]
##            temple.setBaptistrySchedule(baptistryDictionary)




def containsDayOfWeek(input):
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Saturday", "Sunday"]
    for day in days:
        if day in input:
            return True
    return False

# ---------HTML Parsers--------------

class TempleStatsParser(html.parser.HTMLParser):
    """ Returns a tuple: (# operating, # under renovation, # under construction, # announced)"""
    def __init__(self):
        html.parser.HTMLParser.__init__(self)
        self.data = ()

    def handle_data(self, data):
        if not data.startswith("Temple"): # Skip the first data section we get back ("Temple Statistics:")
            pieces = data.split()
            self.data = (pieces[0], pieces[2], pieces[5], pieces[8])

    def getResult(self):
        return self.data

class TempleSimpleParser(html.parser.HTMLParser):
    """ Gets simple data from html and returns it in various lists."""
    def __init__(self):
        html.parser.HTMLParser.__init__(self)
        self.data = []
        self.links = []
        self.index = 0
        self.currentProperty = "n" # Enum here: n for name, p for place. Keeps track of field that needs to be filled.

    def handle_data(self, data):
        if self.currentProperty == "n":
            self.data.append([0,0,0]) # Create a new element in data and fill it with 0's
            self.data[self.index][0] = data
            self.currentProperty = "p"
        elif self.currentProperty == "p":
            self.data[self.index][1] = data
            self.currentProperty = "d"
        else: # Get the date
            if(data == "Announced" or data == "Renovation" or data == "Construction"): # Must be first to prevent short circuit eval...
                self.data[self.index][2] = data
                self.currentProperty = "n"

            elif not (data[-4:]).isdigit(): #Check that last 4 characters are numbers, as any date would have. If not, we've skipped to the next
            # property as a date tag was not provided in the html.
                self.data[self.index][2] = "" # Put in a empty string for date.

                self.data.append([0,0,0]) # Create a new element in data and fill it with 0's
                self.data[self.index][0] = data #Put the data that we did get, next element, into proper spot.
                self.currentProperty = "p"

            else:
                self.data[self.index][2] = data
                self.currentProperty = "n"

            self.index += 1

    def handle_starttag(self, tag, attr): # Get the temple detail links.
        if tag == 'a':
            self.links.append(attr[0][1])

    def getSimpleData(self):
        return self.data

    def getLinks(self):
        return self.links


class TempleDetailParser(html.parser.HTMLParser):
    """ Returns a list of all data collected when called."""
    def __init__(self):
        html.parser.HTMLParser.__init__(self)
        self.data = []
        self.pictureLink = ' '
    def handle_data(self, data):
        self.data.append(data)

    def handle_starttag(self, tag, attr):
        if tag == 'img':
            self.pictureLink = attr[0][1]

    def getResult(self):
        return self.data

    def getPictureLink(self):
        return self.pictureLink

    def clearOldResult(self):
        self.data = []

class TempleScheduleParser(html.parser.HTMLParser):
    """ Returns the schedule in dictionary with keys as days."""
    def __init__(self):
        html.parser.HTMLParser.__init__(self)
        self.data = dict()
        self.tempDayElement = ""
        self.onDayElement = True

    def handle_data(self, data):
        if containsDayOfWeek(data) and self.onDayElement and len(data) < 50:
            self.tempDayElement = data
            self.onDayElement = False
        elif not self.onDayElement:
            self.data[self.tempDayElement] = data
            self.onDayElement = True

    def getResult(self):
        return self.data


#-----JSON Encoders--------------------

class AllTemplesEncoder(json.JSONEncoder):
    """ Give the json encoder a way to know how to serialize an AllTemples object, by __dict__ which is a dict of it's fields."""
    def default(self, obj):
        return obj.__dict__;


# ---------------Data Classes------------------

class Temple(object):
    def __init__(self):
        self. id = uuid.uuid4().int
        self.name = ""
        self.place = ""
        self.dedication = None
        self.detailLink = ""
        self.photoLink = "https://www.lds.org"

        self.address = ""
        self.telephone = ""
        self.endowmentSchedule = dict()
        ##self.baptistrySchedule = dict()
        self.closures = dict()
        self.servicesAvailable = dict()


    def setWithShortData(self, name, place, dedication):
        self.name = name
        self.place = place
        if dedication == "Announced" or dedication == "Renovation" or dedication == "Construction" or dedication == "":
            self.dedication = dedication
        else:
            self.dedication = datetime.datetime.strptime("{0}".format(dedication), "%b %d, %Y").isoformat() # Create datetime obj, then store as string.

    def setLink(self, link):
        self.detailLink = link

    def setSchedule(self, dictionary):
        self.endowmentSchedule = dictionary

    def setClosures(self, dictionary):
        self.closures = dictionary

    def setServicesAvailable(self, dictionary):
        self.servicesAvailable = dictionary

    def setPhotoLink(self, link):
        self.photoLink += link

    def setBaptistrySchedule(self, dictionary):
        self.baptistrySchedule = dictionary

    def __str__(self):
        return "Name: {0}\nPlace: {1}\nDate: {2}\nAddress: {3}\nTelephone: {4}\n\n".format(self.name, self.place, self.dedication, self.address, self.telephone)


class AllTemples(object):
    """ Hold a collection of Temple objects and some data about all the temples."""
    def __init__(self):
        self.templeList = list()
        self.operating = 0
        self.renovation = 0
        self.construction = 0
        self.announced = 0

    def setTemple(self, templeToAdd):
        self.templeList.append(templeToAdd)

    def setStats(self, operating, renovation, construction, announced):
        self.operating = operating
        self.renovation = renovation
        self.construction = construction
        self.announced = announced

    def __str__(self):
        stats = "---Stats--- \n\tOperating: {0}\n\tUnder Renovation: {1}\n\tUnderConstruction: {2}\n\tAnnounced: {3}\n\n".format(self.operatingTemples, self.underRenovation, self.underConstruction, self.announced)
        temples = "---Temple List---\nTemple Name\tTemple Location\tTemple Date\n"
        for temple in self.templeList:
            temples += str(temple) + "\n"
        return "{0}{1}".format(stats, temples)


def main():
    print("Beginning fetch of temple data ...")
    temples = populateTempleListing(templesIndex)
    print("Fetching data on {0} temples found ...".format(len(temples.templeList)))
    for index, temple in enumerate(temples.templeList):
        if index % 10 == 0 and index != 0:
            print("\tFetching number {0}".format(index))
        populateTempleDetail(temple)
    print("Fetched finished, writing to file ...")
    writeTemplesToFile(outfile, temples)
    print("Done")


if __name__ == '__main__':
    main()
