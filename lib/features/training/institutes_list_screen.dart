import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import './services/training_service.dart';
import '../../../core/api/models/driving_institute.dart';

class InstitutesListScreen extends StatefulWidget {
  const InstitutesListScreen({super.key});

  @override
  State<InstitutesListScreen> createState() => _InstitutesListScreenState();
}

class _InstitutesListScreenState extends State<InstitutesListScreen> {
  final TrainingService _trainingService = TrainingService();
  bool _loading = true;
  List<DrivingInstitute> _institutes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstitutes();
  }

  Future<void> _loadInstitutes() async {
    setState(() => _loading = true);
    final list = await _trainingService.getAllInstitutes();
    setState(() {
      _institutes = list;
      _loading = false;
    });
  }

  List<DrivingInstitute> get _filteredInstitutes {
    if (_searchQuery.isEmpty) return _institutes;
    return _institutes.where((inst) {
      final name = inst.name.toLowerCase();
      final city = inst.city.toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || 
             city.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _enroll(int instituteId, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enrollment'),
        content: Text('Do you want to enroll in $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enroll')),
        ],
      ),
    );

    if (confirm == true) {
      final personId = UserSession.instance.personId;
      final userId = UserSession.instance.userId;
      if (personId == null || userId == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await _trainingService.enroll(personId, instituteId, userId);
      
      Navigator.pop(context); // Close loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully enrolled!')),
        );
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrollment failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Institute'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name or city...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(onPressed: () => setState(() => _searchQuery = ''), icon: const Icon(Icons.clear_rounded))
                  : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInstitutes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredInstitutes.length,
                        itemBuilder: (context, index) {
                          final inst = _filteredInstitutes[index];
                          return _buildInstituteCard(inst);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstituteCard(DrivingInstitute inst) {
    const bool isActive = true; // All from API for now are active
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isActive ? () => _enroll(inst.id, inst.name) : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inst.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${inst.city}, ${inst.region}',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag(Icons.phone_outlined, inst.phone),
                  const SizedBox(width: 12),
                  _buildTag(Icons.people_outline_rounded, 'Cap: ${inst.capacity}'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActive ? () => _enroll(inst.id, inst.name) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.primary : AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Select & Enroll'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'No institutes found.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
