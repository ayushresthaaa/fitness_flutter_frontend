import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise/exercise_provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/muscle_filter_chips.dart';

class ExerciseListScreen extends StatefulWidget {
  static const routeName = '/exercises';

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String? _selectedMuscle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExerciseProvider>();
      provider.fetchExercises();
      provider.fetchMuscles();
    });
  }

  void _onMuscleSelected(String? muscle) {
    setState(() => _selectedMuscle = muscle);
    context.read<ExerciseProvider>().fetchExercises(muscleGroup: muscle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          MuscleFilterChips(
            selectedMuscle: _selectedMuscle,
            onMuscleSelected: _onMuscleSelected,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Exercises'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // TODO: Add search
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        // Show error
        if (provider.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showError(provider.error!);
            provider.clearError();
          });
        }

        // Loading
        if (provider.isLoading && provider.exercises.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // Empty
        if (provider.exercises.isEmpty) {
          return Center(
            child: Text(
              'No exercises found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // List
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: provider.exercises.length,
          itemBuilder: (context, index) {
            return ExerciseCard(
              exercise: provider.exercises[index],
              onTap: () => _handleExerciseTap(provider.exercises[index]),
            );
          },
        );
      },
    );
  }

  void _handleExerciseTap(exercise) {
    // TODO: Navigate to exercise detail or add to workout
    print('Tapped: ${exercise.name}');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
