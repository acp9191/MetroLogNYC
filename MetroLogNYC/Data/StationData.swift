import Foundation
import SwiftData

/// Seed data for all NYC subway stations
/// Data sourced from MTA GTFS feeds
struct StationData {

    /// Seeds the database with all NYC subway stations and complexes if empty
    @MainActor
    static func seedIfNeeded(modelContext: ModelContext) {
        let stationDescriptor = FetchDescriptor<Station>()
        let existingStationCount = (try? modelContext.fetchCount(stationDescriptor)) ?? 0

        guard existingStationCount == 0 else { return }

        // Create complexes first
        var complexesByName: [String: StationComplex] = [:]
        for complexInfo in allComplexes {
            let complex = StationComplex(
                name: complexInfo.name,
                borough: complexInfo.borough
            )
            modelContext.insert(complex)
            complexesByName[complexInfo.name] = complex
        }

        // Create stations and link to complexes
        for stationInfo in allStations {
            let station = Station(
                name: stationInfo.name,
                lines: stationInfo.lines,
                latitude: stationInfo.latitude,
                longitude: stationInfo.longitude,
                borough: stationInfo.borough
            )

            // Link station to complex if specified
            if let complexName = stationInfo.complexName,
               let complex = complexesByName[complexName] {
                station.complex = complex
            }

            modelContext.insert(station)
        }

        try? modelContext.save()
    }

    /// Station info for seeding
    struct StationInfo {
        let name: String
        let lines: [SubwayLine]
        let latitude: Double
        let longitude: Double
        let borough: Borough
        let complexName: String?

        init(name: String, lines: [SubwayLine], latitude: Double, longitude: Double, borough: Borough, complexName: String? = nil) {
            self.name = name
            self.lines = lines
            self.latitude = latitude
            self.longitude = longitude
            self.borough = borough
            self.complexName = complexName
        }
    }

    /// Complex info for seeding
    struct ComplexInfo {
        let name: String
        let borough: Borough
    }

    /// All 32 multi-station complexes
    static let allComplexes: [ComplexInfo] = [
        // Manhattan (18)
        ComplexInfo(name: "168 St", borough: .manhattan),
        ComplexInfo(name: "59 St-Columbus Circle", borough: .manhattan),
        ComplexInfo(name: "Lexington Av/59 St", borough: .manhattan),
        ComplexInfo(name: "51 St / Lexington Av-53 St", borough: .manhattan),
        ComplexInfo(name: "Times Sq-42 St / 42 St-Port Authority", borough: .manhattan),
        ComplexInfo(name: "42 St-Bryant Park / 5 Av", borough: .manhattan),
        ComplexInfo(name: "Grand Central-42 St", borough: .manhattan),
        ComplexInfo(name: "34 St-Herald Sq", borough: .manhattan),
        ComplexInfo(name: "14 St / 8 Av", borough: .manhattan),
        ComplexInfo(name: "14 St / 6 Av", borough: .manhattan),
        ComplexInfo(name: "14 St-Union Sq", borough: .manhattan),
        ComplexInfo(name: "Bleecker St / Broadway-Lafayette St", borough: .manhattan),
        ComplexInfo(name: "Delancey St-Essex St", borough: .manhattan),
        ComplexInfo(name: "Canal St", borough: .manhattan),
        ComplexInfo(name: "Chambers St / Brooklyn Bridge-City Hall", borough: .manhattan),
        ComplexInfo(name: "Fulton St / Park Pl / Cortlandt St", borough: .manhattan),
        ComplexInfo(name: "Fulton St", borough: .manhattan),
        ComplexInfo(name: "Whitehall St-South Ferry / South Ferry", borough: .manhattan),

        // Bronx (2)
        ComplexInfo(name: "161 St-Yankee Stadium", borough: .bronx),
        ComplexInfo(name: "149 St-Grand Concourse", borough: .bronx),

        // Queens (2)
        ComplexInfo(name: "Court Sq / Court Sq-23 St", borough: .queens),
        ComplexInfo(name: "Jackson Hts-Roosevelt Av / 74 St-Broadway", borough: .queens),

        // Brooklyn (10)
        ComplexInfo(name: "Lorimer St / Metropolitan Av", borough: .brooklyn),
        ComplexInfo(name: "Myrtle-Wyckoff Avs", borough: .brooklyn),
        ComplexInfo(name: "Court St / Borough Hall", borough: .brooklyn),
        ComplexInfo(name: "Jay St-MetroTech", borough: .brooklyn),
        ComplexInfo(name: "Atlantic Av-Barclays Ctr", borough: .brooklyn),
        ComplexInfo(name: "Franklin Av", borough: .brooklyn),
        ComplexInfo(name: "Broadway Junction", borough: .brooklyn),
        ComplexInfo(name: "4 Av-9 St", borough: .brooklyn),
        ComplexInfo(name: "Franklin Av / Botanic Garden", borough: .brooklyn),
        ComplexInfo(name: "New Utrecht Av / 62 St", borough: .brooklyn),
    ]

