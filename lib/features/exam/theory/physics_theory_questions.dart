import 'theory_questions.dart';

/// Hand-authored WAEC-style Physics theory (Paper 2) questions. Follows the
/// same shape as the Mathematics/English banks in `theory_questions.dart`,
/// but lives in its own file so it can be merged into
/// `_theoryQuestionBanks` independently.
const List<TheoryQuestion> physicsTheoryQuestions = [
  TheoryQuestion(
    topic: 'Equations of Motion',
    question: 'A car starts from rest and accelerates uniformly at 4 m/s² for 5 seconds. Calculate the '
        'distance covered by the car during this time.',
  ),
  TheoryQuestion(
    topic: 'Projectile Motion',
    question: 'A ball is kicked horizontally with a velocity of 20 m/s from the top of a cliff 20 m high. '
        'Taking g = 10 m/s², calculate the horizontal distance from the base of the cliff at which the '
        'ball lands.',
  ),
  TheoryQuestion(
    topic: 'Conservation of Momentum',
    question: 'A trolley of mass 2 kg moving at 3 m/s collides with a stationary trolley of mass 1 kg and '
        'the two move off together after collision. Calculate their common velocity immediately after '
        'the collision.',
  ),
  TheoryQuestion(
    topic: "Newton's Second Law",
    question: 'A car of mass 1000 kg accelerates uniformly from rest to a velocity of 20 m/s in 10 '
        'seconds. Calculate the net force acting on the car.',
  ),
  TheoryQuestion(
    topic: 'Moments and Equilibrium',
    question: 'A uniform plank AB of length 6 m and weight 100 N rests horizontally on two supports '
        'placed at its two ends A and B. A load of 40 N is placed on the plank 2 m from end A. Calculate '
        'the reaction at each support.',
  ),
  TheoryQuestion(
    topic: 'Centre of Gravity',
    question: 'Describe, with the aid of a diagram, an experiment to determine the centre of gravity of '
        'an irregularly shaped lamina using a plumb line.',
  ),
  TheoryQuestion(
    topic: 'Work Done',
    question: 'A load of mass 50 kg is lifted vertically through a height of 3 m. Taking g = 10 m/s², '
        'calculate the work done in lifting the load.',
  ),
  TheoryQuestion(
    topic: 'Power',
    question: 'An electric motor raises a mass of 200 kg through a vertical height of 10 m in 20 seconds. '
        'Taking g = 10 m/s², calculate the power output of the motor.',
  ),
  TheoryQuestion(
    topic: 'Efficiency of Machines',
    question: 'An inclined plane 5 m long and 1 m high is used to raise a load of 200 N by applying an '
        'effort of 60 N along the plane. Calculate the efficiency of the machine.',
  ),
  TheoryQuestion(
    topic: 'Velocity Ratio of a Pulley System',
    question: 'In a pulley system, the effort moves a distance of 12 m while the load moves a distance of '
        '3 m. Calculate the velocity ratio of the pulley system.',
  ),
  TheoryQuestion(
    topic: "Young's Modulus",
    question: 'A wire of length 2 m and cross-sectional area 0.5 mm² extends by 1 mm when a load of 50 N '
        'is applied to it. Calculate the Young\'s modulus of the material of the wire.',
  ),
  TheoryQuestion(
    topic: "Hooke's Law",
    question: 'A spring extends by 4 cm when a load of 2 N is hung on it. Assuming the elastic limit is '
        'not exceeded, calculate the extension produced when a load of 5 N is hung on the same spring.',
  ),
  TheoryQuestion(
    topic: "Archimedes' Principle",
    question: 'A solid weighs 50 N in air and 30 N when fully immersed in water. Calculate the relative '
        'density of the solid.',
  ),
  TheoryQuestion(
    topic: 'Density of a Floating Body',
    question: 'A block of wood floats in water with three-quarters of its volume submerged. If the '
        'density of water is 1000 kg/m³, calculate the density of the wood.',
  ),
  TheoryQuestion(
    topic: 'Specific Heat Capacity (Method of Mixtures)',
    question: 'A metal block of mass 200 g at 100°C is dropped into 150 g of water at 25°C contained in '
        'a calorimeter of negligible heat capacity. If the final steady temperature is 30°C and the '
        'specific heat capacity of water is 4200 J/kg K, calculate the specific heat capacity of the '
        'metal.',
  ),
  TheoryQuestion(
    topic: 'Linear Expansivity',
    question: 'A metal rod of length 2 m at 20°C is heated until its length becomes 2.0024 m at 120°C. '
        'Calculate the linear expansivity of the metal.',
  ),
  TheoryQuestion(
    topic: 'Specific Latent Heat of Fusion',
    question: 'Describe an experiment, using the method of mixtures, to determine the specific latent '
        'heat of fusion of ice.',
  ),
  TheoryQuestion(
    topic: "Boyle's Law",
    question: 'A fixed mass of gas occupies a volume of 300 cm³ at a pressure of 100 kPa. Calculate the '
        'new volume of the gas when it is compressed, at constant temperature, to a pressure of 150 kPa.',
  ),
  TheoryQuestion(
    topic: 'Mirror Formula',
    question: 'A concave mirror has a focal length of 15 cm. An object is placed 20 cm in front of the '
        'mirror. Calculate the image distance from the mirror.',
  ),
  TheoryQuestion(
    topic: 'Lens Formula',
    question: 'A convex lens of focal length 10 cm forms an image of an object placed 15 cm from the '
        'lens. Calculate the distance of the image from the lens.',
  ),
  TheoryQuestion(
    topic: 'Refractive Index (Real and Apparent Depth)',
    question: 'A swimming pool appears to be 2.25 m deep when its real depth is 3 m. Calculate the '
        'refractive index of water.',
  ),
  TheoryQuestion(
    topic: 'Critical Angle and Total Internal Reflection',
    question: 'The refractive index of glass is 1.5. Calculate the critical angle for the glass-air '
        'boundary.',
  ),
  TheoryQuestion(
    topic: 'Focal Length of a Convex Lens',
    question: 'Describe an experiment to determine the focal length of a convex lens using the '
        'no-parallax (plane mirror) method.',
  ),
  TheoryQuestion(
    topic: 'Resonance in a Closed Pipe',
    question: 'A closed pipe resonates with a tuning fork of frequency 300 Hz at its shortest resonating '
        'air column length. If the speed of sound in air is 330 m/s, calculate the shortest length of '
        'the air column.',
  ),
  TheoryQuestion(
    topic: 'Speed of Sound (Echo Method)',
    question: 'A person standing 99 m from a cliff claps and hears the echo 0.6 seconds later. Calculate '
        'the speed of sound in air.',
  ),
  TheoryQuestion(
    topic: "Ohm's Law",
    question: 'A resistor is connected across a 12 V battery and a current of 2 A flows through it. '
        'Calculate the resistance of the resistor.',
  ),
  TheoryQuestion(
    topic: 'Resistors in Series and Parallel',
    question: 'A 4 Ω resistor and a 6 Ω resistor are connected in parallel, and this combination is '
        'connected in series with a 3 Ω resistor across a 12 V battery. Calculate the total current '
        'drawn from the battery.',
  ),
  TheoryQuestion(
    topic: 'Cost of Electrical Energy',
    question: 'An electric heater rated 2000 W is used for 5 hours daily for 30 days. If electrical '
        'energy costs ₦209 per kWh, calculate the total cost of running the heater for the 30 days.',
  ),
  TheoryQuestion(
    topic: 'EMF and Internal Resistance',
    question: 'A cell of EMF 6 V and internal resistance 0.5 Ω is connected to an external resistor of '
        '2.5 Ω. Calculate the current flowing in the circuit.',
  ),
  TheoryQuestion(
    topic: 'Electromagnetic Induction',
    question: 'Describe an experiment to demonstrate electromagnetic induction using a bar magnet, a coil '
        'of wire and a galvanometer, and state two factors that affect the magnitude of the induced emf.',
  ),
  TheoryQuestion(
    topic: 'Transformers',
    question: 'A step-down transformer has 1000 turns on its primary coil and is connected to a 240 V '
        'supply. If the secondary voltage is 12 V, calculate the number of turns on the secondary coil.',
  ),
  TheoryQuestion(
    topic: 'Half-Life Calculation',
    question: 'A radioactive sample has a half-life of 8 days and an initial mass of 80 g. Calculate the '
        'mass of the sample remaining after 24 days.',
  ),
  TheoryQuestion(
    topic: 'Photoelectric Effect',
    question: 'Explain what is meant by the photoelectric effect, and state two factors that affect the '
        'kinetic energy of the photoelectrons emitted from a metal surface.',
  ),
  TheoryQuestion(
    topic: 'Mass Defect and Nuclear Energy',
    question: 'During a nuclear reaction, a mass defect of 0.02 atomic mass units (u) is released as '
        'energy. If 1 u is equivalent to 931 MeV, calculate the energy released in MeV.',
  ),
  TheoryQuestion(
    topic: 'Wave Speed and Wavelength',
    question: 'A wave travels with a speed of 340 m/s and a frequency of 200 Hz. Calculate the wavelength '
        'of the wave.',
  ),
  TheoryQuestion(
    topic: 'Charging by Induction',
    question: 'Describe, with the aid of diagrams, how a metal sphere may be charged negatively by '
        'induction using a negatively charged rod.',
  ),
  TheoryQuestion(
    topic: 'Capacitance of a Capacitor',
    question: 'A parallel-plate capacitor stores a charge of 2 × 10⁻³ C when a potential difference of '
        '100 V is applied across it. Calculate the capacitance of the capacitor.',
  ),
  TheoryQuestion(
    topic: 'Resolution of Forces',
    question: 'A force of 50 N acts at an angle of 30° to the horizontal. Calculate the horizontal '
        'component of the force.',
  ),
  TheoryQuestion(
    topic: 'Coefficient of Friction',
    question: 'A block of mass 5 kg resting on a horizontal surface just begins to slide when a '
        'horizontal force of 15 N is applied to it. Taking g = 10 m/s², calculate the coefficient of '
        'static friction between the block and the surface.',
  ),
  TheoryQuestion(
    topic: 'Circular Motion',
    question: 'A mass of 0.5 kg tied to a string moves in a horizontal circle of radius 0.4 m at a '
        'constant speed of 2 m/s. Calculate the centripetal force acting on the mass.',
  ),
  TheoryQuestion(
    topic: 'Pressure in Liquids',
    question: 'Calculate the pressure exerted at a depth of 5 m below the surface of water of density '
        '1000 kg/m³. Take g = 10 m/s².',
  ),
  TheoryQuestion(
    topic: 'Simple Pendulum Experiment',
    question: 'Describe an experiment to determine the acceleration due to gravity using a simple '
        'pendulum, stating the measurements taken and how the result is calculated.',
  ),
  TheoryQuestion(
    topic: 'Heat Conduction',
    question: 'A metal rod of length 0.5 m and cross-sectional area 2 × 10⁻⁴ m² has a temperature '
        'difference of 50°C between its ends. If the thermal conductivity of the metal is 400 W/mK, '
        'calculate the rate at which heat flows along the rod.',
  ),
  TheoryQuestion(
    topic: 'Magnetic Field Patterns',
    question: 'Describe an experiment, using a plotting compass, to determine the pattern of the magnetic '
        'field around a bar magnet.',
  ),
  TheoryQuestion(
    topic: "Young's Double-Slit Experiment",
    question: 'In a double-slit experiment, the slits are 0.5 mm apart and the screen is placed 1 m from '
        'the slits. If the fringe spacing observed on the screen is 1.2 mm, calculate the wavelength of '
        'the light used.',
  ),
  TheoryQuestion(
    topic: 'Electromagnetic Spectrum',
    question: 'Describe the electromagnetic spectrum, arranging its components in order of increasing '
        'wavelength, and state one use of any two of the components.',
  ),
  TheoryQuestion(
    topic: 'Kinetic Theory of Gases',
    question: 'Explain, using the kinetic theory of gases, how the pressure exerted by a gas on the walls '
        'of its container arises.',
  ),
  TheoryQuestion(
    topic: 'Strength of a Solenoid',
    question: 'State and explain three ways by which the strength of the magnetic field produced by a '
        'current-carrying solenoid can be increased.',
  ),
  TheoryQuestion(
    topic: 'Nuclear Fission and Fusion',
    question: 'Explain the difference between nuclear fission and nuclear fusion, giving one example of '
        'each process.',
  ),
  TheoryQuestion(
    topic: 'The Doppler Effect',
    question: 'Explain what is meant by the Doppler effect and state one practical application of the '
        'effect.',
  ),
];
