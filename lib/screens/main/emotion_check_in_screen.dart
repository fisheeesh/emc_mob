import 'package:emc_mob/components/buttons/custom_elevated_button.dart';
import 'package:emc_mob/providers/check_in_provider.dart';
import 'package:emc_mob/providers/emotion_provider.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/screens/main/check_in_success_screen.dart';
import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:emc_mob/utils/constants/text_strings.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:emc_mob/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmotionCheckInScreen extends StatefulWidget {
  final String userName;

  const EmotionCheckInScreen({
    super.key,
    required this.userName,
  });

  @override
  State<EmotionCheckInScreen> createState() => _EmotionCheckInScreenState();
}

class _EmotionCheckInScreenState extends State<EmotionCheckInScreen> {
  /// Tracks the selected tab (0: Negative, 1: Neutral, 2: Positive)
  int _selectedTabIndex = 1;

  /// Tracks the selected emotion (only one can be selected)
  String? _selectedEmotion;

  String? _selectedLabel;
  final TextEditingController _feelingController = TextEditingController();

  bool isLoading = false;

  static const int _maxCharacters = 100;
  int _currentCharacterCount = 0;

  @override
  void initState() {
    super.initState();
    _feelingController.addListener(_updateCharacterCount);
    _loadEmotions();
  }

  /// Load emotions instantly from cache/fallback and sync in background
  Future<void> _loadEmotions() async {
    final emotionProvider = context.read<EmotionProvider>();
    final loginProvider = context.read<LoginProvider>();

    // Load instantly from cache/fallback (no delay)
    await emotionProvider.loadEmotions();

    // Sync in background if user is logged in
    if (loginProvider.accessToken != null) {
      emotionProvider.syncInBackground(loginProvider.accessToken);
    }
  }

  @override
  void dispose() {
    _feelingController.removeListener(_updateCharacterCount);
    _feelingController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _currentCharacterCount = _feelingController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    double topPadding = MediaQuery.of(context).size.height *
        (EHelperFunctions.isIOS() ? 0.07 : 0.05);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: ESizes.md,
              right: ESizes.md,
              top: topPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// header section
                _headerSection(context),
                const SizedBox(height: 15),

                /// Tab Bar and Emoji Grid
                Container(
                  padding: const EdgeInsets.all(ESizes.md),
                  decoration: BoxDecoration(
                    color: EColors.white,
                    borderRadius: BorderRadius.circular(ESizes.roundedSm),
                    boxShadow: [
                      BoxShadow(
                        color: EColors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _tabBarSection(emotionProvider),
                      ),
                      const SizedBox(height: 20),
                      // Emoji Grid
                      _emojiGridSection(emotionProvider),
                    ],
                  ),
                ),
                SizedBox(height: EHelperFunctions.isIOS() ? 25 : 22),

                /// Feeling Text Field
                _feelingTextField(),

                SizedBox(height: EHelperFunctions.isIOS() ? 25 : 22),

                /// submit button
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Feeling Text Field with Character Counter
  Widget _feelingTextField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ESizes.roundedSm),
        boxShadow: [
          BoxShadow(
            color: EColors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _feelingController,
            cursorColor: EColors.grey,
            maxLines: 4,
            maxLength: _maxCharacters,
            decoration: InputDecoration(
              hintText: ETexts.HINT,
              counterText: '',
              hintStyle: GoogleFonts.lexend(
                textStyle: const TextStyle(color: EColors.grey, fontSize: 16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ESizes.roundedXs),
                borderSide: const BorderSide(color: EColors.lightBlue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ESizes.roundedXs),
                borderSide: const BorderSide(color: EColors.lightBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 5),

          /// Real-time Character Counter
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$_currentCharacterCount/$_maxCharacters",
              style: TextStyle(
                color: _currentCharacterCount >= 90
                    ? EColors.danger
                    : EColors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomElevatedButton(
      onPressed: _selectedEmotion != null && !isLoading
          ? () async {
        setState(() => isLoading = true);

        var isSuccess = await context.read<CheckInProvider>().sendCheckIn(
          context,
          _selectedEmotion!,
          _selectedLabel!,
          _feelingController.text,
        );

        setState(() => isLoading = false);

        if (isSuccess) {
          EHelperFunctions.navigateToScreen(
            context,
            CheckInSuccessScreen(
              userName: widget.userName,
              checkInTime: DateTime.now(),
              emoji: _selectedEmotion!,
              label: _selectedLabel!,
              feeling: _feelingController.text,
            ),
          );
        }
      }
          : null,
      placeholder: isLoading
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            ETexts.SUBMITTING,
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: EColors.white,
              ),
            ),
          ),
        ],
      )
          : Text(
        ETexts.SUBMIT,
        style: GoogleFonts.lexend(
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: EColors.white,
          ),
        ),
      ),
    );
  }

  Row _headerSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        const SizedBox(width: 10),
        Text(
          ETexts.QUES,
          style: ETextTheme.lightTextTheme.headlineMedium,
        )
      ],
    );
  }

  Widget _tabBarSection(EmotionProvider emotionProvider) {
    final categories = emotionProvider.categories;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFFBAD6FE), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          categories.length,
              (index) => _buildTabItem(
            index,
            categories[index].title,
            isFirst: index == 0,
            isLast: index == categories.length - 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      int index,
      String label, {
        bool isFirst = false,
        bool isLast = false,
      }) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _selectedEmotion = null;
            _selectedLabel = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFBAD6FE)
                : const Color(0xFFF7F8F8),
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(20) : Radius.zero,
              right: isLast ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF3085FE)
                    : const Color(0xFF87878B),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emojiGridSection(EmotionProvider emotionProvider) {
    final categories = emotionProvider.categories;

    // Handle empty or invalid state
    if (categories.isEmpty || _selectedTabIndex >= categories.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No emotions available',
            style: TextStyle(color: EColors.grey),
          ),
        ),
      );
    }

    final emotions = categories[_selectedTabIndex].emotions;

    if (emotions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No emotions in this category',
            style: TextStyle(color: EColors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1.1,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        final isSelected = _selectedEmotion == emotion.icon;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLabel = emotion.label;
              _selectedEmotion = emotion.icon;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : EColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? EColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  emotion.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                Text(
                  emotion.label,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}