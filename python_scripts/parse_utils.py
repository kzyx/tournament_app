
def makeConsistentVersus(inputString, switchOrder):
    '''
        Takes in an inputString that can be split in half
        by " v " or " v. " (alternatively " vs " or " vs. ")
        and outputs the same string with " vs. " as the splitter,
        with the order of the two halves swapped if switchOrder == true
    '''
    halves = []
    if (" v " in inputString):
        halves = inputString.split(" v ")
    elif (" v. " in inputString):
        halves = inputString.split(" v. ")
    elif (" vs " in inputString):
        halves = inputString.split(" vs ")
    elif (" vs. " in inputString):
        halves = inputString.split(" vs. ")
    else:
        raise Exception("Invalid input string: did not find 'v.' or 'vs.' in " + inputString)

    return halves[1] + " vs. " + halves[0] if switchOrder else halves[0] + " vs. " + halves[1]