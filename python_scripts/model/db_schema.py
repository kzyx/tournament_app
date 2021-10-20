# This class contains classes that represent the tree structure of the output
# JSON file. It goes Output[root]->Season->Round->Series>Game->TeamGameStat
class Output:
    output = []


class Season:
    seasonNum = -1
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
    # scoringPlayers = [] # FUTURE: Could add later on


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


# FUTURE: Add Team
class Team:
    teamId = -1
    teamName = ""
    teamConference = ""
    # FUTURE: Could add players, etc