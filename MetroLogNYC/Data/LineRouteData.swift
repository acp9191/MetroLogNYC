import Foundation

/// Defines the ordered route of stations for each subway line
/// Handles branching lines by defining separate branches
struct LineRouteData {

    /// Position of branch relative to main line
    enum BranchPosition {
        case top    // Branch appears before main line (e.g., northern branch)
        case bottom // Branch appears after main line (e.g., southern branch)
    }

    /// A branch of a subway line with ordered station names
    struct Branch: Identifiable {
        let id = UUID()
        let name: String
        let stations: [String]
        let position: BranchPosition
        let branchPoint: String // Station where branch connects to main line
    }

    /// Route definition for a line - can have multiple branches
    struct Route {
        let mainLine: [String]
        let branches: [Branch]

        /// Branches that appear before the main line (merge into main line)
        var topBranches: [Branch] {
            branches.filter { $0.position == .top }
        }

        /// Branches that appear after the main line (split from main line)
        var bottomBranches: [Branch] {
            branches.filter { $0.position == .bottom }
        }

        /// Get stations on main line before a branch point (inclusive)
        func stationsBeforeBranch(_ branch: Branch) -> [String] {
            guard let index = mainLine.firstIndex(of: branch.branchPoint) else {
                return mainLine
            }
            return Array(mainLine[...index])
        }

        /// Get stations on main line after a branch point (exclusive of branch point)
        func stationsAfterBranch(_ branch: Branch) -> [String] {
            guard let index = mainLine.firstIndex(of: branch.branchPoint) else {
                return []
            }
            let nextIndex = mainLine.index(after: index)
            guard nextIndex < mainLine.endIndex else { return [] }
            return Array(mainLine[nextIndex...])
        }

        /// All stations in order (main line only, for non-branching lines)
        var allStations: [String] {
            if branches.isEmpty {
                return mainLine
            }
            // For branching lines, return main + all branches
            return mainLine + branches.flatMap { $0.stations }
        }
    }

    /// Get the route data for a specific line
    static func route(for line: String) -> Route {
        switch line {
        // IRT Broadway-Seventh Avenue Line
        case "1":
            return Route(mainLine: line1Stations, branches: [])
        case "2":
            return Route(mainLine: line2Stations, branches: [])
        case "3":
            return Route(mainLine: line3Stations, branches: [])

        // IRT Lexington Avenue Line
        case "4":
            return Route(mainLine: line4Stations, branches: [])
        case "5":
            return Route(mainLine: line5Stations, branches: [])
        case "6":
            return Route(mainLine: line6Stations, branches: [])

        // IRT Flushing Line
        case "7":
            return Route(mainLine: line7Stations, branches: [])

        // IND Eighth Avenue Line
        case "A":
            return Route(
                mainLine: lineAMainStations,
                branches: [
                    Branch(name: "Far Rockaway", stations: lineAFarRockawayBranch, position: .bottom, branchPoint: "Rockaway Blvd")
                ]
            )
        case "C":
            return Route(mainLine: lineCStations, branches: [])
        case "E":
            return Route(mainLine: lineEStations, branches: [])

        // IND Sixth Avenue Line
        case "B":
            return Route(mainLine: lineBStations, branches: [])
        case "D":
            return Route(mainLine: lineDStations, branches: [])
        case "F":
            return Route(mainLine: lineFStations, branches: [])
        case "M":
            return Route(mainLine: lineMStations, branches: [])

        // IND Crosstown Line
        case "G":
            return Route(mainLine: lineGStations, branches: [])

        // BMT Broadway Line
        case "N":
            return Route(mainLine: lineNStations, branches: [])
        case "Q":
            return Route(mainLine: lineQStations, branches: [])
        case "R":
            return Route(mainLine: lineRStations, branches: [])
        case "W":
            return Route(mainLine: lineWStations, branches: [])

        // BMT Nassau Street Line
        case "J":
            return Route(mainLine: lineJStations, branches: [])
        case "Z":
            return Route(mainLine: lineZStations, branches: [])

        // BMT Canarsie Line
        case "L":
            return Route(mainLine: lineLStations, branches: [])

        // Shuttles
        case "GS":
            return Route(mainLine: lineGSStations, branches: [])
        case "FS":
            return Route(mainLine: lineFSStations, branches: [])
        case "RS":
            return Route(mainLine: lineRSStations, branches: [])

        // Staten Island Railway
        case "SIR":
            return Route(mainLine: lineSIRStations, branches: [])

        default:
            return Route(mainLine: [], branches: [])
        }
    }

