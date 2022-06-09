# Things to check on original:
#  - What happens if I use ringway at location 3?

#--------------------------------------------------------------------

class Area
    attr_accessor  :descr, :exitN, :exitNE, :exitE, :exitSE, :exitS, :exitSW, :exitW, :exitNW, :exitR
    # id = Room ID
    # exit is -1 if blocked
    # exitR is destination room id if ring used
    # exitReq is a required item to move
    def initialize(descr, exitN, exitNE, exitE, exitSE, exitS, exitSW, exitW, exitNW, exitR)
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
#  R : Use Ring takes to R location (if 0 msg)

# Movement values:
#  0 : Can't go that way
#  1 : Can go that way

# Handle locked and unlocked routes when items are collected to keep movement matrix simple and number of conditions down
# I have set special movement to 2 (i.e. requiring / not requiring an object) for testing

# Dummy room inserted so I can count from 1, simpler without a map matrix
@locations = [
    #                 descr                                      N  NE   E  SE   S  SW   W  NW   R 
            Area.new("dummy room",                               0,  0,  0,  0,  0,  0,  0,  0,  0),

            Area.new("a cave in Hell",                           0,  0,  2,  0,  0,  0,  0,  0, 59), # drapnir not ofnir for east
            Area.new("a cave in Hell",                           0,  0,  1,  0,  0,  0,  2,  0,  1), # drapnir not ofnir for west
            Area.new("Hell",                                     0,  0,  2,  0,  0,  0,  1,  0,  3), # shield not helmet for east
            Area.new("Hell",                                     0,  0,  0,  0,  0,  0,  2,  0, 59), # shield not helmet for west
            Area.new("an icy waste in Hell",                     0,  0,  2,  0,  0,  0,  0,  0, 24), # key not felstrong for east
            Area.new("a cave in Hell",                           2,  0,  0,  0,  0,  0,  2,  0, 71), # key not felstrong for west, skornir not ring for north
            Area.new("an icy waste in Hell",                     1,  2,  1,  0,  0,  0,  0,  0,  7), # skalir for north east
            Area.new("a marsh in Hell",                          0,  1,  2,  0,  0,  0,  1,  1, 21), # no food for east
            Area.new("a plain in Hell",                          1,  0,  0,  0,  0,  0,  2,  0, 18), # no food for west

            Area.new("a cave in Hell",                           1,  1,  1,  0,  0,  0,  0,  0, 66),
            Area.new("the Pits, which is in a cave in Hell",     0,  0,  1,  0,  0,  0,  1,  0, 22), 
            Area.new("a cave in Hell",                           1,  0,  0,  0,  0,  0,  1,  0, 19),
            Area.new("the mountains in Hell",                    0,  0,  2,  0,  0,  0,  0,  0,  0), # skalir for east
            Area.new("Asnir, which is in the mountains in Hell", 0,  0,  2,  0,  0,  0,  2,  0, 71), # skalir for east and west
            Area.new("the mountains in Hell",                    0,  0,  0,  0,  2,  0,  2,  0,  0),  # skalir west, skornir not ring south
            Area.new("an icy waste in Hell",                     1,  0,  2,  1,  1,  0,  0,  0, 66), # skalir for east
            Area.new("a plain in Hell",                          1,  0,  0,  0,  0,  1,  2,  0, 66), # skalir for west
            Area.new("in the mountains in Hell",                 1,  0,  0,  0,  1,  1,  0,  0,  0), 

            Area.new("in Hell",                                  2,  0,  2,  0,  2,  0,  0,  0, 12), # hel for north, east, and south
            Area.new("an icy waste in Hell",                     1,  0,  2,  0,  0,  1,  0,  0, 46), # ofnir for east
            Area.new("an icy waste in Hell",                     1,  1,  2,  0,  0,  2,  2,  1,  0), # ofnir for north, east, sw and west
            Area.new("a marsh in Hell",                          0,  0,  1,  0,  0,  0,  2,  0,  0), # ofnir for west
            Area.new("a marsh in Hell",                          1,  0,  0,  0,  0,  0,  1,  0, 50),
            Area.new("a cave in Hell",                           0,  0,  2,  0,  0,  0,  0,  0, 71), # skornir for east
            Area.new("a cave in Hell",                           0,  0,  2,  2,  0,  0,  0,  0, 71), # felstrong for east or se
            Area.new("a cave in Hell",                           0,  0,  0,  0,  1,  0,  2,  0,  0), # felstrong for west
            Area.new("an area of lakes in Hell",                 2,  0,  0,  0,  1,  0,  1,  0,  0), # skalir not wine for north

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
    newLoc = loc
    case 
    when cmd.include?('northeast')
        if @locations[loc].exitNE > 0
            newLoc = loc + 11
        end
    when cmd.include?('southeast')
        newLoc = loc - 9
    when cmd.include?('southwest')
        newLoc = loc - 11
    when cmd.include?('northwest')
        newLoc = loc + 9
    when cmd.include?('north')
        newLoc = loc + 10
    when cmd.include?('east')
        if @locations[loc].exitE > 0
            newLoc = loc + 1
        end
    when cmd.include?('south')
        newLoc = loc - 10
    when cmd.include?('west')
        if @locations[loc].exitE > 0
            newLoc = loc - 1
        end
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
loc = 5

while gameRun == 1
    oldLoc = loc
    puts "You are in " + @locations[loc].descr + "."
    cmd = gets
    loc = mvParser(cmd.downcase, loc)
    if oldLoc == loc
        puts "That way is blocked."     
    end
    puts loc
end