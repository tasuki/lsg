#!/usr/bin/env python3

# Reads the calendar .rst files and produces corresponding .html
#
# Python is not a beautiful language. However, it's too easily available...

from bs4 import BeautifulSoup
from docutils import core

print('Running make-cal.py...')

categories = {
    'food': ['śniadanie', 'obiad', 'kolacja', 'ognisko'],
    'play': ['poznawczy', 'memoriał', 'maraton', 'mpp', 'blitz',
             '9×9', '13×13', 'torus', 'rengo', 'fantom'],
    'learn': ['zajęcia', 'tsumego', 'wykład', 'podział', 'relay'],
}

def find_category(event):
    if ":00" in event:
        # uhh skip the hours...
        return ''

    for category in categories:
        for keyword in categories[category]:
            if keyword in event.lower():
                return category
    return 'other'

def process_rst(src):
    document = core.publish_parts(src, writer_name='html5')
    soup = BeautifulSoup(document['body'], 'html.parser')

    # add .cal class to the table
    for table in soup.find_all('table'):
        table['class'] = 'cal'

    # remove colgroup messing up layout...
    for colgroup in soup.find_all('colgroup'):
        colgroup.decompose()

    # strip p from headers
    for th in soup.find_all('th'):
        p = th.find('p')
        if p:
            th.contents = p.contents

    # process table fields: strip p, add class info
    for td in soup.find_all('td'):
        p = td.find('p')
        if p:
            event = p.contents[0].replace('\n', ' ')
            p.contents[0].replace_with(event)

            td.contents = p.contents
            td['class'] = find_category(event)

    return soup


files = ['cal-1', 'cal-2']

for f in files:
    print(f'Calendar: starting processing {f}...')

    src = open(f'./calendar/{f}.rst').read()
    soup = process_rst(src)

    with open(f'./_includes/{f}.html', 'w') as dst:
        dst.write(str(soup))
        print(f'Calendar: finished processing {f}!')