    // MARK: - 1 Train (Van Cortlandt Park to South Ferry)
    private static let line1Stations = [
        "Van Cortlandt Park-242 St",
        "238 St",
        "231 St",
        "Marble Hill-225 St",
        "215 St",
        "207 St",
        "Dyckman St",
        "191 St",
        "181 St",
        "168 St",
        "157 St",
        "145 St",
        "137 St-City College",
        "125 St",
        "116 St-Columbia University",
        "110 St-Cathedral Pkwy",
        "103 St",
        "96 St",
        "86 St",
        "79 St",
        "72 St",
        "66 St-Lincoln Center",
        "59 St-Columbus Circle",
        "50 St",
        "Times Sq-42 St",
        "34 St-Penn Station",
        "28 St",
        "23 St",
        "18 St",
        "14 St",
        "Christopher St-Stonewall",
        "Houston St",
        "Canal St",
        "Franklin St",
        "Chambers St",
        "WTC Cortlandt",
        "Rector St",
        "South Ferry"
    ]

    // MARK: - 2 Train (Wakefield-241 St to Flatbush Av)
    private static let line2Stations = [
        "Wakefield-241 St",
        "Nereid Av",
        "233 St",
        "225 St",
        "219 St",
        "Gun Hill Rd",
        "Burke Av",
        "Allerton Av",
        "Pelham Pkwy",
        "Bronx Park East",
        "East 180 St",
        "West Farms Sq-East Tremont Av",
        "174 St",
        "Freeman St",
        "Simpson St",
        "Intervale Av",
        "Prospect Av",
        "Jackson Av",
        "3 Av-149 St",
        "149 St-Grand Concourse",
        "145 St",
        "135 St",
        "125 St",
        "116 St",
        "Central Park North-110 St",
        "96 St",
        "72 St",
        "Times Sq-42 St",
        "34 St-Penn Station",
        "14 St",
        "Chambers St",
        "Park Pl",
        "Fulton St",
        "Wall St",
        "Clark St",
        "Borough Hall",
        "Hoyt St",
        "Nevins St",
        "Atlantic Av-Barclays Ctr",
        "Bergen St",
        "Grand Army Plaza",
        "Eastern Pkwy-Brooklyn Museum",
        "Franklin Av-Medgar Evers College",
        "President St-Medgar Evers College",
        "Sterling St",
        "Winthrop St",
        "Church Av",
        "Beverly Rd",
        "Newkirk Av-Little Haiti",
        "Flatbush Av-Brooklyn College"
    ]

    // MARK: - 3 Train (Harlem-148 St to New Lots Av)
    private static let line3Stations = [
        "Harlem-148 St",
        "145 St",
        "135 St",
        "125 St",
        "116 St",
        "Central Park North-110 St",
        "96 St",
        "72 St",
        "Times Sq-42 St",
        "34 St-Penn Station",
        "14 St",
        "Chambers St",
        "Park Pl",
        "Fulton St",
        "Wall St",
        "Clark St",
        "Borough Hall",
        "Hoyt St",
        "Nevins St",
        "Atlantic Av-Barclays Ctr",
        "Bergen St",
        "Grand Army Plaza",
        "Eastern Pkwy-Brooklyn Museum",
        "Franklin Av-Medgar Evers College",
        "Nostrand Av",
        "Kingston Av",
        "Crown Hts-Utica Av",
        "Sutter Av-Rutland Rd",
        "Saratoga Av",
        "Rockaway Av",
        "Junius St",
        "Pennsylvania Av",
        "Van Siclen Av",
        "New Lots Av"
    ]

