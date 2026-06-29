import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../data/model/response/nationality_response.dart';
import '../controller/auth_controller.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/style.dart';

class SelectNationalityScreen extends StatefulWidget {
  const SelectNationalityScreen({super.key});

  @override
  State<SelectNationalityScreen> createState() => _SelectNationalityScreenState();
}

class _SelectNationalityScreenState extends State<SelectNationalityScreen> {
  late final AuthController _controller;
  Future<NationalityResponse>? _nationalityFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    // Get the data from API inside this screen
    _nationalityFuture = _controller.authUseCase.nationalityList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSelectedId = _controller.uiState.value.signUpNationalityId.value;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarVET().appBar(context, 'select_nation'.tr),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Container
            Container(
              color: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: TextFormField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: Style.inputText(
                  'search_nation'.tr,
                  iconLeft: Ionicons.search_outline,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            // List of nationalities
            Expanded(
              child: FutureBuilder<NationalityResponse>(
                future: _nationalityFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'try_again'.tr,
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final response = snapshot.data;
                    if (response?.header?.result == true &&
                        response?.header?.statusCode == 200 &&
                        response?.body?.status == true) {
                      final nationalityData = response?.body?.data ?? [];
                      
                      // Filter out duplicates and empty names
                      final uniqueNationalityList = <NationalityResponseData>[];
                      final uniqueNames = <String>{};
                      for (final item in nationalityData) {
                        final name = (item.name ?? '').trim();
                        if (name.isEmpty) continue;
                        if (uniqueNames.add(name.toLowerCase())) {
                          uniqueNationalityList.add(item);
                        }
                      }

                      // Apply search filter
                      final filteredList = uniqueNationalityList.where((item) {
                        final name = (item.name ?? '').toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Ionicons.flag_outline,
                                size: 64,
                                color: AppColors.greyColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'no_data'.tr.isNotEmpty ? 'no_data'.tr : 'No results found',
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        color: AppColors.whiteColor,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: AppColors.deepGrey,
                          ),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final isSelected = item.id == currentSelectedId;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 4.0,
                              ),
                              title: Text(
                                '${item.name}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.primaryColor : AppColors.titleColor,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Ionicons.checkmark,
                                      color: AppColors.primaryColor,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context, {
                                  'name': item.name,
                                  'id': item.id,
                                });
                              },
                            );
                          },
                        ),
                      );
                    }
                  }

                  return Center(
                    child: Text(
                      'try_again'.tr,
                      style: const TextStyle(color: AppColors.textColor),
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