    /// All 472 NYC subway stations
    static let allStations: [StationInfo] = [
        // MANHATTAN STATIONS
        // IRT Broadway-Seventh Avenue Line (1/2/3)
        StationInfo(name: "South Ferry", lines: [.one], latitude: 40.701411, longitude: -74.013042, borough: .manhattan, complexName: "Whitehall St-South Ferry / South Ferry"),
        StationInfo(name: "Rector St", lines: [.one], latitude: 40.707513, longitude: -74.013783, borough: .manhattan),
        StationInfo(name: "City Hall", lines: [.r, .w], latitude: 40.713282, longitude: -74.006978, borough: .manhattan),
        StationInfo(name: "WTC Cortlandt", lines: [.one], latitude: 40.711835, longitude: -74.011029, borough: .manhattan),
        StationInfo(name: "Chambers St", lines: [.one, .two, .three], latitude: 40.715478, longitude: -74.009266, borough: .manhattan),
        StationInfo(name: "Franklin St", lines: [.one], latitude: 40.719318, longitude: -74.006886, borough: .manhattan),
        StationInfo(name: "Canal St", lines: [.one], latitude: 40.722854, longitude: -74.005327, borough: .manhattan),
        StationInfo(name: "Houston St", lines: [.one], latitude: 40.728251, longitude: -74.002353, borough: .manhattan),
        StationInfo(name: "Christopher St-Stonewall", lines: [.one], latitude: 40.733422, longitude: -74.002906, borough: .manhattan),
        StationInfo(name: "14 St", lines: [.one, .two, .three], latitude: 40.737826, longitude: -74.000201, borough: .manhattan, complexName: "14 St / 6 Av"),
        StationInfo(name: "18 St", lines: [.one], latitude: 40.741040, longitude: -73.997871, borough: .manhattan),
        StationInfo(name: "23 St", lines: [.one], latitude: 40.744081, longitude: -73.995657, borough: .manhattan),
        StationInfo(name: "28 St", lines: [.one], latitude: 40.747215, longitude: -73.993365, borough: .manhattan),
        StationInfo(name: "34 St-Penn Station", lines: [.one, .two, .three], latitude: 40.750373, longitude: -73.991057, borough: .manhattan),
        StationInfo(name: "Times Sq-42 St", lines: [.one, .two, .three], latitude: 40.754672, longitude: -73.986754, borough: .manhattan, complexName: "Times Sq-42 St / 42 St-Port Authority"),
        StationInfo(name: "Times Sq-42 St", lines: [.seven], latitude: 40.754612, longitude: -73.987495, borough: .manhattan, complexName: "Times Sq-42 St / 42 St-Port Authority"),
        StationInfo(name: "Times Sq-42 St", lines: [.n, .q, .r, .w], latitude: 40.754901, longitude: -73.987691, borough: .manhattan, complexName: "Times Sq-42 St / 42 St-Port Authority"),
        StationInfo(name: "Times Sq", lines: [.gs], latitude: 40.755477, longitude: -73.986873, borough: .manhattan, complexName: "Times Sq-42 St / 42 St-Port Authority"),
        StationInfo(name: "50 St", lines: [.one], latitude: 40.761728, longitude: -73.983849, borough: .manhattan),
        StationInfo(name: "59 St-Columbus Circle", lines: [.a, .b, .c, .d], latitude: 40.768247, longitude: -73.981929, borough: .manhattan, complexName: "59 St-Columbus Circle"),
        StationInfo(name: "59 St-Columbus Circle", lines: [.one], latitude: 40.768296, longitude: -73.981736, borough: .manhattan, complexName: "59 St-Columbus Circle"),
        StationInfo(name: "66 St-Lincoln Center", lines: [.one], latitude: 40.773621, longitude: -73.982209, borough: .manhattan),
        StationInfo(name: "72 St", lines: [.one, .two, .three], latitude: 40.778453, longitude: -73.981970, borough: .manhattan),
        StationInfo(name: "79 St", lines: [.one], latitude: 40.783934, longitude: -73.979917, borough: .manhattan),
        StationInfo(name: "86 St", lines: [.one], latitude: 40.788644, longitude: -73.976218, borough: .manhattan),
        StationInfo(name: "96 St", lines: [.one, .two, .three], latitude: 40.793919, longitude: -73.972323, borough: .manhattan),
        StationInfo(name: "103 St", lines: [.one], latitude: 40.799446, longitude: -73.968379, borough: .manhattan),
        StationInfo(name: "110 St-Cathedral Pkwy", lines: [.one], latitude: 40.803967, longitude: -73.966847, borough: .manhattan),
        StationInfo(name: "116 St-Columbia University", lines: [.one], latitude: 40.807722, longitude: -73.964113, borough: .manhattan),
        StationInfo(name: "125 St", lines: [.one], latitude: 40.815581, longitude: -73.958372, borough: .manhattan),
        StationInfo(name: "137 St-City College", lines: [.one], latitude: 40.822008, longitude: -73.953676, borough: .manhattan),
        StationInfo(name: "145 St", lines: [.one], latitude: 40.826551, longitude: -73.950308, borough: .manhattan),
        StationInfo(name: "157 St", lines: [.one], latitude: 40.834041, longitude: -73.944741, borough: .manhattan),
        StationInfo(name: "168 St", lines: [.a, .c], latitude: 40.840719, longitude: -73.939561, borough: .manhattan, complexName: "168 St"),
        StationInfo(name: "168 St", lines: [.one], latitude: 40.840556, longitude: -73.939534, borough: .manhattan, complexName: "168 St"),
        StationInfo(name: "181 St", lines: [.one], latitude: 40.849505, longitude: -73.933596, borough: .manhattan),
        StationInfo(name: "191 St", lines: [.one], latitude: 40.855225, longitude: -73.929412, borough: .manhattan),
        StationInfo(name: "Dyckman St", lines: [.one], latitude: 40.860531, longitude: -73.925536, borough: .manhattan),
        StationInfo(name: "207 St", lines: [.one], latitude: 40.864621, longitude: -73.918822, borough: .manhattan),
        StationInfo(name: "215 St", lines: [.one], latitude: 40.869444, longitude: -73.915279, borough: .manhattan),
        StationInfo(name: "Marble Hill-225 St", lines: [.one], latitude: 40.874561, longitude: -73.909831, borough: .manhattan),
        StationInfo(name: "231 St", lines: [.one], latitude: 40.878856, longitude: -73.904834, borough: .bronx),
        StationInfo(name: "238 St", lines: [.one], latitude: 40.884667, longitude: -73.900870, borough: .bronx),
        StationInfo(name: "Van Cortlandt Park-242 St", lines: [.one], latitude: 40.889248, longitude: -73.898583, borough: .bronx),

        // IRT Lexington Avenue Line (4/5/6)
        StationInfo(name: "Brooklyn Bridge-City Hall", lines: [.four, .five, .six], latitude: 40.713065, longitude: -74.004131, borough: .manhattan, complexName: "Chambers St / Brooklyn Bridge-City Hall"),
        StationInfo(name: "Canal St", lines: [.six], latitude: 40.718803, longitude: -74.000193, borough: .manhattan, complexName: "Canal St"),
        StationInfo(name: "Spring St", lines: [.six], latitude: 40.722301, longitude: -73.997141, borough: .manhattan),
        StationInfo(name: "Bleecker St", lines: [.six], latitude: 40.725915, longitude: -73.994659, borough: .manhattan, complexName: "Bleecker St / Broadway-Lafayette St"),
        StationInfo(name: "Astor Pl", lines: [.six], latitude: 40.730054, longitude: -73.991070, borough: .manhattan),
        StationInfo(name: "14 St-Union Sq", lines: [.four, .five, .six], latitude: 40.735736, longitude: -73.990568, borough: .manhattan, complexName: "14 St-Union Sq"),
        StationInfo(name: "14 St-Union Sq", lines: [.l], latitude: 40.734673, longitude: -73.990570, borough: .manhattan, complexName: "14 St-Union Sq"),
        StationInfo(name: "14 St-Union Sq", lines: [.n, .q, .r, .w], latitude: 40.735863, longitude: -73.989907, borough: .manhattan, complexName: "14 St-Union Sq"),
        StationInfo(name: "23 St", lines: [.six], latitude: 40.739864, longitude: -73.986599, borough: .manhattan),
        StationInfo(name: "28 St", lines: [.six], latitude: 40.743077, longitude: -73.984318, borough: .manhattan),
        StationInfo(name: "33 St", lines: [.six], latitude: 40.746081, longitude: -73.982076, borough: .manhattan),
        StationInfo(name: "Grand Central-42 St", lines: [.four, .five, .six], latitude: 40.751776, longitude: -73.976848, borough: .manhattan, complexName: "Grand Central-42 St"),
        StationInfo(name: "Grand Central", lines: [.seven], latitude: 40.751431, longitude: -73.976041, borough: .manhattan, complexName: "Grand Central-42 St"),
        StationInfo(name: "Grand Central", lines: [.gs], latitude: 40.752769, longitude: -73.979189, borough: .manhattan, complexName: "Grand Central-42 St"),
        StationInfo(name: "51 St", lines: [.six], latitude: 40.757107, longitude: -73.971917, borough: .manhattan, complexName: "51 St / Lexington Av-53 St"),
        StationInfo(name: "59 St", lines: [.four, .five, .six], latitude: 40.762526, longitude: -73.967967, borough: .manhattan, complexName: "Lexington Av/59 St"),
        StationInfo(name: "68 St-Hunter College", lines: [.six], latitude: 40.768141, longitude: -73.964015, borough: .manhattan),
        StationInfo(name: "77 St", lines: [.six], latitude: 40.773621, longitude: -73.959874, borough: .manhattan),
        StationInfo(name: "86 St", lines: [.four, .five, .six], latitude: 40.779492, longitude: -73.955589, borough: .manhattan),
        StationInfo(name: "96 St", lines: [.six], latitude: 40.785672, longitude: -73.951014, borough: .manhattan),
        StationInfo(name: "103 St", lines: [.six], latitude: 40.790600, longitude: -73.947478, borough: .manhattan),
        StationInfo(name: "110 St", lines: [.six], latitude: 40.795020, longitude: -73.944430, borough: .manhattan),
        StationInfo(name: "116 St", lines: [.six], latitude: 40.798629, longitude: -73.941617, borough: .manhattan),
        StationInfo(name: "125 St", lines: [.four, .five, .six], latitude: 40.804138, longitude: -73.937594, borough: .manhattan),

        // IRT Pelham Line (6) - Bronx
        StationInfo(name: "3 Av-138 St", lines: [.six], latitude: 40.810476, longitude: -73.926138, borough: .bronx),
        StationInfo(name: "Brook Av", lines: [.six], latitude: 40.807566, longitude: -73.919241, borough: .bronx),
        StationInfo(name: "Cypress Av", lines: [.six], latitude: 40.805368, longitude: -73.914042, borough: .bronx),
        StationInfo(name: "East 143 St-St Mary's St", lines: [.six], latitude: 40.808719, longitude: -73.907657, borough: .bronx),
        StationInfo(name: "East 149 St", lines: [.six], latitude: 40.812118, longitude: -73.904098, borough: .bronx),
        StationInfo(name: "Longwood Av", lines: [.six], latitude: 40.816104, longitude: -73.896435, borough: .bronx),
        StationInfo(name: "Hunts Point Av", lines: [.six], latitude: 40.820948, longitude: -73.890549, borough: .bronx),
        StationInfo(name: "Whitlock Av", lines: [.six], latitude: 40.826525, longitude: -73.886283, borough: .bronx),
        StationInfo(name: "Elder Av", lines: [.six], latitude: 40.828584, longitude: -73.879159, borough: .bronx),
        StationInfo(name: "Morrison Av-Soundview", lines: [.six], latitude: 40.829521, longitude: -73.874516, borough: .bronx),
        StationInfo(name: "St Lawrence Av", lines: [.six], latitude: 40.831509, longitude: -73.867618, borough: .bronx),
        StationInfo(name: "Parkchester", lines: [.six], latitude: 40.833226, longitude: -73.860816, borough: .bronx),
        StationInfo(name: "Castle Hill Av", lines: [.six], latitude: 40.834255, longitude: -73.851222, borough: .bronx),
        StationInfo(name: "Zerega Av", lines: [.six], latitude: 40.836488, longitude: -73.847036, borough: .bronx),
        StationInfo(name: "Westchester Sq-East Tremont Av", lines: [.six], latitude: 40.839892, longitude: -73.842952, borough: .bronx),
        StationInfo(name: "Middletown Rd", lines: [.six], latitude: 40.843863, longitude: -73.836322, borough: .bronx),
        StationInfo(name: "Buhre Av", lines: [.six], latitude: 40.846807, longitude: -73.832569, borough: .bronx),
        StationInfo(name: "Pelham Bay Park", lines: [.six], latitude: 40.852462, longitude: -73.828121, borough: .bronx),

        // IRT White Plains Road Line (2/5) - Bronx
        StationInfo(name: "149 St-Grand Concourse", lines: [.four], latitude: 40.818375, longitude: -73.927351, borough: .bronx, complexName: "149 St-Grand Concourse"),
        StationInfo(name: "149 St-Grand Concourse", lines: [.two, .five], latitude: 40.818375, longitude: -73.927351, borough: .bronx, complexName: "149 St-Grand Concourse"),
        StationInfo(name: "Jackson Av", lines: [.two, .five], latitude: 40.816104, longitude: -73.907948, borough: .bronx),
        StationInfo(name: "Prospect Av", lines: [.two, .five], latitude: 40.819585, longitude: -73.901850, borough: .bronx),
        StationInfo(name: "Intervale Av", lines: [.two, .five], latitude: 40.822181, longitude: -73.896736, borough: .bronx),
        StationInfo(name: "Simpson St", lines: [.two, .five], latitude: 40.824073, longitude: -73.893097, borough: .bronx),
        StationInfo(name: "Freeman St", lines: [.two, .five], latitude: 40.829993, longitude: -73.891865, borough: .bronx),
        StationInfo(name: "174 St", lines: [.two, .five], latitude: 40.837288, longitude: -73.887734, borough: .bronx),
        StationInfo(name: "West Farms Sq-East Tremont Av", lines: [.two, .five], latitude: 40.840295, longitude: -73.880049, borough: .bronx),
        StationInfo(name: "East 180 St", lines: [.two, .five], latitude: 40.841680, longitude: -73.873490, borough: .bronx),
        StationInfo(name: "Bronx Park East", lines: [.two], latitude: 40.848828, longitude: -73.868457, borough: .bronx),
        StationInfo(name: "Pelham Pkwy", lines: [.two], latitude: 40.857192, longitude: -73.867615, borough: .bronx),
        StationInfo(name: "Allerton Av", lines: [.two], latitude: 40.865462, longitude: -73.867352, borough: .bronx),
        StationInfo(name: "Burke Av", lines: [.two], latitude: 40.871356, longitude: -73.867164, borough: .bronx),
        StationInfo(name: "Gun Hill Rd", lines: [.two], latitude: 40.877839, longitude: -73.866256, borough: .bronx),
        StationInfo(name: "219 St", lines: [.two], latitude: 40.883895, longitude: -73.862633, borough: .bronx),
        StationInfo(name: "225 St", lines: [.two], latitude: 40.888022, longitude: -73.860341, borough: .bronx),
        StationInfo(name: "233 St", lines: [.two], latitude: 40.893193, longitude: -73.857473, borough: .bronx),
        StationInfo(name: "Nereid Av", lines: [.two], latitude: 40.898379, longitude: -73.854376, borough: .bronx),
        StationInfo(name: "Wakefield-241 St", lines: [.two], latitude: 40.903125, longitude: -73.850628, borough: .bronx),

        // IRT Jerome Avenue Line (4) - Bronx
        StationInfo(name: "138 St-Grand Concourse", lines: [.four, .five], latitude: 40.813224, longitude: -73.929849, borough: .bronx),
        StationInfo(name: "167 St", lines: [.four], latitude: 40.835537, longitude: -73.921479, borough: .bronx),
        StationInfo(name: "170 St", lines: [.four], latitude: 40.840075, longitude: -73.917062, borough: .bronx),
        StationInfo(name: "176 St", lines: [.four], latitude: 40.848070, longitude: -73.911794, borough: .bronx),
        StationInfo(name: "Burnside Av", lines: [.four], latitude: 40.853453, longitude: -73.907684, borough: .bronx),
        StationInfo(name: "183 St", lines: [.four], latitude: 40.858407, longitude: -73.903879, borough: .bronx),
        StationInfo(name: "Fordham Rd", lines: [.four], latitude: 40.862803, longitude: -73.901034, borough: .bronx),
        StationInfo(name: "Kingsbridge Rd", lines: [.four], latitude: 40.867760, longitude: -73.897174, borough: .bronx),
        StationInfo(name: "Bedford Park Blvd-Lehman College", lines: [.four], latitude: 40.873412, longitude: -73.890064, borough: .bronx),
        StationInfo(name: "Mosholu Pkwy", lines: [.four], latitude: 40.879904, longitude: -73.884655, borough: .bronx),
        StationInfo(name: "Woodlawn", lines: [.four], latitude: 40.886037, longitude: -73.878751, borough: .bronx),

        // IRT Flushing Line (7) - Manhattan/Queens
        StationInfo(name: "34 St-Hudson Yards", lines: [.seven], latitude: 40.755477, longitude: -74.000201, borough: .manhattan),
        StationInfo(name: "5 Av", lines: [.seven], latitude: 40.753821, longitude: -73.981963, borough: .manhattan, complexName: "42 St-Bryant Park / 5 Av"),
        StationInfo(name: "Vernon Blvd-Jackson Av", lines: [.seven], latitude: 40.742626, longitude: -73.953581, borough: .queens),
        StationInfo(name: "Hunters Point Av", lines: [.seven], latitude: 40.742216, longitude: -73.948916, borough: .queens),
        StationInfo(name: "Court Sq", lines: [.seven], latitude: 40.747023, longitude: -73.945264, borough: .queens, complexName: "Court Sq / Court Sq-23 St"),
        StationInfo(name: "Court Sq", lines: [.g], latitude: 40.746554, longitude: -73.943832, borough: .queens, complexName: "Court Sq / Court Sq-23 St"),
        StationInfo(name: "Queensboro Plaza", lines: [.seven, .n, .w], latitude: 40.750582, longitude: -73.940202, borough: .queens),
        StationInfo(name: "33 St-Rawson St", lines: [.seven], latitude: 40.744587, longitude: -73.930997, borough: .queens),
        StationInfo(name: "40 St-Lowery St", lines: [.seven], latitude: 40.743781, longitude: -73.924016, borough: .queens),
        StationInfo(name: "46 St-Bliss St", lines: [.seven], latitude: 40.743132, longitude: -73.918435, borough: .queens),
        StationInfo(name: "52 St", lines: [.seven], latitude: 40.744149, longitude: -73.912549, borough: .queens),
        StationInfo(name: "61 St-Woodside", lines: [.seven], latitude: 40.746554, longitude: -73.902984, borough: .queens),
        StationInfo(name: "69 St", lines: [.seven], latitude: 40.746325, longitude: -73.896403, borough: .queens),
        StationInfo(name: "74 St-Broadway", lines: [.seven], latitude: 40.746848, longitude: -73.891394, borough: .queens, complexName: "Jackson Hts-Roosevelt Av / 74 St-Broadway"),
        StationInfo(name: "82 St-Jackson Hts", lines: [.seven], latitude: 40.747659, longitude: -73.883697, borough: .queens),
        StationInfo(name: "90 St-Elmhurst Av", lines: [.seven], latitude: 40.748408, longitude: -73.876613, borough: .queens),
        StationInfo(name: "Junction Blvd", lines: [.seven], latitude: 40.749145, longitude: -73.869527, borough: .queens),
        StationInfo(name: "103 St-Corona Plaza", lines: [.seven], latitude: 40.749865, longitude: -73.862700, borough: .queens),
        StationInfo(name: "111 St", lines: [.seven], latitude: 40.751728, longitude: -73.855334, borough: .queens),
        StationInfo(name: "Mets-Willets Point", lines: [.seven], latitude: 40.754622, longitude: -73.845625, borough: .queens),
        StationInfo(name: "Flushing-Main St", lines: [.seven], latitude: 40.759600, longitude: -73.830030, borough: .queens),

        // IND Eighth Avenue Line (A/C/E) - Manhattan
        StationInfo(name: "Inwood-207 St", lines: [.a], latitude: 40.868072, longitude: -73.919899, borough: .manhattan),
        StationInfo(name: "Dyckman St", lines: [.a], latitude: 40.865491, longitude: -73.927271, borough: .manhattan),
        StationInfo(name: "190 St", lines: [.a], latitude: 40.859022, longitude: -73.932584, borough: .manhattan),
        StationInfo(name: "181 St", lines: [.a], latitude: 40.851695, longitude: -73.937969, borough: .manhattan),
        StationInfo(name: "175 St", lines: [.a], latitude: 40.847391, longitude: -73.939704, borough: .manhattan),
        StationInfo(name: "163 St-Amsterdam Av", lines: [.c], latitude: 40.836013, longitude: -73.939892, borough: .manhattan),
        StationInfo(name: "155 St", lines: [.c], latitude: 40.830518, longitude: -73.941514, borough: .manhattan),
        StationInfo(name: "155 St", lines: [.b, .d], latitude: 40.830135, longitude: -73.938209, borough: .manhattan),
        StationInfo(name: "145 St", lines: [.a, .b, .c, .d], latitude: 40.824783, longitude: -73.944216, borough: .manhattan),
        StationInfo(name: "135 St", lines: [.b, .c], latitude: 40.817894, longitude: -73.947649, borough: .manhattan),
        StationInfo(name: "125 St", lines: [.a, .b, .c, .d], latitude: 40.811109, longitude: -73.952343, borough: .manhattan),
        StationInfo(name: "116 St", lines: [.b, .c], latitude: 40.802098, longitude: -73.954569, borough: .manhattan),
        StationInfo(name: "110 St-Cathedral Pkwy", lines: [.b, .c], latitude: 40.800603, longitude: -73.958161, borough: .manhattan),
        StationInfo(name: "103 St", lines: [.b, .c], latitude: 40.796092, longitude: -73.961454, borough: .manhattan),
        StationInfo(name: "96 St", lines: [.b, .c], latitude: 40.791642, longitude: -73.964696, borough: .manhattan),
        StationInfo(name: "86 St", lines: [.b, .c], latitude: 40.785868, longitude: -73.968916, borough: .manhattan),
        StationInfo(name: "81 St-Museum of Natural History", lines: [.b, .c], latitude: 40.781433, longitude: -73.972143, borough: .manhattan),
        StationInfo(name: "72 St", lines: [.b, .c], latitude: 40.775594, longitude: -73.976094, borough: .manhattan),
        StationInfo(name: "50 St", lines: [.c, .e], latitude: 40.762456, longitude: -73.985984, borough: .manhattan),
        StationInfo(name: "42 St-Port Authority Bus Terminal", lines: [.a, .c, .e], latitude: 40.757308, longitude: -73.989735, borough: .manhattan, complexName: "Times Sq-42 St / 42 St-Port Authority"),
        StationInfo(name: "34 St-Penn Station", lines: [.a, .c, .e], latitude: 40.752287, longitude: -73.993391, borough: .manhattan),
        StationInfo(name: "23 St", lines: [.c, .e], latitude: 40.745906, longitude: -73.998041, borough: .manhattan),
        StationInfo(name: "14 St", lines: [.a, .c, .e], latitude: 40.740893, longitude: -74.001775, borough: .manhattan, complexName: "14 St / 8 Av"),
        StationInfo(name: "West 4 St-Washington Sq", lines: [.a, .b, .c, .d, .e, .f, .m], latitude: 40.732338, longitude: -74.000495, borough: .manhattan),
        StationInfo(name: "Spring St", lines: [.c, .e], latitude: 40.726227, longitude: -74.003739, borough: .manhattan),
        StationInfo(name: "Canal St", lines: [.a, .c, .e], latitude: 40.720824, longitude: -74.005229, borough: .manhattan),
        StationInfo(name: "Chambers St", lines: [.a, .c], latitude: 40.714111, longitude: -74.008585, borough: .manhattan, complexName: "Fulton St / Park Pl / Cortlandt St"),
        StationInfo(name: "World Trade Center", lines: [.e], latitude: 40.712582, longitude: -74.009781, borough: .manhattan, complexName: "Fulton St / Park Pl / Cortlandt St"),
        StationInfo(name: "Fulton St", lines: [.two, .three], latitude: 40.710374, longitude: -74.008268, borough: .manhattan, complexName: "Fulton St"),
        StationInfo(name: "Fulton St", lines: [.four, .five], latitude: 40.710197, longitude: -74.006753, borough: .manhattan, complexName: "Fulton St"),
        StationInfo(name: "Fulton St", lines: [.a, .c], latitude: 40.710660, longitude: -74.008019, borough: .manhattan, complexName: "Fulton St"),
        StationInfo(name: "Fulton St", lines: [.j, .z], latitude: 40.710368, longitude: -74.007687, borough: .manhattan, complexName: "Fulton St"),
        StationInfo(name: "High St", lines: [.a, .c], latitude: 40.699337, longitude: -73.990531, borough: .brooklyn),

        // IND Sixth Avenue Line (B/D/F/M) - Manhattan
        StationInfo(name: "57 St", lines: [.f, .m], latitude: 40.764326, longitude: -73.977547, borough: .manhattan),
        StationInfo(name: "47-50 Sts-Rockefeller Ctr", lines: [.b, .d, .f, .m], latitude: 40.758663, longitude: -73.981329, borough: .manhattan),
        StationInfo(name: "42 St-Bryant Park", lines: [.b, .d, .f, .m], latitude: 40.754222, longitude: -73.984569, borough: .manhattan, complexName: "42 St-Bryant Park / 5 Av"),
        StationInfo(name: "34 St-Herald Sq", lines: [.b, .d, .f, .m], latitude: 40.749719, longitude: -73.987823, borough: .manhattan, complexName: "34 St-Herald Sq"),
        StationInfo(name: "34 St-Herald Sq", lines: [.n, .q, .r, .w], latitude: 40.749567, longitude: -73.987937, borough: .manhattan, complexName: "34 St-Herald Sq"),
        StationInfo(name: "23 St", lines: [.f, .m], latitude: 40.742954, longitude: -73.992633, borough: .manhattan),
        StationInfo(name: "14 St", lines: [.f, .m], latitude: 40.738228, longitude: -73.996209, borough: .manhattan, complexName: "14 St / 6 Av"),
        StationInfo(name: "Broadway-Lafayette St", lines: [.b, .d, .f, .m], latitude: 40.725297, longitude: -73.996204, borough: .manhattan, complexName: "Bleecker St / Broadway-Lafayette St"),
        StationInfo(name: "2 Av", lines: [.f], latitude: 40.723402, longitude: -73.989938, borough: .manhattan),
        StationInfo(name: "Delancey St", lines: [.f], latitude: 40.718611, longitude: -73.988114, borough: .manhattan, complexName: "Delancey St-Essex St"),
        StationInfo(name: "Essex St", lines: [.j, .m, .z], latitude: 40.718315, longitude: -73.987437, borough: .manhattan, complexName: "Delancey St-Essex St"),
        StationInfo(name: "East Broadway", lines: [.f], latitude: 40.713715, longitude: -73.990173, borough: .manhattan),
        StationInfo(name: "York St", lines: [.f], latitude: 40.701397, longitude: -73.986751, borough: .brooklyn),

        // BMT Broadway Line (N/Q/R/W) - Manhattan
        StationInfo(name: "Lexington Av/59 St", lines: [.n, .r, .w], latitude: 40.762660, longitude: -73.967258, borough: .manhattan, complexName: "Lexington Av/59 St"),
        StationInfo(name: "Lexington Av/63 St", lines: [.m, .q], latitude: 40.764629, longitude: -73.966113, borough: .manhattan),
        StationInfo(name: "57 St-7 Av", lines: [.n, .q, .r, .w], latitude: 40.764664, longitude: -73.980658, borough: .manhattan),
        StationInfo(name: "49 St", lines: [.n, .q, .r, .w], latitude: 40.759901, longitude: -73.984139, borough: .manhattan),
        StationInfo(name: "28 St", lines: [.n, .r, .w], latitude: 40.745494, longitude: -73.988691, borough: .manhattan),
        StationInfo(name: "23 St", lines: [.n, .r, .w], latitude: 40.741303, longitude: -73.989344, borough: .manhattan),
        StationInfo(name: "8 St-NYU", lines: [.n, .r, .w], latitude: 40.730328, longitude: -73.992629, borough: .manhattan),
        StationInfo(name: "Prince St", lines: [.n, .r, .w], latitude: 40.724329, longitude: -73.997702, borough: .manhattan),
        StationInfo(name: "Canal St", lines: [.r, .w], latitude: 40.719527, longitude: -74.001775, borough: .manhattan, complexName: "Canal St"),
        StationInfo(name: "Canal St", lines: [.n, .q], latitude: 40.718711, longitude: -74.000183, borough: .manhattan, complexName: "Canal St"),
        StationInfo(name: "Whitehall St-South Ferry", lines: [.r, .w], latitude: 40.703087, longitude: -74.012994, borough: .manhattan, complexName: "Whitehall St-South Ferry / South Ferry"),
        StationInfo(name: "Cortlandt St", lines: [.r, .w], latitude: 40.710588, longitude: -74.011571, borough: .manhattan, complexName: "Fulton St / Park Pl / Cortlandt St"),
        StationInfo(name: "Rector St", lines: [.r, .w], latitude: 40.707513, longitude: -74.013783, borough: .manhattan),

        // BMT Nassau Street Line (J/Z) - Manhattan
        StationInfo(name: "Broad St", lines: [.j, .z], latitude: 40.706476, longitude: -74.011056, borough: .manhattan),
        StationInfo(name: "Chambers St", lines: [.j, .z], latitude: 40.713243, longitude: -74.003401, borough: .manhattan, complexName: "Chambers St / Brooklyn Bridge-City Hall"),
        StationInfo(name: "Canal St", lines: [.j, .z], latitude: 40.718092, longitude: -73.999892, borough: .manhattan, complexName: "Canal St"),
        StationInfo(name: "Bowery", lines: [.j, .z], latitude: 40.720030, longitude: -73.993915, borough: .manhattan),

        // BROOKLYN STATIONS
        // IND Culver Line (F/G)
        StationInfo(name: "Bergen St", lines: [.f, .g], latitude: 40.686145, longitude: -73.990862, borough: .brooklyn),
        StationInfo(name: "Carroll St", lines: [.f, .g], latitude: 40.680303, longitude: -73.995048, borough: .brooklyn),
        StationInfo(name: "Smith-9 Sts", lines: [.f, .g], latitude: 40.673581, longitude: -73.995959, borough: .brooklyn),
        StationInfo(name: "4 Av-9 St", lines: [.f, .g], latitude: 40.670272, longitude: -73.989779, borough: .brooklyn, complexName: "4 Av-9 St"),
        StationInfo(name: "7 Av", lines: [.f, .g], latitude: 40.666271, longitude: -73.980305, borough: .brooklyn),
        StationInfo(name: "15 St-Prospect Park", lines: [.f, .g], latitude: 40.660365, longitude: -73.979493, borough: .brooklyn),
        StationInfo(name: "Fort Hamilton Pkwy", lines: [.f, .g], latitude: 40.650782, longitude: -73.975776, borough: .brooklyn),
        StationInfo(name: "Church Av", lines: [.f, .g], latitude: 40.644041, longitude: -73.979678, borough: .brooklyn),
        StationInfo(name: "Ditmas Av", lines: [.f], latitude: 40.636119, longitude: -73.978172, borough: .brooklyn),
        StationInfo(name: "18 Av", lines: [.f], latitude: 40.629755, longitude: -73.976971, borough: .brooklyn),
        StationInfo(name: "Av I", lines: [.f], latitude: 40.625322, longitude: -73.976127, borough: .brooklyn),
        StationInfo(name: "Bay Pkwy", lines: [.f], latitude: 40.620769, longitude: -73.975264, borough: .brooklyn),
        StationInfo(name: "Av N", lines: [.f], latitude: 40.614840, longitude: -73.974197, borough: .brooklyn),
        StationInfo(name: "Av P", lines: [.f], latitude: 40.608944, longitude: -73.973022, borough: .brooklyn),
        StationInfo(name: "Kings Hwy", lines: [.f], latitude: 40.603217, longitude: -73.972361, borough: .brooklyn),
        StationInfo(name: "Av U", lines: [.f], latitude: 40.596063, longitude: -73.973357, borough: .brooklyn),
        StationInfo(name: "Av X", lines: [.f], latitude: 40.589740, longitude: -73.974113, borough: .brooklyn),
        StationInfo(name: "Neptune Av", lines: [.f], latitude: 40.581011, longitude: -73.974574, borough: .brooklyn),
        StationInfo(name: "West 8 St-NY Aquarium", lines: [.f, .q], latitude: 40.576034, longitude: -73.975918, borough: .brooklyn),
        StationInfo(name: "Coney Island-Stillwell Av", lines: [.d, .f, .n, .q], latitude: 40.577422, longitude: -73.981233, borough: .brooklyn),

        // IND Crosstown Line (G)
        StationInfo(name: "Greenpoint Av", lines: [.g], latitude: 40.731352, longitude: -73.954449, borough: .brooklyn),
        StationInfo(name: "Nassau Av", lines: [.g], latitude: 40.724635, longitude: -73.951277, borough: .brooklyn),
        StationInfo(name: "Metropolitan Av", lines: [.g], latitude: 40.712792, longitude: -73.951418, borough: .brooklyn, complexName: "Lorimer St / Metropolitan Av"),
        StationInfo(name: "Broadway", lines: [.g], latitude: 40.706092, longitude: -73.950308, borough: .brooklyn),
        StationInfo(name: "Flushing Av", lines: [.g], latitude: 40.700377, longitude: -73.950234, borough: .brooklyn),
        StationInfo(name: "Myrtle-Willoughby Avs", lines: [.g], latitude: 40.694568, longitude: -73.949046, borough: .brooklyn),
        StationInfo(name: "Bedford-Nostrand Avs", lines: [.g], latitude: 40.689627, longitude: -73.953522, borough: .brooklyn),
        StationInfo(name: "Classon Av", lines: [.g], latitude: 40.688873, longitude: -73.960016, borough: .brooklyn),
        StationInfo(name: "Clinton-Washington Avs", lines: [.g], latitude: 40.688089, longitude: -73.966839, borough: .brooklyn),
        StationInfo(name: "Fulton St", lines: [.g], latitude: 40.687119, longitude: -73.975375, borough: .brooklyn),
        StationInfo(name: "Hoyt-Schermerhorn Sts", lines: [.a, .c, .g], latitude: 40.688484, longitude: -73.985001, borough: .brooklyn),

        // IND Fulton Street Line (A/C) - Brooklyn
        StationInfo(name: "Lafayette Av", lines: [.c], latitude: 40.686113, longitude: -73.973946, borough: .brooklyn),
        StationInfo(name: "Clinton-Washington Avs", lines: [.c], latitude: 40.683263, longitude: -73.965838, borough: .brooklyn),
        StationInfo(name: "Franklin Av", lines: [.c], latitude: 40.680596, longitude: -73.958161, borough: .brooklyn, complexName: "Franklin Av"),
        StationInfo(name: "Franklin Av", lines: [.fs], latitude: 40.680596, longitude: -73.958161, borough: .brooklyn, complexName: "Franklin Av"),
        StationInfo(name: "Nostrand Av", lines: [.a, .c], latitude: 40.680438, longitude: -73.950426, borough: .brooklyn),
        StationInfo(name: "Kingston-Throop Avs", lines: [.c], latitude: 40.679921, longitude: -73.940858, borough: .brooklyn),
        StationInfo(name: "Utica Av", lines: [.a, .c], latitude: 40.679364, longitude: -73.930729, borough: .brooklyn),
        StationInfo(name: "Ralph Av", lines: [.c], latitude: 40.678822, longitude: -73.920786, borough: .brooklyn),
        StationInfo(name: "Rockaway Av", lines: [.c], latitude: 40.678339, longitude: -73.911946, borough: .brooklyn),
        StationInfo(name: "Liberty Av", lines: [.c], latitude: 40.674542, longitude: -73.896548, borough: .brooklyn),
        StationInfo(name: "Van Siclen Av", lines: [.c], latitude: 40.678024, longitude: -73.890358, borough: .brooklyn),
        StationInfo(name: "Shepherd Av", lines: [.c], latitude: 40.674461, longitude: -73.880862, borough: .brooklyn),

        // IRT Eastern Parkway Line (2/3/4/5)
        StationInfo(name: "Borough Hall", lines: [.two, .three], latitude: 40.693219, longitude: -73.989998, borough: .brooklyn, complexName: "Court St / Borough Hall"),
        StationInfo(name: "Borough Hall", lines: [.four, .five], latitude: 40.693219, longitude: -73.989998, borough: .brooklyn, complexName: "Court St / Borough Hall"),
        StationInfo(name: "Hoyt St", lines: [.two, .three], latitude: 40.690545, longitude: -73.985065, borough: .brooklyn),
        StationInfo(name: "Nevins St", lines: [.two, .three, .four, .five], latitude: 40.688246, longitude: -73.980492, borough: .brooklyn),
        StationInfo(name: "Atlantic Av-Barclays Ctr", lines: [.two, .three, .four, .five], latitude: 40.684359, longitude: -73.977666, borough: .brooklyn, complexName: "Atlantic Av-Barclays Ctr"),
        StationInfo(name: "Atlantic Av-Barclays Ctr", lines: [.b, .q], latitude: 40.684359, longitude: -73.977666, borough: .brooklyn, complexName: "Atlantic Av-Barclays Ctr"),
        StationInfo(name: "Atlantic Av-Barclays Ctr", lines: [.d, .n, .r], latitude: 40.684359, longitude: -73.977666, borough: .brooklyn, complexName: "Atlantic Av-Barclays Ctr"),
        StationInfo(name: "Bergen St", lines: [.two, .three], latitude: 40.680829, longitude: -73.975098, borough: .brooklyn),
        StationInfo(name: "Grand Army Plaza", lines: [.two, .three], latitude: 40.675235, longitude: -73.971046, borough: .brooklyn),
        StationInfo(name: "Eastern Pkwy-Brooklyn Museum", lines: [.two, .three], latitude: 40.671987, longitude: -73.964375, borough: .brooklyn),
        StationInfo(name: "Franklin Av-Medgar Evers College", lines: [.two, .three, .four, .five, .fs], latitude: 40.670682, longitude: -73.958131, borough: .brooklyn, complexName: "Franklin Av / Botanic Garden"),
        StationInfo(name: "President St-Medgar Evers College", lines: [.two, .five], latitude: 40.667883, longitude: -73.950683, borough: .brooklyn),
        StationInfo(name: "Sterling St", lines: [.two, .five], latitude: 40.662742, longitude: -73.950783, borough: .brooklyn),
        StationInfo(name: "Winthrop St", lines: [.two, .five], latitude: 40.656652, longitude: -73.950308, borough: .brooklyn),
        StationInfo(name: "Church Av", lines: [.two, .five], latitude: 40.650843, longitude: -73.949575, borough: .brooklyn),
        StationInfo(name: "Beverly Rd", lines: [.two, .five], latitude: 40.645098, longitude: -73.948959, borough: .brooklyn),
        StationInfo(name: "Newkirk Av-Little Haiti", lines: [.two, .five], latitude: 40.639967, longitude: -73.948411, borough: .brooklyn),
        StationInfo(name: "Flatbush Av-Brooklyn College", lines: [.two, .five], latitude: 40.632836, longitude: -73.947642, borough: .brooklyn),

        // IRT Nostrand Avenue Line (2/5) - Note: Shares some stations
        StationInfo(name: "Nostrand Av", lines: [.three], latitude: 40.669847, longitude: -73.950466, borough: .brooklyn),
        StationInfo(name: "Kingston Av", lines: [.three], latitude: 40.669399, longitude: -73.942161, borough: .brooklyn),
        StationInfo(name: "Crown Hts-Utica Av", lines: [.three, .four], latitude: 40.668897, longitude: -73.932942, borough: .brooklyn),
        StationInfo(name: "Sutter Av-Rutland Rd", lines: [.three], latitude: 40.664717, longitude: -73.922613, borough: .brooklyn),
        StationInfo(name: "Saratoga Av", lines: [.three], latitude: 40.661453, longitude: -73.916327, borough: .brooklyn),
        StationInfo(name: "Rockaway Av", lines: [.three], latitude: 40.662549, longitude: -73.908946, borough: .brooklyn),
        StationInfo(name: "Junius St", lines: [.three], latitude: 40.663515, longitude: -73.902447, borough: .brooklyn),
        StationInfo(name: "Pennsylvania Av", lines: [.three], latitude: 40.664635, longitude: -73.894895, borough: .brooklyn),
        StationInfo(name: "Van Siclen Av", lines: [.three], latitude: 40.665449, longitude: -73.889395, borough: .brooklyn),
        StationInfo(name: "New Lots Av", lines: [.three], latitude: 40.666235, longitude: -73.884079, borough: .brooklyn),

        // BMT Canarsie Line (L)
        StationInfo(name: "8 Av", lines: [.l], latitude: 40.739777, longitude: -74.002578, borough: .manhattan, complexName: "14 St / 8 Av"),
        StationInfo(name: "6 Av", lines: [.l], latitude: 40.737335, longitude: -73.996786, borough: .manhattan, complexName: "14 St / 6 Av"),
        StationInfo(name: "3 Av", lines: [.l], latitude: 40.732849, longitude: -73.986122, borough: .manhattan),
        StationInfo(name: "1 Av", lines: [.l], latitude: 40.730953, longitude: -73.981628, borough: .manhattan),
        StationInfo(name: "Bedford Av", lines: [.l], latitude: 40.717304, longitude: -73.956872, borough: .brooklyn),
        StationInfo(name: "Lorimer St", lines: [.l], latitude: 40.714063, longitude: -73.950275, borough: .brooklyn, complexName: "Lorimer St / Metropolitan Av"),
        StationInfo(name: "Graham Av", lines: [.l], latitude: 40.714565, longitude: -73.944053, borough: .brooklyn),
        StationInfo(name: "Grand St", lines: [.l], latitude: 40.711926, longitude: -73.940534, borough: .brooklyn),
        StationInfo(name: "Montrose Av", lines: [.l], latitude: 40.707739, longitude: -73.939561, borough: .brooklyn),
        StationInfo(name: "Morgan Av", lines: [.l], latitude: 40.706152, longitude: -73.933147, borough: .brooklyn),
        StationInfo(name: "Jefferson St", lines: [.l], latitude: 40.706607, longitude: -73.922914, borough: .brooklyn),
        StationInfo(name: "DeKalb Av", lines: [.l], latitude: 40.703811, longitude: -73.918425, borough: .brooklyn),
        StationInfo(name: "Myrtle-Wyckoff Avs", lines: [.l], latitude: 40.699814, longitude: -73.911586, borough: .brooklyn, complexName: "Myrtle-Wyckoff Avs"),
        StationInfo(name: "Myrtle-Wyckoff Avs", lines: [.m], latitude: 40.699814, longitude: -73.911586, borough: .brooklyn, complexName: "Myrtle-Wyckoff Avs"),
        StationInfo(name: "Halsey St", lines: [.l], latitude: 40.695602, longitude: -73.904084, borough: .brooklyn),
        StationInfo(name: "Wilson Av", lines: [.l], latitude: 40.688764, longitude: -73.904046, borough: .brooklyn),
        StationInfo(name: "Bushwick Av-Aberdeen St", lines: [.l], latitude: 40.682829, longitude: -73.905249, borough: .brooklyn),
        StationInfo(name: "Broadway Junction", lines: [.l], latitude: 40.678334, longitude: -73.905316, borough: .brooklyn, complexName: "Broadway Junction"),
        StationInfo(name: "Broadway Junction", lines: [.a, .c], latitude: 40.678334, longitude: -73.905316, borough: .brooklyn, complexName: "Broadway Junction"),
        StationInfo(name: "Broadway Junction", lines: [.j, .z], latitude: 40.678334, longitude: -73.905316, borough: .brooklyn, complexName: "Broadway Junction"),
        StationInfo(name: "Atlantic Av", lines: [.l], latitude: 40.675345, longitude: -73.903097, borough: .brooklyn),
        StationInfo(name: "Sutter Av", lines: [.l], latitude: 40.669367, longitude: -73.901975, borough: .brooklyn),
        StationInfo(name: "Livonia Av", lines: [.l], latitude: 40.664038, longitude: -73.900571, borough: .brooklyn),
        StationInfo(name: "New Lots Av", lines: [.l], latitude: 40.658733, longitude: -73.899232, borough: .brooklyn),
        StationInfo(name: "East 105 St", lines: [.l], latitude: 40.650573, longitude: -73.899485, borough: .brooklyn),
        StationInfo(name: "Canarsie-Rockaway Pkwy", lines: [.l], latitude: 40.646654, longitude: -73.901850, borough: .brooklyn),

        // BMT Jamaica Line (J/Z)
        StationInfo(name: "Marcy Av", lines: [.j, .m, .z], latitude: 40.708359, longitude: -73.957757, borough: .brooklyn),
        StationInfo(name: "Hewes St", lines: [.j, .m], latitude: 40.706889, longitude: -73.953431, borough: .brooklyn),
        StationInfo(name: "Lorimer St", lines: [.j, .m], latitude: 40.703844, longitude: -73.947407, borough: .brooklyn),
        StationInfo(name: "Flushing Av", lines: [.j, .m], latitude: 40.700377, longitude: -73.941489, borough: .brooklyn),
        StationInfo(name: "Myrtle Av-Broadway", lines: [.j, .m, .z], latitude: 40.697207, longitude: -73.935657, borough: .brooklyn),
        StationInfo(name: "Central Av", lines: [.m], latitude: 40.697857, longitude: -73.927397, borough: .brooklyn),
        StationInfo(name: "Knickerbocker Av", lines: [.m], latitude: 40.698664, longitude: -73.919711, borough: .brooklyn),
        StationInfo(name: "Gates Av", lines: [.j, .z], latitude: 40.689627, longitude: -73.922131, borough: .brooklyn),
        StationInfo(name: "Kosciuszko St", lines: [.j], latitude: 40.693115, longitude: -73.928814, borough: .brooklyn),
        StationInfo(name: "Halsey St", lines: [.j], latitude: 40.686210, longitude: -73.916559, borough: .brooklyn),
        StationInfo(name: "Chauncey St", lines: [.j, .z], latitude: 40.682893, longitude: -73.910456, borough: .brooklyn),
        StationInfo(name: "Alabama Av", lines: [.j], latitude: 40.676992, longitude: -73.898654, borough: .brooklyn),
        StationInfo(name: "Van Siclen Av", lines: [.j, .z], latitude: 40.672800, longitude: -73.891479, borough: .brooklyn),
        StationInfo(name: "Cleveland St", lines: [.j], latitude: 40.679947, longitude: -73.884639, borough: .brooklyn),
        StationInfo(name: "Norwood Av", lines: [.j, .z], latitude: 40.681311, longitude: -73.880039, borough: .brooklyn),
        StationInfo(name: "Crescent St", lines: [.j, .z], latitude: 40.683194, longitude: -73.873785, borough: .brooklyn),
        StationInfo(name: "Cypress Hills", lines: [.j], latitude: 40.689616, longitude: -73.873412, borough: .brooklyn),
        StationInfo(name: "75 St-Elderts Ln", lines: [.j, .z], latitude: 40.691324, longitude: -73.867351, borough: .queens),
        StationInfo(name: "85 St-Forest Pkwy", lines: [.j, .z], latitude: 40.692435, longitude: -73.860017, borough: .queens),
        StationInfo(name: "Woodhaven Blvd", lines: [.j, .z], latitude: 40.693879, longitude: -73.851576, borough: .queens),
        StationInfo(name: "104 St", lines: [.j, .z], latitude: 40.695178, longitude: -73.844521, borough: .queens),
        StationInfo(name: "111 St", lines: [.j], latitude: 40.697418, longitude: -73.836345, borough: .queens),
        StationInfo(name: "121 St", lines: [.j, .z], latitude: 40.700492, longitude: -73.828294, borough: .queens),

        // BMT Brighton Line (B/Q)
        StationInfo(name: "DeKalb Av", lines: [.b, .q, .r], latitude: 40.690635, longitude: -73.981824, borough: .brooklyn),
        StationInfo(name: "7 Av", lines: [.b, .q], latitude: 40.677810, longitude: -73.972367, borough: .brooklyn),
        StationInfo(name: "Prospect Park", lines: [.b, .q, .fs], latitude: 40.661614, longitude: -73.962246, borough: .brooklyn),
        StationInfo(name: "Parkside Av", lines: [.q], latitude: 40.655292, longitude: -73.961495, borough: .brooklyn),
        StationInfo(name: "Church Av", lines: [.b, .q], latitude: 40.650527, longitude: -73.962982, borough: .brooklyn),
        StationInfo(name: "Beverley Rd", lines: [.q], latitude: 40.644031, longitude: -73.964492, borough: .brooklyn),
        StationInfo(name: "Cortelyou Rd", lines: [.q], latitude: 40.640927, longitude: -73.963891, borough: .brooklyn),
        StationInfo(name: "Newkirk Plaza", lines: [.b, .q], latitude: 40.635082, longitude: -73.962793, borough: .brooklyn),
        StationInfo(name: "Av H", lines: [.q], latitude: 40.629143, longitude: -73.961673, borough: .brooklyn),
        StationInfo(name: "Av J", lines: [.q], latitude: 40.625039, longitude: -73.960803, borough: .brooklyn),
        StationInfo(name: "Av M", lines: [.q], latitude: 40.617618, longitude: -73.959399, borough: .brooklyn),
        StationInfo(name: "Kings Hwy", lines: [.b, .q], latitude: 40.608636, longitude: -73.957734, borough: .brooklyn),
        StationInfo(name: "Av U", lines: [.q], latitude: 40.599017, longitude: -73.955929, borough: .brooklyn),
        StationInfo(name: "Neck Rd", lines: [.q], latitude: 40.595246, longitude: -73.955161, borough: .brooklyn),
        StationInfo(name: "Sheepshead Bay", lines: [.b, .q], latitude: 40.586896, longitude: -73.954155, borough: .brooklyn),
        StationInfo(name: "Brighton Beach", lines: [.b, .q], latitude: 40.577621, longitude: -73.961376, borough: .brooklyn),
        StationInfo(name: "Ocean Pkwy", lines: [.q], latitude: 40.576312, longitude: -73.968501, borough: .brooklyn),

        // BMT Fourth Avenue Line (D/N/R)
        StationInfo(name: "Jay St-MetroTech", lines: [.a, .c, .f], latitude: 40.692338, longitude: -73.987342, borough: .brooklyn, complexName: "Jay St-MetroTech"),
        StationInfo(name: "Jay St-MetroTech", lines: [.r], latitude: 40.692338, longitude: -73.987342, borough: .brooklyn, complexName: "Jay St-MetroTech"),
        StationInfo(name: "Court St", lines: [.r], latitude: 40.694196, longitude: -73.991641, borough: .brooklyn, complexName: "Court St / Borough Hall"),
        StationInfo(name: "Union St", lines: [.r], latitude: 40.677316, longitude: -73.983173, borough: .brooklyn),
        StationInfo(name: "9 St", lines: [.r], latitude: 40.670847, longitude: -73.988302, borough: .brooklyn, complexName: "4 Av-9 St"),
        StationInfo(name: "Prospect Av", lines: [.r], latitude: 40.665414, longitude: -73.992872, borough: .brooklyn),
        StationInfo(name: "25 St", lines: [.r], latitude: 40.660397, longitude: -73.998091, borough: .brooklyn),
        StationInfo(name: "36 St", lines: [.d, .n, .r], latitude: 40.655144, longitude: -74.003549, borough: .brooklyn),
        StationInfo(name: "45 St", lines: [.r], latitude: 40.648939, longitude: -74.010006, borough: .brooklyn),
        StationInfo(name: "53 St", lines: [.r], latitude: 40.645069, longitude: -74.014034, borough: .brooklyn),
        StationInfo(name: "59 St", lines: [.n, .r], latitude: 40.641362, longitude: -74.017881, borough: .brooklyn),
        StationInfo(name: "Bay Ridge Av", lines: [.r], latitude: 40.634967, longitude: -74.023377, borough: .brooklyn),
        StationInfo(name: "77 St", lines: [.r], latitude: 40.629742, longitude: -74.025508, borough: .brooklyn),
        StationInfo(name: "86 St", lines: [.r], latitude: 40.622687, longitude: -74.028398, borough: .brooklyn),
        StationInfo(name: "Bay Ridge-95 St", lines: [.r], latitude: 40.616622, longitude: -74.030876, borough: .brooklyn),

        // BMT West End Line (D)
        StationInfo(name: "9 Av", lines: [.d], latitude: 40.646292, longitude: -73.994324, borough: .brooklyn),
        StationInfo(name: "Fort Hamilton Pkwy", lines: [.d], latitude: 40.640914, longitude: -73.994304, borough: .brooklyn),
        StationInfo(name: "50 St", lines: [.d], latitude: 40.636310, longitude: -73.994798, borough: .brooklyn),
        StationInfo(name: "55 St", lines: [.d], latitude: 40.631435, longitude: -73.995476, borough: .brooklyn),
        StationInfo(name: "62 St", lines: [.d], latitude: 40.626472, longitude: -73.996895, borough: .brooklyn, complexName: "New Utrecht Av / 62 St"),
        StationInfo(name: "71 St", lines: [.d], latitude: 40.619589, longitude: -73.998864, borough: .brooklyn),
        StationInfo(name: "79 St", lines: [.d], latitude: 40.613501, longitude: -74.000967, borough: .brooklyn),
        StationInfo(name: "18 Av", lines: [.d], latitude: 40.607954, longitude: -74.001736, borough: .brooklyn),
        StationInfo(name: "20 Av", lines: [.d], latitude: 40.604556, longitude: -73.998168, borough: .brooklyn),
        StationInfo(name: "Bay Pkwy", lines: [.d], latitude: 40.601875, longitude: -73.993728, borough: .brooklyn),
        StationInfo(name: "25 Av", lines: [.d], latitude: 40.597704, longitude: -73.986829, borough: .brooklyn),
        StationInfo(name: "Bay 50 St", lines: [.d], latitude: 40.588841, longitude: -73.983765, borough: .brooklyn),

        // BMT Sea Beach Line (N)
        StationInfo(name: "8 Av", lines: [.n], latitude: 40.635064, longitude: -74.011719, borough: .brooklyn),
        StationInfo(name: "Fort Hamilton Pkwy", lines: [.n], latitude: 40.631386, longitude: -74.005351, borough: .brooklyn),
        StationInfo(name: "New Utrecht Av", lines: [.n], latitude: 40.624842, longitude: -73.996353, borough: .brooklyn, complexName: "New Utrecht Av / 62 St"),
        StationInfo(name: "18 Av", lines: [.n], latitude: 40.620671, longitude: -73.990414, borough: .brooklyn),
        StationInfo(name: "20 Av", lines: [.n], latitude: 40.617109, longitude: -73.985026, borough: .brooklyn),
        StationInfo(name: "Bay Pkwy", lines: [.n], latitude: 40.611815, longitude: -73.981848, borough: .brooklyn),
        StationInfo(name: "Kings Hwy", lines: [.n], latitude: 40.603923, longitude: -73.980353, borough: .brooklyn),
        StationInfo(name: "Av U", lines: [.n], latitude: 40.597473, longitude: -73.979137, borough: .brooklyn),
        StationInfo(name: "86 St", lines: [.n], latitude: 40.592721, longitude: -73.978164, borough: .brooklyn),

        // Franklin Avenue Shuttle (S)
        StationInfo(name: "Botanic Garden", lines: [.fs], latitude: 40.670343, longitude: -73.959245, borough: .brooklyn, complexName: "Franklin Av / Botanic Garden"),
        StationInfo(name: "Park Pl", lines: [.fs], latitude: 40.674772, longitude: -73.957624, borough: .brooklyn),

        // QUEENS STATIONS
        // IND Queens Boulevard Line (E/F/M/R)
        StationInfo(name: "Court Sq-23 St", lines: [.e, .m], latitude: 40.747846, longitude: -73.946204, borough: .queens, complexName: "Court Sq / Court Sq-23 St"),
        StationInfo(name: "21 St-Queensbridge", lines: [.f], latitude: 40.754203, longitude: -73.942836, borough: .queens),
        StationInfo(name: "Roosevelt Island", lines: [.f, .m], latitude: 40.759145, longitude: -73.953410, borough: .manhattan),
        StationInfo(name: "Lexington Av/53 St", lines: [.e, .m], latitude: 40.757552, longitude: -73.969055, borough: .manhattan, complexName: "51 St / Lexington Av-53 St"),
        StationInfo(name: "5 Av/53 St", lines: [.e, .f], latitude: 40.760167, longitude: -73.975224, borough: .manhattan),
        StationInfo(name: "7 Av", lines: [.b, .d, .e], latitude: 40.762862, longitude: -73.981637, borough: .manhattan),
        StationInfo(name: "Queens Plaza", lines: [.e, .m, .r], latitude: 40.748973, longitude: -73.937243, borough: .queens),
        StationInfo(name: "36 St", lines: [.m, .r], latitude: 40.752039, longitude: -73.928781, borough: .queens),
        StationInfo(name: "Steinway St", lines: [.m, .r], latitude: 40.756880, longitude: -73.920372, borough: .queens),
        StationInfo(name: "46 St", lines: [.m, .r], latitude: 40.756312, longitude: -73.913333, borough: .queens),
        StationInfo(name: "Northern Blvd", lines: [.m, .r], latitude: 40.752885, longitude: -73.906006, borough: .queens),
        StationInfo(name: "65 St", lines: [.m, .r], latitude: 40.749669, longitude: -73.898453, borough: .queens),
        StationInfo(name: "Jackson Hts-Roosevelt Av", lines: [.e, .f, .m, .r], latitude: 40.746644, longitude: -73.891338, borough: .queens, complexName: "Jackson Hts-Roosevelt Av / 74 St-Broadway"),
        StationInfo(name: "Elmhurst Av", lines: [.m, .r], latitude: 40.742454, longitude: -73.882017, borough: .queens),
        StationInfo(name: "Grand Av-Newtown", lines: [.m, .r], latitude: 40.737015, longitude: -73.877223, borough: .queens),
        StationInfo(name: "Woodhaven Blvd", lines: [.m, .r], latitude: 40.733106, longitude: -73.869229, borough: .queens),
        StationInfo(name: "63 Dr-Rego Park", lines: [.m, .r], latitude: 40.729846, longitude: -73.861604, borough: .queens),
        StationInfo(name: "67 Av", lines: [.m, .r], latitude: 40.726523, longitude: -73.852719, borough: .queens),
        StationInfo(name: "Forest Hills-71 Av", lines: [.e, .f, .m, .r], latitude: 40.721691, longitude: -73.844521, borough: .queens),
        StationInfo(name: "75 Av", lines: [.e, .f], latitude: 40.718331, longitude: -73.837324, borough: .queens),
        StationInfo(name: "Kew Gardens-Union Tpke", lines: [.e, .f], latitude: 40.714441, longitude: -73.831008, borough: .queens),
        StationInfo(name: "Briarwood", lines: [.e, .f], latitude: 40.709179, longitude: -73.820574, borough: .queens),
        StationInfo(name: "Jamaica-179 St", lines: [.f], latitude: 40.712646, longitude: -73.783817, borough: .queens),
        StationInfo(name: "Sutphin Blvd", lines: [.f], latitude: 40.705461, longitude: -73.810708, borough: .queens),
        StationInfo(name: "Jamaica Center-Parsons/Archer", lines: [.e, .j, .z], latitude: 40.702147, longitude: -73.801109, borough: .queens),
        StationInfo(name: "169 St", lines: [.f], latitude: 40.710517, longitude: -73.793604, borough: .queens),
        StationInfo(name: "Parsons Blvd", lines: [.f], latitude: 40.707564, longitude: -73.803326, borough: .queens),
        StationInfo(name: "Sutphin Blvd-Archer Av-JFK Airport", lines: [.e, .j, .z], latitude: 40.700486, longitude: -73.807969, borough: .queens),
        StationInfo(name: "Jamaica-Van Wyck", lines: [.e], latitude: 40.702566, longitude: -73.816859, borough: .queens),

        // IND Rockaway Line (A/S)
        StationInfo(name: "Euclid Av", lines: [.a, .c], latitude: 40.675377, longitude: -73.872106, borough: .brooklyn),
        StationInfo(name: "Grant Av", lines: [.a], latitude: 40.677044, longitude: -73.865031, borough: .brooklyn),
        StationInfo(name: "80 St", lines: [.a], latitude: 40.679371, longitude: -73.858992, borough: .queens),
        StationInfo(name: "88 St", lines: [.a], latitude: 40.679843, longitude: -73.851346, borough: .queens),
        StationInfo(name: "Rockaway Blvd", lines: [.a], latitude: 40.680429, longitude: -73.843853, borough: .queens),
        StationInfo(name: "104 St", lines: [.a], latitude: 40.681711, longitude: -73.837683, borough: .queens),
        StationInfo(name: "111 St", lines: [.a], latitude: 40.684331, longitude: -73.832163, borough: .queens),
        StationInfo(name: "Ozone Park-Lefferts Blvd", lines: [.a], latitude: 40.685951, longitude: -73.825798, borough: .queens),
        StationInfo(name: "Aqueduct Racetrack", lines: [.a], latitude: 40.672097, longitude: -73.835919, borough: .queens),
        StationInfo(name: "Aqueduct-N Conduit Av", lines: [.a], latitude: 40.668234, longitude: -73.834058, borough: .queens),
        StationInfo(name: "Howard Beach-JFK Airport", lines: [.a], latitude: 40.660476, longitude: -73.830301, borough: .queens),
        StationInfo(name: "Broad Channel", lines: [.a, .rs], latitude: 40.608382, longitude: -73.815925, borough: .queens),
        StationInfo(name: "Beach 90 St", lines: [.rs], latitude: 40.588034, longitude: -73.813641, borough: .queens),
        StationInfo(name: "Beach 98 St", lines: [.rs], latitude: 40.585307, longitude: -73.820558, borough: .queens),
        StationInfo(name: "Beach 105 St", lines: [.rs], latitude: 40.583209, longitude: -73.827559, borough: .queens),
        StationInfo(name: "Rockaway Park-Beach 116 St", lines: [.rs], latitude: 40.580903, longitude: -73.835592, borough: .queens),
        StationInfo(name: "Beach 67 St", lines: [.a], latitude: 40.590927, longitude: -73.796924, borough: .queens),
        StationInfo(name: "Beach 60 St", lines: [.a], latitude: 40.592374, longitude: -73.788522, borough: .queens),
        StationInfo(name: "Beach 44 St", lines: [.a], latitude: 40.592943, longitude: -73.776013, borough: .queens),
        StationInfo(name: "Beach 36 St", lines: [.a], latitude: 40.595398, longitude: -73.768175, borough: .queens),
        StationInfo(name: "Beach 25 St", lines: [.a], latitude: 40.600066, longitude: -73.761353, borough: .queens),
        StationInfo(name: "Far Rockaway-Mott Av", lines: [.a], latitude: 40.603995, longitude: -73.755405, borough: .queens),

        // BMT Astoria Line (N/W)
        StationInfo(name: "Astoria-Ditmars Blvd", lines: [.n, .w], latitude: 40.775036, longitude: -73.912034, borough: .queens),
        StationInfo(name: "Astoria Blvd", lines: [.n, .w], latitude: 40.770258, longitude: -73.917843, borough: .queens),
        StationInfo(name: "30 Av", lines: [.n, .w], latitude: 40.766779, longitude: -73.921479, borough: .queens),
        StationInfo(name: "Broadway", lines: [.n, .w], latitude: 40.761820, longitude: -73.925508, borough: .queens),
        StationInfo(name: "36 Av", lines: [.n, .w], latitude: 40.756804, longitude: -73.929575, borough: .queens),
        StationInfo(name: "39 Av", lines: [.n, .w], latitude: 40.752882, longitude: -73.932755, borough: .queens),

        // STATEN ISLAND RAILWAY (SIR)
        StationInfo(name: "St George", lines: [.sir], latitude: 40.643748, longitude: -74.073643, borough: .statenIsland),
        StationInfo(name: "Tompkinsville", lines: [.sir], latitude: 40.636949, longitude: -74.074835, borough: .statenIsland),
        StationInfo(name: "Stapleton", lines: [.sir], latitude: 40.627316, longitude: -74.075750, borough: .statenIsland),
        StationInfo(name: "Clifton", lines: [.sir], latitude: 40.621319, longitude: -74.070809, borough: .statenIsland),
        StationInfo(name: "Grasmere", lines: [.sir], latitude: 40.603117, longitude: -74.084087, borough: .statenIsland),
        StationInfo(name: "Old Town", lines: [.sir], latitude: 40.596612, longitude: -74.087168, borough: .statenIsland),
        StationInfo(name: "Dongan Hills", lines: [.sir], latitude: 40.588849, longitude: -74.096036, borough: .statenIsland),
        StationInfo(name: "Jefferson Av", lines: [.sir], latitude: 40.583183, longitude: -74.103508, borough: .statenIsland),
        StationInfo(name: "Grant City", lines: [.sir], latitude: 40.578847, longitude: -74.109724, borough: .statenIsland),
        StationInfo(name: "New Dorp", lines: [.sir], latitude: 40.573502, longitude: -74.117295, borough: .statenIsland),
        StationInfo(name: "Oakwood Heights", lines: [.sir], latitude: 40.565280, longitude: -74.126172, borough: .statenIsland),
        StationInfo(name: "Bay Terrace", lines: [.sir], latitude: 40.556676, longitude: -74.136669, borough: .statenIsland),
        StationInfo(name: "Great Kills", lines: [.sir], latitude: 40.551341, longitude: -74.151443, borough: .statenIsland),
        StationInfo(name: "Eltingville", lines: [.sir], latitude: 40.544601, longitude: -74.164336, borough: .statenIsland),
        StationInfo(name: "Annadale", lines: [.sir], latitude: 40.540544, longitude: -74.178168, borough: .statenIsland),
        StationInfo(name: "Huguenot", lines: [.sir], latitude: 40.533674, longitude: -74.191734, borough: .statenIsland),
        StationInfo(name: "Prince's Bay", lines: [.sir], latitude: 40.525507, longitude: -74.200027, borough: .statenIsland),
        StationInfo(name: "Pleasant Plains", lines: [.sir], latitude: 40.522422, longitude: -74.217847, borough: .statenIsland),
        StationInfo(name: "Richmond Valley", lines: [.sir], latitude: 40.519631, longitude: -74.229141, borough: .statenIsland),
        StationInfo(name: "Arthur Kill", lines: [.sir], latitude: 40.516578, longitude: -74.242096, borough: .statenIsland),
        StationInfo(name: "Tottenville", lines: [.sir], latitude: 40.512764, longitude: -74.251961, borough: .statenIsland),

        // Additional Manhattan Stations - Second Avenue Subway
        StationInfo(name: "72 St", lines: [.q], latitude: 40.768799, longitude: -73.958424, borough: .manhattan),
        StationInfo(name: "86 St", lines: [.q], latitude: 40.777891, longitude: -73.951618, borough: .manhattan),
        StationInfo(name: "96 St", lines: [.q], latitude: 40.784318, longitude: -73.947152, borough: .manhattan),
        // Missing Manhattan Stations
        StationInfo(name: "Grand St", lines: [.b, .d], latitude: 40.718267, longitude: -73.993753, borough: .manhattan),
        StationInfo(name: "5 Av-59 St", lines: [.n, .r, .w], latitude: 40.764811, longitude: -73.973347, borough: .manhattan),

        // Additional Brooklyn Stations
        StationInfo(name: "Clark St", lines: [.two, .three], latitude: 40.697466, longitude: -73.993086, borough: .brooklyn),

        // IND Concourse Line (B/D) - Bronx
        StationInfo(name: "161 St-Yankee Stadium", lines: [.four], latitude: 40.827994, longitude: -73.925831, borough: .bronx, complexName: "161 St-Yankee Stadium"),
        StationInfo(name: "161 St-Yankee Stadium", lines: [.b, .d], latitude: 40.827994, longitude: -73.925831, borough: .bronx, complexName: "161 St-Yankee Stadium"),
        StationInfo(name: "167 St", lines: [.b, .d], latitude: 40.833771, longitude: -73.921479, borough: .bronx),
        StationInfo(name: "170 St", lines: [.b, .d], latitude: 40.839306, longitude: -73.917741, borough: .bronx),
        StationInfo(name: "174-175 Sts", lines: [.b, .d], latitude: 40.845920, longitude: -73.910136, borough: .bronx),
        StationInfo(name: "Tremont Av", lines: [.b, .d], latitude: 40.850411, longitude: -73.905227, borough: .bronx),
        StationInfo(name: "182-183 Sts", lines: [.b, .d], latitude: 40.856093, longitude: -73.900741, borough: .bronx),
        StationInfo(name: "Fordham Rd", lines: [.b, .d], latitude: 40.861296, longitude: -73.897749, borough: .bronx),
        StationInfo(name: "Kingsbridge Rd", lines: [.b, .d], latitude: 40.866978, longitude: -73.893509, borough: .bronx),
        StationInfo(name: "Bedford Park Blvd", lines: [.b, .d], latitude: 40.873244, longitude: -73.887138, borough: .bronx),
        StationInfo(name: "Norwood-205 St", lines: [.d], latitude: 40.874811, longitude: -73.878855, borough: .bronx),

        // IRT Dyre Avenue Line (5) - Bronx
        StationInfo(name: "Morris Park", lines: [.five], latitude: 40.854364, longitude: -73.860495, borough: .bronx),
        StationInfo(name: "Pelham Pkwy", lines: [.five], latitude: 40.858985, longitude: -73.855350, borough: .bronx),
        StationInfo(name: "Gun Hill Rd", lines: [.five], latitude: 40.869526, longitude: -73.846384, borough: .bronx),
        StationInfo(name: "Baychester Av", lines: [.five], latitude: 40.878663, longitude: -73.838591, borough: .bronx),
        StationInfo(name: "Eastchester-Dyre Av", lines: [.five], latitude: 40.888224, longitude: -73.830834, borough: .bronx),

        // Additional Bronx Stations
        StationInfo(name: "3 Av-149 St", lines: [.two, .five], latitude: 40.816109, longitude: -73.917757, borough: .bronx),
        StationInfo(name: "Mt Eden Av", lines: [.four], latitude: 40.844434, longitude: -73.914685, borough: .bronx),

        // Queens - Additional Stations
        StationInfo(name: "21 St", lines: [.g], latitude: 40.744065, longitude: -73.949724, borough: .queens),
        StationInfo(name: "Seneca Av", lines: [.m], latitude: 40.702762, longitude: -73.907660, borough: .queens),
        StationInfo(name: "Forest Av", lines: [.m], latitude: 40.704423, longitude: -73.903077, borough: .queens),
        StationInfo(name: "Fresh Pond Rd", lines: [.m], latitude: 40.706186, longitude: -73.895877, borough: .queens),
        StationInfo(name: "Middle Village-Metropolitan Av", lines: [.m], latitude: 40.711396, longitude: -73.889601, borough: .queens),

        // Additional Manhattan Stations
        StationInfo(name: "Wall St", lines: [.two, .three], latitude: 40.706821, longitude: -74.009209, borough: .manhattan),
        StationInfo(name: "Wall St", lines: [.four, .five], latitude: 40.707557, longitude: -74.011862, borough: .manhattan),
        StationInfo(name: "Bowling Green", lines: [.four, .five], latitude: 40.704817, longitude: -74.014065, borough: .manhattan),
        StationInfo(name: "Park Pl", lines: [.two, .three], latitude: 40.713051, longitude: -74.008811, borough: .manhattan, complexName: "Fulton St / Park Pl / Cortlandt St"),

        // IRT Lenox Avenue Line (2/3) - Harlem
        StationInfo(name: "Central Park North-110 St", lines: [.two, .three], latitude: 40.799075, longitude: -73.951822, borough: .manhattan),
        StationInfo(name: "116 St", lines: [.two, .three], latitude: 40.802098, longitude: -73.949625, borough: .manhattan),
        StationInfo(name: "125 St", lines: [.two, .three], latitude: 40.807754, longitude: -73.945495, borough: .manhattan),
        StationInfo(name: "135 St", lines: [.two, .three], latitude: 40.814229, longitude: -73.940772, borough: .manhattan),
        StationInfo(name: "145 St", lines: [.two, .three], latitude: 40.820421, longitude: -73.936425, borough: .manhattan),
        StationInfo(name: "Harlem-148 St", lines: [.three], latitude: 40.824073, longitude: -73.936245, borough: .manhattan),
    ]
}