    // MARK: - 4 Train (Woodlawn to Crown Hts-Utica Av)
    private static let line4Stations = [
        "Woodlawn",
        "Mosholu Pkwy",
        "Bedford Park Blvd-Lehman College",
        "Kingsbridge Rd",
        "Fordham Rd",
        "183 St",
        "Burnside Av",
        "176 St",
        "Mt Eden Av",
        "170 St",
        "167 St",
        "161 St-Yankee Stadium",
        "149 St-Grand Concourse",
        "138 St-Grand Concourse",
        "125 St",
        "86 St",
        "59 St",
        "Grand Central-42 St",
        "14 St-Union Sq",
        "Brooklyn Bridge-City Hall",
        "Fulton St",
        "Wall St",
        "Bowling Green",
        "Borough Hall",
        "Nevins St",
        "Atlantic Av-Barclays Ctr",
        "Franklin Av-Medgar Evers College",
        "Crown Hts-Utica Av"
    ]

    // MARK: - 5 Train (Eastchester-Dyre Av to Flatbush Av)
    private static let line5Stations = [
        "Eastchester-Dyre Av",
        "Baychester Av",
        "Gun Hill Rd",
        "Pelham Pkwy",
        "Morris Park",
        "East 180 St",
        "West Farms Sq-East Tremont Av",
        "174 St",
        "Freeman St",
        "Simpson St",
        "Intervale Av",
        "Prospect Av",
        "Jackson Av",
        "3 Av-149 St",
        "149 St-Grand Concourse",
        "138 St-Grand Concourse",
        "125 St",
        "86 St",
        "59 St",
        "Grand Central-42 St",
        "14 St-Union Sq",
        "Brooklyn Bridge-City Hall",
        "Fulton St",
        "Wall St",
        "Bowling Green",
        "Borough Hall",
        "Nevins St",
        "Atlantic Av-Barclays Ctr",
        "Franklin Av-Medgar Evers College",
        "President St-Medgar Evers College",
        "Sterling St",
        "Winthrop St",
        "Church Av",
        "Beverly Rd",
        "Newkirk Av-Little Haiti",
        "Flatbush Av-Brooklyn College"
    ]

    // MARK: - 6 Train (Pelham Bay Park to Brooklyn Bridge)
    private static let line6Stations = [
        "Pelham Bay Park",
        "Buhre Av",
        "Middletown Rd",
        "Westchester Sq-East Tremont Av",
        "Zerega Av",
        "Castle Hill Av",
        "Parkchester",
        "St Lawrence Av",
        "Morrison Av-Soundview",
        "Elder Av",
        "Whitlock Av",
        "Hunts Point Av",
        "Longwood Av",
        "East 149 St",
        "East 143 St-St Mary's St",
        "Cypress Av",
        "Brook Av",
        "3 Av-138 St",
        "125 St",
        "116 St",
        "110 St",
        "103 St",
        "96 St",
        "86 St",
        "77 St",
        "68 St-Hunter College",
        "59 St",
        "51 St",
        "Grand Central-42 St",
        "33 St",
        "28 St",
        "23 St",
        "14 St-Union Sq",
        "Astor Pl",
        "Bleecker St",
        "Spring St",
        "Canal St",
        "Brooklyn Bridge-City Hall"
    ]

    // MARK: - 7 Train (Flushing-Main St to 34 St-Hudson Yards)
    private static let line7Stations = [
        "Flushing-Main St",
        "Mets-Willets Point",
        "111 St",
        "103 St-Corona Plaza",
        "Junction Blvd",
        "90 St-Elmhurst Av",
        "82 St-Jackson Hts",
        "74 St-Broadway",
        "69 St",
        "61 St-Woodside",
        "52 St",
        "46 St-Bliss St",
        "40 St-Lowery St",
        "33 St-Rawson St",
        "Queensboro Plaza",
        "Court Sq",
        "Hunters Point Av",
        "Vernon Blvd-Jackson Av",
        "Grand Central",
        "5 Av",
        "Times Sq-42 St",
        "34 St-Hudson Yards"
    ]

