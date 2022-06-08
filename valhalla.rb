# Things to check on original:
#  - What happens if I use ringway at location 3?

#--------------------------------------------------------------------

class Area
    attr_accessor  :descr, :exitN, :exitNE, :exitE, :exitSE, :exitS, :exitSW, :exitW, :exitNW, :exitR, :exitRequire, :exitBlock
    # id = Room ID
    # exit is -1 if blocked
    # exitR is destination room id if ring used
    # exitReq is a required item to move
    def initialize(descr, exitN, exitNE, exitE, exitSE, exitS, exitSW, exitW, exitNW, exitR, exitRequire, exitBlock)
        @descr = descr
        @exitN = exitN
        @exitNE = exitNE
        @exitE = exitE
        @exitSE = exitSE
        @exitS = exitS
        @exitSW = exitSW
        @exitW = exitW
        @exitNW = exitNW
        @exitR = exitR
        @exitRequire = exitRequire
        @exitBlock = exitBlock
    end
end

#--------------------------------------------------------------------

# Valhalla's map is a 9x9 grid of 81 locations, only 1-81 valid
# Some rooms are blocked if carrying a certain item
# Some rooms are only accessible if carrying a certain item

# Movement rules, perform this calc on current area number:
#  N : +10
# NE : +11
#  E : +1
# SE : -9
#  S : -10
# SW : -11
#  W : -1
# NW : +9
#  R : Use Ring takes to R location (if same as current location, msg)

# Movement values:
#  0 : Can't go that way
#  1 : Can go that way
#  2 : Requires xReq to go that way
#  3 : Cannot be carrying xBlock to go that way
#  4 : Requires xReq AND cannot be carrying xBlock to go that way

# Dummy room inserted so I can count from 1, simpler without a map matrix
locations = [
    #                 descr             N  NE   E  SE   S  SW   W  NW   R  xReq       xBlock
            Area.new("dummy room",      0,  0,  0,  0,  0,  0,  0,  0,  0,       "" ,       ""),
            Area.new("a cave in Hell",  0,  0,  4,  0,  0,  0,  0,  0, 59, "drapnir",  "ofnir"),
            Area.new("a cave in Hell",  0,  0,  1,  0,  0,  0,  4,  0, 01, "drapnir",  "ofnir"),
            Area.new("in Hell",         0,  0,  4,  0,  0,  0,  1,  0, 03,  "shield", "helmet"),
            Area.new("in Hell",         0,  0,  0,  0,  0,  0,  4,  0, 59,  "shield", "helmet")
]

#--------------------------------------------------------------------

class Thing
    def initialize(descr, carried)
        @descr = descr
        @carried = 0
    end
end

#
drapnir = Thing.new("Drapnir", 0)
ofnir   = Thing.new("Ofnir", 0)

#--------------------------------------------------------------------

def mvParser (cmd, loc)
    # If player wants to go somewhere this will check if movement is allowed
    # Case order is important, longest possibilities first :)
    case 
    when cmd.include?('northeast')
        newLoc = loc + 11
    when cmd.include?('southeast')
        newLoc = loc - 9
    when cmd.include?('southwest')
        newLoc = loc - 11
    when cmd.include?('northwest')
        newLoc = loc + 9
    when cmd.include?('north')
        newLoc = loc + 10
    when cmd.include?('east')
        newLoc = loc + 1
    when cmd.include?('south')
        newLoc = loc - 10
    when cmd.include?('west')
        newLoc = loc - 1
    end
    # put the permitted movement check here
    return newLoc
end

#--------------------------------------------------------------------

def cmdParser (cmd, loc)
    # For other commands doesn't do anything yet, just pasted from above
    splitCmd = cmd.split
    if splitCmd[0] == "go"
        puts "You want to go somewhere"
        case splitCmd[1]
        when "north"
            newLoc = loc + 10
        when "northeast"
            newLoc = loc + 11
        when "east"
            newLoc = loc + 1
        when "southeast"
            newLoc = loc - 9
        when "south"
            newLoc = loc - 10
        when "southwest"
            newLoc = loc - 11
        when "west"
            newLoc = loc - 1
        when "northwest"
            newLoc = loc + 9
        end
        loc = newLoc
        puts loc
    else
        puts "You don't want to go somewhere"
    end
end

#--------------------------------------------------------------------

# Games loop
gameRun = 1
loc = 2

while gameRun == 1
    #puts "You are in " + locations[loc].descr
    #uncomment above when all locations are in
    cmd = gets
    loc = mvParser(cmd.downcase, loc)
    puts loc
end