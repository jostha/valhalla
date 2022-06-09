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
#  N : +9
# NE : +10
#  E : +1
# SE : -8
#  S : -9
# SW : -10
#  W : -1
# NW : +8
#  R : Use Ring takes to R location (if 0 msg)

# Movement values:
#  0 : Can't go that way
#  1 : Can go that way

# Handle locked and unlocked routes when items are collected to keep movement matrix simple and number of conditions down
# I have set special movement to 2 (i.e. requiring / not requiring an object) for testing

# Dummy room inserted so I can count from 1, simpler without a map matrix
@locations = [
    #                 descr                                      N  NE   E  SE   S  SW   W  NW   R 
            Area.new("cyberspace",                               0,  0,  0,  0,  0,  0,  0,  0,  0), # AREA 0
#1>
            Area.new("a cave in Hell",                           0,  0,  2,  0,  0,  0,  0,  0, 59), # drapnir not ofnir for east
            Area.new("a cave in Hell",                           0,  0,  1,  0,  0,  0,  2,  0,  1), # drapnir not ofnir for west
            Area.new("Hell",                                     0,  0,  2,  0,  0,  0,  1,  0,  3), # shield not helmet for east
            Area.new("Hell",                                     0,  0,  0,  0,  0,  0,  2,  0, 59), # shield not helmet for west  # SKORNIR
            Area.new("an icy waste in Hell",                     0,  0,  2,  0,  0,  0,  0,  0, 24), # key not felstrong for east
            Area.new("a cave in Hell",                           2,  0,  0,  0,  0,  0,  2,  0, 71), # key not felstrong for west, skornir not ring for north # FELSTRONG
            Area.new("an icy waste in Hell",                     1,  2,  1,  0,  0,  0,  0,  0,  7), # skalir for north east
            Area.new("a marsh in Hell",                          0,  1,  2,  0,  0,  0,  1,  1, 21), # no food for east
            Area.new("a plain in Hell",                          1,  0,  0,  0,  0,  0,  2,  0, 18), # no food for west
#10>
            Area.new("a cave in Hell",                           1,  1,  1,  0,  0,  0,  0,  0, 66),
            Area.new("the Pits, which is in a cave in Hell",     0,  0,  1,  0,  0,  0,  1,  0, 22), 
            Area.new("a cave in Hell",                           1,  0,  0,  0,  0,  0,  1,  0, 19),
            Area.new("the mountains in Hell",                    0,  0,  2,  0,  0,  0,  0,  0,  0), # skalir for east
            Area.new("Asnir, which is in the mountains in Hell", 0,  0,  2,  0,  0,  0,  2,  0, 71), # skalir for east and west
            Area.new("the mountains in Hell",                    0,  0,  0,  0,  2,  0,  2,  0,  0), # skalir west, skornir not ring south
            Area.new("an icy waste in Hell",                     1,  0,  2,  1,  1,  0,  0,  0, 66), # skalir for east
            Area.new("a plain in Hell",                          1,  0,  0,  0,  0,  1,  2,  0, 66), # skalir for west
            Area.new("in the mountains in Hell",                 1,  0,  0,  0,  1,  1,  0,  0,  0), 
#19>
            Area.new("in Hell",                                  2,  0,  2,  0,  2,  0,  0,  0, 12), # hel for north, east, and south
            Area.new("an icy waste in Hell",                     1,  0,  2,  0,  0,  1,  0,  0, 46), # ofnir for east
            Area.new("an icy waste in Hell",                     1,  1,  2,  0,  0,  2,  2,  1,  0), # ofnir for north, east, sw and west
            Area.new("a marsh in Hell",                          0,  0,  1,  0,  0,  0,  2,  0,  0), # ofnir for west
            Area.new("a marsh in Hell",                          1,  0,  0,  0,  0,  0,  1,  0, 50),
            Area.new("a cave in Hell",                           0,  0,  2,  0,  0,  0,  0,  0, 71), # skornir for east
            Area.new("a cave in Hell",                           0,  0,  2,  2,  0,  0,  0,  0, 71), # felstrong for east or se
            Area.new("a cave in Hell",                           0,  0,  0,  0,  1,  0,  2,  0,  0), # felstrong for west
            Area.new("an area of lakes in Hell",                 2,  0,  0,  0,  1,  0,  1,  0,  0), # skalir not wine for north
#28>
            Area.new("Despair, which is in Hell",                2,  0,  0,  0,  2,  0,  0,  0, 10), # food not ofnir for north, hel for south
            Area.new("an icy waste in Hell",                     1,  1,  0,  1,  0,  0,  0,  0, 46), 
            Area.new("Hel's hall, which is in Hell",             1,  0,  0,  0,  2,  0,  0,  0, 48), # ofnir for south
            Area.new("an icy waste in Hell",                     1,  0,  0,  0,  0,  1,  0,  1,  0),
            Area.new("Klepto's hall, which is in Hell",          2,  0,  0,  0,  1,  0,  0,  0,  0), # skornir not drapnir for north
            Area.new("a marsh in Hell",                          0,  1,  1,  0,  0,  0,  0,  0, 71),
            Area.new("a marsh in Hell",                          1,  0,  1,  0,  0,  0,  1,  0, 71),
            Area.new("a marsh in Hell",                          2,  0,  0,  0,  0,  0,  1,  1, 71), # sword not key for north
            Area.new("the mountains in Hell",                    1,  0,  0,  0,  2,  0,  0,  0,  0), # skalir not wine for east
#37>
            Area.new("Hell",                                     0,  0,  1,  0,  0,  0,  0,  0,  0), # DRAPNIR
            Area.new("Hell",                                     0,  0,  0,  0,  1,  0,  0,  0,  0),
            Area.new("an icy waste in Hell",                     1,  0,  0,  1,  0,  1,  0,  1,  0),
            Area.new("Rankle's hall, which is in Hell",          2,  0,  0,  0,  1,  0,  0,  0,  0), # skornir for north 
            Area.new("Trouble, which is in Hell",                0,  0,  2,  0,  2,  0,  0,  0, 70), # wine not ring e, skornir not drapnir s             )
            Area.new("a cave in Hell",                           1,  0,  0,  0,  0,  0,  2,  0, 43), # wine not ring w
            Area.new("an icy waste in Hell",                     1,  1,  0,  1,  1,  1,  0,  1, 66),
            Area.new("the mountains in Hell",                    1,  0,  0,  0,  2,  1,  1,  1, 71), # SKALIR
            Area.new("a forest in Hell",                         1,  0,  0,  0,  1,  0,  0,  1,  0),
#46>
            Area.new("a cave in Midgard",                        0,  0,  0,  0,  0,  0,  0,  0, 31),
            Area.new("a marsh in Midgard",                       1,  0,  1,  1,  0,  0,  0,  1,  0),
            Area.new("Hellgate, which is in a marsh in Midgard", 2,  0,  0,  0,  1,  0,  1,  1,  0), # ofnir for north
            Area.new("a marsh in Midgard",                       1,  0,  1,  0,  0,  0,  0,  0, 47),
            Area.new("the mountains in Midgard",                 2,  0,  1,  0,  0,  0,  1,  1, 21), # ofnir north
            Area.new("an area of lakes in Asgard",               2,  1,  1,  0,  0,  0,  1,  0, 68), # no axe north
            Area.new("an area of lakes in Asgard",               1,  0,  1,  0,  0,  0,  1,  0,  0),
            Area.new("in the mountains in Asgard",               1,  0,  0,  0,  0,  0,  1,  1, 56),
            Area.new("in a marsh in Asgard",                     1,  0,  0,  0,  1,  0,  1,  0,  0)
#55>

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
            newLoc = loc + 10
        end
    when cmd.include?('southeast')
        if @locations[loc].exitSE > 0
            newLoc = loc - 8
        end
    when cmd.include?('southwest')
        if @locations[loc].exitSW > 0
            newLoc = loc - 10
        end
    when cmd.include?('northwest')
        if @locations[loc].exitNW > 0
            newLoc = loc + 8
        end
    when cmd.include?('north')
        if @locations[loc].exitN > 0
            newLoc = loc + 9
        end
    when cmd.include?('east')
        if @locations[loc].exitE > 0
            newLoc = loc + 1
        end
    when cmd.include?('south')
        if @locations[loc].exitS > 0
            newLoc = loc - 9
        end
    when cmd.include?('west')
        if @locations[loc].exitW > 0
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
loc = 17

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