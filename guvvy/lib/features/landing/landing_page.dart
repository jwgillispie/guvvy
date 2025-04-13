import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on screen width
          final isDesktop = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header/Navigation
                _buildHeader(isDesktop),
                
                // Hero section
                _buildHeroSection(isDesktop),
                
                // Features section
                _buildFeaturesSection(isDesktop),
                
                // How it works
                _buildHowItWorksSection(isDesktop),
                
                // Testimonials
                _buildTestimonialsSection(isDesktop),
                
                // Call to action
                _buildCallToActionSection(isDesktop),
                
                // Footer
                _buildFooter(isDesktop),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 16
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: GuvvyTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Guvvy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GuvvyTheme.primary,
                ),
              ),
            ],
          ),
          
          // Navigation links
          if (isDesktop)
            Row(
              children: [
                _buildNavLink('Features'),
                _buildNavLink('How It Works'),
                _buildNavLink('Testimonials'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Scroll to sign up section
                    Scrollable.ensureVisible(
                      _formKey.currentContext ?? context,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GuvvyTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Show mobile menu
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Features'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('How It Works'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Testimonials'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Sign Up'),
                        onTap: () {
                          Navigator.pop(context);
                          // Scroll to sign up section
                          Scrollable.ensureVisible(
                            _formKey.currentContext ?? context,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          // Scroll to section
        },
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: GuvvyTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: isDesktop ? 120 : 60
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GuvvyTheme.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side content
                Expanded(
                  child: _buildHeroContent(),
                ),
                
                // Right side image
                Expanded(
                  child: _buildHeroImage(),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroContent(),
                const SizedBox(height: 40),
                _buildHeroImage(),
              ],
            ),
    );
  }

  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Know Your Representatives',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: GuvvyTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Guvvy connects you with your elected officials at all levels of government. Track their actions, understand their responsibilities, and hold them accountable.',
          style: TextStyle(
            fontSize: 18,
            color: GuvvyTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // Scroll to sign up section
                Scrollable.ensureVisible(
                  _formKey.currentContext ?? context,
                  duration: const Duration(milliseconds: 500),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GuvvyTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Download the App',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                // Scroll to how it works section
              },
              style: TextButton.styleFrom(
                foregroundColor: GuvvyTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Row(
                children: [
                  Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://api.placeholder.com/600/400', // Replace with actual app screenshot
          fit: BoxFit.cover,
          height: 400,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 400,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_android, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Guvvy App Preview',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDesktop) {
    final features = [
      {
        'icon': Icons.location_on,
        'title': 'Find Your Representatives',
        'description': 'Easily discover who represents you at federal, state, and local levels based on your address.'
      },
      {
        'icon': Icons.how_to_vote,
        'title': 'Track Voting Records',
        'description': 'See how your representatives vote on issues that matter to you with detailed voting histories.'
      },
      {
        'icon': Icons.groups,
        'title': 'Committee Insights',
        'description': 'Learn which committees your representatives serve on and understand their influence.'
      },
      {
        'icon': Icons.contact_mail,
        'title': 'Direct Contact',
        'description': 'Seamlessly connect with your representatives through phone, email, or social media.'
      },
      {
        'icon': Icons.school,
        'title': 'Civic Education',
        'description': 'Understand the roles and responsibilities of different government positions.'
      },
      {
        'icon': Icons.notifications,
        'title': 'Vote Alerts',
        'description': 'Receive notifications about upcoming votes and recent activities from your representatives.'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 80
      ),
      child: Column(
        children: [
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Everything You Need to Stay Informed',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Guvvy gives you powerful tools to understand and engage with your government.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              childAspectRatio: isDesktop ? 1.2 : 1.5,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GuvvyTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: GuvvyTheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GuvvyTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isDesktop) {
    final steps = [
      {
        'number': '01',
        'title': 'Enter Your Address',
        'description': 'Simply input your address to discover all your representatives from federal to local levels.',
      },
      {
        'number': '02',
        'title': 'Explore Your Representatives',
        'description': 'Browse detailed profiles including contact information, committee memberships, and voting histories.',
      },
      {
        'number': '03',
        'title': 'Stay Informed',
        'description': 'Save representatives to your list, receive updates on their activities, and learn about their positions.',
      },
      {
        'number': '04',
        'title': 'Take Action',
        'description': 'Easily contact your representatives directly through the app about issues that matter to you.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 80
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simple Steps to Civic Engagement',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((step) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildStep(step),
                    ),
                  )).toList(),
                );
              } else {
                return Column(
                  children: steps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildStep(step),
                  )).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep(Map<String, String> step) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: GuvvyTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step['number']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step['title']!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GuvvyTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          step['description']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection(bool isDesktop) {
    final testimonials = [
      {
        'quote': 'Guvvy helped me understand who represents me and what they actually do. It\'s like having a personal guide to government.',
        'author': 'Sarah J.',
        'location': 'Atlanta, GA',
      },
      {
        'quote': 'I\'ve never been more informed about my local representatives. The voting history feature is a game-changer for accountability.',
        'author': 'Michael T.',
        'location': 'Boston, MA',
      },
      {
        'quote': 'As someone who wants to be civically engaged but was overwhelmed by the process, Guvvy makes it simple and accessible.',
        'author': 'Priya K.',
        'location': 'Denver, CO',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 80
      ),
      child: Column(
        children: [
          const Text(
            'Testimonials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'What Our Users Say',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: testimonials.map((testimonial) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTestimonial(testimonial),
                    ),
                  )).toList(),
                );
              } else {
                return Column(
                  children: testimonials.map((testimonial) => Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildTestimonial(testimonial),
                  )).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonial(Map<String, String> testimonial) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote,
              color: GuvvyTheme.primary,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              testimonial['quote']!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              testimonial['author']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GuvvyTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              testimonial['location']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToActionSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 80
      ),
      color: GuvvyTheme.primary.withOpacity(0.05),
      child: Column(
        children: [
          const Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of citizens taking control of their civic engagement.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : double.infinity,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, 
                        vertical: 16
                      ),
                      suffixIcon: _isSigningUp
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(8),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GuvvyTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24, 
                                  vertical: 16
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Get Early Access',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Download the app to get started. Available on iOS and Android.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAppStoreButton(
                        'App Store',
                        Icons.apple,
                        () {
                          // Launch App Store link
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildAppStoreButton(
                        'Google Play',
                        Icons.android,
                        () {
                          // Launch Google Play link
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppStoreButton(String store, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Download on',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  store,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24, 
        vertical: 40
      ),
      color: Colors.grey[900],
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildFooterBranding(),
                ),
                Expanded(
                  child: _buildFooterLinks('Product', ['Features', 'Pricing', 'FAQ', 'Download']),
                ),
                Expanded(
                  child: _buildFooterLinks('Company', ['About Us', 'Blog', 'Careers', 'Contact']),
                ),
                Expanded(
                  child: _buildFooterLinks('Legal', ['Terms', 'Privacy', 'Security', 'Cookies']),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFooterBranding(),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFooterLinks('Product', ['Features', 'Pricing', 'FAQ', 'Download']),
                    ),
                    Expanded(
                      child: _buildFooterLinks('Company', ['About Us', 'Blog', 'Careers', 'Contact']),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFooterLinks('Legal', ['Terms', 'Privacy', 'Security', 'Cookies']),
                    ),
                    Expanded(
                      child: Container(), // Empty space for alignment
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildFooterBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: GuvvyTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Guvvy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Empowering citizens through transparency and civic engagement.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook),
            _buildSocialIcon(Icons.south_america),
            _buildSocialIcon(Icons.camera_alt),
            _buildSocialIcon(Icons.public),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            link,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        )).toList(),
      ],
    );
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningUp = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSigningUp = false;
        });
        
        // Show success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thank You!'),
            content: const Text('We\'ve added you to our waitlist. You\'ll be among the first to know when Guvvy launches in your area.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        // Clear form
        _emailController.clear();
      });
    }
  }
}