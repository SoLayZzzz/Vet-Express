import 'package:express_vet/feature/location-dashboard/presentation/screen/location_detail_screen.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationSearchScreen extends StatefulWidget {
  final List<Data> allBranches;

  const LocationSearchScreen({super.key, required this.allBranches});

  @override
  State<LocationSearchScreen> createState() => _LocationState();
}

class _LocationState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Data> _filteredBranches;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBranches);
    _filteredBranches = widget.allBranches;
  }

  /// Filter branches based on search query
  void _filterBranches() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _hasSearched = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredBranches = widget.allBranches;
      } else {
        _filteredBranches =
            widget.allBranches.where((branch) {
              final branchName = branch.name?.toLowerCase() ?? '';
              final branchNameKh = branch.nameKh?.toLowerCase() ?? '';
              final telephone = branch.telephone?.toLowerCase() ?? '';
              return branchName.contains(query) ||
                  branchNameKh.contains(query) ||
                  telephone.contains(query);
            }).toList();
      }
    });
  }

  /// Handle branch selection - Navigate to detail screen
  void _onBranchSelected(Data branch) {
    Get.to(
      () => LocationDetailScreen(
        lats: branch.lats.toString(),
        longs: branch.longs.toString(),
        type: branch.type!,
        nameKh: branch.nameKh.toString(),
        name: branch.name.toString(),
        telephone: branch.telephone.toString(),
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'vet_location'.tr),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) => _filterBranches(),
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'search_virak'.tr,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    prefixIconColor: AppColors.borderColor,
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _hasSearched && _filteredBranches.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: _filteredBranches.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildBranchItem(_filteredBranches[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build branch item
  Widget _buildBranchItem(Data branch) {
    return InkWell(
      onTap: () => _onBranchSelected(branch),
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Image.asset(
                  branch.type == 1
                      ? "assets/images/ic_map_branch.png"
                      : "assets/images/ic_map_agency.png",
                  width: 34,
                  height: 34,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Text(branch.name.toString(), maxLines: 2),
                ),
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Text(
                    branch.telephone.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'data_not_found'.tr,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
