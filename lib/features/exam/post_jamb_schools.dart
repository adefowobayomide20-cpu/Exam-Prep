class PostJambSchool {
  const PostJambSchool({
    required this.name,
    required this.shortName,
    required this.website,
  });

  final String name;
  final String shortName;

  /// Bare domain for the institution's official website — screening
  /// portals, cut-off marks, and dates move every admission cycle, so we
  /// link out to the source of truth rather than hardcoding figures that
  /// go stale.
  final String website;
}

const postJambSchools = [
  PostJambSchool(name: 'University of Lagos', shortName: 'UNILAG', website: 'unilag.edu.ng'),
  PostJambSchool(name: 'University of Ilorin', shortName: 'UNILORIN', website: 'unilorin.edu.ng'),
  PostJambSchool(name: 'University of Ibadan', shortName: 'UI', website: 'ui.edu.ng'),
  PostJambSchool(
    name: 'Obafemi Awolowo University',
    shortName: 'OAU',
    website: 'oauife.edu.ng',
  ),
  PostJambSchool(name: 'University of Benin', shortName: 'UNIBEN', website: 'uniben.edu'),
  PostJambSchool(
    name: 'University of Nigeria Nsukka (UNN)',
    shortName: 'UNN',
    website: 'unn.edu.ng',
  ),
  PostJambSchool(
    name: 'Federal University of Technology Akure',
    shortName: 'FUTA',
    website: 'futa.edu.ng',
  ),
  PostJambSchool(
    name: 'Ladoke Akintola University of Technology',
    shortName: 'LAUTECH',
    website: 'lautech.edu.ng',
  ),
];