    // MARK: - A Train (branches to Far Rockaway and Lefferts Blvd)
    private static let lineAMainStations = [
        "Inwood-207 St",
        "Dyckman St",
        "190 St",
        "181 St",
        "175 St",
        "168 St",
        "145 St",
        "125 St",
        "59 St-Columbus Circle",
        "42 St-Port Authority Bus Terminal",
        "34 St-Penn Station",
        "14 St",
        "West 4 St-Washington Sq",
        "Spring St",
        "Canal St",
        "Chambers St",
        "Fulton St",
        "High St",
        "Jay St-MetroTech",
        "Hoyt-Schermerhorn Sts",
        "Lafayette Av",
        "Clinton-Washington Avs",
        "Franklin Av",
        "Nostrand Av",
        "Kingston-Throop Avs",
        "Utica Av",
        "Ralph Av",
        "Rockaway Av",
        "Broadway Junction",
        "Liberty Av",
        "Van Siclen Av",
        "Shepherd Av",
        "Euclid Av",
        "Grant Av",
        "80 St",
        "88 St",
        "Rockaway Blvd",
        "104 St",
        "111 St",
        "Ozone Park-Lefferts Blvd"
    ]

    private static let lineAFarRockawayBranch = [
        "Aqueduct Racetrack",
        "Aqueduct-N Conduit Av",
        "Howard Beach-JFK Airport",
        "Broad Channel",
        "Beach 67 St",
        "Beach 60 St",
        "Beach 44 St",
        "Beach 36 St",
        "Beach 25 St",
        "Far Rockaway-Mott Av"
    ]

    // MARK: - C Train
    private static let lineCStations = [
        "168 St",
        "163 St-Amsterdam Av",
        "155 St",
        "145 St",
        "135 St",
        "125 St",
        "116 St",
        "110 St-Cathedral Pkwy",
        "103 St",
        "96 St",
        "86 St",
        "81 St-Museum of Natural History",
        "72 St",
        "59 St-Columbus Circle",
        "50 St",
        "42 St-Port Authority Bus Terminal",
        "34 St-Penn Station",
        "23 St",
        "14 St",
        "West 4 St-Washington Sq",
        "Spring St",
        "Canal St",
        "Chambers St",
        "Fulton St",
        "High St",
        "Jay St-MetroTech",
        "Hoyt-Schermerhorn Sts",
        "Lafayette Av",
        "Clinton-Washington Avs",
        "Franklin Av",
        "Nostrand Av",
        "Kingston-Throop Avs",
        "Utica Av",
        "Ralph Av",
        "Rockaway Av",
        "Liberty Av",
        "Van Siclen Av",
        "Shepherd Av",
        "Euclid Av"
    ]

    // MARK: - E Train
    private static let lineEStations = [
        "Jamaica Center-Parsons/Archer",
        "Sutphin Blvd-Archer Av-JFK Airport",
        "Jamaica-Van Wyck",
        "Kew Gardens-Union Tpke",
        "75 Av",
        "Forest Hills-71 Av",
        "Jackson Hts-Roosevelt Av",
        "Queens Plaza",
        "Court Sq-23 St",
        "Lexington Av/53 St",
        "5 Av/53 St",
        "7 Av",
        "50 St",
        "42 St-Port Authority Bus Terminal",
        "34 St-Penn Station",
        "23 St",
        "14 St",
        "West 4 St-Washington Sq",
        "Spring St",
        "Canal St",
        "World Trade Center"
    ]

    // MARK: - B Train
    private static let lineBStations = [
        "Bedford Park Blvd",
        "Kingsbridge Rd",
        "Fordham Rd",
        "182-183 Sts",
        "Tremont Av",
        "174-175 Sts",
        "170 St",
        "167 St",
        "161 St-Yankee Stadium",
        "155 St",
        "145 St",
        "135 St",
        "125 St",
        "116 St",
        "110 St-Cathedral Pkwy",
        "103 St",
        "96 St",
        "86 St",
        "81 St-Museum of Natural History",
        "72 St",
        "59 St-Columbus Circle",
        "7 Av",
        "47-50 Sts-Rockefeller Ctr",
        "42 St-Bryant Park",
        "34 St-Herald Sq",
        "Broadway-Lafayette St",
        "Grand St",
        "DeKalb Av",
        "Atlantic Av-Barclays Ctr",
        "7 Av",
        "Prospect Park",
        "Church Av",
        "Newkirk Plaza",
        "Kings Hwy",
        "Sheepshead Bay",
        "Brighton Beach"
    ]

