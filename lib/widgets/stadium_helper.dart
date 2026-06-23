class StadiumProfileModel {
  final String name;
  final String photoUrl;
  final String description;
  final String facts;

  StadiumProfileModel({
    required this.name,
    required this.photoUrl,
    required this.description,
    required this.facts,
  });
}

class StadiumHelper {
  /// Maps local venue names to GitHub JSON ground names
  static final Map<String, String> venueToGround = {
    'metlife stadium': 'New York/New Jersey (East Rutherford)',
    'azteca stadium': 'Mexico City',
    'sofi stadium': 'Los Angeles (Inglewood)',
    'bc place': 'Vancouver',
    'mercedes-benz stadium': 'Atlanta',
    'at&t stadium': 'Dallas (Arlington)',
    'bmo field': 'Toronto',
    'hard rock stadium': 'Miami (Miami Gardens)',
  };

  /// Returns the GitHub ground name for a venue, or the venue name itself if not found.
  static String getGroundName(String venueName) {
    return venueToGround[venueName.toLowerCase().trim()] ?? venueName;
  }

  static final Map<String, StadiumProfileModel> _stadiums = {
    'metlife stadium': StadiumProfileModel(
      name: 'MetLife Stadium',
      photoUrl: 'https://images.unsplash.com/photo-1569429596654-e692cf26cc63?w=800&auto=format&fit=crop&q=80',
      description: 'MetLife Stadium is a premier multi-purpose open-air stadium located in East Rutherford, New Jersey. Opened in 2010, it is one of the most technologically advanced and expensive stadium projects in the world.',
      facts: 'Set to host the prestigious FIFA World Cup 2026 Final match. It features a neutral exterior coloring design that adapts dynamically to the home team.',
    ),
    'azteca stadium': StadiumProfileModel(
      name: 'Estadio Azteca',
      photoUrl: 'https://images.unsplash.com/photo-1614713783935-7cf0529d2b27?w=800&auto=format&fit=crop&q=80',
      description: 'The legendary temple of global football. Located in Mexico City, Estadio Azteca is the first stadium to have hosted two FIFA World Cup finals (1970 and 1986). It stands at an altitude of 2,200 meters above sea level.',
      facts: 'The iconic ground where Pelé (1970) and Diego Maradona (1986) lifted the FIFA World Cup trophies. Famous for the "Hand of God" and "Goal of the Century" matches.',
    ),
    'sofi stadium': StadiumProfileModel(
      name: 'SoFi Stadium',
      photoUrl: 'https://images.unsplash.com/photo-1610996845347-190ea4d03991?w=800&auto=format&fit=crop&q=80',
      description: 'Located in Inglewood, California, SoFi Stadium is a state-of-the-art indoor-outdoor sports masterpiece. Completed in 2020, it features a revolutionary translucent canopy roof and a massive double-sided 4K Oculus video board.',
      facts: 'The most expensive stadium ever built in human history (\$4.9 Billion). Features a fully integrated digital layout with scenic indoor-outdoor canyon gardens.',
    ),
    'bc place': StadiumProfileModel(
      name: 'BC Place',
      photoUrl: 'https://images.unsplash.com/photo-1594470117722-de4b9a02ebed?w=800&auto=format&fit=crop&q=80',
      description: "BC Place is Canada's premier multi-purpose sports arena, situated in the heart of Vancouver, British Columbia. Opened in 1983, it underwent a major redevelopment featuring the largest cable-supported retractable roof in the world.",
      facts: "Host of the 2015 FIFA Women's World Cup Final. Known for its gorgeous architectural light structural columns that illuminate the Vancouver skyline.",
    ),
    'mercedes-benz stadium': StadiumProfileModel(
      name: 'Mercedes-Benz Stadium',
      photoUrl: 'https://images.unsplash.com/photo-1540749676585-783517c5b61f?w=800&auto=format&fit=crop&q=80',
      description: 'Mercedes-Benz Stadium is a world-renowned architectural wonder located in Atlanta, Georgia. Opened in 2017, it features a unique pinwheel-like retractable roof that opens and closes like a camera aperture, and a massive 360-degree halo board.',
      facts: 'A global leader in sustainability and water conservation. It holds the record for the largest single-unit LED video screen in professional sports.',
    ),
    'at&t stadium': StadiumProfileModel(
      name: 'AT&T Stadium',
      photoUrl: 'https://images.unsplash.com/photo-1599156715694-fb4dfcc4b1f4?w=800&auto=format&fit=crop&q=80',
      description: 'AT&T Stadium, widely known as "Jerry World," is a colossal retractable-roof stadium located in Arlington, Texas. Completed in 2009, it features massive column-free glass doors on each end zone and a high-definition center-hung video board.',
      facts: 'One of the largest enclosed dome structures in the world. Famous for its majestic column-free internal space and futuristic glass structural designs.',
    ),
    'bmo field': StadiumProfileModel(
      name: 'BMO Field',
      photoUrl: 'https://images.unsplash.com/photo-1577223625856-758c127e1279?w=800&auto=format&fit=crop&q=80',
      description: "BMO Field is Canada's national soccer stadium, situated on the scenic Exhibition Place grounds in Toronto, Ontario. Originally opened in 2007, it has undergone major modern expansions to add expansive grandstands and premium canopies.",
      facts: "Canada's primary soccer fortress. Famously known for its vibrant and passionate crowd atmosphere situated right next to Lake Ontario.",
    ),
    'hard rock stadium': StadiumProfileModel(
      name: 'Hard Rock Stadium',
      photoUrl: 'https://images.unsplash.com/photo-1564243258143-471245ee5445?w=800&auto=format&fit=crop&q=80',
      description: 'Hard Rock Stadium is a beautifully retrofitted multi-purpose stadium situated in Miami Gardens, Florida. Known for its iconic towering corner masts and an open-air canopy roof that shelters 90% of spectator seats.',
      facts: 'Host of multiple NFL Super Bowls, Formula 1 Miami Grand Prix, and prestigious international soccer finals. Famous for its energetic South Florida tropical atmosphere.',
    ),
  };

  /// Returns stadium facts, image URL, and description based on stadium name.
  static StadiumProfileModel getProfile(String stadiumName) {
    final key = stadiumName.toLowerCase().trim();
    if (_stadiums.containsKey(key)) {
      return _stadiums[key]!;
    }

    // Default Fallback
    return StadiumProfileModel(
      name: stadiumName,
      photoUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&auto=format&fit=crop&q=80',
      description: 'A world-class sports venue selected to host match fixtures for the highly anticipated FIFA World Cup tournament.',
      facts: 'Meets elite FIFA criteria for top-tier international play, featuring pristine pitch conditions and state-of-the-art facilities.',
    );
  }
}
