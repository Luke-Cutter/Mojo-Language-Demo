# =====================================================
# Mojo Demonstration by Luke Cutter and Alexander Mayo
# =====================================================

# This program showcases Mojo's key features:

# Strong typing for performance optimization
# Parallelization capabilities
# Memory-efficient data structures
# High-performance numerical computing
# Similar syntax to Python but with performance benefits

# Import Mojo's built-in modules
# algorithm provides parallel processing utilities
# random provides high-performance random number generation
from algorithm import parallelize  # Mojo's parallelization framework
from random import random_float64, seed  # Efficient random number generators


# This function demonstrates Mojo's strong typing (Int, Float64),
# Explicit return type annotations (-> List[Float64]), & Efficient list operations
fn create_optimized_list(size: Int) -> List[Float64]:
    """Create a list of random values with Mojo's optimized random generator."""
    # Initializes the random number generator
    seed()
    
    # Creates an empty list with Float64 type to store results
    # Mojo enforces strict typing for better performance
    var result = List[Float64]()
    
    # Fills the list with random values
    # Unlike Python, this is compiled to efficient machine code
    for i in range(size):
        result.append(random_float64())
    
    return result


# This function demonstrates Mojo's parallel processing capabilities, The @parameter decorator for inline functions,
# Memory pre-allocation for performance, & Thread-safe list operations
fn transform_list(input_list: List[Float64]) -> List[Float64]:
    """Square each value in the list using Mojo's parallelization."""
    # Pre-allocates the result list for better performance. This avoids reallocations during parallel operations.
    var result = List[Float64]()
    for i in range(len(input_list)):
        result.append(0.0)  # Initialize with zeros
    
    # Defines a nested function that will process a chunk of data in parallel
    # @parameter indicates this function will be used with the parallelize framework
    @parameter
    fn process_chunk(chunk_idx: Int):
        # Calculates the start and end indices for this chunk
        # This divides the work evenly across 4 threads
        var chunk_size = len(input_list) // 4
        var start = chunk_idx * chunk_size
        var end = start + chunk_size
        
        # Handles the remainder in the last chunk
        if chunk_idx == 3:  # Last chunk gets remainder
            end = len(input_list)
        
        # Processes this chunk (square each value)
        # Each thread works on its own portion of the data
        for i in range(start, end):
            result[i] = input_list[i] * input_list[i]
    
    # Executes the process_chunk function in parallel across 4 threads
    # This is a key Mojo feature for high-performance computing
    parallelize[process_chunk](4)
    
    return result


# This function demonstrates Tuple return types for multiple return values, efficient numerical computations,
# Manual optimization of statistical algorithms, & Handles edge cases explicitly
fn calculate_stats(data: List[Float64]) -> Tuple[Float64, Float64, Float64, Float64]:
    """Calculate mean, std dev, min, and max for a list of values."""
    # Handles the empty list case
    if len(data) == 0:
        return (0.0, 0.0, 0.0, 0.0)
    
    # Initializes variables for calculation
    var sum = 0.0
    var min_val = data[0]
    var max_val = data[0]
    
    # Single-pass algorithm to calculate sum, min, and max which is more efficient than multiple passes
    for i in range(len(data)):
        var val = data[i]
        sum += val
        if val < min_val:
            min_val = val
        if val > max_val:
            max_val = val
    
    # Calculates the mean
    var mean = sum / Float64(len(data))
    
    # Calculates variance and standard deviation
    # Second pass through the data to compute squared differences
    var variance_sum = 0.0
    for i in range(len(data)):
        var diff = data[i] - mean
        variance_sum += diff * diff
    
    var variance = variance_sum / Float64(len(data))
    var std_dev = variance ** 0.5  # Square root for standard deviation
    
    # Returns multiple values as a tuple
    # Mojo supports multi-value returns via tuples
    return (mean, std_dev, min_val, max_val)

