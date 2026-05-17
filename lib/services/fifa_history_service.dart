class FifaHistoryModel {
  final String teamName;
  final int titlesCount;
  final List<String> titleYears;
  final String bestFinish;
  final String legends;
  final String interestingFact;
  final String appearanceCount;

  FifaHistoryModel({
    required this.teamName,
    required this.titlesCount,
    required this.titleYears,
    required this.bestFinish,
    required this.legends,
    required this.interestingFact,
    required this.appearanceCount,
  });
}

class FifaHistoryService {
  static final Map<String, FifaHistoryModel> _historyMap = {
    'argentina': FifaHistoryModel(
      teamName: 'Argentina',
      titlesCount: 3,
      titleYears: ['1978', '1986', '2022'],
      bestFinish: 'Champions (1978, 1986, 2022)',
      legends: 'Lionel Messi, Diego Maradona, Mario Kempes',
      interestingFact: 'Lionel Messi is the player with the most World Cup appearances in history (26 matches).',
      appearanceCount: '18 times',
    ),
    'france': FifaHistoryModel(
      teamName: 'France',
      titlesCount: 2,
      titleYears: ['1998', '2018'],
      bestFinish: 'Champions (1998, 2018)',
      legends: 'Zinedine Zidane, Kylian Mbappé, Michel Platini',
      interestingFact: 'Just Fontaine holds the record for most goals scored in a single World Cup (13 goals in 1958).',
      appearanceCount: '16 times',
    ),
    'usa': FifaHistoryModel(
      teamName: 'USA',
      titlesCount: 0,
      titleYears: [],
      bestFinish: '3rd Place (1930)',
      legends: 'Landon Donovan, Clint Dempsey, Christian Pulisic',
      interestingFact: 'The United States played in the very first World Cup in 1930 and reached the semi-finals.',
      appearanceCount: '11 times',
    ),
    'england': FifaHistoryModel(
      teamName: 'England',
      titlesCount: 1,
      titleYears: ['1966'],
      bestFinish: 'Champions (1966)',
      legends: 'Bobby Charlton, Gary Lineker, Harry Kane',
      interestingFact: 'England won their only title on home soil in 1966 in a thrilling final against West Germany.',
      appearanceCount: '16 times',
    ),
    'brazil': FifaHistoryModel(
      teamName: 'Brazil',
      titlesCount: 5,
      titleYears: ['1958', '1962', '1970', '1994', '2002'],
      bestFinish: 'Champions (5 times)',
      legends: 'Pelé, Ronaldo Nazário, Ronaldinho',
      interestingFact: 'Brazil is the most successful nation in World Cup history and the only one to play in all 22 tournaments.',
      appearanceCount: '22 times',
    ),
    'germany': FifaHistoryModel(
      teamName: 'Germany',
      titlesCount: 4,
      titleYears: ['1954', '1974', '1990', '2014'],
      bestFinish: 'Champions (4 times)',
      legends: 'Franz Beckenbauer, Miroslav Klose, Gerd Müller',
      interestingFact: 'Miroslav Klose is the all-time top goalscorer in World Cup history with 16 goals.',
      appearanceCount: '20 times',
    ),
    'spain': FifaHistoryModel(
      teamName: 'Spain',
      titlesCount: 1,
      titleYears: ['2010'],
      bestFinish: 'Champions (2010)',
      legends: 'Andres Iniesta, Xavi Hernandez, Iker Casillas',
      interestingFact: 'Spain won the 2010 World Cup in South Africa by scoring just 8 goals in the entire tournament, the fewest for any champion.',
      appearanceCount: '16 times',
    ),
    'portugal': FifaHistoryModel(
      teamName: 'Portugal',
      titlesCount: 0,
      titleYears: [],
      bestFinish: '3rd Place (1966)',
      legends: 'Eusébio, Cristiano Ronaldo, Luis Figo',
      interestingFact: 'Cristiano Ronaldo is the first male player to score in five different World Cup tournaments.',
      appearanceCount: '8 times',
    ),
    'mexico': FifaHistoryModel(
      teamName: 'Mexico',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Quarter-finals (1970, 1986)',
      legends: 'Hugo Sánchez, Rafael Márquez, Javier Hernández',
      interestingFact: 'Mexico has hosted the World Cup twice (1970, 1986) and will become the first nation to host it three times in 2026.',
      appearanceCount: '17 times',
    ),
    'canada': FifaHistoryModel(
      teamName: 'Canada',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Group Stage (1986, 2022)',
      legends: 'Alphonso Davies, Atiba Hutchinson, Jonathan David',
      interestingFact: "Alphonso Davies scored Canada's first-ever World Cup goal against Croatia in the 2022 edition.",
      appearanceCount: '2 times',
    ),
    'netherlands': FifaHistoryModel(
      teamName: 'Netherlands',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Runners-up (1974, 1978, 2010)',
      legends: 'Johan Cruyff, Marco van Basten, Arjen Robben',
      interestingFact: 'Netherlands holds the record for playing in the most World Cup finals (3) without ever winning the trophy.',
      appearanceCount: '11 times',
    ),
    'belgium': FifaHistoryModel(
      teamName: 'Belgium',
      titlesCount: 0,
      titleYears: [],
      bestFinish: '3rd Place (2018)',
      legends: 'Eden Hazard, Kevin De Bruyne, Romelu Lukaku',
      interestingFact: "Belgium's 'Golden Generation' achieved their highest-ever finish in 2018, beating England in the third-place match.",
      appearanceCount: '14 times',
    ),
    'croatia': FifaHistoryModel(
      teamName: 'Croatia',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Runners-up (2018)',
      legends: 'Luka Modrić, Davor Šuker, Ivan Perišić',
      interestingFact: 'With a population of only 4 million, Croatia reached the final in 2018 and secured third place in 1998 and 2022.',
      appearanceCount: '6 times',
    ),
    'japan': FifaHistoryModel(
      teamName: 'Japan',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Round of 16 (2002, 2010, 2018, 2022)',
      legends: 'Hidetoshi Nakata, Keisuke Honda, Shinji Kagawa',
      interestingFact: 'Japan has qualified for seven consecutive World Cups since making their debut in 1998.',
      appearanceCount: '7 times',
    ),
    'morocco': FifaHistoryModel(
      teamName: 'Morocco',
      titlesCount: 0,
      titleYears: [],
      bestFinish: '4th Place (2022)',
      legends: 'Mustapha Hadji, Yassine Bounou, Achraf Hakimi',
      interestingFact: 'Morocco made history in 2022 as the first African and Arab nation to ever reach the World Cup semi-finals.',
      appearanceCount: '6 times',
    ),
    'senegal': FifaHistoryModel(
      teamName: 'Senegal',
      titlesCount: 0,
      titleYears: [],
      bestFinish: 'Quarter-finals (2002)',
      legends: 'Sadio Mané, El Hadji Diouf, Aliou Cissé',
      interestingFact: 'In their debut match in 2002, Senegal shocked reigning champions France with a 1-0 victory in the opening match.',
      appearanceCount: '3 times',
    ),
  };

  static FifaHistoryModel? getHistory(String teamName) {
    return _historyMap[teamName.toLowerCase().trim()];
  }
}
