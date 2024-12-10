import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer/pedometer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginSignupScreen(),
      routes: {
          '/signup': (context) => const SignupScreen(),
             '/homepage': (context) => const homepg(),
                 '/account': (context) => const AccountPage(firstName: "firstName", lastName: "lastName", email: "email", age: "age", weight: "weight", height: "height", gender: "gender", activityLevel: "activityLevel"),
      },
    );
  }
}

class LoginSignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    LoginSignupScreen({super.key});

    @override
    Widget build(BuildContext context) {
       return Scaffold(
          body: Stack(
             children: [
                    const Background(),
                    Center(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white12,
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        loginUser(
                          context,
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  String selectedGender = 'Male';
  String selectedActivityLevel = 'Moderately Active';
  int calculatedAge = 0;

  final List<String> genders = ['Male', 'Female'];
  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildTextField(firstNameController, 'First Name'),
                const SizedBox(height: 16),
                _buildTextField(lastNameController, 'Last Name'),
                const SizedBox(height: 16),
                _buildTextField(emailController, 'Email', TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(passwordController, 'Password', null, true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth (MM/DD/YYYY)',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              dobController.text = "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                              calculatedAge = _calculateAge(pickedDate);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Age: $calculatedAge",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(weightController, 'Weight (kg)', TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(heightController, 'Height (cm)', TextInputType.number),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  items: genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedActivityLevel,
                  items: activityLevels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedActivityLevel = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    labelText: 'Activity Level',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    signUpUser(
                      context,
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      firstNameController.text.trim(),
                      lastNameController.text.trim(),
                      calculatedAge,
                      double.tryParse(weightController.text.trim()) ?? 0.0,
                      double.tryParse(heightController.text.trim()) ?? 0.0,
                      selectedGender,
                      selectedActivityLevel,
                    );
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? type, bool isPassword = false]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: type,
      obscureText: isPassword,
    );
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

Future<void> signUpUser(
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
    int age,
    double weight,
    double height,
    String gender,
    String activityLevel,
    ) async {

    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
    });

    Navigator.pushNamed(context, '/homepage');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User registered successfully!")));
  }


Future<void> loginUser(BuildContext context, String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.pushNamed(context, '/homepage');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged in successfully!")),
    );
  } catch (e) {
    if (e is FirebaseAuthException) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        default:
          errorMessage = "An unexpected error occurred. Please try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
      print("Error logging in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }
}

class AccountPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String age;
  final String weight;
  final String height;
  final String gender;
  final String activityLevel;

  const AccountPage({super.key, 
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
  });

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late String _selectedGender;
  late String _selectedActivityLevel;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _ageController = TextEditingController(text: widget.age);
    _weightController = TextEditingController(text: widget.weight);
    _heightController = TextEditingController(text: widget.height);
    _selectedGender = widget.gender;
    _selectedActivityLevel = widget.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Account Info'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("First Name", _firstNameController),
              _buildTextField("Last Name", _lastNameController),
              _buildTextField("Email", _emailController),
              _buildTextField("Age", _ageController),
              _buildTextField("Weight (kg)", _weightController),
              _buildTextField("Height (cm)", _heightController),
              _buildDropdown("Gender", ["Male", "Female"], _selectedGender, (newValue) {
                setState(() {
                  _selectedGender = newValue ?? _selectedGender;
                });
              }),
              _buildDropdown("Activity Level", ["Low", "Moderate", "High", "Very High"], _selectedActivityLevel, (newValue) {
                setState(() {
                  _selectedActivityLevel = newValue ?? _selectedActivityLevel;
                });
              }),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateUserInfo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedItem,
            dropdownColor: Colors.black,
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _updateUserInfo() {
    print("User information updated");
    print("First Name: ${_firstNameController.text}");
    print("Last Name: ${_lastNameController.text}");
    print("Email: ${_emailController.text}");
    print("Age: ${_ageController.text}");
    print("Weight: ${_weightController.text}");
    print("Height: ${_heightController.text}");
    print("Gender: $_selectedGender");
    print("Activity Level: $_selectedActivityLevel");
  }
}
//class StepTracker extends StatefulWidget {
 // @override
  //_StepTrackerState createState() => _StepTrackerState();
//}
//class _StepTrackerState extends State<StepTracker> {
 // String _stepCountValue = '0';
  //late Stream<StepCount> _stepCountStream;
  //@override
  //void initState() {
   // super.initState();
    //startStepTracking();
 // }
  //void startStepTracking() {
   // try {
      //_stepCountStream = Pedometer.stepCountStream;
      //stepCountStream.listen(onStepCount).onError(onError);
    //} catch (e) {
     // print('Error starting pedometer: $e');
    //}
 // }
  //void onStepCount(StepCount event) {
   // setState(() {
    //  _stepCountValue = event.steps.toString();
   // });

class homepg extends StatefulWidget {
  const homepg({super.key});

  @override
  homepgstate createState() => homepgstate();
}

class homepgstate extends State<homepg> with SingleTickerProviderStateMixin {
  double? bmi;
  int waterIntake = 0;
  int steps = 0;
  int calorieLimit = 2000;
  int consumedCalories = 0;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchUserDataAndCalculateBMI();
//animeation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
//+water
  void incrementWater() {
    setState(() {
      if (waterIntake < 16) {
        waterIntake++;
        _animateProgress();
      }
    });
  }
//-water
  void decrementWater() {
    setState(() {
      if (waterIntake > 0) {
        waterIntake--;
        _animateProgress();
      }
    });
  }

  void _animateProgress() {
    double progress = waterIntake / 16.0;
    _animationController.animateTo(progress);
  }
//firebase
  Future<void> fetchUserDataAndCalculateBMI() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        double weight = userDoc['weight'] ?? 0.0;
        double height = userDoc['height'] ?? 0.0;
        height = height / 100;
        double calculatedBMI = weight / (height * height);
        setState(() {
          bmi = calculatedBMI;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double calorieProgress = consumedCalories / calorieLimit;

    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Positioned(
            top: 500,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: _animationController.value,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                              strokeWidth: 10.0,
                            ),
                          ),
                          Text(
                            '$waterIntake / 16',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text(
                            'Water Intake (Cups)',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.red),
                                onPressed: decrementWater,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: incrementWater,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),//voiding out for the final presentaion, after chagne teh bxo color to view inforamtion
                  //  and Calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox('Calories Left', '${calorieLimit - consumedCalories}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    bmi == null
                        ? 'Calculating BMI...'
                        : 'Your BMI: ${bmi!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 0),
                      Text(
                        'Select a Muscle group to view exercises',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/muscle1.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only (bottom: 160, left: 210),
                    child: SizedBox(
                      width: 60,
                      height: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Back"),
                              //back
                            ),
                          );
                        },
                        child: const Text(" "),//back
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 190, right: 190),
                    child: SizedBox(
                      width: 50,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Chest"),
                            ),
                          );
                        },
                        child: const Text(" "),//chest
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100, right: 190),
                    child: SizedBox(
                      width: 50,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: " Abs"),//abs
                            ),
                          );
                        },
                        child: const Text(" "),//abs
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100, right: 190),
                    child: SizedBox(
                      width: 50,
                      height: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Legs"),
                            ),
                          );
                        },
                        child: const Text(" "),//legs
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150, left: 120),
                    child: SizedBox(
                      width: 10,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Triceps"),
                            ),
                          );
                        },
                        child: const Text(" "),//Right tris
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150, right: 100),
                    child: SizedBox(
                      width: 10,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Biceps"),
                            ),
                          );
                        },
                        child: const Text(""),//left bi
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150, right: 270),
                    child: SizedBox(
                      width: 10,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Biceps"),
                            ),
                          );
                        },
                        child: const Text(""),//Right bi
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150, left: 300),
                    child: SizedBox(
                      width: 10,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Tricep"),
                            ),
                          );
                        },
                        child: const Text(" "),//Right Tri
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100, left: 210),
                    child: SizedBox(
                      width: 50,
                      height: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Legs"),
                            ),
                          );
                        },
                        child: const Text(" "),//Back leg
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, left: 320),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Forearms"),
                            ),
                          );
                        },
                        child: const Text(" "),//right forearm-pic2
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60, left: 100),
              child: SizedBox(
                width: 20,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,

                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MuscleVideosPage(muscleGroup: "Forearms"),
                      ),
                    );
                  },
                  child: const Text(""),//left forearm-pic2
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, right: 290),
                    child: SizedBox(
                      width: 20,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Forearms"),
                            ),
                          );
                        },
                        child: const Text(" "),//left forearm-pic 1
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70, right: 70),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Forearms"),
                            ),
                          );
                        },
                        child: const Text(" "),//right forearm-pic1
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 210, left: 300),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Shoulders"),
                            ),
                          );
                        },
                        child: const Text(" "),//Shoulders right - pic 2
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 210, left: 120),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Shoulders"),
                            ),
                          );
                        },
                        child: const Text(" "),//Shoulders left - pic 2
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 210, right: 270),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Shoulders"),
                            ),
                          );
                        },
                        child: const Text(" "),//Shoulders left - pic 1
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 210, right: 120),
                    child: SizedBox(
                      width: 20,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MuscleVideosPage(muscleGroup: "Shoulders"),
                            ),
                          );
                        },
                        child: const Text(" "),//Shoulders right - pic 1
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              iconSize: 32.0,
              onPressed: () {
                Navigator.pushNamed(context, '/liked');
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              iconSize: 32.0,
              onPressed: () {
                Navigator.pushNamed(context, '/account');
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Plus button pressed");
        },
        backgroundColor: Colors.white.withOpacity(0.8),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Column(
      children: [
      Text(
      title,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
    const SizedBox(height: 8),
    Text(
    value,
    style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class MuscleVideosPage extends StatelessWidget {
  final String muscleGroup;

  const MuscleVideosPage({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> muscleImages = {
      "Back": "assets/back.png",
      "Chest": "assets/chest.png",
      "Abs": "assets/abs.png",
      "Legs": "assets/legs.png",
      "Triceps": "assets/triceps.png",
      "Biceps": "assets/biceps.png",
      "Forearms": "assets/forearms.png",
      "Shoulders": "assets/shoulders.png",
    };

    String? imagePath = muscleImages[muscleGroup];

    return Scaffold(
      appBar: AppBar(
        title: Text(muscleGroup),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                height: 200,
                width: 1000,
                fit: BoxFit.cover,
              )
            else
              const Text(
                "No Image Available",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            const SizedBox(height: 20),
            Text(
              '$muscleGroup Exercises',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

    class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: XPainter(),
      ),
    );
  }
}

class XPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 10;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}