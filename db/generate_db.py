import json
import time
import requests
import jsonpickle

#####################################################################
# Database class declarations
class SeasonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Season):
            return obj.__dict__   
        return json.JSONEncoder.default(self, obj)

    
class Season(object):
    seasonNum = 20182019
    rounds = [] # array of playoff rounds
    def __init__(self, season, rounds):
        self.season = season
        self.rounds = rounds
    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__, 
            sort_keys=True, indent=4)


class Round:
    roundNum = -1
    name = ""
    seriesList = []
    def __init__(self, roundNum, name, seriesList):
        self.roundNum = roundNum
        self.name = name
        self.seriesList = seriesList


class Series:
    # teamOne is the team with the lower teamId
    teamOne = -1
    teamTwo = -1
    teamOneGamesWon = -1
    teamTwoGamesWon = -1
    conference = ""
    games = []
    def __init__(self, teamOne, teamTwo, teamOneGamesWon, teamTwoGamesWon, conference, games):
        self.teamOne = teamOne
        self.teamTwo = teamTwo
        self.teamOneGamesWon = teamOneGamesWon
        self.teamTwoGamesWon = teamTwoGamesWon
        self.conference = conference
        self.games = games

class TeamGameStat:
    goalsAttempted = -1
    goalsScored = -1
    # scoringPlayers = [] # TODO: Could add later on
    def __init__(self, goalsAttempted, goalsScored):
        self.goalsAttempted = goalsAttempted
        self.goalsScored = goalsScored
        # self.scoringPlayers = scoringPlayers

class Game:
    gameId: -1
    teamGameStatOne = TeamGameStat(-1, -1)
    teamGameStatTwo = TeamGameStat(-1, -1)
    gameVictor = -1
    homeTeamId = -1
    venue = ""
    highlights = ""
    def __init__(self, gameId, teamGameStatOne, teamGameStatTwo, gameVictorId, homeTeamId, venue, highlights):
        self.gameId = gameId
        self.teamGameStatOne = teamGameStatOne
        self.teamGameStatTwo = teamGameStatTwo
        self.gameVictorId = gameVictorId
        self.homeTeamId = homeTeamId
        self.venue = venue
        self.highlights = highlights

# TODO: Could add this class in the future
# class Team:
#     teamId = -1
#     teamName = ""
#     def __init__(self, teamId, teamName):
#         self.teamId = teamId
#         self.teamName = teamName

# TODO: Could add this class in the future
# class Player:
#     playerId = -1
#     playerName = ""
#     def __init__(self, teamId, teamName):
#         self.teamId = teamId
#         self.teamName = teamName
#####################################################################

roundNumberToName = {1:'Conference Quarterfinals', 2:'Conference Semifinals',\
                     3:'Conference Finals', 4:'Stanley Cup Finals'}

roundNumberToSeriesNumber = {1:8, 2: 4, 3: 2, 4:1}

output = {}

startTime = time.time()
for year in range(2007, 2019):
    seasonNum = year*10**4 + year + 1
    playoffURL = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs?expand=round.series&season={}'.format(seasonNum)
    playoffsResp = requests.get(playoffURL)
    playoffsJson = playoffsResp.json()

    playoffGamesURL = 'https://statsapi.web.nhl.com/api/v1/schedule?season={}&gameType=P'.format(seasonNum)
    playoffGamesResp = requests.get(playoffGamesURL)
    playoffGamesJson = playoffGamesResp.json()

    season = Season(seasonNum, [Round(i, roundNumberToName[i], []) for i in range(1, 5)])
    
    for rd in range(0, 4):
        season.rounds[rd].seriesList = [Series(-1, -1, -1, -1, "", []) for j in range(roundNumberToSeriesNumber[rd + 1])]
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
                season.rounds[rd].seriesList[sr].conference = "N/A"


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
                        game = Game(gameId, TeamGameStat(-1, -1), TeamGameStat(-1, -1), victorId, \
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
                        season.rounds[rd].seriesList[sr].games.append(game)


    output[seasonNum] = season
    print("Completed season " + str(seasonNum))
    
print("Took {} seconds".format(time.time() - startTime))
# with open('data.json', 'w') as f:
#     SeasonEncoder().encode(f)
frozen = jsonpickle.encode(output)

with open("save.json", "w") as text_file:
    print(frozen, file=text_file)

