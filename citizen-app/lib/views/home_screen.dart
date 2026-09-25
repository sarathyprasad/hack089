import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/constants/app_colors.dart';
import 'ai_assistant_dialog.dart';
import '../widgets/citizen_drawer.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/location_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _selectedCategoryFilter = 'All';
  late final PageController _heroPageController;
  Timer? _heroTimer;
  int _currentHeroPage = 0;
  late final AnimationController _subtlePulseController;
  late final Animation<double> _subtlePulseAnimation;

  bool _isAutoSlidePlaying = true;

  // Ultra-Modern Commercial Poster Banners (Matching Image 2 Reference Style)
  final List<Map<String, dynamic>> _heroSlides = [
    {
      'id': 'radar',
      'tag': 'HYPERLOCAL RADAR',
      'tagColor': const Color(0xFF047857),
      'tagBg': const Color(0xFFD1FAE5),
      'title': 'Live Artisan\nRadar',
      'subtitle': '84+ verified tradespeople active across your sector with live GPS',
      'cta': 'Find Workers',
      'ctaIcon': Icons.near_me_rounded,
      'route': '/find-worker',
      'isAiAction': false,
      'assetImage': 'assets/images/banners/radar.jpg',
      'baseColor': const Color(0xFFF0FDF4),
      'cardBorder': const Color(0xFF86EFAC),
      'badgeText': '84+ ON RADAR',
    },
    {
      'id': 'ai_diagnostics',
      'tag': 'PRITHVI VISION AI',
      'tagColor': const Color(0xFF0284C7),
      'tagBg': const Color(0xFFE0F2FE),
      'title': 'Prithvi AI\nDiagnostics',
      'subtitle': 'Snap a photo of tap leaks, geyser issues, sparks, or AC drip for fair rates',
      'cta': 'Scan Problem',
      'ctaIcon': Icons.camera_alt_rounded,
      'isAiAction': true,
      'assetImage': 'assets/images/banners/ai_diagnostics.jpg',
      'baseColor': const Color(0xFFF0F9FF),
      'cardBorder': const Color(0xFF7DD3FC),
      'badgeText': 'PRITHVI AI',
    },
    {
      'id': 'fair_wage',
      'tag': 'STATUTORY CO-OP',
      'tagColor': const Color(0xFFB45309),
      'tagBg': const Color(0xFFFEF3C7),
      'title': '93% Direct\nWorker Wage',
      'subtitle': 'Zero platform middleman cut • 100% transparent statutory tariff',
      'cta': 'View Rates',
      'ctaIcon': Icons.receipt_long_rounded,
      'route': '/rate-card',
      'isAiAction': false,
      'assetImage': 'assets/images/banners/fair_wage.jpg',
      'baseColor': const Color(0xFFFFFBEB),
      'cardBorder': const Color(0xFFFCD34D),
      'badgeText': 'ZERO SURGE',
    },
    {
      'id': 'warranty',
      'tag': 'WORKMANSHIP WARRANTY',
      'tagColor': const Color(0xFF1D4ED8),
      'tagBg': const Color(0xFFDBEAFE),
      'title': '30-Day Free\nRevisit Warranty',
      'subtitle': 'If fault recurs within 30 days, Master Artisan re-dispatched at ₹0 fee',
      'cta': 'Explore Coverage',
      'ctaIcon': Icons.gpp_good_rounded,
      'route': '/services',
      'isAiAction': false,
      'assetImage': 'assets/images/banners/warranty.jpg',
      'baseColor': const Color(0xFFEFF6FF),
      'cardBorder': const Color(0xFF93C5FD),
      'badgeText': '₹0 REVISIT',
    },
    {
      'id': 'otp_security',
      'tag': 'TWO-STAGE SECURITY',
      'tagColor': const Color(0xFF6D28D9),
      'tagBg': const Color(0xFFEDE9FE),
      'title': '2-Stage OTP\nHandshake',
      'subtitle': 'Arrival OTP verifies artisan badge • Completion OTP releases wage safely',
      'cta': 'Security Guide',
      'ctaIcon': Icons.verified_user_rounded,
      'route': '/help',
      'isAiAction': false,
      'assetImage': 'assets/images/banners/otp_security.jpg',
      'baseColor': const Color(0xFFFAF5FF),
      'cardBorder': const Color(0xFFC4B5FD),
      'badgeText': 'ZERO FRAUD',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Modern quick-commerce carousel with adjacent card peek (0.88 viewport)
    _heroPageController = PageController(viewportFraction: 0.88);
    _startHeroAutoSlide();

    // Very gentle subtle micro-pulse animation (2.4s period)
    _subtlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _subtlePulseAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _subtlePulseController, curve: Curves.easeInOut),
    );
  }

  void _startHeroAutoSlide() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (_heroPageController.hasClients) {
        final nextPage = (_currentHeroPage + 1) % _heroSlides.length;
        _heroPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _toggleAutoSlide() {
    setState(() {
      _isAutoSlidePlaying = !_isAutoSlidePlaying;
      if (_isAutoSlidePlaying) {
        _startHeroAutoSlide();
      } else {
        _heroTimer?.cancel();
      }
    });
  }

  void _goToSlide(int index) {
    if (_heroPageController.hasClients) {
      _heroPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevSlide() {
    final prev = (_currentHeroPage - 1 + _heroSlides.length) % _heroSlides.length;
    _goToSlide(prev);
  }

  void _nextSlide() {
    final next = (_currentHeroPage + 1) % _heroSlides.length;
    _goToSlide(next);
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    _subtlePulseController.dispose();
    super.dispose();
  }





  // Realistic photography of authentic tradespeople & home environments (not AI-generated)
  static const List<Map<String, dynamic>> popularServices = [
    {
      'id': 1,
      'title': 'AC Jet Deep Clean & Gas Check',
      'category': 'AC & Cooling',
      'price': 499,
      'duration': '45 mins',
      'rating': 4.9,
      'reviews': '1.2k',
      'tag': 'MOST POPULAR',
      'tagColor': Color(0xFF0284C7),
      'imageUrl': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.ac_unit,
      'description': 'High-pressure foam wash of cooling fins, blower fan disinfection, and compressor pressure audit.',
    },
    {
      'id': 2,
      'title': 'Switchboard & Fuse Diagnostic',
      'category': 'Electrical',
      'price': 149,
      'duration': '30 mins',
      'rating': 4.8,
      'reviews': '2.4k',
      'tag': 'FAIR TARIFF',
      'tagColor': Color(0xFFF59E0B),
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.electrical_services,
      'description': 'Full distribution board testing, loose wire tightening, and tripping MCB inspection.',
    },
    {
      'id': 3,
      'title': 'Sink & Drain Clog Clearance',
      'category': 'Plumbing',
      'price': 249,
      'duration': '40 mins',
      'rating': 4.9,
      'reviews': '980',
      'tag': 'MONSOON ESSENTIAL',
      'tagColor': Color(0xFF0284C7),
      'imageUrl': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.plumbing,
      'description': 'Mechanical snake pipe clearing, sanitary trap descaling, and high-pressure drainage test.',
    },
    {
      'id': 4,
      'title': 'Precision Door Lock & Woodwork',
      'category': 'Carpentry',
      'price': 299,
      'duration': '60 mins',
      'rating': 4.8,
      'reviews': '750',
      'tag': 'VETTED ARTISAN',
      'tagColor': Color(0xFFD97706),
      'imageUrl': 'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.carpenter,
      'description': 'Mortise lock fitting, squeak elimination, door frame alignment, and smooth wood planishing.',
    },
    {
      'id': 5,
      'title': 'Full Home Deep Sanitization',
      'category': 'Deep Clean',
      'price': 899,
      'duration': '120 mins',
      'rating': 5.0,
      'reviews': '1.5k',
      'tag': 'HYGIENE SHIELD',
      'tagColor': Color(0xFF10B981),
      'imageUrl': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.cleaning_services,
      'description': 'Intensive bathroom tile descaling, balcony wash, vacuuming, and organic antibacterial mopping.',
    },
    {
      'id': 6,
      'title': 'Washing Machine Drum Care',
      'category': 'Appliances',
      'price': 299,
      'duration': '45 mins',
      'rating': 4.8,
      'reviews': '640',
      'tag': 'DIAGNOSTIC',
      'tagColor': Color(0xFF8B5CF6),
      'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=600&q=80',
      'fallbackIcon': Icons.local_laundry_service,
      'description': 'Motor balance testing, lint trap descaling, water inlet filter rinse, and bearing check.',
    },
  ];

  static const List<Map<String, dynamic>> serviceCategories = [
    {
      'name': 'Electrical',
      'subtitle': '14 Services',
      'icon': Icons.bolt_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF0284C7),
    },
    {
      'name': 'Plumbing',
      'subtitle': '11 Services',
      'icon': Icons.water_drop_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF0EA5E9),
    },
    {
      'name': 'AC & Cooling',
      'subtitle': '9 Services',
      'icon': Icons.ac_unit_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF38BDF8),
    },
    {
      'name': 'Carpentry',
      'subtitle': '7 Services',
      'icon': Icons.handyman_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFFD97706),
    },
    {
      'name': 'Deep Clean',
      'subtitle': '8 Services',
      'icon': Icons.sanitizer_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF0D9488),
    },
    {
      'name': 'Painting',
      'subtitle': '5 Services',
      'icon': Icons.format_paint_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Appliances',
      'subtitle': '6 Services',
      'icon': Icons.kitchen_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Gardening',
      'subtitle': '4 Services',
      'icon': Icons.park_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1557429287-b2e26467fc2b?auto=format&fit=crop&w=400&q=80',
      'color': Color(0xFF10B981),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final filteredServices = _selectedCategoryFilter == 'All'
        ? popularServices
        : popularServices.where((s) => s['category'] == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: const CitizenDrawer(),
      floatingActionButton: AnimatedBuilder(
        animation: _subtlePulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _subtlePulseAnimation.value,
          child: child,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => AiAssistantSheet.show(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: Text(
            'Prithvi AI',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Sky Blue Theme & Ultra-Modern Interactive Aesthetic Slider
          SliverAppBar(
            expandedHeight: 286,
            pinned: true,
            backgroundColor: AppColors.primary,
            titleSpacing: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Branded Logo Emblem
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/logo-emblem.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Text Branding
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prithvi',
                          style: GoogleFonts.outfit(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fix',
                          style: GoogleFonts.outfit(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFBBF24), // Vibrant Amber gold
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      context.tr('citizenPortal', 'CITIZEN PORTAL'),
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                ),
                tooltip: 'Open Menu',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0C4A6E)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Space for top app bar icons
                      const SizedBox(height: 52),

                      // Interactive Modern Hero Slide Card
                      Expanded(
                        child: PageView.builder(
                          controller: _heroPageController,
                          itemCount: _heroSlides.length,
                          onPageChanged: (idx) {
                            setState(() {
                              _currentHeroPage = idx;
                            });
                          },
                          itemBuilder: (context, index) {
                            final slide = _heroSlides[index];
                            final isAiAction = slide['isAiAction'] == true;
                            final cta = slide['cta'] as String;
                            final ctaIcon = (slide['ctaIcon'] as IconData?) ?? Icons.arrow_forward_rounded;
                            final tag = slide['tag'] as String;
                            final tagColor = (slide['tagColor'] as Color?) ?? const Color(0xFF047857);
                            final tagBg = (slide['tagBg'] as Color?) ?? const Color(0xFFD1FAE5);
                            final title = slide['title'] as String;
                            final subtitle = slide['subtitle'] as String;
                            final assetImage = slide['assetImage'] as String;
                            final baseColor = (slide['baseColor'] as Color?) ?? const Color(0xFFF8FAFC);
                            final cardBorder = (slide['cardBorder'] as Color?) ?? const Color(0xFFE2E8F0);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                elevation: 5,
                                shadowColor: Colors.black.withValues(alpha: 0.18),
                                child: InkWell(
                                  onTap: () {
                                    if (isAiAction) {
                                      AiAssistantSheet.show(context);
                                    } else if (slide['route'] != null) {
                                      context.push(slide['route'] as String);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: baseColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: cardBorder.withValues(alpha: 0.65),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(19),
                                      child: Stack(
                                        children: [
                                          // 1. Right Side Real Commercial Photo (with reflective table & morning sunlight)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            bottom: 0,
                                            width: 175,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.asset(
                                                  assetImage,
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.center,
                                                  errorBuilder: (ctx, err, stack) => Container(
                                                    color: baseColor,
                                                    child: Icon(Icons.handyman_rounded, size: 40, color: tagColor),
                                                  ),
                                                ),
                                                // Silky smooth horizontal gradient blend so text flows into photo
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                        colors: [
                                                          baseColor,
                                                          baseColor.withValues(alpha: 0.88),
                                                          baseColor.withValues(alpha: 0.20),
                                                          Colors.transparent,
                                                        ],
                                                        stops: const [0.0, 0.22, 0.55, 1.0],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // 2. Left Side Content (Poster Typography matching Image 2 reference)
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(16, 12, 140, 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Category/Tag Pill with live beacon dot
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                    decoration: BoxDecoration(
                                                      color: tagBg,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: tagColor.withValues(alpha: 0.35),
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 5,
                                                          height: 5,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: tagColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          tag,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 8.5,
                                                            fontWeight: FontWeight.w800,
                                                            color: tagColor,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),

                                                  // Bold, High-Contrast Headline (Matching "Hit refresh with your favourites")
                                                  Text(
                                                    title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w900,
                                                      color: const Color(0xFF0F172A),
                                                      letterSpacing: -0.4,
                                                      height: 1.12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3.5),

                                                  // Clear, Readable Subtitle (Matching "Get cold drinks, fruit juices...")
                                                  Text(
                                                    subtitle,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10.5,
                                                      color: const Color(0xFF475569),
                                                      fontWeight: FontWeight.w500,
                                                      height: 1.22,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Solid Black Tactile Pill Button (Matching "Shop now" in Image 2!)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5.5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0F172A),
                                                      borderRadius: BorderRadius.circular(20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.25),
                                                          blurRadius: 5,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          cta,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.w800,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(
                                                          ctaIcon,
                                                          size: 11,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 3. Bottom Interactive Control Bar: Clickable Dots + Unified Controller Pill
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Clickable Smooth Indicator Dots
                            Row(
                              children: List.generate(_heroSlides.length, (i) {
                                final isActive = i == _currentHeroPage;
                                return InkWell(
                                  onTap: () => _goToSlide(i),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: isActive ? 22 : 6,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: Colors.white.withValues(alpha: 0.5),
                                                  blurRadius: 4,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const Spacer(),
                            // Unified Sleek Glass Controller Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _prevSlide,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Icon(Icons.chevron_left_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _toggleAutoSlide,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isAutoSlidePlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                            size: 11,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${_currentHeroPage + 1}/${_heroSlides.length}',
                                            style: GoogleFonts.inter(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _nextSlide,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Builder(
                builder: (ctx) {
                  final localeProvider = ctx.watch<LocaleProvider>();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => showLanguageDialog(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.translate_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                localeProvider.currentLanguageName,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: AppColors.accent, size: 20),
                ),
                onPressed: () => context.push('/rewards'),
                tooltip: 'Coupons & Rewards',
              ),
              if (auth.isAuthenticated)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () => context.push('/my-bookings'),
                  tooltip: 'My Bookings',
                )
              else
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),

          // Location Selector Bar
          const SliverToBoxAdapter(
            child: AnimatedListItem(
              index: 0,
              delay: Duration(milliseconds: 50),
              child: LocationBar(),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: AnimatedListItem(
              index: 0,
              delay: const Duration(milliseconds: 100),
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GestureDetector(
                onTap: () => context.push('/services'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('searchPlaceholder', 'Search electrical, plumbing, AC servicing...'),
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => AiAssistantSheet.show(context, startListening: true),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 18),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.tr('rateCard', 'Rate Card'),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),

          // AI Fault Photo Diagnosis Feature Banner
          SliverToBoxAdapter(
            child: AnimatedListItem(
              index: 1,
              delay: const Duration(milliseconds: 100),
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: InkWell(
                onTap: () => AiAssistantSheet.show(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF7DD3FC)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _subtlePulseAnimation,
                        builder: (ctx, child) => Transform.scale(
                          scale: _subtlePulseAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('prithviAi', 'Prithvi AI Defect Diagnosis'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0369A1),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('prithviAiSub', 'Upload a photo of a tap leak, sparking switch, or AC drip for instant diagnosis & fair repair cost'),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF075985),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0284C7)),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),

          // Service Filter Pills
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterPill(
                    label: context.tr('allServicesOption', 'All Services'),
                    isSelected: _selectedCategoryFilter == 'All',
                    onTap: () => setState(() => _selectedCategoryFilter = 'All'),
                  ),
                  _FilterPill(
                    label: 'AC & Cooling',
                    isSelected: _selectedCategoryFilter == 'AC & Cooling',
                    onTap: () => setState(() => _selectedCategoryFilter = 'AC & Cooling'),
                  ),
                  _FilterPill(
                    label: 'Electrical',
                    isSelected: _selectedCategoryFilter == 'Electrical',
                    onTap: () => setState(() => _selectedCategoryFilter = 'Electrical'),
                  ),
                  _FilterPill(
                    label: 'Plumbing',
                    isSelected: _selectedCategoryFilter == 'Plumbing',
                    onTap: () => setState(() => _selectedCategoryFilter = 'Plumbing'),
                  ),
                  _FilterPill(
                    label: 'Carpentry',
                    isSelected: _selectedCategoryFilter == 'Carpentry',
                    onTap: () => setState(() => _selectedCategoryFilter = 'Carpentry'),
                  ),
                  _FilterPill(
                    label: 'Deep Clean',
                    isSelected: _selectedCategoryFilter == 'Deep Clean',
                    onTap: () => setState(() => _selectedCategoryFilter = 'Deep Clean'),
                  ),
                  _FilterPill(
                    label: 'Appliances',
                    isSelected: _selectedCategoryFilter == 'Appliances',
                    onTap: () => setState(() => _selectedCategoryFilter = 'Appliances'),
                  ),
                ],
              ),
            ),
          ),

          // Section Header: Most Booked Services (with real images)
          SliverToBoxAdapter(
            child: AnimatedListItem(
              index: 2,
              delay: const Duration(milliseconds: 100),
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('popularServices', 'Most Booked Services'),
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Transparent govt rate cards • 30-day warranty',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/services'),
                    child: Text(
                      context.tr('viewAll', 'View All'),
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),

          // Horizontal Most Booked Services Cards
          SliverToBoxAdapter(
            child: SizedBox(
              height: 295,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredServices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return _PopularServiceCard(service: service);
                },
              ),
            ),
          ),

          // Section Header: Explore Service Categories (with real photos)
          SliverToBoxAdapter(
            child: AnimatedListItem(
              index: 3,
              delay: const Duration(milliseconds: 100),
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('categories', 'Explore Service Categories'),
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'NCCT Certified & Police Verified Shramik Artisans',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),

          // Grid of 8 Service Categories with Real Photo Backgrounds & Icons
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = serviceCategories[index];
                  return _CategoryPhotoCard(category: cat);
                },
                childCount: serviceCategories.length,
              ),
            ),
          ),

          // Seasonal & Household Care Packages (Real Photo Banners)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('seasonalPackages', 'Cooperative Seasonal Packages'),
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Subsidized combo packages with direct artisan welfare share',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Seasonal Package 1: Monsoon Weatherproofing & Earthing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _PackageBanner(
                title: 'Monsoon Home Safety & Waterproofing Shield',
                subtitle: 'Roof leak audit + MCB earthing check + P-trap drain clearing',
                price: '₹699',
                originalPrice: '₹950',
                discountTag: 'SAVE 26%',
                badge: 'RAIN & SURGE PROOF',
                imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=600&q=80',
                fallbackIcon: Icons.water_drop,
                onTap: () => context.push('/book-service'),
              ),
            ),
          ),

          // Seasonal Package 2: Senior Citizen Home Care
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _PackageBanner(
                title: 'Senior Citizen Safe Living Inspection',
                subtitle: 'Grab-bar anchoring + anti-skid bathroom check + geyser earthing test',
                price: '₹199',
                originalPrice: '₹499',
                discountTag: '60% OFF',
                badge: 'COOP AID PROGRAM',
                imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=600&q=80',
                fallbackIcon: Icons.elderly,
                onTap: () => context.push('/book-service'),
              ),
            ),
          ),

          // Cooperative 93-2-5 Trust & Guarantee Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '93-2-5 Statutory Fair Model',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Zero corporate middlemen cut. 100% transparent split.',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ModelPill(value: '93%', label: 'Direct to Worker', icon: Icons.person_pin),
                      _ModelPill(value: '2%', label: 'Platform Ops', icon: Icons.hub),
                      _ModelPill(value: '5%', label: 'Welfare & ESIC', icon: Icons.health_and_safety),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/rate-card'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: Text(
                      'View Standardized Rate Card',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGETS & REALISTIC PHOTO RENDERING
// ---------------------------------------------------------------------------

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const _PopularServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final title = service['title'] as String;
    final price = service['price'] as int;
    final duration = service['duration'] as String;
    final rating = service['rating'] as double;
    final reviews = service['reviews'] as String;
    final tag = service['tag'] as String;
    final tagColor = service['tagColor'] as Color;
    final imageUrl = service['imageUrl'] as String;
    final fallbackIcon = service['fallbackIcon'] as IconData;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Realistic Photo with Tag Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: RealisticImage(
                  imageUrl: imageUrl,
                  width: 240,
                  height: 125,
                  fallbackIcon: fallbackIcon,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '$rating ($reviews)',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    Text(
                      '₹$price',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () => context.push('/book-service?serviceId=${service['id']}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      context.tr('btnBookNow', 'Book Service'),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPhotoCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryPhotoCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final name = category['name'] as String;
    final subtitle = category['subtitle'] as String;
    final icon = category['icon'] as IconData;
    final imageUrl = category['imageUrl'] as String;
    final color = category['color'] as Color;

    return GestureDetector(
      onTap: () => context.push('/services'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Background
              RealisticImage(
                imageUrl: imageUrl,
                fallbackIcon: icon,
                fallbackColor: color,
              ),
              // Dark Tint Gradient Overlay for high readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              // Title & Icon
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String originalPrice;
  final String discountTag;
  final String badge;
  final String imageUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _PackageBanner({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
    required this.discountTag,
    required this.badge,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Photo Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: RealisticImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 110,
                    fallbackIcon: fallbackIcon,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discountTag,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        originalPrice,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        price,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ModelPill({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}

/// Fallback-safe realistic image viewer with rounded clipping and clean loading
class RealisticImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const RealisticImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    required this.fallbackIcon,
    this.fallbackColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: (width != null && width!.isFinite && !width!.isNaN) ? (width! * 2).round() : 600,
        cacheHeight: (height != null && height!.isFinite && !height!.isNaN) ? (height! * 2).round() : 400,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.primarySubtle,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  fallbackColor.withValues(alpha: 0.15),
                  fallbackColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(fallbackIcon, size: 28, color: fallbackColor),
          );
        },
      ),
    );
  }
}
