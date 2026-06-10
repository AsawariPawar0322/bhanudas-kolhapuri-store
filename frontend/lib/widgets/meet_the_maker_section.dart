import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MeetTheMakerSection extends StatelessWidget {
  const MeetTheMakerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Meet The Maker',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View Story', style: TextStyle(color: AppTheme.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMakerCard(
                  context,
                  'Ramesh Kumar',
                  'Kolhapur, India',
                  '3rd Generation Cobbler',
                  'https://images.unsplash.com/photo-1533867617858-e7b97e060509?q=80&w=600',
                ),
                const SizedBox(width: 16),
                _buildMakerCard(
                  context,
                  'Anjali Devi',
                  'Varanasi, India',
                  'Master Weaver',
                  'https://images.unsplash.com/photo-1508962914676-134849a727f0?q=80&w=600',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMakerCard(BuildContext context, String name, String location, String title, String imageUrl) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: AppTheme.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
