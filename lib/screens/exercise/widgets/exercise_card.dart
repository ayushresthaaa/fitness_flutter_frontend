import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  //stateless means it doesn't manage its own state, it just displays data passed to it
  final Exercise
  exercise; //this value doesnt change within the card, it is passed in when the card is created; also this is the data model for the exercise, it contains all the info about the exercise that we want to display on the card
  final VoidCallback
  onTap; //this is a function that gets called when the card is tapped; it is passed in from the parent widget, and it allows the card to notify the parent when it is tapped, so the parent can navigate to the exercise details screen or do something else

  const ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    //build context means child can access parents widget data and stuff at the time of building the widget tree;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              SizedBox(width: 16),
              Expanded(child: _buildContent()),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text('🏋️', style: TextStyle(fontSize: 24))),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          '${_capitalize(exercise.category)} • ${_capitalize(exercise.level)}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
  }
}
