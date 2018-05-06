# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Workout.delete_all
Exercise.destroy_all
Routine.destroy_all

workouts = Workout.create([{name: 'Chest Workout'}, {name: 'Legs Workout'}])
exercises = Exercise.create([{
  name: 'Inclined Pushups',
  picture: 'http://via.placeholder.com/150x150',
  video: 'https://www.youtube.com/watch?v=Me9bHFAxnCs',
  purpose: 'Nice Inclined Pushups'
}, {
  name: 'Wide Arm Pushups',
  picture: 'http://via.placeholder.com/200x200',
  video: 'https://www.youtube.com/watch?v=rr6eFNNDQdU',
  purpose: 'Nice Wide Arm Pushups'
}, {
  name: 'Jumping Jacks',
  picture: 'http://via.placeholder.com/100x100',
  video: 'https://www.youtube.com/watch?v=iSSAk4XCsRA',
  purpose: 'Nice Jumping Jacks'
}, {
  name: 'High Stepping',
  picture: 'http://via.placeholder.com/250x250',
  video: 'https://www.youtube.com/watch?v=QPfOZ0e30xg',
  purpose: 'Nice High Stepping'
}, {
  name: 'Squats',
  picture: 'http://via.placeholder.com/300x300',
  video: 'https://www.youtube.com/watch?v=aclHkVaku9U',
  purpose: 'Nice exeSquatsrcise'
}])

exercises.first(3).each.with_index do |exercise, index|
  routine = Routine.new({ set: 2, repetition: 10, preparation: 5, start: 5, hold: 2, release: 5, pause: 5, position: index + 1 })
  routine.workout = workouts.first
  routine.exercise = exercise
  routine.save
end

exercises.last(3).each.with_index do |exercise, index|
  routine = Routine.new({ set: 2, repetition: 10, preparation: 5, start: 5, hold: 2, release: 5, pause: 5, position: index + 1 })
  routine.workout = workouts.last
  routine.exercise = exercise
  routine.save
end
