import json
import time
import requests
from marshmallow import Schema, fields
import os, sys
from parse_utils import makeConsistentVersus
from model.db_schema import *
from model.db_schema_serialize import *

roundNumberToName = {1:'Conference Quarterfinals', 2:'Conference Semifinals',\
                     3:'Conference Finals', 4:'Stanley Cup Finals'}
roundNumberToSeriesNumber = {1:8, 2: 4, 3: 2, 4:1} # maps round -> # of series in round

def parsePlayoffs(startYear=1997, endYear=2000):
    '''
        Generates a JSON object containing the data for the NHL seasons
        [startYear-starYear+1, ..., endYear-1, endYear].
        Currently skips problematic seasons such as the 2004-2005 lockout.
        This JSON is saved in 'assets/data'.
    '''

    if (startYear <= 1995):
        raise "Entered season is not currently supported"

    startTime = time.time()
    seasonsDone = 0
    out = Output()
    out.output = [None] * (endYear - startYear)

    # Seasons to ignore (not fetch), some such as the 2004-2005 correspond to an NHL lockout
    seasonsToIgnore = set([20032004, 20042005, 20062007, 20072008, 20082009])

    for year in range(startYear, endYear):
        seasonNum = year*10**4 + year + 1

        # Ignore season if it is known to have issues 
        if seasonNum in seasonsToIgnore:
            out.output.pop(-1) # shrink size of output season list by one
            print("Ignored season {}".format(seasonNum))
            continue
        print("Started season {}".format(seasonNum))

        teamURL = 'https://statsapi.web.nhl.com/api/v1/teams?expand=team.conference&season=' + str(seasonNum)
        teamResp = requests.get(teamURL)
        teamJson = teamResp.json()

        playoffURL = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs?expand=round.series&season={}'.format(seasonNum)
        playoffsResp = requests.get(playoffURL)
        playoffsJson = playoffsResp.json()

        # Special case: The NHL Stats API is yet again inconsistent, and returns a different JSON for 20192020.
        #               The 20192020 object has an extra initial round that is just a qualifier round
        #               We handle this by simply replacing rounds [0...3] with [1...4]
        if (seasonNum == 20192020):
            for rd in range(4):
                playoffsJson["rounds"][rd] = playoffsJson["rounds"][rd+1]

        playoffGamesURL = 'https://statsapi.web.nhl.com/api/v1/schedule?season={}&gameType=P'.format(seasonNum)
        playoffGamesResp = requests.get(playoffGamesURL)
        playoffGamesJson = playoffGamesResp.json()

        season = Season(str(seasonNum), [Round(i, roundNumberToName[i], []) for i in range(1, 5)])

        for rd in range(0, 4):
            season.rounds[rd].seriesList = [Series() for j in range(roundNumberToSeriesNumber[rd + 1])]
            for sr in range(0, roundNumberToSeriesNumber[rd + 1]):
                # teamOneIsFirst is used to reorder the teamIDs so that teamOneId < teamTwoId
                teamOneIsFirst = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"] < \
                    playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"]
                season.rounds[rd].seriesList[sr].teamOne = min(playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"], \
                                                       playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"])
                season.rounds[rd].seriesList[sr].teamTwo = max(playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"], \
                                                       playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"])
                season.rounds[rd].seriesList[sr].teamOneGamesWon = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0 if teamOneIsFirst else 1]["seriesRecord"]["wins"]
                season.rounds[rd].seriesList[sr].teamTwoGamesWon = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1 if teamOneIsFirst else 0]["seriesRecord"]["wins"]

                # The following try except block is needed for cases where the conference name is null/not present
                # This happens due to the fact that the NHL Stats API can be horribly inconsistent.
                # We solve this problem by looking at our team JSON to find the conferences of each team on the series that year
                # If both teams have the same conference, we update our series conference variable. Otherwise, we leave it "N/A"
                try:
                    season.rounds[rd].seriesList[sr].conference = playoffsJson["rounds"][rd]["series"][sr]["conference"]["name"]
                except KeyError as e:
                    season.rounds[rd].seriesList[sr].conference = "N/A"
                    if (rd != 4): # we don't care about the conference if it's the Stanley Cup Final
                        teamOneConf = ""
                        teamTwoConf = ""
                        for tm in range(len(teamJson["teams"])):
                            if (teamJson["teams"][tm]["id"] == season.rounds[rd].seriesList[sr].teamOne):
                                teamOneConf = teamJson["teams"][tm]["conference"]["name"]
                                # print("Found team1", teamOneConf)
                            if (teamJson["teams"][tm]["id"] == season.rounds[rd].seriesList[sr].teamTwo):
                                teamTwoConf = teamJson["teams"][tm]["conference"]["name"]
                                # print("Found team2", teamTwoConf)
                            if (teamOneConf != "" and teamTwoConf != "" and teamOneConf == teamTwoConf):
                                season.rounds[rd].seriesList[sr].conference = teamOneConf
                                # print("Found team1 and team2", rd, sr, teamOneConf)
                                break

                season.rounds[rd].seriesList[sr].shortName = makeConsistentVersus(playoffsJson["rounds"][rd]["series"][sr]["names"]["matchupShortName"], not(teamOneIsFirst))
                season.rounds[rd].seriesList[sr].longName  = makeConsistentVersus(playoffsJson["rounds"][rd]["series"][sr]["names"]["matchupName"], not(teamOneIsFirst))

                season.rounds[rd].seriesList[sr].shortResult = playoffsJson["rounds"][rd]["series"][sr]["currentGame"]["seriesSummary"]["seriesStatusShort"]
                season.rounds[rd].seriesList[sr].longResult = playoffsJson["rounds"][rd]["series"][sr]["currentGame"]["seriesSummary"]["seriesStatus"]

                season.rounds[rd].seriesList[sr].games = [None] * (season.rounds[rd].seriesList[sr].teamOneGamesWon + season.rounds[rd].seriesList[sr].teamTwoGamesWon)
                gamesDone = 0 # index of array that we are adding to

                for date in range(0, len(playoffGamesJson["dates"])):
                    for gm in range(0, len(playoffGamesJson["dates"][date]["games"])):
                        gameId = playoffGamesJson["dates"][date]["games"][gm]["gamePk"]
                        minId = min(playoffGamesJson["dates"][date]["games"][gm]["teams"]["away"]["team"]["id"], \
                                    playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["team"]["id"])
                        maxId = max(playoffGamesJson["dates"][date]["games"][gm]["teams"]["away"]["team"]["id"], \
                                    playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["team"]["id"])

                        teamOneIsHome = (minId == playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["team"]["id"])

                        victorId = -1
                        if (teamOneIsHome and playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["score"] > \
                            playoffGamesJson["dates"][date]["games"][gm]["teams"]["away"]["score"]):
                            victorId = minId
                        elif (not(teamOneIsHome) and playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["score"] < \
                            playoffGamesJson["dates"][date]["games"][gm]["teams"]["away"]["score"]):
                            victorId = minId
                        else:
                            victorId = maxId

                        # If found matching game ID
                        if (minId == season.rounds[rd].seriesList[sr].teamOne and maxId == season.rounds[rd].seriesList[sr].teamTwo):
                            game = Game(gameId, TeamGameStat(), TeamGameStat(), victorId, \
                                playoffGamesJson["dates"][date]["games"][gm]["teams"]["home"]["team"]["id"], \
                                        playoffGamesJson["dates"][date]["games"][gm]["venue"]["name"], "")

                            # Make call to get highlights
                            gameURL = 'https://statsapi.web.nhl.com/api/v1/game/{}/content'.format(gameId)
                            gameResp = requests.get(gameURL)
                            gameJson = gameResp.json()
                            game.highlights = "N/A"
                            if ("media" in gameJson.keys()):
                                for vid in range(len(gameJson["media"]["epg"])):
                                    if (gameJson["media"]["epg"][vid]["title"] == "Extended Highlights"):
                                        try:
                                            game.highlights = gameJson["media"]["epg"][vid]["items"][0]["playbacks"][-1]["url"] # NOTE: ASSUMES LAST ELEMENT IS HIGHLIGHT REEL
                                        except IndexError as e:
                                            pass


                            # Make call to get linescore
                            gameURL = 'https://statsapi.web.nhl.com/api/v1/game/{}/linescore'.format(gameId)
                            gameResp = requests.get(gameURL)
                            gameJson = gameResp.json()
                            game.teamGameStatOne.goalsAttempted = gameJson["teams"]["home" if teamOneIsHome else "away"]["shotsOnGoal"]
                            game.teamGameStatOne.goalsScored = gameJson["teams"]["home" if teamOneIsHome else "away"]["goals"]
                            game.teamGameStatTwo.goalsAttempted = gameJson["teams"]["away" if teamOneIsHome else "home"]["shotsOnGoal"]
                            game.teamGameStatTwo.goalsScored = gameJson["teams"]["away" if teamOneIsHome else "home"]["goals"]
                            try:
                                season.rounds[rd].seriesList[sr].games[gamesDone] = game
                            except IndexError as e:
                                print("IndexError occured at rd {}, sr {}, game {}".format(rd, sr, gamesDone))
                            gamesDone += 1

        out.output[seasonsDone] = season
        seasonsDone += 1
        print("Completed season " + str(seasonNum))

    print("Took {} seconds".format(time.time() - startTime))
    savePath = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "playoffData.json")

    with open(savePath, "w") as text_file:
        print(json.dumps(OuterListSchema().dump(out)), file=text_file)

parsePlayoffs()