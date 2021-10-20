# This file downloads and saves logo icon pngs for each NHL Team
# NOTE: Certain historical teams like the Quebec Nordiques and the 1972-1996
#       Winnipeg Jets are not available from this source
import urllib.request
import os

# This code is needed to indicate folder where vips is stored on my PC
os.environ['path'] += r';C:\\vips-dev-8.11\\bin'
import pyvips

# This code right here is needed to make sure that we save to the right folder
#       regardless of what type of computer (Mac, Windows) we open it in
__location__ = os.path.realpath(
    os.path.join(os.getcwd(), os.path.dirname(__file__)))


def grab_team_icons():
    '''
        Grabs icons of every team from the online API and saves them in the
        assets folder with the name 'team_<TEAMID>.svg' where <TEAMID> is the
        integer id that the NHL's API associates with the team.
    '''
    # Loops from 1 to 100, saving all team icons that don't throw an error
    #   Note: there are certain gaps (i.e. teamID = 11 is inactive, etc)
    for i in range(1, 100):
        linkToFile = "https://www-league.nhlstatic.com/images/logos/teams-current-primary-dark/{}.svg".format(i)
        try: 
            urllib.request.urlretrieve(linkToFile, os.path.join(__location__, '..', 'assets' , 'team_{}.svg'.format(i)))
        except:
            print("Failed at team {}".format(i))


def convert_svgs_to_png():
    '''
        Converts svgs of NHL team icons to pngs, and then DELETES THE SVGS.
    '''
    for i in range(1, 100):
        try:
            image = pyvips.Image.new_from_file(os.path.join(__location__, '..','assets' , 'team_{}.svg'.format(i)), dpi=200)
            image.write_to_file(os.path.join(__location__,'..', 'assets' , 'team_{}.png'.format(i)))
            os.remove(os.path.join(__location__, '..', 'assets' , 'team_{}.svg'.format(i)))
        except:
            print("Failed at team {}".format(i))

grab_team_icons()
convert_svgs_to_png()