# This function shows applying multiple transformations in parallel, Complex nested data structures (List of Lists),
# implementing mathematical approximations efficiently, & reusing parallel processing patterns
fn apply_transformations(data: List[Float64]) -> List[List[Float64]]:
    """Apply multiple transformations in parallel and return results."""
    # Creates lists for each transformation result
    # Pre-allocates for better performance
    var square_results = List[Float64]()
    var sqrt_results = List[Float64]()
    var log_approx_results = List[Float64]()
    var sigmoid_approx_results = List[Float64]()
    
    # Initializes all result lists with zeros
    # This makes them thread-safe for parallel access
    for i in range(len(data)):
        square_results.append(0.0)
        sqrt_results.append(0.0)
        log_approx_results.append(0.0)
        sigmoid_approx_results.append(0.0)
    
    # Defines parallel processing function
    # Similar to transform_list but applying multiple transformations
    @parameter
    fn process_chunk(chunk_idx: Int):
        # Calculates the chunk boundaries as before
        var chunk_size = len(data) // 4
        var start = chunk_idx * chunk_size
        var end = start + chunk_size
        if chunk_idx == 3:  # Last chunk gets the remainder
            end = len(data)
        
        # Processes this chunk with multiple transformations
        # Each thread handles multiple operations on its chunk
        for i in range(start, end):
            var x = data[i]
            
            # Square: f(x) = x²
            square_results[i] = x * x
            
            # Approximate square root: f(x) = x^0.5
            sqrt_results[i] = x ** 0.5
            
            # Approximate log: Using piece-wise approximation
            # This demonstrates implementing custom mathematical functions
            # (this is just for demonstration - not accurate)
            if x > 0:
                log_approx_results[i] = 2.0 * (x - 1) / (x + 1)
            else:
                log_approx_results[i] = 0.0
            
            # Approximate sigmoid: Using piece-wise approximation
            # Shows conditional logic in parallel execution
            # (this is just for demonstration - not accurate)
            if x < -3.0:
                sigmoid_approx_results[i] = 0.0
            elif x > 3.0:
                sigmoid_approx_results[i] = 1.0
            else:
                sigmoid_approx_results[i] = 0.5 + x * (0.15 - 0.005 * x * x)
    
    # Process all transformations in parallel using 4 threads
    parallelize[process_chunk](4)
    
    # Collect all results into a list of lists
    # Shows Mojo's ability to handle nested data structures
    var results = List[List[Float64]]()
    results.append(square_results)
    results.append(sqrt_results)
    results.append(log_approx_results)
    results.append(sigmoid_approx_results)
    
    return results


# This function demonstrates Program organization with a main function,
# Timing operations for performance measurement, Accessing and using tuple elements,
# & Structured output for data analysis
fn main():
    """Main function to demonstrate Mojo capabilities."""
    print("Mojo Performance Demo")
    print("====================")
    
    # Create data with Mojo's optimized random generator
    var data_size = 100000  # Large data size to demonstrate performance
    print("\nGenerating", data_size, "random samples with Mojo...")
    var mojo_data = create_optimized_list(data_size)
    
    # Displays a sample of the data
    print("Data generated! First 5 samples:")
    for i in range(min(5, len(mojo_data))):
        print("  ", mojo_data[i])
    
    # Calculates the statistics using our custom function
    print("\nCalculating statistics...")
    var stats = calculate_stats(mojo_data)
    
    # Accesses tuple elements using indexing
    # Mojo tuples are accessed with standard indexing syntax
    var mean = stats[0]
    var std_dev = stats[1]
    var min_val = stats[2]
    var max_val = stats[3]
    
    # Displays the statistics
    print("Data Statistics:")
    print("  Mean:", mean)
    print("  Standard Deviation:", std_dev)
    print("  Min:", min_val)
    print("  Max:", max_val)
    
    # Performs a simple parallel transformation
    print("\nApplying parallel squaring transformation...")
    var transformed_data = transform_list(mojo_data)
    
    # Displays a sample of transformed data
    print("Transformed data! First 5 samples:")
    for i in range(min(5, len(transformed_data))):
        print("  ", transformed_data[i])
    
    # Sets up for multiple transformations
    # Using a typed List for transformation names
    print("\nApplying multiple parallel transformations...")
    var transformation_names = List[String]()
    transformation_names.append("Square")
    transformation_names.append("Square Root")
    transformation_names.append("Log Approximation")
    transformation_names.append("Sigmoid Approximation")
    
    # Applys all transformations in parallel
    var all_transformations = apply_transformations(mojo_data)
    
    # Displays samples of all transformation results
    print("Results of multiple transformations:")
    for i in range(len(transformation_names)):
        var transform = all_transformations[i]
        print("  ", transformation_names[i], ":", end=" ")
        for j in range(min(3, len(transform))):
            print(transform[j], end=" ")
        print("...")
    
    # Calculates and display statistics for each transformation
    print("\nStatistics for each transformation:")
    for i in range(len(transformation_names)):
        var transform = all_transformations[i]
        var transform_stats = calculate_stats(transform)
        
        # Accesses tuple elements for each transformation's statistics
        var t_mean = transform_stats[0]
        var t_std = transform_stats[1]
        var t_min = transform_stats[2]
        var t_max = transform_stats[3]
        
        # Displays statistics for this transformation
        print("  ", transformation_names[i], ":")
        print("    Mean:", t_mean)
        print("    Std Dev:", t_std)
        print("    Range:", t_min, "to", t_max)
    
    print("\nDemo completed successfully!")

# Program entry point
# This separates the function definition from execution
# Similar to Python's if __name__ == "__main__" pattern
fn run():
    main()
