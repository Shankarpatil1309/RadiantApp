class AppConfig {
  static const String adminEmail = 'admin@bkit.edu.in';
  static const String adminPhone = '+91 80-12345678';
  static const String collegeName = 'B.K.I.T College';
  static const String copyrightYear = '2024';

  static String get contactInfo => 'Contact $adminEmail or call $adminPhone';
  static String get copyrightNotice =>
      '© $copyrightYear $collegeName. All rights reserved.';

  static List<String> get genders => ['Male', 'Female', 'Other'];

  static List<String> get departments => [
        'Computer Science',
        'Data Science',
        'Electronics and Communication',
        'Cyber Security',
        'Mechanical Engineering',
        'Civil Engineering',
        'Robotics',
        'AI and ML',
      ];

  static List<String> get departmentCodes => [
        'CSE',
        'DS',
        'ECE',
        'CY',
        'ME',
        'CE',
        'RO',
        'AIML',
      ];

  static List<String> get semesters => [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
      ];

  static List<String> get sections2 => [
        'A',
        'B',
      ];

  static Map<String, List<String>> get sectionsByDepartment => {
        'CSE': ['A', 'B'],
        'ECE': ['A', 'B'],
        'DS': ['A', 'B'],
        'CY': ['A', 'B'],
        'ME': ['A', 'B'],
        'CE': ['A', 'B'],
        'RO': ['A', 'B'],
        'AIML': ['A', 'B'],
      };

  static List<String> get facultyDesignations => [
        'Assistant Professor',
        'Associate Professor',
        'Professor',
        'Head of Department',
        'Principal',
        'Lecturer',
      ];

  // Restructured to map department -> semester -> subjects
  static Map<String, Map<String, List<String>>> get departmentSubjects => {
        'CSE': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Engineering Graphics',
            'Basic Electrical Engineering',
            'Programming Fundamentals',
          ],
          '2': [
            'Mathematics II',
            'Physics II',
            'Environmental Science',
            'Object Oriented Programming',
            'Digital Logic Design',
            'Engineering Mechanics',
          ],
          '3': [
            'Mathematics III',
            'Data Structures',
            'Computer Organization',
            'Database Management Systems',
            'Operating Systems',
            'Discrete Mathematics',
          ],
          '4': [
            'Algorithms',
            'Software Engineering',
            'Computer Networks',
            'Theory of Computation',
            'Microprocessors',
            'Web Technologies',
          ],
          '5': [
            'Compiler Design',
            'Computer Graphics',
            'Machine Learning',
            'Distributed Systems',
            'Network Security',
            'Mobile Application Development',
          ],
          '6': [
            'Artificial Intelligence',
            'Cloud Computing',
            'Big Data Analytics',
            'Software Testing',
            'Human Computer Interaction',
            'Project Management',
          ],
          '7': [
            'Advanced Algorithms',
            'Blockchain Technology',
            'IoT Systems',
            'DevOps',
            'Capstone Project I',
            'Technical Seminar',
          ],
          '8': [
            'Industry Training',
            'Capstone Project II',
            'Research Methodology',
            'Entrepreneurship',
            'Ethics in Computing',
          ],
        },
        'DS': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Statistics I',
            'Programming Fundamentals',
            'Introduction to Data Science',
          ],
          '2': [
            'Mathematics II',
            'Statistics II',
            'Python Programming',
            'Database Systems',
            'Data Visualization',
            'Business Analytics',
          ],
          '3': [
            'Mathematics III',
            'Machine Learning',
            'Data Mining',
            'Statistical Computing',
            'Big Data Fundamentals',
            'Research Methods',
          ],
          '4': [
            'Deep Learning',
            'Natural Language Processing',
            'Time Series Analysis',
            'Data Engineering',
            'Business Intelligence',
            'Data Ethics',
          ],
          '5': [
            'Advanced Machine Learning',
            'Computer Vision',
            'Big Data Analytics',
            'Cloud Computing for Data Science',
            'Optimization Techniques',
            'Data Science Project I',
          ],
          '6': [
            'Reinforcement Learning',
            'Distributed Computing',
            'MLOps',
            'Advanced Statistics',
            'Data Science Project II',
            'Industry Collaboration',
          ],
          '7': [
            'AI in Business',
            'Advanced Data Visualization',
            'Capstone Project I',
            'Research Paper',
            'Data Science Consulting',
          ],
          '8': [
            'Industry Training',
            'Capstone Project II',
            'Thesis Work',
            'Professional Development',
          ],
        },
        'ECE': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Basic Electrical Engineering',
            'Engineering Graphics',
            'Electronics Fundamentals',
          ],
          '2': [
            'Mathematics II',
            'Physics II',
            'Circuit Analysis',
            'Digital Electronics',
            'Programming in C',
            'Engineering Mechanics',
          ],
          '3': [
            'Mathematics III',
            'Signals and Systems',
            'Analog Electronics',
            'Network Theory',
            'Electromagnetic Fields',
            'Data Structures',
          ],
          '4': [
            'Communication Systems',
            'Microprocessors',
            'Control Systems',
            'VLSI Design',
            'Digital Signal Processing',
            'Antenna Theory',
          ],
          '5': [
            'Embedded Systems',
            'Optical Communication',
            'Microwave Engineering',
            'Digital Communication',
            'Power Electronics',
            'Project Work I',
          ],
          '6': [
            'Wireless Communication',
            'Computer Networks',
            'Advanced VLSI',
            'Image Processing',
            'RF Circuit Design',
            'Project Work II',
          ],
          '7': [
            'Satellite Communication',
            'IoT Systems',
            'Advanced Signal Processing',
            'Technical Seminar',
            'Industry Training',
          ],
          '8': [
            'Capstone Project',
            'Research Methodology',
            'Professional Ethics',
            'Entrepreneurship Development',
          ],
        },
        'CY': {
          '1': [
            'Mathematics I',
            'Physics',
            'Computer Fundamentals',
            'Programming Basics',
            'Cyber Security Basics',
            'Digital Literacy',
          ],
          '2': [
            'Mathematics II',
            'Network Fundamentals',
            'Operating Systems',
            'Web Technologies',
            'Cryptography Basics',
            'Database Security',
          ],
          '3': [
            'Mathematics III',
            'Malware Analysis',
            'Digital Forensics',
            'Incident Response',
            'Security Policies',
            'Risk Management',
          ],
          '4': [
            'Network Security',
            'Penetration Testing',
            'Security Auditing',
            'Ethical Hacking',
            'Cloud Security',
            'IoT Security',
          ],
          '5': [
            'Advanced Cyber Security',
            'Blockchain Security',
            'AI for Cyber Security',
            'Cyber Security Operations',
            'Incident Management',
            'Capstone Project I',
          ],
          '6': [
            'Cyber Threat Intelligence',
            'Security Automation',
            'Data Privacy',
            'Digital Identity',
            'Capstone Project II',
            'Industry Collaboration',
          ],
          '7': [
            'Cyber Security Consulting',
            'Advanced Incident Response',
            'Security Architecture',
            'Technical Seminar',
            'Industry Training',
          ],
          '8': [
            'Thesis Work',
            'Professional Development',
            'Entrepreneurship in Cyber Security',
            'Research Methodology',
          ],
        },
        'ME': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Engineering Mechanics',
            'Thermodynamics',
            'Fluid Mechanics',
          ],
          '2': [
            'Mathematics II',
            'Dynamics',
            'Strength of Materials',
            'Material Science',
            'Manufacturing Processes',
            'Engineering Metrology',
          ],
          '3': [
            'Mathematics III',
            'Machine Design',
            'Heat Transfer',
            'Control Systems',
            'Production Planning',
            'Operations Research',
          ],
          '4': [
            'Mechanical Vibrations',
            'Finite Element Analysis',
            'Computational Fluid Dynamics',
            'Robotics',
            'Mechatronics',
            'Technical Communication',
          ],
          '5': [
            'Advanced Manufacturing',
            'Quality Engineering',
            'Supply Chain Management',
            'Project Management',
            'Engineering Management',
            'Capstone Project I',
          ],
          '6': [
            'Renewable Energy Systems',
            'Automotive Engineering',
            'Aerospace Engineering',
            'Nanotechnology',
            'Capstone Project II',
            'Industry Collaboration',
          ],
          '7': [
            'Advanced Materials',
            'Smart Manufacturing',
            'Engineering Design',
            'Technical Seminar',
            'Industry Training',
          ],
          '8': [
            'Thesis Work',
            'Professional Development',
            'Entrepreneurship in Engineering',
            'Research Methodology',
          ],
        },
        'CE': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Engineering Mechanics',
            'Surveying',
            'Fluid Mechanics',
          ],
          '2': [
            'Mathematics II',
            'Strength of Materials',
            'Concrete Technology',
            'Soil Mechanics',
            'Transportation Engineering',
            'Environmental Engineering',
          ],
          '3': [
            'Mathematics III',
            'Structural Analysis',
            'Hydraulics',
            'Water Resources Engineering',
            'Engineering Geology',
            'Construction Materials',
          ],
          '4': [
            'Geotechnical Engineering',
            'Transportation Planning',
            'Environmental Impact Assessment',
            'Pavement Design',
            'Steel Structures',
            'Technical Communication',
          ],
          '5': [
            'Advanced Structural Analysis',
            'Bridge Engineering',
            'Tunnel Engineering',
            'Project Management',
            'Construction Management',
            'Capstone Project I',
          ],
          '6': [
            'Earthquake Engineering',
            'Wind Engineering',
            'Disaster Management',
            'Capstone Project II',
            'Industry Collaboration',
          ],
          '7': [
            'Advanced Geotechnical Engineering',
            'Transportation Systems',
            'Environmental Systems',
            'Technical Seminar',
            'Industry Training',
          ],
          '8': [
            'Thesis Work',
            'Professional Development',
            'Entrepreneurship in Civil Engineering',
            'Research Methodology',
          ],
        },
        'RO': {
          '1': [
            'Mathematics I',
            'Physics',
            'Chemistry',
            'Engineering Mechanics',
            'Introduction to Robotics',
            'Programming Fundamentals',
          ],
          '2': [
            'Mathematics II',
            'Dynamics',
            'Control Systems',
            'Sensors and Actuators',
            'Robot Kinematics',
            'Manufacturing Processes',
          ],
          '3': [
            'Mathematics III',
            'Machine Learning',
            'Computer Vision',
            'Artificial Intelligence',
            'Embedded Systems',
            'Data Structures',
          ],
          '4': [
            'Robotics Software Engineering',
            'Human-Robot Interaction',
            'Mobile Robotics',
            'Robot Perception',
            'Capstone Project I',
            'Technical Communication',
          ],
          '5': [
            'Advanced Robotics',
            'Swarm Robotics',
            'Soft Robotics',
            'Robotics in Industry',
            'Capstone Project II',
            'Industry Collaboration',
          ],
          '6': [
            'Robotics Research',
            'Robotics and Automation',
            'Technical Seminar',
            'Industry Training',
          ],
          '7': [
            'Entrepreneurship in Robotics',
            'Professional Development',
            'Research Methodology',
            'Thesis Work',
          ],
          '8': [
            'Capstone Project III',
            'Advanced Topics in Robotics',
            'Robotics Consulting',
            'Innovation in Robotics',
          ],
        },
        'AIML': {
          '1': [
            'Mathematics I',
            'Statistics',
            'Python Programming',
            'Data Science Fundamentals',
            'Introduction to AI',
            'Digital Literacy',
          ],
          '2': [
            'Mathematics II',
            'Linear Algebra',
            'Calculus',
            'Probability and Statistics',
            'Data Visualization',
            'Database Systems',
          ],
          '3': [
            'Data Mining',
            'Machine Learning',
            'Deep Learning',
            'Natural Language Processing',
            'Computer Vision',
            'Reinforcement Learning',
          ],
          '4': [
            'AI Ethics',
            'AI in Business',
            'AI for Healthcare',
            'AI for Robotics',
            'Capstone Project I',
            'Technical Communication',
          ],
          '5': [
            'Advanced Machine Learning',
            'Big Data Analytics',
            'Cloud Computing for AI',
            'AI Model Deployment',
            'Capstone Project II',
            'Industry Collaboration',
          ],
          '6': [
            'AI Research',
            'AI in Cyber Security',
            'AI for IoT',
            'AI for Social Good',
            'Technical Seminar',
            'Industry Training',
          ],
          '7': [
            'Entrepreneurship in AI',
            'Professional Development',
            'Research Methodology',
            'Thesis Work',
          ],
          '8': [
            'Capstone Project III',
            'Advanced Topics in AI and ML',
            'AI Consulting',
            'Innovation in AI',
          ],
        },
      };

  static List<String> getSubjectsForDepartment(
      String departmentCode, String semester) {
    return departmentSubjects[departmentCode]?[semester] ?? [];
  }

  static List<String> getSubjectsForDepartmentByName(
      String departmentName, String semester) {
    final index = departments.indexOf(departmentName);
    if (index != -1 && index < departmentCodes.length) {
      return getSubjectsForDepartment(departmentCodes[index], semester);
    }
    return [];
  }

  static bool isDepartmentCodeValid(String code) {
    return departmentSubjects.containsKey(code);
  }

  static bool isSemesterValidForDepartment(
      String departmentCode, String semester) {
    return departmentSubjects[departmentCode]?.containsKey(semester) ?? false;
  }

  static List<String> getAllSubjectsForDepartment(String departmentCode) {
    final allSubjects = <String>{};
    final deptMap = departmentSubjects[departmentCode];
    if (deptMap != null) {
      for (final subjects in deptMap.values) {
        allSubjects.addAll(subjects);
      }
    }
    return allSubjects.toList()..sort();
  }

  static List<String> getAllUniqueSubjects() {
    final allSubjects = <String>{};
    for (final deptMap in departmentSubjects.values) {
      for (final subjects in deptMap.values) {
        allSubjects.addAll(subjects);
      }
    }
    return allSubjects.toList()..sort();
  }

  static List<String> getAvailableSemestersForDepartment(
      String departmentCode) {
    return departmentSubjects[departmentCode]?.keys.toList() ?? [];
  }
}
