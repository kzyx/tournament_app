# This class contains classes that are essential for the serialization of
# the JSON object. We use marshmallow's Schema & Field for this serialization.
# The keys in the JSON are always strings
# The Field helps us specify the data type of the value
from marshmallow import Schema, fields

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
    # NOTE: teamOne is the team with the lower teamId
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