import json
import time
import requests
import jsonpickle
import pydantic
from marshmallow import Schema, fields
import os, sys

#####################################################################
# Database class declarations
class SeasonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Season):
            return obj.__dict__   
        return json.JSONEncoder.default(self, obj)

class Output:
    output = []

    
class Season:
    seasonNum = str(20182019)
    rounds = [] # array of playoff rounds
    def __init__(self, seasonNum, rounds):
        self.seasonNum = seasonNum
        self.rounds = rounds


class Round:
    roundNum = -1
    roundName = ""
    seriesList = []
    def __init__(self, roundNum, roundName, seriesList):
        self.roundNum = roundNum
        self.roundName = roundName
        self.seriesList = seriesList


class Series:
    # teamOne is the team with the lower teamId
    shortName = ""
    longName = ""
    shortResult = ""
    longResult = ""
    teamOne = -1
    teamTwo = -1
    teamOneGamesWon = -1
    teamTwoGamesWon = -1
    conference = ""
    games = []

class TeamGameStat:
    goalsAttempted = -1
    goalsScored = -1
    # scoringPlayers = [] # TODO: Could add later on
        # self.scoringPlayers = scoringPlayers

class Game:
    gameId = -1
    teamGameStatOne = TeamGameStat()
    teamGameStatTwo = TeamGameStat()
    victorId = -1
    homeTeamId = -1
    venue = ""
    highlights = ""
    def __init__(self, gameId, teamGameStatOne, teamGameStatTwo, victorId, homeTeamId, venue, highlights):
        self.gameId = gameId
        self.teamGameStatOne = teamGameStatOne
        self.teamGameStatTwo = teamGameStatTwo
        self.victorId = victorId
        self.homeTeamId = homeTeamId
        self.venue = venue
        self.highlights = highlights

# TODO: Could add this class in the future
class Team:
    teamId = -1
    teamName = ""
    teamConference = ""

class OutputTeam:
    output = []

class TeamSchema(Schema):
    teamId = fields.Int()
    teamName = fields.Str()
    teamConference = fields.Str()

class OutputTeamSchema(Schema):
    output = fields.List(fields.Nested(TeamSchema))
    

# TODO: Could add this class in the future
# class Player:
#     playerId = -1
#     playerName = ""
#     def __init__(self, teamId, teamName):
#         self.teamId = teamId
#         self.teamName = teamName
#####################################################################

class TeamGameStatSchema(Schema):
    goalsAttempted = fields.Int()
    goalsScored = fields.Int()

class GameSchema(Schema):
    gameId = fields.Int()
    teamGameStatOne = fields.Nested(TeamGameStatSchema())
    teamGameStatTwo = fields.Nested(TeamGameStatSchema())
    victorId = fields.Int()
    homeTeamId = fields.Int()
    venue = fields.Str()
    highlights = fields.Str()


class SeriesSchema(Schema):
    # teamOne is the team with the lower teamId
    shortName = fields.Str()
    longName = fields.Str()
    shortResult = fields.Str()
    longResult = fields.Str()
    teamOne = fields.Int()
    teamTwo = fields.Int()
    teamOneGamesWon = fields.Int()
    teamTwoGamesWon = fields.Int()
    conference = fields.Str()
    games = fields.List(fields.Nested(GameSchema()))

class RoundSchema(Schema):
    roundNum = fields.Int()
    roundName = fields.Str()
    seriesList = fields.List(fields.Nested(SeriesSchema()))

class SeasonSchema(Schema):
    seasonNum = fields.Str()
    rounds = fields.List(fields.Nested(RoundSchema()))

class OuterListSchema(Schema):
    output = fields.List(fields.Nested(SeasonSchema()))
################################################

roundNumberToName = {1:'Conference Quarterfinals', 2:'Conference Semifinals',\
                     3:'Conference Finals', 4:'Stanley Cup Finals'}

roundNumberToSeriesNumber = {1:8, 2: 4, 3: 2, 4:1}

