import 'package:dharma_app/Profile/profile_setup_controller.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  late final ProfileSetupController _controller;
  final List<Worker> _workers = [];

  String? _gender;
  String? _day;
  String? _month;
  String? _year;

  static const List<String> _days = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _years = [
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        Get.isRegistered<ProfileSetupController>()
            ? Get.find<ProfileSetupController>()
            : Get.put(ProfileSetupController());

    _workers.addAll([
      ever<String>(_controller.fullName, (value) {
        if (_nameController.text != value) {
          _nameController.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
      }),
      ever<String>(_controller.currentLocation, (value) {
        if (_locationController.text != value) {
          _locationController.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
      }),
      ever<String>(_controller.birthPlace, (value) {
        if (_birthPlaceController.text != value) {
          _birthPlaceController.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
      }),
      ever<String?>(_controller.gender, (value) {
        if (mounted) {
          setState(() => _gender = value);
        }
      }),
      ever<String?>(_controller.day, (value) {
        if (mounted) {
          setState(() => _day = value);
        }
      }),
      ever<String?>(_controller.month, (value) {
        if (mounted) {
          setState(() => _month = value);
        }
      }),
      ever<String?>(_controller.year, (value) {
        if (mounted) {
          setState(() => _year = value);
        }
      }),
    ]);
  }

  @override
  void dispose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    _nameController.dispose();
    _locationController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homeBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Obx(
          () => Stack(
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: mediaQuery.size.width * 0.12,
                      right: mediaQuery.size.width * 0.12,
                      bottom: 18 * scale,
                      child: IgnorePointer(
                        child: Container(
                          height: 220 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.homeGoldDark.withOpacity(0.16),
                              width: 1.6,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 180 * scale,
                              height: 180 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.homeGoldDark.withOpacity(
                                    0.12,
                                  ),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        22 * scale,
                        12 * scale,
                        22 * scale,
                        28 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28 * scale),
                          Text(
                            'Set Up Your Profile',
                            style: TextStyle(
                              fontSize: 26 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 22 * scale),
                          Text(
                            'Birth Details (Nakshatra, Date, Time)',
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 14 * scale),
                          _buildInputField(
                            controller: _nameController,
                            hint: 'Full Name',
                            scale: scale,
                            onChanged: _controller.updateFullName,
                          ),
                          SizedBox(height: 18 * scale),
                          _buildInputField(
                            controller: _locationController,
                            hint: 'Current Location',
                            scale: scale,
                            onChanged: _controller.updateCurrentLocation,
                          ),
                          SizedBox(height: 24 * scale),
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          Row(
                            children: [
                              Expanded(
                                child: _GenderChip(
                                  label: 'Male',
                                  icon: Icons.male,
                                  selected: _gender == 'Male',
                                  scale: scale,
                                  onTap: () => setState(() {
                                    _gender = 'Male';
                                    _controller.updateGender(_gender);
                                  }),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: _GenderChip(
                                  label: 'Female',
                                  icon: Icons.female,
                                  selected: _gender == 'Female',
                                  scale: scale,
                                  onTap: () => setState(() {
                                    _gender = 'Female';
                                    _controller.updateGender(_gender);
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24 * scale),
                          Text(
                            'Birth Date',
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          _buildDateSection(scale),
                          SizedBox(height: 24 * scale),
                          Text(
                            'Place of Birth',
                            style: TextStyle(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          _buildInputField(
                            controller: _birthPlaceController,
                            hint: 'Enter Place Name...',
                            scale: scale,
                            onChanged: _controller.updateBirthPlace,
                          ),
                          SizedBox(height: 34 * scale),
                          Center(
                            child: SizedBox(
                              width: mediaQuery.size.width * 0.68,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.homePrimary,
                                  foregroundColor: AppColors.white,
                                  elevation: 2,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 13 * scale,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      30 * scale,
                                    ),
                                  ),
                                ),
                                onPressed: _onContinuePressed,
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 150 * scale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.isLoading)
                AppLoader(message: _controller.loadingMessage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required double scale,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: _fieldDecoration(scale),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black54,
            fontSize: 14 * scale,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 16 * scale,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _onContinuePressed() {
    FocusScope.of(context).unfocus();
    _controller
      ..updateFullName(_nameController.text)
      ..updateCurrentLocation(_locationController.text)
      ..updateBirthPlace(_birthPlaceController.text)
      ..updateGender(_gender)
      ..updateDay(_day)
      ..updateMonth(_month)
      ..updateYear(_year);
    _controller.saveProfile();
  }

  BoxDecoration _fieldDecoration(double scale) {
    return BoxDecoration(
      color: AppColors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(16 * scale),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildDateSection(double scale) {
    return Row(
      children: [
        Expanded(
          child: _DateTile(
            value: _day,
            items: _days,
            hint: 'Day',
            scale: scale,
            onChanged: (value) => setState(() {
              _day = value!;
              _controller.updateDay(_day);
            }),
          ),
        ),
        SizedBox(width: 10 * scale),
        Expanded(
          flex: 2,
          child: _DateTile(
            value: _month,
            items: _months,
            hint: 'Month',
            scale: scale,
            onChanged: (value) => setState(() {
              _month = value!;
              _controller.updateMonth(_month);
            }),
          ),
        ),
        SizedBox(width: 10 * scale),
        Expanded(
          child: _DateTile(
            value: _year,
            items: _years,
            hint: 'Year',
            scale: scale,
            onChanged: (value) => setState(() {
              _year = value!;
              _controller.updateYear(_year);
            }),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 14 * scale,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.homePrimary.withOpacity(0.08)
              : AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: selected ? AppColors.homePrimary : Colors.transparent,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.homePrimary.withOpacity(0.16)
                  : const Color(0x18000000),
              blurRadius: selected ? 18 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28 * scale,
              color: selected ? AppColors.homePrimary : Colors.black54,
            ),
            SizedBox(width: 12 * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * scale,
                color: selected ? AppColors.homePrimary : Colors.black87,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.value,
    required this.items,
    required this.hint,
    required this.scale,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final String hint;
  final double scale;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.homeGoldDark.withOpacity(0.18),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.homePrimary,
            size: 20 * scale,
          ),
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
