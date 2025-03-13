// lib/core/services/government_position_data.dart
class GovernmentPositionData {
  static Map<String, Map<String, dynamic>> getPositionInfo() {
    return {
      // Federal Positions
      'Senator': {
        'level': 'federal',
        'description': 'A member of the U.S. Senate, the upper chamber of Congress. Each state elects two senators to serve six-year terms.',
        'responsibilities': [
          'Writes and votes on national legislation',
          'Confirms presidential appointments (judges, cabinet members, etc.)',
          'Ratifies international treaties',
          'Conducts impeachment trials',
          'Oversees federal budget approval'
        ],
        'termLength': '6 years',
        'requirements': 'Must be at least 30 years old, a U.S. citizen for at least 9 years, and a resident of the state they represent.',
        'powers': [
          'Introduces legislation',
          'Serves on committees',
          'Conducts investigations',
          'Represents state interests'
        ],
        'limitations': [
          'Cannot introduce revenue bills (must originate in House)',
          'Subject to Senate rules and procedures',
          'Legislation requires House approval as well'
        ],
        'funFacts': [
          'The Senate was designed to be the more deliberative body of Congress',
          'Vice President of the United States serves as President of the Senate',
          'Senate rules allow for filibuster, requiring 60 votes to end debate'
        ]
      },
      'Representative': {
        'level': 'federal',
        'description': 'A member of the U.S. House of Representatives, the lower chamber of Congress. Representatives are elected from congressional districts based on population.',
        'responsibilities': [
          'Writes and votes on national legislation',
          'Initiates revenue and spending bills',
          'Confirms presidential appointments (for some positions)',
          'Represents local district interests',
          'Conducts oversight of federal agencies'
        ],
        'termLength': '2 years',
        'requirements': 'Must be at least 25 years old, a U.S. citizen for at least 7 years, and a resident of the state they represent.',
        'powers': [
          'Introduces legislation',
          'Serves on committees',
          'Exclusive power to initiate impeachment proceedings',
          'Exclusive power to introduce revenue bills'
        ],
        'limitations': [
          'Shorter term requires more frequent campaigning',
          'Represents smaller constituency than senators',
          'Legislation requires Senate approval as well'
        ],
        'funFacts': [
          'House seats are reapportioned after each census',
          'Number of House members has been fixed at 435 since 1911',
          'The Speaker of the House is second in line for presidential succession'
        ]
      },
    
      // State Positions
      'State Senator': {
        'level': 'state',
        'description': 'A member of the state senate, typically the upper chamber of a state legislature.',
        'responsibilities': [
          'Creates and votes on state laws',
          'Approves state budgets',
          'Confirms appointments by the governor (in many states)',
          'Oversees state agencies',
          'Addresses state-level policy issues'
        ],
        'termLength': 'Varies by state (typically 2-4 years)',
        'requirements': 'Varies by state, typically includes minimum age, citizenship, and residency requirements.',
        'powers': [
          'Introduces state legislation',
          'Serves on state committees',
          'Represents district interests',
          'Oversees state spending'
        ],
        'limitations': [
          'Authority limited to state jurisdiction',
          'Subject to state constitution',
          'Cannot pass laws that conflict with federal law'
        ],
        'funFacts': [
          'State senates are often modeled after the U.S. Senate',
          'Nebraska is the only state with a unicameral (single-chamber) legislature',
          'State senators often represent larger districts than state representatives'
        ]
      },
      'State Representative': {
        'level': 'state',
        'description': 'A member of the state house of representatives or assembly, typically the lower chamber of a state legislature.',
        'responsibilities': [
          'Creates and votes on state laws',
          'Approves state budgets',
          'Represents local district interests',
          'Addresses state-level policy issues',
          'Conducts oversight of state agencies'
        ],
        'termLength': 'Varies by state (typically 2 years)',
        'requirements': 'Varies by state, typically includes minimum age, citizenship, and residency requirements.',
        'powers': [
          'Introduces state legislation',
          'Serves on state committees',
          'Conducts state-level investigations',
          'Often initiates budget legislation'
        ],
        'limitations': [
          'Authority limited to state jurisdiction',
          'Subject to state constitution',
          'Cannot pass laws that conflict with federal law'
        ],
        'funFacts': [
          'State houses often have more members than state senates',
          'Term limits exist in some states but not all',
          'Many state legislators serve part-time and have other careers'
        ]
      },
      'Governor': {
        'level': 'state',
        'description': 'The chief executive officer of a state, similar to the president at the federal level.',
        'responsibilities': [
          'Implements and enforces state laws',
          'Prepares and administers state budget',
          'Appoints state officials and judges',
          'Commands state national guard',
          'Sets policy priorities for the state',
          'Issues executive orders',
          'Grants pardons and reprieves'
        ],
        'termLength': 'Varies by state (typically 4 years)',
        'requirements': 'Varies by state, typically includes minimum age, citizenship, and state residency requirements.',
        'powers': [
          'Veto legislation',
          'Call special legislative sessions',
          'Declare states of emergency',
          'Represent state in dealings with other states and federal government'
        ],
        'limitations': [
          'Powers defined by state constitution',
          'Legislature can override vetoes',
          'Subject to judicial review',
          'Term limits in many states'
        ],
        'funFacts': [
          'Governors in 44 states have line-item veto power',
          'The governor of New Hampshire serves only a two-year term',
          'Many governors have gone on to become president'
        ]
      },
      
      // Local Positions
      'Mayor': {
        'level': 'local',
        'description': 'The chief executive officer of a city or town.',
        'responsibilities': [
          'Oversees city departments and services',
          'Proposes city budget',
          'Represents the city officially',
          'Implements city council policies',
          'Coordinates emergency response'
        ],
        'termLength': 'Varies by city (typically 2-4 years)',
        'requirements': 'Typically local residency and voter registration.',
        'powers': [
          'Appoints city officials (in some systems)',
          'Veto council legislation (in some systems)',
          'Represents city in dealings with other governments',
          'Sets policy priorities'
        ],
        'limitations': [
          'Powers vary widely based on city charter',
          'Subject to city council oversight',
          'Cannot pass laws that conflict with state or federal law'
        ],
        'funFacts': [
          'Mayor-council and council-manager are the two most common forms of city government',
          'The mayor of New York City oversees a budget larger than most states',
          'Some mayors serve part-time with limited formal powers'
        ]
      },
      'City Council Member': {
        'level': 'local',
        'description': 'An elected official who serves on a city council, the legislative body of a city or town.',
        'responsibilities': [
          'Creates and votes on local ordinances',
          'Approves city budget',
          'Sets tax rates',
          'Establishes land use policies',
          'Oversees city services and operations'
        ],
        'termLength': 'Varies by city (typically 2-4 years)',
        'requirements': 'Typically local residency and voter registration.',
        'powers': [
          'Introduces local legislation',
          'Serves on council committees',
          'Represents district/ward interests',
          'Approves or rejects mayor\'s appointments (in some systems)'
        ],
        'limitations': [
          'Authority limited to city jurisdiction',
          'Subject to city charter',
          'Cannot pass ordinances that conflict with state or federal law'
        ],
        'funFacts': [
          'Council members may represent specific districts or be elected at-large',
          'Some cities use partisan elections while others are nonpartisan',
          'City councils range from 5 to 50+ members depending on the city'
        ]
      },
      'County Commissioner': {
        'level': 'local',
        'description': 'A member of a county board or commission, which serves as the governing body for a county.',
        'responsibilities': [
          'Creates county ordinances',
          'Approves county budget',
          'Oversees county services',
          'Manages county property',
          'Sets tax rates'
        ],
        'termLength': 'Varies by county (typically 2-4 years)',
        'requirements': 'Typically county residency and voter registration.',
        'powers': [
          'Establishes county policies',
          'Appoints county officials (in some systems)',
          'Represents county interests',
          'Allocates county resources'
        ],
        'limitations': [
          'Authority limited to county jurisdiction',
          'Responsibilities vary widely by state',
          'Cannot pass ordinances that conflict with state or federal law'
        ],
        'funFacts': [
          'Counties in Connecticut and Rhode Island have no governmental function',
          'Some states call them "supervisors" instead of "commissioners"',
          'Louisiana has "parishes" instead of counties'
        ]
      }
    };
  }

  static Map<String, dynamic> getPositionInfoByTitle(String title) {
    final allPositions = getPositionInfo();
    
    // Try exact match first
    if (allPositions.containsKey(title)) {
      return allPositions[title]!;
    }
    
    // Try partial match - useful for variations like "U.S. Senator" vs "Senator"
    for (final positionTitle in allPositions.keys) {
      if (title.toLowerCase().contains(positionTitle.toLowerCase()) || 
          positionTitle.toLowerCase().contains(title.toLowerCase())) {
        return allPositions[positionTitle]!;
      }
    }
    
    // Default information for unknown positions
    return {
      'level': 'unknown',
      'description': 'An elected government official.',
      'responsibilities': [
        'Represents constituents',
        'Participates in government processes',
        'Votes on legislation and policies'
      ],
      'termLength': 'Varies',
      'requirements': 'Varies by position',
      'powers': ['Specific powers depend on the exact position'],
      'limitations': ['Subject to legal and constitutional constraints'],
      'funFacts': ['Government positions create our system of checks and balances']
    };
  }
}