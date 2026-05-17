class PlayerHistoryModel {
  final String name;
  final String club;
  final String bio;
  final String achievements;

  PlayerHistoryModel({
    required this.name,
    required this.club,
    required this.bio,
    required this.achievements,
  });
}

class PlayerHistoryService {
  static final Map<String, PlayerHistoryModel> _customBios = {
    'lionel messi': PlayerHistoryModel(
      name: 'Lionel Messi',
      club: 'Inter Miami (USA)',
      bio: "Widely regarded as the greatest player in football history, Messi inspired Argentina to a historic FIFA World Cup triumph in Qatar 2022, scoring twice in the final. He holds the record for most World Cup appearances (26) and has won an unprecedented 8 Ballon d'Or awards.",
      achievements: "FIFA World Cup Winner (2022), 2x World Cup Golden Ball, 8x Ballon d'Or, 4x UEFA Champions League.",
    ),
    'cristiano ronaldo': PlayerHistoryModel(
      name: 'Cristiano Ronaldo',
      club: 'Al Nassr (KSA)',
      bio: "One of the most prolific goalscorers in the history of the sport, Ronaldo is the only male player to score in five consecutive World Cup tournaments (2006-2022). Portugal's all-time top scorer and appearance holder.",
      achievements: "UEFA Euro Champion (2016), 5x Ballon d'Or, 5x UEFA Champions League, All-time leading international goalscorer.",
    ),
    'kylian mbappé': PlayerHistoryModel(
      name: 'Kylian Mbappé',
      club: 'Real Madrid (Spain)',
      bio: "A sensational speedster and lethal finisher, Mbappé burst onto the global stage in 2018, helping France win the World Cup and becoming only the second teenager (after Pelé) to score in a World Cup final. He scored a historic hat-trick in the 2022 final.",
      achievements: "FIFA World Cup Winner (2018), World Cup Golden Boot (2022), 7x Ligue 1 Champion.",
    ),
    'jude bellingham': PlayerHistoryModel(
      name: 'Jude Bellingham',
      club: 'Real Madrid (Spain)',
      bio: "A complete box-to-box midfielder with exceptional vision, work rate, and maturity beyond his years. Bellingham became one of England's youngest-ever World Cup goalscorers in 2022 and has established himself as a global superstar.",
      achievements: "La Liga Player of the Season, Kopa Trophy Winner, UEFA Champions League Winner.",
    ),
    'vinicius junior': PlayerHistoryModel(
      name: 'Vinicius Junior',
      club: 'Real Madrid (Spain)',
      bio: "A dynamic and explosive winger known for his mesmerizing dribbling skills, electric pace, and crucial goals. Vinicius has become Brazil's primary attacking threat and a key pillar for both club and country.",
      achievements: "2x UEFA Champions League Winner, UCL Player of the Season (2023-24), Copa del Rey Winner.",
    ),
    'luka modrić': PlayerHistoryModel(
      name: 'Luka Modrić',
      club: 'Real Madrid (Spain)',
      bio: "The maestro of Croatia's golden generation. Modrić won the Golden Ball at the 2018 World Cup after leading his country to the final, and secured the Bronze medal in 2022. One of the greatest midfielders of all time.",
      achievements: "FIFA World Cup Golden Ball (2018), Ballon d'Or Winner (2018), 6x UEFA Champions League Winner.",
    ),
    'harry kane': PlayerHistoryModel(
      name: 'Harry Kane',
      club: 'Bayern Munich (Germany)',
      bio: "England's all-time top goalscorer and one of the finest strikers of his generation. Kane won the Golden Boot at the 2018 World Cup as England reached the semi-finals, and is renowned for both his prolific finishing and playmaking abilities.",
      achievements: "FIFA World Cup Golden Boot (2018), 3x Premier League Golden Boot, European Golden Shoe.",
    ),
    'jamal musiala': PlayerHistoryModel(
      name: 'Jamal Musiala',
      club: 'Bayern Munich (Germany)',
      bio: "Nicknamed 'Bambi' for his sublime dribbling in tight spaces, Musiala is Germany's brightest young talent. Blessed with extraordinary agility, close control, and spatial awareness, he is a nightmare for defenders.",
      achievements: "4x Bundesliga Champion, German national team rising star, Kopa Trophy Runner-up.",
    ),
    'alphonso davies': PlayerHistoryModel(
      name: 'Alphonso Davies',
      club: 'Bayern Munich (Germany)',
      bio: "One of the fastest players in world football. Davies made history by scoring Canada's first-ever World Cup goal in 2022 against Croatia. A trailblazer for North American soccer.",
      achievements: "UEFA Champions League Winner, 5x Bundesliga Champion, 4x CONCACAF Men's Player of the Year.",
    ),
    'kevin de bruyne': PlayerHistoryModel(
      name: 'Kevin De Bruyne',
      club: 'Manchester City (England)',
      bio: "Widely regarded as the best playmaker in modern football. De Bruyne possesses unmatched crossing accuracy, vision, and long-range shooting. He led Belgium's golden generation to a third-place finish in 2018.",
      achievements: "2x Premier League Player of the Season, UEFA Champions League Winner, FIFA World Cup 3rd Place (2018).",
    ),
    'antoine griezmann': PlayerHistoryModel(
      name: 'Antoine Griezmann',
      club: 'Atletico Madrid (Spain)',
      bio: "A brilliant playmaker and hardworking forward, Griezmann was a key architect of France's 2018 World Cup victory, winning the Bronze Ball and Silver Boot, and was stellar in their 2022 campaign.",
      achievements: "FIFA World Cup Winner (2018), La Liga Best Player, UEFA Europa League Winner.",
    ),
    'virgil van dijk': PlayerHistoryModel(
      name: 'Virgil van Dijk',
      club: 'Liverpool (England)',
      bio: "The towering Dutch captain, renowned for his composure, aerial dominance, and leadership. Van Dijk is considered one of the best defenders of the modern era, guiding the Netherlands back to the top tier of world football.",
      achievements: "UEFA Champions League Winner, PFA Players' Player of the Year, Premier League Winner.",
    ),
  };

  static PlayerHistoryModel getPlayerHistory(String name, String country, String position, int number) {
    final key = name.toLowerCase().trim();
    if (_customBios.containsKey(key)) {
      return _customBios[key]!;
    }

    // Dynamic generation fallback
    String dynamicClub = 'Top Tier European Club';
    if (position.toLowerCase() == 'goalkeeper') {
      dynamicClub = 'Premier League Club';
    } else if (position.toLowerCase() == 'midfielder') {
      dynamicClub = 'La Liga Club';
    } else if (position.toLowerCase() == 'forward') {
      dynamicClub = 'Serie A Club';
    }

    return PlayerHistoryModel(
      name: name,
      club: dynamicClub,
      bio: "A crucial asset for the $country national team, $name wears the number #$number shirt and plays as a $position. Known for tactical discipline, exceptional athleticism, and excellent teamwork, $name is set to make a significant impact in the FIFA tournament representing their country.",
      achievements: "National Team Squad Member, Key Player for Club and Country.",
    );
  }
}
