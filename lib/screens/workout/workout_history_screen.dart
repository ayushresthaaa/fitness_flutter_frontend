// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/exercise/workout_provider.dart';
// import '../../models/exercise/workout_model.dart';
// import '../exercise/workout_detail_screen.dart';

// class WorkoutHistoryScreen extends StatefulWidget {
//   static const routeName = '/workout-history';

//   const WorkoutHistoryScreen({super.key});

//   @override
//   State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
// }

// class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<WorkoutProvider>().fetchWorkouts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<WorkoutProvider>();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Workout History',
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF212121),
//           ),
//         ),
//       ),
//       body: _buildBody(provider),
//     );
//   }

//   Widget _buildBody(WorkoutProvider provider) {
//     if (provider.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
//       );
//     }

//     if (provider.workouts.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.fitness_center, size: 48, color: Color(0xFF9E9E9E)),
//             SizedBox(height: 12),
//             Text(
//               'No workouts yet',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF9E9E9E),
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Start a workout to see it here',
//               style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: provider.workouts.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, index) {
//         final workout = provider.workouts[index];
//         return _WorkoutCard(workout: workout);
//       },
//     );
//   }
// }

// class _WorkoutCard extends StatelessWidget {
//   final Workout workout;

//   const _WorkoutCard({required this.workout});

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
//   }

//   String _formatDuration(DateTime start, DateTime? end) {
//     if (end == null) return 'In progress';
//     final diff = end.difference(start).inMinutes;
//     if (diff < 60) return '$diff mins';
//     final h = diff ~/ 60;
//     final m = diff % 60;
//     return m == 0 ? '${h}h' : '${h}h ${m}m';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => WorkoutDetailScreen(workout: workout),
//         ),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.fitness_center,
//                 color: Color(0xFF1E88E5),
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     workout.title ?? 'My Workout',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF212121),
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     '${workout.exercises.length} exercises · ${_formatDuration(workout.startTime, workout.endTime)}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF9E9E9E),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatDate(workout.startTime),
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF9E9E9E),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 22),
//           ],
//         ),
//       ),
//     );
//   }
// }