def parsePlayoffs():
    output = {}

    startYear = 2006
    endYear = 2019

    startTime = time.time()
    seasonsDone = 0
    out = Output()
    out.output = [None] * (endYear - startYear)

    for year in range(startYear, endYear):
        seasonNum = year*10**4 + year + 1
        playoffURL = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs?expand=round.series&season={}'.format(seasonNum)
        playoffsResp = requests.get(playoffURL)
        playoffsJson = playoffsResp.json()

        playoffGamesURL = 'https://statsapi.web.nhl.com/api/v1/schedule?season={}&gameType=P'.format(seasonNum)
        playoffGamesResp = requests.get(playoffGamesURL)
        playoffGamesJson = playoffGamesResp.json()

        season = Season(str(seasonNum), [Round(i, roundNumberToName[i], []) for i in range(1, 5)])

        for rd in range(0, 4):
            season.rounds[rd].seriesList = [Series() for j in range(roundNumberToSeriesNumber[rd + 1])]
            for sr in range(0, roundNumberToSeriesNumber[rd + 1]):
                # need victor, games
                teamOneIsFirst = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"] < \
                    playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"]
                season.rounds[rd].seriesList[sr].teamOne = min(playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"], \
                                                       playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"])
                season.rounds[rd].seriesList[sr].teamTwo = max(playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0]["team"]["id"], \
                                                       playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1]["team"]["id"])
                season.rounds[rd].seriesList[sr].teamOneGamesWon = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][0 if teamOneIsFirst else 1]["seriesRecord"]["wins"]
                season.rounds[rd].seriesList[sr].teamTwoGamesWon = playoffsJson["rounds"][rd]["series"][sr]["matchupTeams"][1 if teamOneIsFirst else 0]["seriesRecord"]["wins"]

                try:
                    season.rounds[rd].seriesList[sr].conference = playoffsJson["rounds"][rd]["series"][sr]["conference"]["name"]
                except KeyError as e:
                    teamURL = 'https://statsapi.web.nhl.com/api/v1/teams'
                    teamResp = requests.get(teamURL)
                    teamJson = teamResp.json()

                    season.rounds[rd].seriesList[sr].conference = "N/A"
                    teamOneConf = ""
                    teamTwoConf = ""
                    for tm in range(len(teamJson["teams"])):
                        if (teamJson["teams"][tm]["id"] == season.rounds[rd].seriesList[sr].teamOne):
                            teamOneConf = teamJson["teams"][tm]["conference"]["name"]
                            print("c1", teamOneConf, minId, maxId)
                        if (teamJson["teams"][tm]["id"] == season.rounds[rd].seriesList[sr].teamTwo):
                            teamTwoConf = teamJson["teams"][tm]["conference"]["name"]
                            print("c2", teamTwoConf, minId, maxId)
                        if (teamOneConf != "" and teamTwoConf != "" and teamOneConf == teamTwoConf):
                            season.rounds[rd].seriesList[sr].conference = teamOneConf
                            print("c3", rd, sr, teamOneConf, minId, maxId)

                season.rounds[rd].seriesList[sr].shortName = playoffsJson["rounds"][rd]["series"][sr]["names"]["matchupShortName"]
                season.rounds[rd].seriesList[sr].longName  = playoffsJson["rounds"][rd]["series"][sr]["names"]["matchupName"]
                season.rounds[rd].seriesList[sr].shortResult = playoffsJson["rounds"][rd]["series"][sr]["currentGame"]["seriesSummary"]["seriesStatusShort"]
                season.rounds[rd].seriesList[sr].longResult = playoffsJson["rounds"][rd]["series"][sr]["currentGame"]["seriesSummary"]["seriesStatus"]

                season.rounds[rd].seriesList[sr].games = [None] * (season.rounds[rd].seriesList[sr].teamOneGamesWon + season.rounds[rd].seriesList[sr].teamTwoGamesWon)

                gamesDone = 0

                # for date in range(0, season.rounds[rd].series.teamOneGamesWon + season.rounds[rd].series.teamTwoGamesWon):
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
                            season.rounds[rd].seriesList[sr].games[gamesDone] = game
                            gamesDone += 1


        out.output[seasonsDone] = season
        seasonsDone += 1
        print("Completed season " + str(seasonNum))

    print("Took {} seconds".format(time.time() - startTime))
    # with open('data.json', 'w') as f:
    #     SeasonEncoder().encode(f)

#     frozen = jsonpickle.encode(output)

    # for i in range(len(output)):
    #     output[i] = SeasonSchema().dumps(output[i])

    savePath = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "playoffData.json")

    with open(savePath, "w") as text_file:
        # print(SeasonSchema().dumps(output), file=text_file)
        # print(OuterListSchema().dump(output), file=text_file)
        print(json.dumps(OuterListSchema().dump(out)), file=text_file)


def parseTeams():
    output = {}

    startTime = time.time()
    url = 'https://statsapi.web.nhl.com/api/v1/teams'
    resp = requests.get(url)
    myjson = resp.json()

    out = OutputTeam()
    out.output = [Team()] * len(myjson["teams"])

    for r in range(len(myjson["teams"])):
        out.output[r].teamName = myjson["teams"][r]["name"]
        out.output[r].teamId = myjson["teams"][r]["id"]
        out.output[r].teamConference = myjson["teams"][r]["conference"]["name"]

    savePath = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "teamData.json")

    with open(savePath, "w") as text_file:
        # print(SeasonSchema().dumps(output), file=text_file)
        # print(OuterListSchema().dump(output), file=text_file)
        print(json.dumps(OutputTeamSchema().dump(out)), file=text_file)

parsePlayoffs()
# parseTeams()