    // MARK: - D Train
    private static let lineDStations = [
        "Norwood-205 St",
        "Bedford Park Blvd",
        "Kingsbridge Rd",
        "Fordham Rd",
        "182-183 Sts",
        "Tremont Av",
        "174-175 Sts",
        "170 St",
        "167 St",
        "161 St-Yankee Stadium",
        "155 St",
        "145 St",
        "125 St",
        "59 St-Columbus Circle",
        "7 Av",
        "47-50 Sts-Rockefeller Ctr",
        "42 St-Bryant Park",
        "34 St-Herald Sq",
        "Broadway-Lafayette St",
        "Grand St",
        "DeKalb Av",
        "Atlantic Av-Barclays Ctr",
        "36 St",
        "9 Av",
        "Fort Hamilton Pkwy",
        "50 St",
        "55 St",
        "62 St",
        "71 St",
        "79 St",
        "18 Av",
        "20 Av",
        "Bay Pkwy",
        "25 Av",
        "Bay 50 St",
        "Coney Island-Stillwell Av"
    ]

    // MARK: - F Train
    private static let lineFStations = [
        "Jamaica-179 St",
        "169 St",
        "Parsons Blvd",
        "Sutphin Blvd",
        "Briarwood",
        "Kew Gardens-Union Tpke",
        "75 Av",
        "Forest Hills-71 Av",
        "67 Av",
        "63 Dr-Rego Park",
        "Woodhaven Blvd",
        "Grand Av-Newtown",
        "Elmhurst Av",
        "Jackson Hts-Roosevelt Av",
        "65 St",
        "Northern Blvd",
        "46 St",
        "Steinway St",
        "36 St",
        "Queens Plaza",
        "21 St-Queensbridge",
        "Roosevelt Island",
        "Lexington Av/63 St",
        "57 St",
        "47-50 Sts-Rockefeller Ctr",
        "42 St-Bryant Park",
        "34 St-Herald Sq",
        "23 St",
        "14 St",
        "West 4 St-Washington Sq",
        "Broadway-Lafayette St",
        "2 Av",
        "Delancey St",
        "East Broadway",
        "York St",
        "Jay St-MetroTech",
        "Bergen St",
        "Carroll St",
        "Smith-9 Sts",
        "4 Av-9 St",
        "7 Av",
        "15 St-Prospect Park",
        "Fort Hamilton Pkwy",
        "Church Av",
        "Ditmas Av",
        "18 Av",
        "Av I",
        "Bay Pkwy",
        "Av N",
        "Av P",
        "Kings Hwy",
        "Av U",
        "Av X",
        "Neptune Av",
        "West 8 St-NY Aquarium",
        "Coney Island-Stillwell Av"
    ]

    // MARK: - M Train
    private static let lineMStations = [
        "Middle Village-Metropolitan Av",
        "Fresh Pond Rd",
        "Forest Av",
        "Seneca Av",
        "Myrtle-Wyckoff Avs",
        "Knickerbocker Av",
        "Central Av",
        "Myrtle Av-Broadway",
        "Flushing Av",
        "Lorimer St",
        "Hewes St",
        "Marcy Av",
        "Essex St",
        "Broadway-Lafayette St",
        "14 St",
        "23 St",
        "34 St-Herald Sq",
        "42 St-Bryant Park",
        "47-50 Sts-Rockefeller Ctr",
        "57 St",
        "Lexington Av/53 St",
        "Court Sq-23 St",
        "Queens Plaza",
        "36 St",
        "Steinway St",
        "46 St",
        "Northern Blvd",
        "65 St",
        "Jackson Hts-Roosevelt Av",
        "Elmhurst Av",
        "Grand Av-Newtown",
        "Woodhaven Blvd",
        "63 Dr-Rego Park",
        "67 Av",
        "Forest Hills-71 Av"
    ]

