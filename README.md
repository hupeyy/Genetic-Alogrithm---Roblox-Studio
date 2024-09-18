# Autonomous Vehicle AI Project

This project implements a simple genetic algorithm to train virtual cars in Roblox to complete a track. The cars use raycasting to detect their surroundings and adjust their orientation to navigate the track. Over multiple generations, the cars evolve to improve their performance.

## Features
- **Raycasting for Environment Detection**: Each car uses multiple rays to sense the environment and make decisions based on the inputs.
- **Neural Network with Genetic Algorithm**: Cars are controlled by a neural network that is trained using a genetic algorithm. The genes, which are weights for the neural network, evolve over time through crossover and mutation.
- **Fitness Evaluation**: Each car’s fitness is determined based on its distance from the finish line. The closer the car is to the finish, the higher its fitness score.
- **Collision Group**: The cars are grouped in a collision group to prevent them from colliding with each other during the simulation.

## Project Structure

- `getInputs(vehicle: Model)`: Performs raycasting to detect obstacles around the vehicle and returns normalized distances.
- `getWeights(inputs, genes)`: Multiplies input values from raycasting with the gene weights to calculate an output.
- `getAction(weights)`: Determines the car's steering based on the weights.
- `simulateVehicle(genes)`: Clones a car from the server storage and simulates its movement based on its neural network (controlled by genes).
- `calculateFitness(dummy: Model)`: Calculates the car’s fitness based on its distance from the finish line.
- `crossover(p1, p2)`: Combines genes from two parent cars to create offspring.
- `mutate(gene)`: Mutates a gene by randomly changing one of its values.
- `evolve()`: Main loop that evolves the population over multiple generations.

## Usage

1. **Place the Car Model in ServerStorage**:
   - Ensure that a model named `Car` is stored in `ServerStorage`. This model should contain a `VehicleSeat` for steering and a part named `Chassis` for raycasting and position detection.

2. **Track Setup**:
   - Add a `Track` part in the `workspace` that the cars can navigate.
   - Add a `Start` and `Finish` part to indicate the beginning and end of the track.

3. **Simulation**:
   - Run the game in Roblox Studio, and the cars will begin evolving over multiple generations.
   - Each generation improves upon the last until the cars can successfully navigate the track.

## Genetic Algorithm Details

- **Population Size**: 24 cars per generation.
- **Mutation Rate**: 10% chance of mutating a gene after crossover.
- **Fitness Evaluation**: Based on the distance of each car from the finish line after a set time period.

## How It Works

1. **Initialization**: The cars are randomly initialized with different genes (weights).
2. **Raycasting**: Each car uses raycasting to sense its environment and make decisions on how to steer.
3. **Fitness Calculation**: The fitness of each car is determined based on how close it gets to the finish line.
4. **Evolution**: The best-performing cars (based on fitness) are selected for reproduction, and their genes are combined and mutated to create the next generation.

## Future Improvements

- Add more sophisticated fitness functions, such as penalizing collisions or rewarding faster completions.
- Implement more advanced neural network architectures with hidden layers for better decision-making.
- Tune hyperparameters such as mutation rate and population size for better performance.

## Requirements

- **Roblox Studio**
- **Roblox PhysicsService**: The project uses `PhysicsService` for handling collision groups.
- **Roblox ServerStorage**: The car models should be placed in `ServerStorage`.

## License

This project is open-source. Feel free to modify and distribute as needed.

