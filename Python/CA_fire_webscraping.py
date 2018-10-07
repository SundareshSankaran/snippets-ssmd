# The CA Fire Web Scraping Code

# HEre is it - please note however, that beyond a pupose of learning and illustration, the web page of the California fire Department (ref below) is not used for any commercial purpose whatsover.


# coding: utf-8

# Imports

import requests
from bs4 import BeautifulSoup
import re



# Create result Array
fireArray = []


for h in range(1, 48):

    page = requests.get(
        "http://www.fire.ca.gov/current_incidents/?page="+str(h))
    soup = BeautifulSoup(page.content, 'html.parser')

    for tables in soup.find_all(class_="incident_table"):
        for tbody in tables.find_all("tbody"):

            fireInfo = {}
# Identifying headers - proved useful in learning regex further - especially greedy matches
            for headers in tbody.find_all(class_="header_tr"):
                fireInfo["fireName"] = re.findall(
                    r"(.*)?\:", headers.find_all("td")[0].text)
                fireInfo["Updated"] = re.findall(
                    r"\:(.*)", headers.find_all("td")[1].text)

# We (especially Mallika - MD) are quite proud of this part of the code - the very fact that we utilized the natural layout of the html table to parse data and load into an array as is
            for odds in tbody.find_all(class_="odd"):
                fireInfo[odds.find_all("td")[0].get_text()] = odds.find_all("td")[
                    1].get_text()

                if "Acres Burned - Containment:" in fireInfo.keys():
                    fireInfo["acres"] = re.findall(
                        r"(\d+\,{0,1}\d+) acres", fireInfo["Acres Burned - Containment:"])
                    fireInfo["containment"] = re.findall(
                        r"(\d+)%", fireInfo["Acres Burned - Containment:"])

            fireArray.append(fireInfo)

# For splitting out the counties into different array elements

newFireArray = []
for eachitem in fireArray:
    if 'County:' in eachitem.keys():
        for counties in eachitem['County:'].split(","):
            eachitem['County Name'] = counties.replace("County", "")
            newFireArray.append(eachitem)