    // MARK: - G Train
    private static let lineGStations = [
        "Court Sq",
        "21 St",
        "Greenpoint Av",
        "Nassau Av",
        "Metropolitan Av",
        "Broadway",
        "Flushing Av",
        "Myrtle-Willoughby Avs",
        "Bedford-Nostrand Avs",
        "Classon Av",
        "Clinton-Washington Avs",
        "Fulton St",
        "Hoyt-Schermerhorn Sts",
        "Bergen St",
        "Carroll St",
        "Smith-9 Sts",
        "4 Av-9 St",
        "7 Av",
        "15 St-Prospect Park",
        "Fort Hamilton Pkwy",
        "Church Av"
    ]

    // MARK: - N Train
    private static let lineNStations = [
        "Astoria-Ditmars Blvd",
        "Astoria Blvd",
        "30 Av",
        "Broadway",
        "36 Av",
        "39 Av",
        "Queensboro Plaza",
        "Lexington Av/59 St",
        "5 Av-59 St",
        "57 St-7 Av",
        "49 St",
        "Times Sq-42 St",
        "34 St-Herald Sq",
        "28 St",
        "23 St",
        "14 St-Union Sq",
        "8 St-NYU",
        "Prince St",
        "Canal St",
        "City Hall",
        "Cortlandt St",
        "Rector St",
        "Whitehall St-South Ferry",
        "Atlantic Av-Barclays Ctr",
        "36 St",
        "59 St",
        "8 Av",
        "Fort Hamilton Pkwy",
        "New Utrecht Av",
        "18 Av",
        "20 Av",
        "Bay Pkwy",
        "Kings Hwy",
        "Av U",
        "86 St",
        "Coney Island-Stillwell Av"
    ]

    // MARK: - Q Train
    private static let lineQStations = [
        "96 St",
        "86 St",
        "72 St",
        "Lexington Av/63 St",
        "57 St-7 Av",
        "49 St",
        "Times Sq-42 St",
        "34 St-Herald Sq",
        "14 St-Union Sq",
        "Canal St",
        "DeKalb Av",
        "Atlantic Av-Barclays Ctr",
        "7 Av",
        "Prospect Park",
        "Parkside Av",
        "Church Av",
        "Beverley Rd",
        "Cortelyou Rd",
        "Newkirk Plaza",
        "Av H",
        "Av J",
        "Av M",
        "Kings Hwy",
        "Av U",
        "Neck Rd",
        "Sheepshead Bay",
        "Brighton Beach",
        "Ocean Pkwy",
        "West 8 St-NY Aquarium",
        "Coney Island-Stillwell Av"
    ]

    // MARK: - R Train
    private static let lineRStations = [
        "Forest Hills-71 Av",
        "67 Av",
        "63 Dr-Rego Park",
        "Woodhaven Blvd",
        "Grand Av-Newtown",
        "Elmhurst Av",
        "Jackson Hts-Roosevelt Av",
        "65 St",
        "Northern Blvd",
        "46 St",
        "Steinway St",
        "36 St",
        "Queens Plaza",
        "Lexington Av/59 St",
        "5 Av-59 St",
        "57 St-7 Av",
        "49 St",
        "Times Sq-42 St",
        "34 St-Herald Sq",
        "28 St",
        "23 St",
        "14 St-Union Sq",
        "8 St-NYU",
        "Prince St",
        "Canal St",
        "City Hall",
        "Cortlandt St",
        "Rector St",
        "Whitehall St-South Ferry",
        "Court St",
        "Jay St-MetroTech",
        "DeKalb Av",
        "Atlantic Av-Barclays Ctr",
        "Union St",
        "9 St",
        "Prospect Av",
        "25 St",
        "36 St",
        "45 St",
        "53 St",
        "59 St",
        "Bay Ridge Av",
        "77 St",
        "86 St",
        "Bay Ridge-95 St"
    ]

