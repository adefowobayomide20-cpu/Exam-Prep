class ServiceSection {
  const ServiceSection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

const serviceSections = [
  ServiceSection(
    title: 'Sales',
    items: ['Examination Result Scratch Card'],
  ),
  ServiceSection(
    title: 'Result Services',
    items: [
      'WAEC Result Checker',
      'NECO Result Checker',
      'JAMB Result Checker',
    ],
  ),
  ServiceSection(
    title: 'JAMB Services',
    items: [
      'Admission Letter Printing Guidance',
      'Original Result Printing Guidance',
      'CAPS Guidance',
    ],
  ),
  ServiceSection(
    title: 'Admission Support',
    items: ['Post-UTME & Tertiary Institution Application Assistance'],
  ),
  ServiceSection(
    title: 'Final Year Services',
    items: [
      'Project Topic Assistance',
      'Proposal Support',
      'Research Assistance',
      'Data Analysis',
      'Editing Services',
    ],
  ),
];
