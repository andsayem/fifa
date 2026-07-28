class TeamLogoHelper {
  static const _fallbackUrl = 'https://flagcdn.com/w320/un.png';

  static String getLogo(String teamName) {
    if (teamName.isEmpty) return _fallbackUrl;

    final map = {
      "Mexico": "https://flagcdn.com/w320/mx.png",
      "South Africa": "https://flagcdn.com/w320/za.png",
      "South Korea": "https://flagcdn.com/w320/kr.png",
      "Czechia": "https://flagcdn.com/w320/cz.png",
      "Czech Republic": "https://flagcdn.com/w320/cz.png",
      "Canada": "https://flagcdn.com/w320/ca.png",
      "Bosnia and Herzegovina": "https://flagcdn.com/w320/ba.png",
      "Bosnia & Herzegovina": "https://flagcdn.com/w320/ba.png",
      "Qatar": "https://flagcdn.com/w320/qa.png",
      "Switzerland": "https://flagcdn.com/w320/ch.png",
      "Brazil": "https://flagcdn.com/w320/br.png",
      "Morocco": "https://flagcdn.com/w320/ma.png",
      "Haiti": "https://flagcdn.com/w320/ht.png",
      "Scotland": "https://flagcdn.com/w320/gb-sct.png",
      "United States": "https://flagcdn.com/w320/us.png",
      "USA": "https://flagcdn.com/w320/us.png",
      "Paraguay": "https://flagcdn.com/w320/py.png",
      "Australia": "https://flagcdn.com/w320/au.png",
      "Turkey": "https://flagcdn.com/w320/tr.png",
      "Germany": "https://flagcdn.com/w320/de.png",
      "Curaçao": "https://flagcdn.com/w320/cw.png",
      "Ivory Coast": "https://flagcdn.com/w320/ci.png",
      "Ecuador": "https://flagcdn.com/w320/ec.png",
      "Netherlands": "https://flagcdn.com/w320/nl.png",
      "Japan": "https://flagcdn.com/w320/jp.png",
      "Sweden": "https://flagcdn.com/w320/se.png",
      "Tunisia": "https://flagcdn.com/w320/tn.png",
      "Belgium": "https://flagcdn.com/w320/be.png",
      "Egypt": "https://flagcdn.com/w320/eg.png",
      "Iran": "https://flagcdn.com/w320/ir.png",
      "New Zealand": "https://flagcdn.com/w320/nz.png",
      "Spain": "https://flagcdn.com/w320/es.png",
      "Cape Verde": "https://flagcdn.com/w320/cv.png",
      "Saudi Arabia": "https://flagcdn.com/w320/sa.png",
      "Uruguay": "https://flagcdn.com/w320/uy.png",
      "France": "https://flagcdn.com/w320/fr.png",
      "Senegal": "https://flagcdn.com/w320/sn.png",
      "Iraq": "https://flagcdn.com/w320/iq.png",
      "Norway": "https://flagcdn.com/w320/no.png",
      "Argentina": "https://flagcdn.com/w320/ar.png",
      "Algeria": "https://flagcdn.com/w320/dz.png",
      "Austria": "https://flagcdn.com/w320/at.png",
      "Jordan": "https://flagcdn.com/w320/jo.png",
      "Portugal": "https://flagcdn.com/w320/pt.png",
      "Congo DR": "https://flagcdn.com/w320/cd.png",
      "DR Congo": "https://flagcdn.com/w320/cd.png",
      "Uzbekistan": "https://flagcdn.com/w320/uz.png",
      "Colombia": "https://flagcdn.com/w320/co.png",
      "England": "https://flagcdn.com/w320/gb-eng.png",
      "Croatia": "https://flagcdn.com/w320/hr.png",
      "Ghana": "https://flagcdn.com/w320/gh.png",
      "Panama": "https://flagcdn.com/w320/pa.png",
      "Hungary": "https://flagcdn.com/w320/hu.png",
      "Poland": "https://flagcdn.com/w320/pl.png",
      "Soviet Union": "https://flagcdn.com/w320/su.png",
      "Czechoslovakia": "https://flagcdn.com/w320/cz.png",
      "Yugoslavia": "https://flagcdn.com/w320/rs.png",
      "Bulgaria": "https://flagcdn.com/w320/bg.png",
      "Cameroon": "https://flagcdn.com/w320/cm.png",
      "Russia": "https://flagcdn.com/w320/ru.png",
      "Ireland": "https://flagcdn.com/w320/ie.png",
      "Northern Ireland": "https://flagcdn.com/w320/gb-nir.png",
      "Wales": "https://flagcdn.com/w320/gb-wls.png",
      "West Germany": "https://flagcdn.com/w320/de.png",
      "East Germany": "https://flagcdn.com/w320/de.png",
      "Bolivia": "https://flagcdn.com/w320/bo.png",
      "Peru": "https://flagcdn.com/w320/pe.png",
      "Romania": "https://flagcdn.com/w320/ro.png",
      "Cuba": "https://flagcdn.com/w320/cu.png",
      "Indonesia": "https://flagcdn.com/w320/id.png",
      "Dutch East Indies": "https://flagcdn.com/w320/id.png",
      "India": "https://flagcdn.com/w320/in.png"
    };

    // Case-insensitive lookup helper
    final key = teamName.trim();
    final matchedKey = map.keys.firstWhere(
      (k) => k.toLowerCase() == key.toLowerCase(),
      orElse: () => "",
    );

    if (matchedKey.isNotEmpty) {
      return map[matchedKey]!;
    }

    return _fallbackUrl;
  }
}