    // MARK: - W Train
    private static let lineWStations = [
        "Astoria-Ditmars Blvd",
        "Astoria Blvd",
        "30 Av",
        "Broadway",
        "36 Av",
        "39 Av",
        "Queensboro Plaza",
        "Lexington Av/59 St",
        "5 Av-59 St",
        "57 St-7 Av",
        "49 St",
        "Times Sq-42 St",
        "34 St-Herald Sq",
        "28 St",
        "23 St",
        "14 St-Union Sq",
        "8 St-NYU",
        "Prince St",
        "Canal St",
        "City Hall",
        "Cortlandt St",
        "Rector St",
        "Whitehall St-South Ferry"
    ]

    // MARK: - J Train
    private static let lineJStations = [
        "Jamaica Center-Parsons/Archer",
        "Sutphin Blvd-Archer Av-JFK Airport",
        "121 St",
        "111 St",
        "104 St",
        "Woodhaven Blvd",
        "85 St-Forest Pkwy",
        "75 St-Elderts Ln",
        "Cypress Hills",
        "Crescent St",
        "Norwood Av",
        "Cleveland St",
        "Van Siclen Av",
        "Alabama Av",
        "Broadway Junction",
        "Chauncey St",
        "Halsey St",
        "Gates Av",
        "Kosciuszko St",
        "Myrtle Av-Broadway",
        "Flushing Av",
        "Lorimer St",
        "Hewes St",
        "Marcy Av",
        "Essex St",
        "Bowery",
        "Canal St",
        "Chambers St",
        "Fulton St",
        "Broad St"
    ]

    // MARK: - Z Train (skip-stop express)
    private static let lineZStations = [
        "Jamaica Center-Parsons/Archer",
        "Sutphin Blvd-Archer Av-JFK Airport",
        "121 St",
        "Woodhaven Blvd",
        "75 St-Elderts Ln",
        "Crescent St",
        "Norwood Av",
        "Van Siclen Av",
        "Broadway Junction",
        "Chauncey St",
        "Myrtle Av-Broadway",
        "Marcy Av",
        "Essex St",
        "Bowery",
        "Canal St",
        "Chambers St",
        "Fulton St",
        "Broad St"
    ]

    // MARK: - L Train
    private static let lineLStations = [
        "8 Av",
        "6 Av",
        "14 St-Union Sq",
        "3 Av",
        "1 Av",
        "Bedford Av",
        "Lorimer St",
        "Graham Av",
        "Grand St",
        "Montrose Av",
        "Morgan Av",
        "Jefferson St",
        "DeKalb Av",
        "Myrtle-Wyckoff Avs",
        "Halsey St",
        "Wilson Av",
        "Bushwick Av-Aberdeen St",
        "Broadway Junction",
        "Atlantic Av",
        "Sutter Av",
        "Livonia Av",
        "New Lots Av",
        "East 105 St",
        "Canarsie-Rockaway Pkwy"
    ]

    // MARK: - Shuttles
    private static let lineGSStations = [
        "Grand Central",
        "Times Sq"
    ]

    private static let lineFSStations = [
        "Franklin Av",
        "Park Pl",
        "Botanic Garden",
        "Prospect Park"
    ]

    private static let lineRSStations = [
        "Broad Channel",
        "Beach 90 St",
        "Beach 98 St",
        "Beach 105 St",
        "Rockaway Park-Beach 116 St"
    ]

    // MARK: - Staten Island Railway
    private static let lineSIRStations = [
        "St George",
        "Tompkinsville",
        "Stapleton",
        "Clifton",
        "Grasmere",
        "Old Town",
        "Dongan Hills",
        "Jefferson Av",
        "Grant City",
        "New Dorp",
        "Oakwood Heights",
        "Bay Terrace",
        "Great Kills",
        "Eltingville",
        "Annadale",
        "Huguenot",
        "Prince's Bay",
        "Pleasant Plains",
        "Richmond Valley",
        "Arthur Kill",
        "Tottenville"
    ]
}
