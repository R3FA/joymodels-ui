import 'package:flutter/material.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar.dart';
import 'package:provider/provider.dart';
import '../view_model/home_page_view_model.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<HomePageScreenViewModel>(context, listen: false).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageScreenViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: const NavigationBarWidget(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 32, 14, 0),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TODO: Pronadji nacin kako da se ucita avatar korisnika
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.person, size: 42, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Hi, ', style: theme.textTheme.titleLarge),
                          Text(
                            viewModel.loggedUsername,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text('Welcome back!', style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 28),

            // CATEGORIES GRID
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.55,
                children: viewModel.categories
                    .map(
                      (cat) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'], size: 30),
                          const SizedBox(height: 5),
                          Text(
                            cat['label'],
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // TOP ARTISTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Artists', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.topArtists.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final artist = viewModel.topArtists[i];
                  return Container(
                    width: 95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(artist.imageUrl),
                          radius: 28,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          artist.name,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${artist.count} models",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // TOP RATED MODELS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Rated Models', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('View All >'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 115,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.topRatedModels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final model = viewModel.topRatedModels[i];
                  return Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            model.imageUrl,
                            width: 65,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0, right: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name,
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                if (model.price.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      model.price,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
